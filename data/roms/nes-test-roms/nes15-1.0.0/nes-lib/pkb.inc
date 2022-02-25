;
; File: pkb.inc
; Namespace: pkb_ / PKB_
; Code Segment: PKBLIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; PackBits decoding library
;
; A PackBits data stream consists of packets with a one-byte header followed by
; data. The header is a signed byte; the data is treated as an unsigned char.
; 
; 	Header byte	Data following the header byte
; 
;	 0 to  127	(1 + n) literal bytes of data
;	-1 to -127	One byte of data, repeated (1 - n) times in the
; 			decompressed output
;	-128		Marks the end of the encoded data
;
; Note that the PackBits encoding used here differs somewhat from the original.
; The header byte -128 is used to mark the end of the encoded data instead of
; indicating a no-op or a run.
;

.ifndef PKB_INC
PKB_INC = 1

; Address of the PackBits encoded data to be decoded

.globalzp pkb_src



;
; Decodes and writes PackBits encoded data to PPUDATA. Note that the user is
; responsible for setting PPUADDR.
;
; In:
;	pkb_src/+1 = Address of the PackBits data to decode
;
; Destroyed: a, x, y, pkb_src/+1
;
.global pkb_to_vram

.endif

