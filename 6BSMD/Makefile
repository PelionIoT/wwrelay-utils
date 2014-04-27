
CC=gcc -g

%.o: %.c
	$(CC) $(CFLAGS) $(TGT_CFLAGS) -c $< -o $@

all: mc1322x-load

mc1322x-load: mc1322x-load.o
	$(CC) $@.o -o $@

tunslip6: tunslip6.o
	$(CC) $@.o -o $@
