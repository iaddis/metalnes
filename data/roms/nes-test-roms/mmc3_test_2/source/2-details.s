; Tests MMC3 IRQ counter details

.include "test_mmc3.inc"
	
main:
	jsr begin_mmc3_tests
	
	set_test 2,"Counter isn't working when reloaded with 255"
	ldx #255
	jsr begin_counter_test
	ldx #255
	jsr clock_counter_x ; first clock loads with 255
	jsr should_be_clear
	jsr clock_counter
	jsr should_be_set
	
	set_test 3,"Counter should run even when IRQ is disabled"
	ldx #2
	jsr begin_counter_test
	jsr disable_irq
	jsr clock_counter   ; 2
	jsr clock_counter   ; 1
	jsr clock_counter   ; 0
	jsr clock_counter   ; 2
	jsr clock_counter   ; 1
	jsr enable_irq
	jsr should_be_clear
	jsr clock_counter   ; 0
	jsr should_be_set
	
	set_test 4,"Counter should run even after IRQ flag has been set"
	ldx #2
	jsr begin_counter_test
	jsr clock_counter   ; 2
	jsr clock_counter   ; 1
	jsr clock_counter   ; 0
	jsr clock_counter   ; 2
	jsr clear_irq
	jsr clock_counter   ; 1
	jsr should_be_clear
	jsr clock_counter   ; 0
	jsr should_be_set
	
	set_test 5,"IRQ should not be set when counter reloads with non-zero"
	ldx #1
	jsr begin_counter_test
	jsr clock_counter   ; 1
	jsr clock_counter   ; 0
	jsr clear_irq
	jsr clock_counter   ; 1
	jsr should_be_clear
	
	set_test 6,"IRQ should not be set when counter is cleared via $C001"
	ldx #2
	jsr begin_counter_test
	jsr clock_counter   ; 2
	jsr clock_counter   ; 1
	jsr clear_counter
	jsr should_be_clear
	
	set_test 7,"IRQ should be set when non-zero and reloading to 0 after clear"
	ldx #3
	jsr begin_counter_test
	jsr clock_counter   ; 3
	jsr clock_counter   ; 2
	lda #0
	jsr set_reload
	jsr clear_counter
	jsr clock_counter   ; 0
	jsr should_be_set
	
	jsr clear_oam
	set_test 8,"Counter should be clocked 241 times in PPU frame"
	ldx #241
	jsr begin_counter_test
	jsr wait_vbl
	setb PPUSCROLL,0
	sta PPUSCROLL
	setb PPUCTRL,$08            ; sprites use tiles at $1xxx
	setb PPUMASK,$18            ; enable bg and sprites
	delay 29800
	setb PPUMASK,$00            ; disable rendering
	jsr should_be_clear
	jsr clock_counter
	jsr should_be_set
		
	jmp tests_passed

