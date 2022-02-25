;
; File: bcd.inc
; Namespace: bcd_ / BCD_
; Code Segment: BCDLIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; Binary-coded decimal library
;

.ifndef BCD_INC
BCD_INC = 1

; Output binary-coded decimal number and temporary storage

.global bcd_num

; Output binary value and temporary storage

.global bcd_bin



;
; Converts an 8-bit binary value to BCD format.
;
; In:
; 	a = The 8-bit binary value to convert
; Out:
;	a = The 8-bit BCD result
;
; Preserved: x
; Destroyed: a, y, bcd_num
;
.global bcd8_from_bin

;
; Converts an 8-bit BCD number to binary format.
;
; In:
; 	a = The 8-bit BCD number to convert
; Out:
;	a = The 8-bit binary result
;
; Preserved: x
; Destroyed: a, y, bcd_bin
;
.global bcd8_to_bin

;
; Sets up a VRUB update to draw an 8-bit BCD number to the screen. Note that
; ASCII digit values are used and leading zeros are replaced with whitespace.
;
; In:
;	a = The low byte of the address to draw to
;	y = The high byte of the address to draw to
; 	bcd_num = The 8-bit BCD number to draw
;
; Preserved: y, bcd_num
; Destroyed: a, x
;
.global bcd8_to_vrub

;
; Converts a 16-bit binary value to BCD format.
;
; In:
;	a = The low byte of the 16-bit binary value to convert
;	y = The high byte of the 16-bit binary value to convert
; Out:
;	a, bcd_num = The low byte of the 16-bit BCD result
;	y, bcd_num + 1 = The high byte of the 16-bit BCD result
;
; Preserved: x
; Destroyed: a, y, bcd_bin/+1
;
.global bcd16_from_bin

;
; Converts a 16-bit BCD number to binary format.
;
; In:
;	a = The low byte of the 16-bit BCD number to convert
;	y = The high byte of the 16-bit BCD number to convert
; Out:
;	a, bcd_bin = The low byte of the 16-bit binary result
;	y, bcd_bin + 1 = The high byte of the 16-bit binary result
;
; Preserved: x
; Destroyed: a, y, bcd_num/+1
;
.global bcd16_to_bin

;
; Sets up a VRUB update to draw a 16-bit BCD number to the screen. Note that
; ASCII digit values are used and leading zeros are replaced with whitespace.
;
; In:
;	a = The low byte of the address to draw to
;	y = The high byte of the address to draw to
; 	bcd_num/+1 = The 16-bit BCD number to draw
;
; Preserved: bcd_num/+1
; Destroyed: a, x, y
;
.global bcd16_to_vrub

.endif

