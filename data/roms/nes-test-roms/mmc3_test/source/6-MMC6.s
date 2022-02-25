; Tests MMC6-specific behavior. Some MMC3 chips also have this behavior,
; though their markings appear identical to those that have normal
; MMC3 behavior. My copy of Crystalis in particular behaves this way,
; but not my copy of Super Mario Bros. 3, even though both have a chip
; marked MMC3B.

.include "test_mmc3.inc"
	
main:
	jsr begin_mmc3_tests
	
	set_test 2,"IRQ should be set when reloading to 0 after clear"
	ldx #0
	jsr begin_counter_test
	jsr clock_counter       ; 0
	jsr should_be_set
	
	set_test 3,"IRQ shouldn't occur when reloading after counter normally reaches 0"
	ldx #1
	jsr begin_counter_test
	jsr clock_counter       ; 1
	lda #0
	jsr set_reload
	jsr clock_counter       ; 0
	jsr clear_irq
	jsr clock_counter       ; 0
	jsr should_be_clear
	ldx #255
		
	jmp tests_passed

