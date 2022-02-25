; Tests MMC3 IRQ clocking via bit 12 of VRAM address

.include "test_mmc3.inc"
	
main:
	jsr begin_mmc3_tests
	
	setb PPUCTRL,0          ; disable PPU, sprites and bg use $0xxx patterns
	sta PPUMASK
	
	set_test 2,"Shouldn't be clocked when A12 doesn't change"
	ldx #1
	jsr begin_counter_test
	lda #$00                ; transition everything but A12
	ldx #$ef
	ldy #$ff
	sta PPUADDR
	sta PPUADDR
	stx PPUADDR
	sty PPUADDR
	sta PPUADDR
	sta PPUADDR
	stx PPUADDR
	sty PPUADDR
	sta PPUADDR
	sta PPUADDR
	jsr should_be_clear
	
	set_test 3,"Shouldn't be clocked when A12 changes to 0"
	ldx #1
	jsr begin_counter_test
	jsr clock_counter       ; avoid pathological behavior
	setb PPUADDR,$10
	sta PPUADDR
	jsr clear_counter
	jsr clear_irq
	ldx #$00
	ldy #$10
	stx PPUADDR
	stx PPUADDR
	sty PPUADDR             ; counter = 1
	stx PPUADDR
	stx PPUADDR             ; second 1 to 0 transition
	stx PPUADDR
	jsr should_be_clear
	
	set_test 4,"Should be clocked when A12 changes to 1 via PPUADDR write"
	ldx #1
	jsr begin_counter_test
	jsr clock_counter
	setb PPUADDR,$00        ; transition A12 from 0 to 1
	sta PPUADDR
	setb PPUADDR,$10
	sta PPUADDR
	jsr should_be_set
	
	set_test 5,"Should be clocked when A12 changes to 1 via PPUDATA read"
	ldx #1
	jsr begin_counter_test
	jsr clock_counter
	setb PPUADDR,$0f        ; vaddr = $0fff
	setb PPUADDR,$ff
	jsr should_be_clear
	bit PPUDATA
	jsr should_be_set
	
	set_test 6,"Should be clocked when A12 changes to 1 via PPUDATA write"
	ldx #1
	jsr begin_counter_test
	jsr clock_counter
	setb PPUADDR,$0f        ; vaddr = $0fff
	setb PPUADDR,$ff
	jsr should_be_clear
	sta PPUDATA
	jsr should_be_set
	
	jmp tests_passed
