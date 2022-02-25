;
; File: header.inc
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; NROM-128 iNES header
;

.segment "INESHDR"

	.byte "NES", $1A
	.byte $01		; 1 16k bank of PRGROM
	.byte $01		; 1 8k back of CHRROM
	.byte $01, $00		; Mapper 0 with vertical mirroring
	.byte $00

