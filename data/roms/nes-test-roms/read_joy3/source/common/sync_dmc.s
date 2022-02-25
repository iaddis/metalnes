; Synchronizes precisely with DMC timer. Leaves DMC at
; maximum rate, length 0 (1 byte). To avoid stopping
; other sound channels when writing to SNDCHN, it
; writes $1F rather than $10.
; Preserved: A, X, Y
; Time: ~680-3800 clocks
.align 64
sync_dmc:
	pha
	
	; Setup
	lda #0
	sta $4013
	lda #$0F
	sta $4010
	sta SNDCHN
	
	; Start twice (first will clear immediately)
	lda #$1F
	sta SNDCHN
	nop
	sta SNDCHN
	
	; Coarse synchronize
	lda #$10
:       bit SNDCHN
	bne :-
	
	; DO NOT write to memory. It affects timing.
	
	bit <0          ; 3 fine-tune: 2=OK 3=OK 4=fail
	nop             ; 2
	lda #57         ; 400 delay for first iter
	bne :+          ; 3
	
	; Fine synchronize. 433 clocks per iter.
@sync:  lda #59         ; 414 delay
:       sec
	sbc #1
	bne :-
			; 4 DMC wait-states
	lda #$1F        ; 2
	sta SNDCHN      ; 4
	lda #$10        ; 2
	bit SNDCHN      ; 4
	bne @sync       ; 3
	
	pla
	rts
