; Thoroughly tests routine with DMC DMA occurring
; at every possible timing. Ensures that no more
; than one corruption can occur out of the four
; the routine makes.

iter = 1000

.include "shell.inc"
.include "sync_dmc.s"
.include "read_joy.inc"

log_size = 4
zp_res log,log_size

main:   for_loop16 test,0,iter,+1
	jmp tests_passed

test:   jsr sync_dmc
	
	; Start DMC
	lda #$4F
	sta $4010
	lda #$10
	sta $4015
	
	; Delay
	txa
	jsr delay_a_25_clocks
	tya
	jsr delay_256a_16_clocks
	
	; DMC DMA occurs during this code
	jsr read_joy
	pha
	pha
	
	; Recover second controller read
	; from below stack pointer
	tsx
	dex
	txs
	pla
	
	; Ensure that no more than one reading
	; was corrupted by DMC DMA.
	ldx #0
	cmp #0
	beq :+
	inx
:       lda <temp
	beq :+
	inx
:       lda <temp2
	beq :+
	inx
:       lda <temp3
	beq :+
	inx
:       cpx #2
	jge test_failed
	
	; Ensure read worked correctly
	pla
	pla
	jne test_failed
	
	rts
