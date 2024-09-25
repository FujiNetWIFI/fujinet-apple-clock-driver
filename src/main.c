#include <dirent.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern void init_driver();

char *sys_name = "FNCLK.SYSTEM";

void main() {
    bool found_self = false;
    DIR *dir;
    struct dirent *ent;
    
    init_driver();

    dir = opendir(".");
    if (dir) {
        while (ent = readdir(dir)) {
            if (found_self) {
                if (strstr(ent->d_name, ".SYSTEM")) {
                    exec(ent->d_name, NULL);
                }
            } else if (!strcmp(ent->d_name, sys_name)) {
                found_self = true;
            }
        }
        closedir(dir);
    }

}