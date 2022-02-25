; Serial output at 57600 bits/sec on controller port 2
;
; Uses stack and register A only, and doesn't mind page crossing
; (uses subroutines instead of loops).

; Initializes serial. If this isn't done, first byte sent to
; PC might be corrupt.
; Preserved: X, Y
serial_init:
	sec
	lda #$FF
	bne serial_write_ ; always branches


; Writes byte A to serial
; Preserved: X, Y
serial_write:
	clc
serial_write_:
	jsr @bit        ; start
	nop             ; TODO: why the extra delay?
	jsr @first      ; bit 0
	jsr @bit        ; bit 1
	jsr @bit        ; bit 2
	jsr @bit        ; bit 3
	jsr @bit        ; bit 4
	jsr @bit        ; bit 5
	jsr @bit        ; bit 6
	jsr @bit        ; bit 7
	sec             ; 2 stop bit
@first: nop             ; 4
	nop 
@bit:                   ; 6 jsr
	pha             ; 3
	rol a           ; 2
	and #1          ; 2
	sta JOY1        ; 4
	pla             ; 4
	ror a           ; 2
	nop             ; 2
	rts             ; 6
