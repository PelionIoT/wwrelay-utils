
TARGET = ledclient leddaemon
CC?=gcc
CFLAGS=-I.
HEADERS = ""

#this keeps make from doing something strange with files that happen to be named default,all, clean (if we had them)
.PHONY: default all clean

default: $(TARGET)
all: default

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(TGT_CFLAGS) -c $< -o $@

ledclient: ledclient.o 
	$(CC) -o ledclient ledclient.o

leddaemon: leddaemon.o
	$(CC) -pthread -o leddaemon leddaemon.o

clean:
	rm -f *.o $(TARGET)