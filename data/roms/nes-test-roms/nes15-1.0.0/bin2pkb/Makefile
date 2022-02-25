#
# 'bin2pkb' GNU Makefile
#

OBJS = \
	../clib/binio.o \
	../clib/packbits.o \
	bin2pkb.o

PROG = bin2pkb

CC = gcc
LFLAGS = -o $(PROG)
CFLAGS = -I ../clib -Wall -Wextra -pedantic -ansi

#
# Targets
#

$(PROG): $(OBJS)
	$(CC) $(OBJS) $(LFLAGS)

-include $(OBJS:.o=.d)

%.o: %.c
	$(CC) $(CFLAGS) -c $*.c -o $*.o
	$(CC) $(CFLAGS) -MM $*.c > $*.d

.PHONY: debug
debug: CFLAGS += -g
debug: $(PROG)

.PHONY: clean
clean:
	rm $(OBJS) $(OBJS:.o=.d) $(PROG)

