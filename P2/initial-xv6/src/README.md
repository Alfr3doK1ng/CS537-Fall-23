Files modified:
syscall.h added a new syscall with number 22
syscall.c added a new syscall with corresponding info
sysproc.c added a sys_getlastcat function that implements the syscall
exec.c added the main logic of getlastcat
sysfile.c modified the sys_open to check if the file has been successfully opened or not
getlastcat.c created the user program of getlastcat
usys.S user.h Makefile added corresponding settings for getlastcat to run

name: Hanzhe Long
wisc id: 908 494 1005
email: hlong25@wisc.edu
status: all done