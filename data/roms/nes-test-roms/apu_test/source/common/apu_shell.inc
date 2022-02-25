.include "shell.inc"
.include "sync_apu.s"
.include "test_main_chans.s"

len_2 = $18 ; value that loads length counter with 2
len_4 = $28 ; value that loads length counter with 4
len_6 = $38 ; value that loads length counter with 6

halt   = $B0
unhalt = $10

should_be_playing:
	lda chan_bit
	and SNDCHN
	jeq chan_failed
	rts

len_should_be_1:
	jsr should_be_playing
	setb SNDMODE,$C0 ; clock length
should_be_silent:
	lda chan_bit
	and SNDCHN
	jne chan_failed
	rts

chan_failed:
	print_str "Channel: "
	lda chan_idx
	jsr print_dec
	jsr print_newline
	jmp test_failed
