#
# 'nes15' GNU Makefile
#

INCS = \
	fifteen/fifteen.inc \
	snd/snd.inc \
	src/game.inc \
	src/gfx.inc \
	src/nmi.inc \
	src/play.inc \
	src/title.inc

OBJS = \
	fifteen/fifteen.o \
	snd/mus0.o \
	snd/mus1.o \
	snd/sfx0.o \
	snd/sfx1.o \
	snd/snd.o \
	src/game.o \
	src/gfx.o \
	src/header.o \
	src/nmi.o \
	src/play.o \
	src/title.o

LIBINCS = \
	nes-lib/apu.inc \
	nes-lib/bcd.inc \
	nes-lib/joy.inc \
	nes-lib/lfsr32.inc \
	nes-lib/muse.inc \
	nes-lib/oam.inc \
	nes-lib/pkb.inc \
	nes-lib/ppu.inc \
	nes-lib/vrub.inc

LIBOBJS = \
	nes-lib/bcd16_from_bin.o \
	nes-lib/bcd16.o \
	nes-lib/bcd16_to_vrub.o \
	nes-lib/joy_read1.o \
	nes-lib/joy_repeat1.o \
	nes-lib/joy_update1.o \
	nes-lib/lfsr32.o \
	nes-lib/muse.o \
	nes-lib/oam_clear.o \
	nes-lib/pkb.o \
	nes-lib/pkb_to_vram.o \
	nes-lib/vrub_from_mem.o \
	nes-lib/vrub.o

CHRS = \
	gfx/cursor.chr \
	gfx/edges.chr \
	gfx/font.chr \
	gfx/tile.chr

VCHRS = \
	gfx/nums.chr

PKBS = \
	gfx/play.pkb \
	gfx/title.pkb

PALS = \
	gfx/bgd.pal \
	gfx/spr.pal

INES = nes15.nes
AS65 = ca65
LD65 = ld65
AFLAGS65 = -l -I src -I fifteen -I gfx -I snd -I nes-lib

ifdef PAL
	AFLAGS65 += -DPAL=1
endif

LCONFIG = game.cfg
MAPFILE = map.txt
PCX2CHR = pcx2chr
BIN2PKB = bin2pkb

#
# Targets
#

$(INES): header.bin game.bin chr1.chr chr2.chr
	cat header.bin game.bin chr1.chr chr2.chr > $(INES)

header.bin game.bin chr1.chr chr2.chr: $(LCONFIG) $(OBJS) $(LIBOBJS)
	$(LD65) -C $(LCONFIG) $(LIBOBJS) $(OBJS) -m $(MAPFILE) -o $@

$(OBJS): $(INCS) $(LIBINCS) $(CHRS) $(VCHRS) $(PKBS) $(PALS)
$(LIBOBJS): $(LIBINCS)

$(CHRS): $(CHRS:.chr=.pcx)
	$(PCX2CHR) $(@:.chr=.pcx) $@

$(VCHRS): $(VCHRS:.chr=.pcx)
	$(PCX2CHR) $(@:.chr=.pcx) $@ -V

%.pkb: %.nam
	$(BIN2PKB) $< $@

%.o: %.s
	$(AS65) $(AFLAGS65) $< -o $@

.PHONY: clean
clean:
	rm $(INES) *.bin *.chr $(OBJS) $(OBJS:.o=.lst) $(LIBOBJS) \
		$(LIBOBJS:.o=.lst) $(MAPFILE) $(CHRS) $(VCHRS) $(PKBS)

