
; Beep A times. Made to require minimal features from APU.
debug_beeps:
beep_loop:
      pha
      
      lda   #1          ; set up square 1
      sta   $4015
      sta   $4003
      sta   $4001
      sta   $4002
      
      lda   #$0f        ; fade volume
:     pha
      eor   #$30
      sta   $4000
      lda   #8
      jsr   delay_msec
      pla
      clc
      adc   #-1
      bpl   -
      
      sta   $4015       ; silence square for a bit
      lda   #120
      jsr   delay_msec
      
      pla
      clc
      adc   #-1
      bne   beep_loop
      rts
      .code

; Print indicated register to console as $hh
; Preserved: A, X, Y, P
print_a:
      php
      jsr   debug_byte
      plp
      rts
      .code

print_x:
      php
      pha
      txa
      jsr   debug_byte
      pla
      plp
      rts
      .code

print_y:
      php
      pha
      tya
      jsr   debug_byte
      pla
      plp
      rts
      .code

print_s:
      php
      pha
      txa
      pha
      tsx
      txa
      jsr   debug_byte
      pla
      tax
      pla
      plp
      rts
      .code

print_p:
      php
      pha
      php
      pla
      jsr   debug_byte
      pla
      plp
      rts
      .code

print_ay:
      php
      pha
      lda   #36
      jsr   debug_char
      pla
      pha
      jsr   hex_byte
      tya
      jsr   hex_byte
      lda   #32         ; ' '
      jsr   debug_char_no_wait
      pla
      plp
      rts
      .code

; Print address YA to console as $hhhh
; Preserved: A, X, Y
debug_addr:
      pha
      lda   #36         ; '$'
      jsr   debug_char
      tya
      jsr   hex_byte
      jmp   debug_byte_impl
      .code
      
; Print byte A to console as $hh
; Preserved: A, X, Y
debug_byte:
      pha
      lda   #36         ; '$'
      jsr   debug_char
debug_byte_impl:
      pla
      pha
      jsr   hex_byte
      lda   #32         ; ' '
      jsr   debug_char_no_wait
      pla
      rts
      
hex_byte:
      pha
      lsr   a
      lsr   a
      lsr   a
      lsr   a
      jsr   nybble
      pla
      and   #$0f
nybble:
      cmp   #10
      bcc   not_letter
      adc   #6          ; relies on carry being set
not_letter:
      adc   #$30
      jmp   debug_char_no_wait
      .code
