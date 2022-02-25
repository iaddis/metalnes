; Builds program as NSF music file

.ifndef NSF_SONG_COUNT
	NSF_SONG_COUNT = 1
.endif

.ifndef CUSTOM_NSF_HEADER
	.segment "HEADER"
		.byte "NESM",26,1
		.byte NSF_SONG_COUNT
		.byte 1 ; start with first song
		.word load_addr,reset,nsf_play
.endif

.segment "DMC"
	load_addr:

.ifndef CUSTOM_NSF_VECTORS
	.segment "VECTORS"
		.word 0,0,0,nmi,internal_error,irq
.endif

.include "shell.s"

nv_res nsf_track,1
nv_res nsf_running,1
	
.ifdef EMPTY_NSF_PLAY
	CUSTOM_NSF_PLAY = 1
	nsf_play:
		rts
.endif

std_reset:
	sta nsf_track
	
	; In case NSF player interrupts init with play,
	; wait a while in init. If play interrupts, then
	; we just use that play call to run program, and
	; this is never resumed.
	setb nsf_running,1
	delay_msec 500

.ifndef CUSTOM_NSF_PLAY
	nsf_play:
.endif
std_nsf_play:
	php
	bit nsf_running
	bpl :+
	plp
	rts

:   lda nsf_running
	beq :+
	
	; First call
	setb nsf_running,0
	delay_msec 20
	jmp run_shell
	
	; Player let init run too long before interrupting
	; with play, or play call interrupted itself.
:   setb nsf_running,$80
	jsr clear_ram
	jsr init_shell
	print_str "NSF player called play recursively"
	jmp internal_error


init_runtime:
	rts

post_exit:
forever:
	jmp forever

; Reports A in binary as high and low tones, with
; leading low tone for reference. Omits leading
; zeroes.
; Preserved: A, X, Y
play_byte:
	pha
	
	; Make low reference beep
	clc
	jsr @beep
	
	; Remove high zero bits
	sec
:   rol a
	bcc :-
	
	; Play remaining bits
	beq @zero
:   jsr @beep
	asl a
	bne :-
@zero:

	delay_msec 300
	pla
	rts

; Plays low/high beep based on carry
; Preserved: A, X, Y
@beep:
	pha
	
	; Set up square
	lda #1
	sta SNDCHN
	sta $4001
	sta $4003
	adc #$FE    ; period=$100 if carry, $1FF if none
	sta $4002
	
	; Fade volume
	lda #$0F
:   ora #$30
	sta $4000
	delay_msec 8
	sec
	sbc #$31
	bpl :-
	
	; Silence
	sta SNDCHN
	delay_msec 160
	
	pla
	rts

; User code goes in main code segment
.code
