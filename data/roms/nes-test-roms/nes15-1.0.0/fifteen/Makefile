#
# 'fifteen' test GNU Makefile
#

INCS = \
	../nes-lib/lfsr32.inc \
	fifteen.inc

OBJS = \
	../nes-lib/lfsr32.o \
	fifteen.o \
	test.o

BIN = test.bin

AS65 = ca65
LD65 = ld65
AFLAGS65 = -l -I ../nes-lib
LCONFIG = test.cfg
MAPFILE = map.txt

#
# Targets
#

$(BIN): $(OBJS)
	$(LD65) -C $(LCONFIG) $(OBJS) -m $(MAPFILE) -o $(BIN)

.PHONY: clean
clean:
	rm $(BIN) $(OBJS) $(OBJS:.o=.lst) $(MAPFILE)

%.o: %.s $(INCS) $(LCONFIG)
	$(AS65) $(AFLAGS65) $< -o $@

