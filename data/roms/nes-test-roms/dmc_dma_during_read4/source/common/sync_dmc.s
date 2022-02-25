; Synchronizes to DMC and times a piece of code

; Synchronizes precisely with DMC timer
; Preserved: X, Y
; Time: 8 msec avg, 17 msec max
.align 64
sync_dmc:
      ; Setup
      lda #$80
      sta $4010
      lda #0
      sta $4013
      sta SNDCHN
      
      ; Start twice (first will clear immediately)
      lda #$10
      sta SNDCHN
      nop
      sta SNDCHN
      
      ; Coarse synchronize
:     bit SNDCHN
      bne :-
      
      ; DO NOT write to memory. It affects timing.
      
      nop               ; 2 fine-tune: 2=OK 3=OK 4=fail
      
      ; Fine synchronize. 3421+4 clocks per iter
      nop               ; 2
      nop               ; 2
      lda #226          ; 3391 delay
      bne @first        ; 3
@wait:
      lda #227          ; 3406 delay
@first:
:     nop
      nop
      nop
      nop
      sec
      sbc #1
      bne :-
                        ; 4 DMC wait-states
      lda #$10          ; 2
      sta SNDCHN        ; 4
      nop               ; 2
      bit SNDCHN        ; 4
      bne @wait         ; 3
      
      rts


; Returns in XA number of clocks elapsed since call to
; time_code_begin, MOD 3424. Unreliable if result is
; 3387 or greater.
; Time: 33 msec max
.align 64
time_code_end:
      ; Restart
      lda #$10
      sta SNDCHN
      nop
      sta SNDCHN
      
      ; Rough sync
      ldy #-$2C
@coarse:
      nop
      nop
      bne :+
:     dey
      bit SNDCHN
      bne @coarse
      
      ; DO NOT write to memory. It affects timing.
      
      ; Fine sync
      ldx #-$2
@wait:
      lda #$10          ; 2
      sta SNDCHN        ; 4
      
      lda #179          ; delay 3402
:     nop
      nop
      nop
      nop
      nop
      nop
      sec
      sbc #1
      bne :-
      
      inx               ; 2
      lda #$10          ; 2
      bit SNDCHN        ; 4
      beq @wait         ; 3
      
      ;jsr print_y
      ;jsr print_x
      
      ; Calculate result
      ; XA = Y << 4 | X
      stx <0
      
      tya
      lsr a
      lsr a
      lsr a
      lsr a
      tax
      
      tya
      asl a
      asl a
      asl a
      asl a
      
      clc
      adc <0
      bcc :+
      inx
:     
      rts


; Begins timing section of code
; Preserved: A, X, Y, flags
; Time: 9 msec avg, 17 msec max
.align 32
time_code_begin:
      php
      pha
      txa
      pha
      tya
      pha
      
      jsr sync_dmc
      
      nop
      
      ldx #163          ; 3396 delay
      lda #3
:     dex
      bne :-
      sec
      sbc #1
      bne :-
      
      pla
      tay
      pla
      tax
      pla
      plp
      
      rts
