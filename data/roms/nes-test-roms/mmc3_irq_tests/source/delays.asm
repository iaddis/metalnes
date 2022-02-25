; to do: delay loops that take only a single count
      
; Delay for almost A milliseconds (A * 0.999009524 msec)
; Preserved: X, Y
delay_msec:
      pha                     ; 3
      lda   #253              ; 2
      sec                     ; 2
delay_msec_:
      nop                     ; 2
      adc   #-2               ; 2
      bne   delay_msec_       ; 3
                              ; -1
      pla                     ; 4
      clc                     ; 2
      adc   #-1               ; 2
      bne   delay_msec        ; 3
      rts
      .code

; Delay for almost 'A / 10' milliseconds (A * 0.099453968 msec)
; Preserved: X, Y
delay_01msec:
      pha                     ; 3
      lda   #18               ; 2
      sec                     ; 2
delay_01msec_:
      nop                     ; 2
      nop                     ; 2
      adc   #-2               ; 2
      bne   delay_01msec_     ; 3
                              ; -1
      pla                     ; 4
      clc                     ; 2
      adc   #-1               ; 2
      bne   delay_01msec      ; 3
      rts
      .code

; Delay for almost A*10 milliseconds
; Preserved: X, Y
delay_10msec:
      pha
      lda   #10
      jsr   delay_msec
      pla
      clc
      adc   #-1
      bne   delay_10msec
      rts
      .code

; Delay n clocks
; Preserved: P, A, X, Y
delay_32:   nop
delay_30:   nop
delay_28:   nop
delay_26:   nop
delay_24:   nop
delay_22:   nop
delay_20:   nop
delay_18:   nop
delay_16:   nop
delay_14:   nop
delay_12:   rts

delay_33:   nop
delay_31:   nop
delay_29:   nop
delay_27:   nop
delay_25:   nop
delay_23:   nop
delay_21:   nop
delay_19:   nop
delay_17:   beq   +     ; 5
:           bne   +
:           rts         ; 6
      .code
      
; Delay (5 * A + 6) * Y + 7 + n clocks
delay_ya11:
      .db   $a2         ; 1 ldx #imm
delay_ya10:
      .db   $a2         ; 1 ldx #imm
delay_ya9:
      .db   $a2         ; 1 ldx #imm
delay_ya8:
      .db   $a2         ; 1 ldx #imm
delay_ya7:
      .db   $a2         ; 1 ldx #imm
delay_ya6:
      .db   $a2         ; 1 ldx #imm
delay_ya5:
      .db   $a2         ; 1 ldx #imm
delay_ya4:
      .db   $a2         ; 1 ldx #imm
delay_ya3:
      .db   $a2         ; 1 ldx #imm
delay_ya2:
      .db   $a2         ; 1 ldx #imm
delay_ya1:
      .db   $a6         ; 1 ldx zp
delay_ya0:
      nop               ; 2
delay_ya:
                        ; 2 lda #
                        ; 2 ldy #
                        ; 6 jsr
      tax               ; *2
delay_yax:
      dex               ; **2
      bne   delay_yax   ; **3
                        ; *-1
      dey               ; *2
      bne   delay_ya    ; *3
                        ; -1
      rts               ; 6
      .code
