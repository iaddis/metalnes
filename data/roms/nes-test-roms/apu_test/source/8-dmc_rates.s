; Verifies the DMC's 16 rates

.include "shell.inc"
.include "sync_dmc.s"

.macro test rate, period
	jsr sync_dmc_fast
	setb $4013,1    ; length = 17 bytes
	setb $4010,rate
	setb SNDCHN,$10 ; start
	delay (period)*8*17 - (period) - 65
	ldx $4015       ; should still be playing
	delay 90
	ldy $4015       ; should have stopped
	set_test rate*2+2,{"Rate ",.string(rate),"'s period is too short"}
	txa
	and #$10
	jeq test_failed
	set_test rate*2+3,{"Rate ",.string(rate),"'s period is too long"}
	tya
	and #$10
	jne test_failed
.endmacro

main:
	setb $4012,<((dmc_sample-$C000)/$40)
	setb SNDCHN,$00
	
	test $0, 428
	test $1, 380
	test $2, 340
	test $3, 320
	test $4, 286
	test $5, 254
	test $6, 226
	test $7, 214
	test $8, 190
	test $9, 160
	test $A, 142
	test $B, 128
	test $C, 106
	test $D,  84
	test $E,  72
	test $F,  54
	
	jmp tests_passed

; Silent DMC sample so tests won't make any noise
.align $40
dmc_sample:
	.res 33,$00
