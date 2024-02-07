#include "types.h"
#include "user.h"
#include "param.h"

int
main(int argc, char *argv[])
{
  int pid;
  int x = 0;

  pid = fork();
  if(pid < 0) {
    printf(2, "Error in fork\n");
    exit();
  }

  if(pid == 0) {
    printf(1, "Child process, setting nice value to 10\n");
    nice(10); // Assuming nice() works as expected, this should lower the priority of this process
    for(;;) {
      x++;  // Dummy computation
      if(x % 10000000 == 0) {
        printf(1, "Child process is running\n");
      }
    }
  } else {
    printf(1, "Parent process, keeping default nice value\n");
    for(;;) {
      x++;  // Dummy computation
      if(x % 10000000 == 0) {
        printf(1, "Parent process is running\n");
      }
    }
  }

  // Normally, we would never reach this point in the code.
  wait(); // Wait for child process to join
  exit();
}
