#include "types.h"
#include "stat.h"
#include "user.h"
#include "psched.h"

int getpriority(int pid) {
    struct pschedinfo st;
    
    if (getschedstate(&st) == 0) {
        for (int i = 0; i < NPROC; i++) {
            if (st.inuse[i] && st.pid[i] == pid) {
                return st.priority[i];
            }
        }
    } else {
        return -1;
    }
    return -1;
}

int getcputicks(int pid) {
    struct pschedinfo st;
    
    if (getschedstate(&st) == 0) {
        for (int i = 0; i < NPROC; i++) {
            if (st.inuse[i] && st.pid[i] == pid) {
                return st.ticks[i];
            }
        }
    } else {
        return -1;
    }
    return -1;
}

void spin() {
    int i;
    for (i = 0; i < 100000000; i++) {
        if (i % 10000000 == 0) {
            // int priority = getpriority(getpid());
            // int ticks = getcputicks(getpid());
            // printf(1, "cpu_ticks is %d\n", ticks); 
            // printf(1, "priority is %d\n", priority); 
        }
        asm("nop");
    }
}

int
main(int argc, char *argv[])
{
    int pid = getpid();
    if (getpriority(pid) != 0) {
        printf(1, "initial priority was non-zero\n");
        printf(1, "XV6_SCHEDULER\t FAILED\n");
        exit();
    }

    spin();
    printf(1, "ticks after spin is %d\n", getcputicks(pid));
    printf(1, "priority after spin is %d\n", getpriority(pid));
    printf(1, "uptime before sleep is %d\n", uptime());
    sleep(120);
    printf(1, "ticks after sleep is %d\n", getcputicks(pid));
    printf(1, "priority after sleep is %d\n", getpriority(pid));
    printf(1, "uptime after sleep is %d\n", uptime());



    int priority;
    if ((priority = getpriority(pid)) == 0) {
        printf(1, "priority was %d\n", priority);
        printf(1, "XV6_SCHEDULER\t FAILED\n");
        exit();
    }

    printf(1, "priority of %d is %d", pid, priority);
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
    exit();
}
