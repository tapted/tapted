#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    if (argc < 3 || argc > 4) {
        fprintf(stderr, "Usage: %s file_to_replace file_to_link_to [ln_arguments = -s]\n", argv[0]);
        exit(1);
    }
    char* lnargs = "-s";
    if (argc > 3)
        lnargs = argv[3];
    int first = 1;
    int back = 0;
    char* lhs_save, *rhs_save;
    char* lp = strtok_r(argv[1], "/", &lhs_save);
    char* rp = strtok_r(argv[2], "/", &rhs_save);
    while (lp && rp && strcmp(lp, rp) == 0) {
        if (first) {
            first = 0;
            fprintf(stdout, "%s", "( cd '");
        } else {
            putchar('/');
        }
        fprintf(stdout, "%s", lp);
        lp = strtok_r(NULL, "/", &lhs_save);
        rp = strtok_r(NULL, "/", &rhs_save);
    }
    if (!lp || !rp) {
        if (!first)
            fprintf(stdout, "' )\n");
        if (!rp)
            fprintf(stderr, "Refusing to make a cyclic link\n");
        else if (!lp)
            fprintf(stderr, "Refusing to overwrite a parent\n");
        exit(1);
    }
    char *lps = lp;
    while (lp) {
        lps = lp;
        lp = strtok_r(NULL, "/", &lhs_save);
        if (!lp)
            break;
        if (first) {
            first = 0;
            fprintf(stdout, "%s", "( cd '");
        } else {
            putchar('/');
        }
        fprintf(stdout, "%s", lps);
        ++back;
    }
    fprintf(stdout, "%sln %s '", first ? "" : "' && ", lnargs);
    int wasfirst = first;
    first = 1;
    for (;back; --back) {
        fprintf(stdout, "../");
    }
    while (rp) {
        if (first) {
            first = 0;
        } else {
            putchar('/');
        }
        fprintf(stdout, "%s", rp);
        rp = strtok_r(NULL, "/", &rhs_save);
    }
    fprintf(stdout, "' '%s'%s\n", lps, wasfirst ? "" : " )");
    return 0;
}

