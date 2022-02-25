
; Same as sync_ppu_20 plus next frame is odd (clock subtracted) or even
; (no clock subtracted).
sync_ppu_odd_20:
      lda   #$80
      bne   sync_ppu_frame_
sync_ppu_even_20:
      lda   #$00
sync_ppu_frame_:
      pha
      ; Synchronize with PPU
      jsr   sync_ppu_20 ; synchronize with PPU
      
      ; Run for two frames with BG enabled. One of the two frames will
      ; be one PPU clock shorter. Note whether the first frame was the
      ; shorter one.
      
      lda   #$08        ; 6 enable bg
      sta   $2001
      ldy   #41         ; 29785 delay
      lda   #144
      jsr   delay_ya2
      nop               ; 2 delay
      pla               ; 4
      eor   $2002       ; 4 find whether frame was odd or even
      pha               ; 3
                        ; run another enabled frame so that clock will
                        ; have been subtracted on one of the two frames
      ldy   #43         ; 29730+ delay
      lda   #137        
      jsr   delay_ya1
      lda   #$00        ; 6 disable bg
      sta   $2001
      
      ; If the first frame was shorter, wait three frames to switch
      ; the even/odd synchronization without changing the CPU clock's
      ; synchronization with the PPU clock.
      
      pla               ; 4
      pha               ; 3
      bpl   +           ; 3
                        ; -1
      ldy   #75         ; 89343 delay
      lda   #237        
      jsr   delay_ya1
:     pla               ; 4
      rts               ; 6
      .code

; After return, 30 clocks until VBL flag will read
; as set, then 29781, then 29780. Turns PPU
; rendering, NMI, IRQ, and DMC off.
sync_ppu_align2_30:
      pha
      txa
      pha
      tya
      pha
      lda   #0          ; disable dmc and irq
      sta   $4015
      sei
      jsr   wait_vbl
      lda   #0          ; disable bg and nmi
      sta   $2000
      sta   $2001

      bit   $2002
:     bit   $2002       ; 1
      bpl   -           ; 2
      
      ldy   #141        ; 29774 delay
      lda   #41         
      jsr   delay_ya6
      
:     ldy   #86         ; 29774 delay
      lda   #68         
      jsr   delay_ya1

      bit   $2002       ; 1
      bpl   -           ; 2

      ldy   #28         ; 29726 delay
      lda   #211        
      jsr   delay_ya1
      
      pla               ; 16
      tay
      pla
      tax
      pla
      
      rts               ; 6
      .code
      
sync_ppu_align1_30:
      jsr   sync_ppu_align2_30
      ldy   #86         ; 29775 delay
      lda   #68         
      jsr   delay_ya2
      rts
      .code

sync_ppu_align1_31:
      jsr   sync_ppu_align2_30
      ldy   #86         ; 29774 delay
      lda   #68         
      jsr   delay_ya1
      rts
      .code

sync_ppu_align0_30:
      jsr   sync_ppu_align1_30
      ldy   #86         ; 29774 delay
      lda   #68         
      jsr   delay_ya1
      rts
      .code

sync_ppu_20:
      jsr   sync_ppu_align2_30
      nop               ; 4
      nop
      rts               ; 6
      .code
