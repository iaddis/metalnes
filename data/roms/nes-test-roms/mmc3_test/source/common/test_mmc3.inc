CUSTOM_IRQ=1
CUSTOM_MAPPER=4 ; MMC3
.include "shell.inc"

r_set_reload    = $C000
r_clear_counter = $C001
r_disable_irq   = $E000
r_enable_irq    = $E001

begin_mmc3_tests:
	delay_msec 200
	setb SNDMODE,$C0        ; disable frame irq
	setb PPUMASK,0          ; disable PPU
	setb PPUCTRL,0
	set_ppuaddr 0
	
	lda #1
	jsr set_reload
	jsr clear_counter
	ldx #0
	jsr clock_counter_x
	jsr clear_counter
	ldx #0
	jsr clock_counter_x
	jsr clear_irq
	rts

set_reload:
	sta r_set_reload
	rts

clear_counter:
	setb r_clear_counter,123
	rts

disable_irq:
	setb r_disable_irq,123
	rts

; Disable then re-enable IRQ
clear_irq:
	setb r_disable_irq,123
enable_irq:
	setb r_enable_irq,123
	rts

; Clock counter X times
; Preserved: A, Y
clock_counter_x:
:       jsr clock_counter
	dex
	bne :-
	rts

; Clock counter once
; Preserved: A, X, Y
clock_counter:
	pha
	setb PPUADDR,0
	sta PPUADDR
	setb PPUADDR,$10
	sta PPUADDR
	setb PPUADDR,0
	sta PPUADDR
	pla
	rts

; Return X=1 if IRQ is pending, otherwise X=0
; Preserved: Y
get_pending:
	setb irq_flag,$01
	cli
	nop
	sei     ; IRQ causes return from this routine
	nop
	ldx irq_flag
	dex
	rts
	
; Decrement counter until IRQ occurs and return
; number of decrements required in A.
get_countx:
	ldx #0
	cli
	nop
	nop
:       setb PPUADDR,0
	sta PPUADDR
	lda #$10
	inx
	sta PPUADDR
	sta PPUADDR
	bne :-
	sei
	ldx #$FF
	rts

zp_res irq_flag

irq:    asl irq_flag
	sta r_disable_irq
	rti
	
begin_counter_test:
	jsr clock_counter       ; avoid pathological reload behavior
	jsr clock_counter
	txa
	jsr set_reload
	jsr clear_counter
	jsr clear_irq
	rts

should_be_clear:
	jsr get_pending
	cpx #0
	jne test_failed
	jsr clear_irq
	rts

should_be_set:
	jsr get_pending
	cpx #1
	jne test_failed
	jsr clear_irq
	rts
