#include "wsh.h"

BackgroundJob bg_jobs[MAX_BACKGROUND_JOBS];
int bg_job_count = 0;

char ***split_pipeline_commands(char **args) {
    int cmd_count = 1; // Counting commands in the pipeline
    for (int i = 0; args[i]; i++) {
        if (strcmp(args[i], "|") == 0)
            cmd_count++;
    }

    char ***commands = malloc((cmd_count + 1) * sizeof(char **));
    if (!commands) {
        perror("wsh: memory allocation failed");
        exit(1);
    }

    int cmd_idx = 0;
    commands[cmd_idx] = args;
    for (int i = 0; args[i]; i++) {
        if (strcmp(args[i], "|") == 0) {
            args[i] = NULL; // terminate current command
            commands[++cmd_idx] = &args[i + 1];
        }
    }
    commands[cmd_count] = NULL; // end of commands

    return commands;
}

void execute_pipeline(char **args) {
    char ***commands = split_pipeline_commands(args);

    int fd[2];
    int prev_fd = -1; // holds the read-end of the previous pipe
    pid_t child_pid;

    for (int i = 0; commands[i]; i++) {
        if (commands[i + 1]) { // if not the last command, create a pipe
            if (pipe(fd) == -1) {
                perror("wsh: pipe failed");
                exit(1);
            }
        }

        if ((child_pid = fork()) == 0) {
            // Redirect input if it's not the first command
            if (prev_fd != -1) {
                if (dup2(prev_fd, STDIN_FILENO) == -1) {
                    perror("wsh: dup2 failed");
                    exit(1);
                }
                close(prev_fd);
            }

            // Redirect output if it's not the last command
            if (commands[i + 1]) {
                if (dup2(fd[1], STDOUT_FILENO) == -1) {
                    perror("wsh: dup2 failed");
                    exit(1);
                }
                close(fd[1]);
            }

            execvp(commands[i][0], commands[i]);
            perror("wsh");
            exit(1);
        } else {
            if (prev_fd != -1)
                close(prev_fd);
            if (commands[i + 1])
                close(fd[1]);
            prev_fd = fd[0];
        }
    }

    // In parent: wait for all child processes to complete
    while (wait(NULL) > 0)
        ;
    free(commands);
}

void print_args(char **args) {
    int i = 0;
    printf("Arguments:\n");
    while (args[i] != NULL) {
        printf("args[%d]: %s\n", i, args[i]);
        i++;
    }
}

int is_builtin_command(char *cmd) {
    char *builtins[] = {"exit", "cd", "jobs", "fg", "bg"};
    for (int i = 0; i < 5; i++) {
        if (strcmp(cmd, builtins[i]) == 0)
            return 1;
    }
    return 0;
}

char *rebuild_command_from_args(char **args) {
    size_t length = 0;
    for (int i = 0; args[i] != NULL; i++) {
        length += strlen(args[i]) + 1; // +1 for space
    }

    char *command_str = malloc(length);
    if (!command_str) {
        perror("wsh: memory allocation failed");
        exit(1);
    }

    strcpy(command_str, args[0]);
    for (int i = 1; args[i] != NULL; i++) {
        strcat(command_str, " ");
        strcat(command_str, args[i]);
    }

    return command_str;
}

int contains_pipe_symbol(char **args) {
    for (int i = 0; args[i]; i++) {
        if (strcmp(args[i], "|") == 0)
            return 1;
    }
    return 0;
}

void execute_command(char **args) {
    if (is_builtin_command(args[0])) {
        if (strcmp(args[0], "exit") == 0) {
            exit(0);
        } else if (strcmp(args[0], "cd") == 0) {
            if (args[1]) {
                if (chdir(args[1]) != 0) {
                    perror("wsh");
                }
            } else {
                fprintf(stderr, "wsh: cd: missing argument\n");
            }
        } else if (strcmp(args[0], "jobs") == 0) {
            for (int i = 0; i < bg_job_count; i++) {
                int status;
                pid_t result = waitpid(bg_jobs[i].pid, &status, WNOHANG);

                if (result == 0) {
                    // Child still running
                    printf("%d: %s\n", i + 1, bg_jobs[i].command);
                } else if (result == bg_jobs[i].pid) {
                    if (WIFEXITED(status)) {
                        // Child has terminated, remove from list
                        for (int j = i; j < bg_job_count - 1; j++) {
                            bg_jobs[j] = bg_jobs[j + 1];
                        }
                        i--; // Adjust the index to account for the shifted jobs
                        bg_job_count--;
                    } else if (WIFSTOPPED(status)) {
                        // Child has been stopped, keep it in the list
                        printf("%d: %s (stopped)\n", i + 1, bg_jobs[i].command);
                    }
                }
            }
        } else if (strcmp(args[0], "fg") == 0) {
            int job_id =
                (args[1] == NULL) ? bg_job_count - 1 : atoi(args[1]) - 1;

            if (job_id >= bg_job_count || job_id < 0) {
                fprintf(stderr, "wsh: fg: job not found: %d\n", job_id);
                return;
            }

            tcsetpgrp(STDIN_FILENO,
                      bg_jobs[job_id].pid);     // Set foreground process group
            kill(bg_jobs[job_id].pid, SIGCONT); // Continue the process

            int status;
            waitpid(bg_jobs[job_id].pid, &status, WUNTRACED);

            if (WIFSTOPPED(status)) {
                // The process was stopped, so add it back to the list of
                // background jobs. You've already got this logic in your "else"
                // branch below, so consider refactoring for reuse.
                bg_jobs[bg_job_count].pid = bg_jobs[job_id].pid;
                strcpy(bg_jobs[bg_job_count].command, bg_jobs[job_id].command);
                bg_job_count++;
            }

            tcsetpgrp(STDIN_FILENO, getpid()); // Return control to the shell

            // Remove job from bg_jobs array
            for (int j = job_id; j < bg_job_count - 1; j++) {
                bg_jobs[j] = bg_jobs[j + 1];
            }
            bg_job_count--;

        } else if (strcmp(args[0], "bg") == 0) {
            int job_id =
                (args[1] == NULL) ? bg_job_count - 1 : atoi(args[1]) - 1;

            if (job_id >= bg_job_count || job_id < 0) {
                fprintf(stderr, "wsh: bg: job not found: %d\n", job_id);
                return;
            }

            kill(bg_jobs[job_id].pid,
                 SIGCONT); // Continue the process in background
        }
    } else {
        int is_background = 0;
        for (int i = 0; args[i] !=a NULL; i++) {
            if (strcmp(args[i], "&") == 0) {
                args[i] = NULL; // Remove the & from args
                is_background = 1;
                break;
            }
        }

        if (contains_pipe_symbol(args)) {
            execute_pipeline(args);
        } else {
            //... rest of the existing code ...

            pid_t pid = fork();
            if (pid == 0) {
                setpgid(0, 0);
                if (!is_background) {
                    tcsetpgrp(STDIN_FILENO, getpgrp());
                }
                execvp(args[0], args);
                perror("wsh");
                exit(1);
            } else {
                if (is_background) {
                    setpgid(pid, pid);

                    bg_jobs[bg_job_count].pid = pid;

                    char *command_str = rebuild_command_from_args(args);

                    strcpy(bg_jobs[bg_job_count].command, command_str);
                    free(command_str);

                    bg_job_count++;
                } else {
                    tcsetpgrp(STDIN_FILENO, pid);
                    int status;
                    waitpid(pid, &status, WUNTRACED);
                    if (WIFSTOPPED(status)) {
                        // If the process has been stopped, add it to the
                        // background jobs list
                        bg_jobs[bg_job_count].pid = pid;
                        char *command_str = rebuild_command_from_args(args);
                        strcpy(bg_jobs[bg_job_count].command, command_str);
                        free(command_str);
                        bg_job_count++;
                    }
                    tcsetpgrp(STDIN_FILENO, getpgrp());
                }
            }
        }
    }
}

void parse_input(char *input, char **args) {
    char *token = strtok(input, " \n");
    int i = 0;
    while (token != NULL) {
        // Check if the last character of the token is '&'
        if (token[strlen(token) - 1] == '&' && strlen(token) > 1) {
            token[strlen(token) - 1] = '\0'; // Null terminate before '&'
            args[i++] = token; // Add the command/argument before '&'
            args[i++] = "&";   // Add '&' as a separate argument
        } else {
            args[i++] = token;
        }
        token = strtok(NULL, " \n");
    }
    args[i] = NULL;
}

void sigchld_handler(int signo) {
    (void)signo; // suppress unused parameter warning
    while (waitpid(-1, NULL, WNOHANG) > 0)
        ; // Reap dead child processes
}

void sigint_handler(int signo) {
    (void)signo; // suppress unused parameter warning
    // SIGINT (Ctrl-C) will default to terminating foreground processes.
}

void sigtstp_handler(int signo) {
    (void)signo; // suppress unused parameter warning
    // SIGTSTP (Ctrl-Z) will default to stopping foreground processes.
}

void execute_batch_mode(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("wsh: could not open file");
        exit(1);
    }

    char input[MAX_INPUT_SIZE];
    char *args[MAX_ARG_SIZE];

    while (fgets(input, MAX_INPUT_SIZE, file)) {
        parse_input(input, args);
        execute_command(args);
    }

    fclose(file);
    exit(0);
}


int main(int argc, char *argv[]) {
    signal(SIGTTOU, SIG_IGN);
    signal(SIGTTIN, SIG_IGN);

    signal(SIGCHLD, sigchld_handler);
    signal(SIGINT, sigint_handler);
    signal(SIGTSTP, sigtstp_handler);

    char input[MAX_INPUT_SIZE];
    char *args[MAX_ARG_SIZE];

    if (argc == 2) {
        // Batch mode: Execute commands from the file specified in argv[1]
        execute_batch_mode(argv[1]);
    } else if (argc > 2) {
        fprintf(stderr, "wsh: too many arguments\n");
        exit(1);
    }

    while (1) {
        printf("wsh> ");
        fgets(input, MAX_INPUT_SIZE, stdin);

        parse_input(input, args);
        execute_command(args);
    }
    return 0;
}