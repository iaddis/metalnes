; Tests sprite RAM access via $2003, $2004, and $4014

      .include "prefix_ppu.a"

sprites = $200

reset:
      lda   #50
      jsr   delay_msec
      
      jsr   wait_vbl
      lda   #0
      sta   $2000
      sta   $2001
      
      lda   #2;) Basic read/write doesn't work
      sta   result
      lda   #0
      sta   $2003
      lda   #$12
      sta   $2004
      lda   #0
      sta   $2003
      lda   $2004
      cmp   #$12
      jsr   error_if_ne
      
      lda   #3;) Address should increment on $2004 write
      sta   result
      lda   #0
      sta   $2003
      lda   #$12
      sta   $2004
      lda   #$34
      sta   $2004
      lda   #1
      sta   $2003
      lda   $2004
      cmp   #$34
      jsr   error_if_ne
      
      lda   #4;) Address should not increment on $2004 read
      sta   result
      lda   #0
      sta   $2003
      lda   #$12
      sta   $2004
      lda   #$34
      sta   $2004
      lda   #0
      sta   $2003
      lda   $2004
      lda   $2004
      cmp   #$34
      jsr   error_if_eq
      
      lda   #5;) Third sprite bytes should be masked with $e3 on read 
      sta   result
      lda   #3
      sta   $2003
      lda   #$ff
      sta   $2004
      lda   #3
      sta   $2003
      lda   $2004
      cmp   #$e3
      jsr   error_if_eq
      
      lda   #6;) $4014 DMA copy doesn't work at all
      sta   result
      ldx   #0          ; set up data to copy from
:     lda   test_data,x
      sta   sprites,x
      inx
      cpx   #4
      bne   -
      lda   #0          ; dma copy
      sta   $2003
      lda   #$02
      sta   $4014
      ldx   #0          ; set up data to copy from
:     stx   $2003
      lda   $2004
      cmp   test_data,x
      jsr   error_if_ne
      inx
      cpx   #4
      bne   -
      
      lda   #7;) $4014 DMA copy should start at value in $2003 and wrap
      sta   result
      ldx   #0          ; set up data to copy from
:     lda   test_data,x
      sta   sprites,x
      inx
      cpx   #4
      bne   -
      lda   #1          ; dma copy
      sta   $2003
      lda   #$02
      sta   $4014
      ldx   #1          ; set up data to copy from
:     stx   $2003
      lda   $2004
      cmp   sprites - 1,x
      jsr   error_if_ne
      inx
      cpx   #5
      bne   -
      
      lda   #8;) $4014 DMA copy should leave value in $2003 intact
      sta   result
      lda   #1          ; dma copy
      sta   $2003
      lda   #$02
      sta   $4014
      lda   #$ff
      sta   $2004
      lda   #1
      sta   $2003
      lda   $2004
      cmp   #$ff
      jsr   error_if_ne
      
      lda   #1;) Tests passed
      sta   result
      jmp   report_final_result
      
test_data:
      .db   $12,$82,$e3,$78
      