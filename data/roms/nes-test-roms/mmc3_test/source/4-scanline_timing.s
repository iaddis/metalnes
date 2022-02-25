; Tests MMC3 IRQ timing to PPU clock accuracy. Tests both modes,
; $2000=$08 and $2000=$10.
;
; Timing tested is between $2002 reads of VBL flag first set,
; and IRQ occurring.

.include "test_mmc3.inc"
.include "sync_vbl.s"

.macro test mode, count, n
	.local n_
	n_ = (n) + 1
	setb PPUMASK,0
	jsr sync_vbl_even
	delay_ppu_even (n_ .MOD 3) + 9
	setb PPUCTRL,mode
	lda #count
	jsr begin_
	delay n_/3 - 3 - 43
	jsr end_
.endmacro

begin_:
	pha
	setb PPUMASK,$18
	pla
	sta r_set_reload
	sta r_clear_counter
	sta r_disable_irq
	sta r_enable_irq
	rts

end_:
	setb irq_flag,$10
	cli
	nop
	nop
	inc irq_flag
	delay 1000
	sei
	nop
	lda irq_flag
	cmp #$11
	beq @no_irq
	rts

@no_irq:
	set_test 14,"IRQ never occurred"
	jmp test_failed

main:
	jsr begin_mmc3_tests
	
	jsr clear_oam
	
	scanline_0_08 = 6976
	scanline_1_08 = scanline_0_08
	
	set_test 2,"Scanline 0 IRQ should occur later when $2000=$08"
	test $08, 0, scanline_0_08 - 1
	cmp #$22
	jne test_failed
	
	set_test 3,"Scanline 0 IRQ should occur sooner when $2000=$08"
	test $08, 0, scanline_0_08
	cmp #$21
	jne test_failed
	
	set_test 4,"Scanline 1 IRQ should occur later when $2000=$08"
	test $08, 1, scanline_1_08 + 341 - 1
	cmp #$22
	jne test_failed
	
	set_test 5,"Scanline 1 IRQ should occur sooner when $2000=$08"
	test $08, 1, scanline_1_08 + 341
	cmp #$21
	jne test_failed
	
	set_test 6,"Scanline 239 IRQ should occur later when $2000=$08"
	test $08, 239, scanline_1_08 + 239*341 - 1
	cmp #$22
	jne test_failed
	
	set_test 7,"Scanline 239 IRQ should occur sooner when $2000=$08"
	test $08, 239, scanline_1_08 + 239*341
	cmp #$21
	jne test_failed
	
	
	scanline_0_10 = 6976 - 256
	scanline_1_10 = scanline_0_10 - 21
	
	set_test 8,"Scanline 0 IRQ should occur later when $2000=$10"
	test $10, 0, scanline_0_10 - 1
	cmp #$22
	jne test_failed
	
	set_test 9,"Scanline 0 IRQ should occur sooner when $2000=$10"
	test $10, 0, scanline_0_10
	cmp #$21
	jne test_failed
	
	set_test 10,"Scanline 1 IRQ should occur later when $2000=$10"
	test $10, 1, scanline_1_10 + 341 - 1
	cmp #$22
	jne test_failed
	
	set_test 11,"Scanline 1 IRQ should occur sooner when $2000=$10"
	test $10, 1, scanline_1_10 + 341
	cmp #$21
	jne test_failed
	
	set_test 12,"Scanline 239 IRQ should occur later when $2000=$10"
	test $10, 239, scanline_1_10 + 239*341 - 1
	cmp #$22
	jne test_failed
	
	set_test 13,"Scanline 239 IRQ should occur sooner when $2000=$10"
	test $10, 239, scanline_1_10 + 239*341
	cmp #$21
	jne test_failed
	
	jmp tests_passed
