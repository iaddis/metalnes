

;variables

  .org 00100h

int_en:   .block 1
sng_ctr:  .block 1
pv_btn:   .block 1

;code

  .org 0c000h

start:    sei
          cld
          ldx #0ffh
          txs

w_vbi:    lda 2002h
          bpl w_vbi
          
          lda #0
          tax

ci_lp:    sta 0000h,x
          sta 0100h,x
          sta 0200h,x
          sta 0300h,x
          sta 0400h,x
          sta 0500h,x
          sta 0600h,x
          sta 0700h,x
          inx
          bne ci_lp     ;clear RAM
          
          lda #080h
          sta 2000h
          lda #081h
          sta 2001h  ;set up PPU for interrupts, disable screen

          lda #00c
          sta sng_ctr
          jsr 9a3ch     ;init tune
          lda #1
          sta int_en

k_loop:   jsr r_btn
          and #010h
          beq k_loop

          inc sng_ctr
          lda #02bh
          cmp sng_ctr
          bne no_scr
          lda #0
          sta sng_ctr

no_scr:   lda #0
          sta int_en
          lda sng_ctr
          jsr 9a3ch
          lda #1
          sta int_en
          jmp k_loop    ;check button, if pressed inc song # and re-init


interrupt: pha
           txa
           pha
           tya
           pha
           lda int_en 
           beq no_ints
           jsr 9a7bh    ;play tune

no_ints:   pla
           tay
           pla
           tax
           pla
           rti

r_btn:     ldy #8      ;read keypad
           ldx #1
           stx 4016h
           dex
           stx 4016h
           
r_bit:     lda 4016h
           ror a
           txa
           rol a
           tax
           dey
           bne r_bit
           
           cmp pv_btn
           beq no_chg
           sta pv_btn
           rts

no_chg:    lda #0
           rts

;info line

           .db "Linus Spacehead music... "
           .db "ripped and player by k.horton "
           .db "khorton@iquest.net "
           .db "press START to change song"

;fill empty space

 .fill 0fffah-*,0eah


;vectors

 .dw interrupt
 .dw start
 .dw interrupt

 .end
