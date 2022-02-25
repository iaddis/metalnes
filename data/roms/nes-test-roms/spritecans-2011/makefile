#!/usr/bin/make -f
#
# Makefile for codename spritecans
# Copyright 2010 Damian Yerrick
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#
version = 2011
objlist = sprite sound music musicseq paldetect ntscPeriods

CC65 = /usr/local/bin
AS65 = ca65
LD65 = ld65
#EMU := "/C/Program Files/nintendulator/Nintendulator.exe"
EMU := start
CC = gcc
ifdef COMSPEC
DOTEXE=.exe
else
DOTEXE=
endif
CFLAGS = -std=gnu99 -Wall -DNDEBUG -O
CFLAGS65 = 
objdir = obj/nes
srcdir = src
imgdir = tilesets

objlistntsc = $(foreach o,$(objlist),$(objdir)/$(o).o)

.PHONY: run dist zip

run: spritecans.nes
	$(EMU) $<

# Actually this depends on every single file in zip.in, but currently
# we use changes to spritecans.nes, makefile, and README as a heuristic
# for when something was changed.  Limitation: it won't see changes
# to docs or tools.
dist: zip
zip: spritecans-$(version).zip
spritecans-$(version).zip: zip.in spritecans.nes README.txt $(objdir)/index.txt
	zip -9 -u $@ -@ < $<

$(objdir)/index.txt: makefile
	echo Files produced by build tools go here, but caulk goes where? > $@

$(objdir)/%.o: $(srcdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

map.txt spritecans.prg: nes.ini $(objlistntsc)
	$(LD65) -C $^ -m map.txt -o spritecans.prg

spritecans.chr: $(imgdir)/main.png
	tools/pilbmp2nes.py $< $@

$(objdir)/ntscPeriods.s: tools/mktables.py
	$< period $@

%.nes: %.prg %.chr
	cat $^ > $@
