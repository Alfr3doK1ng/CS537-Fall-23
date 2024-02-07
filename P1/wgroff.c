#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void process_line(char *line, FILE *outfile) {
    if (line[0] == '#')
        return;

    if (strncmp(line, ".SH ", 4) == 0) {
        char upper_section[1024];
        strncpy(upper_section, line + 4, 1024);
        for (int i = 0; upper_section[i]; i++) {
            upper_section[i] = toupper(upper_section[i]);
        }
        upper_section[strlen(upper_section) - 1] = '\0';
        fprintf(outfile, "\n\033[1m%s\033[0m\n", upper_section);
        return;
    }

    fprintf(outfile, "       ");
    char *p = line;
    while (*p) {
        if (strncmp(p, "/fB", 3) == 0) {
            fprintf(outfile, "\033[1m");
            p += 3;
        } else if (strncmp(p, "/fI", 3) == 0) {
            fprintf(outfile, "\033[3m");
            p += 3;
        } else if (strncmp(p, "/fU", 3) == 0) {
            fprintf(outfile, "\033[4m");
            p += 3;
        } else if (strncmp(p, "/fP", 3) == 0) {
            fprintf(outfile, "\033[0m");
            p += 3;
        } else if (strncmp(p, "//", 2) == 0) {
            fprintf(outfile, "/");
            p += 2;
        } else {
            fputc(*p, outfile);
            p++;
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Improper number of arguments\nUsage: ./wgroff <file>\n");
        return 0;
    }
    FILE *infile = fopen(argv[1], "r");
    if (infile == NULL) {
        printf("File doesn't exist\n");
        return 0;
    }

    char title[64], section[4], date[12];
    char output_filename[128];
    if (fscanf(infile, ".TH %s %s %s\n", title, section, date) != 3) {
        printf("Improper formatting on line 1\n");
        fclose(infile);
        return 0;
    }
    char *endptr;
    long section_num = strtol(section, &endptr, 10);
    if (*endptr != '\0' || section_num < 1 || section_num > 9) {
        printf("Improper formatting on line 1\n");
        fclose(infile);
        return 0;
    }
    int year, month, day;

    if (sscanf(date, "%4d-%2d-%2d", &year, &month, &day) != 3) {
        printf("Improper formatting on line 1\n");
        fclose(infile);
        return 0;
    }

    snprintf(output_filename, sizeof(output_filename), "%s.%s", title, section);
    FILE *outfile = fopen(output_filename, "w");
    if (outfile == NULL) {
        printf("Failed to create output file\n");
        fclose(infile);
        return 0;
    }

    int space_padding =
        80 - 2 * ((int)strlen(title) + (int)strlen(section) + 2);
    fprintf(outfile, "%s(%s)%*s%s(%s)\n", title, section, space_padding, "",
            title, section);

    int lineno = 1;
    char line[1025];
    while (fgets(line, sizeof(line), infile)) {
        lineno++;
        process_line(line, outfile);
    }

    int padding = (80 - (int)strlen(date)) / 2;
    fprintf(outfile, "%*s%s%*s\n", padding, "", date, padding, "");

    fclose(infile);
    fclose(outfile);
    return 0;
}
