#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(void)
{
  char buf[64];
  
  if(getlastcat(buf) < 0) {
    printf(1, "getlastcat failed\n");
    return -1;
  }
  
  printf(1, "XV6_TEST_OUTPUT Last catted filename: %s\n", buf);
  return 0;
}
