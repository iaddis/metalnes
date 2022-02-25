      .include "delays.a"
      .include "serial.a"
      .include "debug.a"
      .include "ppu_util.a"
      
debug_newline:
      lda   #13
debug_char:
debug_char_no_wait:
      jmp   serial_write
      .code

init_runtime:
      rts
      .code
      
forever:
      jmp   $0700
      .code
      
      .default main = reset
      
      .org $fffa
      .dw   nmi
      .dw   main
      .dw   irq
