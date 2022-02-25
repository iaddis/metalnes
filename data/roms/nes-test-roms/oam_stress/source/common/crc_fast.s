; Fast table-based CRC-32

; Uses 1K of RAM
checksum_t0 = $400
checksum_t1 = $500
checksum_t2 = $600
checksum_t3 = $700

; Initializes fast CRC tables and resets checksum.
; Preserved: Y
; Time: ~60 msec
init_crc_fast:
	ldx #0
@byte:  ; Calculate CRC for this byte
	lda #0
	sta checksum+3
	sta checksum+2
	sta checksum+1
	stx checksum
	jsr update_crc_
	
	; Write in table
	lda checksum
	sta checksum_t0,x
	lda checksum+1
	sta checksum_t1,x
	lda checksum+2
	sta checksum_t2,x
	lda checksum+3
	sta checksum_t3,x
	
	inx
	bne @byte
	
	jmp reset_crc


; Updates checksum with byte from A
; Preserved: X, Y
; Time: 54 clocks
update_crc_fast:
	stx checksum_temp

; Updates checksum with byte from A
; Preserved: Y
; Time: 42 clocks
.macro update_crc_fast
	eor checksum
	tax
	lda checksum+1
	eor checksum_t0,x
	sta checksum
	lda checksum+2
	eor checksum_t1,x
	sta checksum+1
	lda checksum+3
	eor checksum_t2,x
	sta checksum+2
	lda checksum_t3,x
	sta checksum+3
.endmacro

	update_crc_fast
	ldx checksum_temp
	rts
