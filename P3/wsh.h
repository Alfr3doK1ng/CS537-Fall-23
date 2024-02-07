#ifndef WSH_H
#define WSH_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>
#include <errno.h>

#define MAX_INPUT_SIZE 1024
#define MAX_ARG_SIZE 100
#define MAX_BACKGROUND_JOBS 100

typedef struct {
    pid_t pid;
    char command[MAX_INPUT_SIZE];
} BackgroundJob;

#endif
