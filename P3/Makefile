# Compiler and Compiler Flags
CC = gcc
CFLAGS = -Wall -Werror -pedantic -std=gnu18

# Other Variables
LOGIN = hlong
SUBMITPATH = ~cs537-1/handin/hlong/P3

# Targets
.PHONY: all

all: wsh

wsh: wsh.c
	$(CC) $(CFLAGS) -o $@ $<

run: wsh
	./wsh

pack:
	tar -czvf $(LOGIN).tar.gz wsh.h wsh.c Makefile README.md

submit: pack
	cp $(LOGIN).tar.gz $(SUBMITPATH)

# Add your own tests and more targets as needed

