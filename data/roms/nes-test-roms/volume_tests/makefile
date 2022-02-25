CC65 = /e/nesdev/cc65/bin
AS65 = $(CC65)/ca65.exe
LD65 = $(CC65)/ld65.exe
#EMU = /e/games/nes/fceu080win/fceu.exe
EMU := /e/games/nes/nintendulator0900bin/Nintendulator.exe
CC = gcc
DOTEXE=.exe
CFLAGS = -std=gnu99 -Wall -DNDEBUG -O
CFLAGS65 = 
objdir = obj/nes
srcdir = src

objlist = hello pads sound
objlistntsc = $(foreach o,$(objlist),$(objdir)/$(o).o)

.PHONY: run

run: volumes.nes
	$(EMU) $<

$(objdir)/%.o: $(srcdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

map.txt volumes.prg: nes.ini $(objlistntsc)
	$(LD65) -C $^ -m map.txt -o volumes.prg

%.nes: %.prg empty.chr
	cat $^ > $@
