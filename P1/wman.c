#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void search_man_pages(char *section, char *page) {
    char path[256];
    FILE *fp = NULL;

    if (section) {
        snprintf(path, sizeof(path), "./man_pages/man%s/%s.%s", section, page, section);
        fp = fopen(path, "r");
        if (fp == NULL) {
            printf("No manual entry for %s in section %s\n", page, section);
            exit(0);
        }
    } else {
        for (int i = 1; i <= 9; i++) {
            snprintf(path, sizeof(path), "./man_pages/man%d/%s.%d", i, page, i);
            fp = fopen(path, "r");
            if (fp != NULL) {
                break;
            }
        }

        if (fp == NULL) {
            printf("No manual entry for %s\n", page);
            exit(0);
        }
    }

    char buffer[1024];
    while (fgets(buffer, sizeof(buffer), fp)) {
        printf("%s", buffer);
    }

    fclose(fp);
}

int main(int argc, char *argv[]) {
    if (argc == 1) {
        printf("What manual page do you want?\nFor example, try 'wman wman'\n");
        exit(0);
    } else if (argc == 2) {
        search_man_pages(NULL, argv[1]);
    } else if (argc == 3) {
        int section = atoi(argv[1]);
        if (section >= 1 && section <= 9) {
            search_man_pages(argv[1], argv[2]);
        } else {
            printf("invalid section\n");
            exit(1);
        }
    } else {
        printf("Invalid usage\n");
        exit(1);
    }

    return 0;
}
