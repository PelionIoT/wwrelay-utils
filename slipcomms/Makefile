#
# Makefile for slipcomms
#

CC?=gcc
CFLAGS?=-g -Wall
APP=slipcomms

all: $(APP)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

OBJS=$(APP).o

$(APP): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@

clean:
	rm -f *.o $(APP)
