#include "types.h"
#include "stat.h"
#include "user.h"
#include "psched.h"

int getnice(int pid) {
    struct pschedinfo st;
    
    if (getschedstate(&st) == 0) {
        for (int i = 0; i < NPROC; i++) {
            if (st.inuse[i] && st.pid[i] == pid) {
                return st.nice[i];
            }
        }
    } else {
        return -1;
    }
    return -1;
}

int main(int argc, char *argv[])
{
    if (nice(10) != 0) {
        printf(1, "XV6_SCHEDULER\t FAILED 0\n");
        exit();
    }

    if (getnice(getpid()) != 10) {
        printf(1, "XV6_SCHEDULER\t FAILED 1\n");
        exit();
    }
 
    if (nice(0) != 10) {
        printf(1, "XV6_SCHEDULER\t FAILED 2\n");
        exit();
    }

    if (getnice(getpid()) != 0) {
        printf(1, "XV6_SCHEDULER\t FAILED 3\n");
        exit();
    }
    
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
    exit();
}
