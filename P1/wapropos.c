#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int searchFile(char *currPath, char *entryName, char *keyword) {
    FILE *fp = fopen(currPath, "r");
    if (fp == NULL) {
        return 0;
    }
    char line[1024];
    int inName = 0;
    int inDescription = 0;
    char nameOneLiner[256] = "";
    while (fgets(line, sizeof(line), fp)) {
        // printf("Current line is: %s", line);
        // printf("inName: %d inDescription: %d\n", inName, inDescription);
        if (strstr(line, "[1m") != NULL && strstr(line, "[0m\n") != NULL) {
            // printf("gotya!\n");
            if (strstr(line, "NAME") != NULL) {
                inName = 1;
                inDescription = 0;
                continue;
            } else if (strstr(line, "DESCRIPTION") != NULL) {
                inDescription = 1;
                inName = 0;
                continue;
            } else {
                inDescription = 0;
                inName = 0;
                continue;
            }
        }

        if (inName || inDescription) {
            if (inName) {
                char *pos = strstr(line, "- ");
                if (pos != NULL) {
                    strcpy(nameOneLiner, pos + 2);
                    strtok(nameOneLiner, "\n");
                }
            }
            if (strstr(line, keyword) != NULL) {
                // printf("%s", line);
                printf("%s (%c) - %s\n", entryName,
                       currPath[strlen(currPath) - 1], nameOneLiner);
                return 1;
            }
        }
    }
    fclose(fp);
    return 0;
}

void searchWithKeyword(char *keyword) {
    char path[256];
    int found = 0;
    for (int i = 1; i <= 9; i++) {
        snprintf(path, sizeof(path), "./man_pages/man%d", i);
        DIR *dir;
        struct dirent *entry;
        if ((dir = opendir(path)) == NULL) {
            return;
        }

        while ((entry = readdir(dir)) != NULL) {
            if (strcmp(entry->d_name, ".") != 0 &&
                strcmp(entry->d_name, "..") != 0) {
                char currPath[512];
                snprintf(currPath, sizeof(currPath), "%s/%s", path,
                         entry->d_name);
                // printf("Now searching: %s\n", currPath);
                if (searchFile(currPath, strtok(entry->d_name, "."), keyword) ==
                    1) {
                    found = 1;
                }
            }
        }
        closedir(dir);
    }
    if (found == 0) {
        printf("nothing appropriate\n");
    }
}

int main(int argc, char *argv[]) {
    if (argc == 1) {
        printf("wapropos what?\n");
        exit(0);
    } else if (argc == 2) {
        char *keyword = argv[1];
        searchWithKeyword(keyword);
    } else {
        printf("Invalid usage\n");
        exit(1);
    }
    return 0;
}