; Tests MMC3-specifics

.include "test_mmc3.inc"
	
main:
	jsr begin_mmc3_tests
	
	set_test 2,"Should reload and set IRQ every clock when reload is 0"
	ldx #0
	jsr begin_counter_test
	jsr clock_counter       ; 0
	jsr should_be_set
	jsr clock_counter       ; 0
	jsr should_be_set
	jsr clock_counter       ; 0
	jsr should_be_set
	
	set_test 3,"IRQ should be set when counter is 0 after reloading"
	ldx #1
	jsr begin_counter_test
	jsr clock_counter       ; 1
	jsr clock_counter       ; 0
	jsr clear_irq
	lda #0
	jsr set_reload
	jsr clock_counter       ; 0
	jsr should_be_set
	
		
	jmp tests_passed

