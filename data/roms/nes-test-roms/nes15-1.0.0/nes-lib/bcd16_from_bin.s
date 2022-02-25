;
; File: bcd16_from_bin.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; 'bcd16_from_bin' subroutine
;
; The technique used was adapted from source code by 'Damian Yerrick' found at:
; http://wiki.nesdev.com/w/index.php/16-bit_BCD
;

.include "bcd.inc"



.import bcd_table_lo
.import bcd_table_hi



.segment "ZEROPAGE"

temp:				.res 1



.segment "BCDLIB"

.proc bcd16_from_bin

	sta bcd_bin
	sty bcd_bin + 1
	ldy #16

loop:
	lda bcd_bin
	sec
	sbc bcd_table_lo - 1, y
	sta temp
	lda bcd_bin + 1
	sbc bcd_table_hi - 1, y
	bcc lower
	sta bcd_bin + 1
	lda temp
	sta bcd_bin

lower:
	rol bcd_num
	rol bcd_num + 1
	dey
	bne loop
	lda bcd_num
	ldy bcd_num + 1
	rts

.endproc

