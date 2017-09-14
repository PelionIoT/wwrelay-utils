TARGET = scanner
CC?=gcc
CFLAGS=-I.
HEADERS = "input-event-codes.h"

#this keeps make from doing something strange with files that happen to be named default,all, clean (if we had them)
.PHONY: default all clean

default: $(TARGET)
all: default

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(TGT_CFLAGS) -c $< -o $@

scanner: scanner.o 
	$(CC) -o scanner scanner.o

clean:
	rm -f *.o $(TARGET)

