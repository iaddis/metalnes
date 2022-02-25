;
; File: bcd16.s
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Common 16-bit binary-coded decimal subroutines and data
;

.include "bcd.inc"



.segment "BSS"

bcd_num:			.res 2
bcd_bin:			.res 2



.segment "BCDLIB"

.export bcd_table_lo
bcd_table_lo:
	.byte <1, <2, <4, <8
	.byte <10, <20, <40, <80
	.byte <100, <200, <400, <800
	.byte <1000, <2000, <4000, <8000

.export bcd_table_hi
bcd_table_hi:
	.byte >1, >2, >4, >8
	.byte >10, >20, >40, >80
	.byte >100, >200, >400, >800
	.byte >1000, >2000, >4000, >8000

