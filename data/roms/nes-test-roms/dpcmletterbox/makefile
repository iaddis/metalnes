#!/usr/bin/make -f
#
# Makefile for DPCM Letterbox demo
# Copyright 2010 Damian Yerrick
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#
CC65 = /usr/local/bin
AS65 = $(CC65)/ca65
LD65 = $(CC65)/ld65
EMU := fceu -slstart 0 -slend 239 -xscale 2 -yscale 2 -opengl 0
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

objlist = reset
objlistntsc = $(foreach o,$(objlist),$(objdir)/$(o).o)

.PHONY: run

run: dpcmletterbox.nes
	$(EMU) $<

$(objdir)/%.o: $(srcdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

map.txt dpcmletterbox.prg: NROM.ini $(objlistntsc)
	$(LD65) -C $^ -m map.txt -o dpcmletterbox.prg

$(objdir)/ac16.chr: $(imgdir)/ac16.png
	tools/pilbmp2nes.py -H 16 $< $@

%.nes: %.prg %.chr
	cat $^ > $@

dpcmletterbox.chr: $(objdir)/ac16.chr
	cat $(objdir)/ac16.chr $(objdir)/ac16.chr > $@

