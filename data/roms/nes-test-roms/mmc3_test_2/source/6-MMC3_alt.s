; Tests alternate MMC3 behavior. Some MMC3 chips also have this behavior,
; though their markings appear identical to those that have normal
; MMC3 behavior. My copy of Crystalis in particular behaves this way,
; but not my copy of Super Mario Bros. 3, even though both have a chip
; marked MMC3B.

.include "test_mmc3.inc"

main:
	jsr begin_mmc3_tests
	
	set_test 2,"IRQ shouldn't be set when reloading to 0 due to counter naturally reaching 0 previously"
	ldx #2
	jsr begin_counter_test
	jsr clock_counter       ; reload with 2
	jsr clock_counter       ; decrement to 1
	jsr clock_counter       ; decrement to 0
	jsr should_be_set
	lda #0
	jsr set_reload
	jsr clock_counter       ; reload with 0
	jsr should_be_clear
	jsr clock_counter       ; reload with 0
	jsr should_be_clear
	jsr clock_counter       ; reload with 0
	jsr should_be_clear
	jsr clock_counter       ; reload with 0
	jsr should_be_clear
	
	set_test 3,"IRQ should be set when reloading due to clear, even if counter was already 0"
	ldx #2
	jsr begin_counter_test
	jsr clock_counter       ; reload with 2
	jsr clock_counter       ; decrement to 1
	jsr clock_counter       ; decrement to 0
	jsr should_be_set
	lda #0
	jsr set_reload
	jsr clock_counter       ; reload with 0
	jsr should_be_clear
	jsr clock_counter       ; reload with 0
	jsr should_be_clear
	lda #2
	jsr set_reload
	jsr clear_counter       ; this sets internal flag that is examined on next clock
	lda #0
	jsr set_reload
	jsr clock_counter       ; reload with 0, AND set IRQ flag, unlike before
	jsr should_be_set

	jmp tests_passed

