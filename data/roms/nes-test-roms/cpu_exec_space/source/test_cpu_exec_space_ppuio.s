; Expected output, and explanation:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TEST: test_cpu_exec_space
; This program verifies that the
; CPU can execute code from any
; possible location that it can
; address, including I/O space.
; 
; In addition, it will be tested
; that an RTS instruction does a
; dummy read of the byte that
; immediately follows the
; instructions.
; 
; JSR test OK
; JMP test OK
; RTS test OK
; JMP+RTI test OK
; BRK test OK
; 
; Passed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Written by Joel Yliluoma - http://iki.fi/bisqwit/

.segment "LIB"
.include "shell.inc"
.include "colors.inc"
.segment "CODE"

zp_res nmi_count
zp_res brk_issued
zp_res maybe_crashed

.macro print_str_and_ret s,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15
	print_str s,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15
	rts
.endmacro
.macro my_print_str s,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15
	.local Addr
	jsr Addr
	seg_data "RODATA",{Addr: print_str_and_ret s,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15}
.endmacro

set_vram_pos:
	ldy PPUSTATUS
	sta PPUADDR ; poke high 6 bits
	stx PPUADDR ; poke low  8 bits
	rts

test_failed_finish:
	jsr crash_proof_end
	; Re-enable screen
	jsr console_show
	text_white
	jmp test_failed

open_bus_pathological_fail:
	jmp test_failed_finish

main:   
	lda #0
	sta brk_issued

	; Operations we will be doing are:
	;
	jsr intro

	text_color2
	
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 2,"PPU  memory  access  through  $2007 does not work properly. (Use other tests to determine the exact problem.)"
	jsr console_hide
	jsr crash_proof_begin

	; Put byte $55 at $2400 and byte $AA at $2411.
	lda #$24
	ldx #$00
	jsr set_vram_pos
	ldy #$55
	sty PPUDATA
	ldx #$11
	jsr set_vram_pos
	ldy #$AA
	sty PPUDATA
	; Read from $2400 and $2411.
	lda #$24
	ldx #$00
	jsr set_vram_pos
	ldy PPUDATA ; Discard the buffered byte; load $55 into buffer.
	ldx #$11
	jsr set_vram_pos
	lda PPUDATA ; Load buffer ($55); place $AA in buffer.
	cmp #$55
	bne test_failed_finish
	lda PPUDATA ; Load buffer ($AA); place unknown in buffer.
	cmp #$AA
	bne test_failed_finish
	
	jsr crash_proof_end
	jsr console_show

	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 3,"PPU open bus  implementation  is missing  or incomplete:  A write to $2003, followed by a read from $2001 should return the same value as was written."
	jsr wait_vbl
	lda #$B2   ; sufficiently random byte.
	sta $2003  ; OAM index, but also populates open bus
	eor $2001
	bne open_bus_pathological_fail
	
	; Set VRAM address ($2411). This is the address we will be reading from, if the test worked properly.
	jsr console_hide
	jsr crash_proof_begin

	lda #$24
	ldx #$00
	jsr set_vram_pos

	; Now, set HALF of the other address ($2400). If the test did NOT work properly, this address will be read from.
	lda #$24
	sta PPUADDR

	; Poke the open bus again; it was wasted earlier.
	lda #$60   ; rts
	sta $2003  ; OAM index, but also populates open bus

	set_test 4,"The RTS  at  $2001 was  never executed."

	jsr $2001 ; should fetch opcode from $2001, and do a dummy read at $2002

	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 5,"An RTS opcode should still do a dummy  fetch  of  the  next opcode.   (The same  goes for all one-byte opcodes, really.)"

	; Poke the OTHER HALF of the address ($2411). If the RTS did a dummy read at $2002, as it should,
	; this ends up being a first HALF of a dummy address.
	lda #$11
	sta PPUADDR
	
	; Read from PPU.
	lda PPUDATA ; Discard the buffered byte; load something into buffer
	lda PPUDATA ; eject buffer. We should have $2400 contents ($55).
	pha
	 jsr crash_proof_end
	 jsr console_show
	pla
	cmp #$55
	beq passed_1
	cmp #$AA    ; $AA is the expected result if the dummy read was not implemented properly.
	beq :+
	;
	; If we got neither $55 nor $AA, there is something else wrong.
	;
	jsr print_hex
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 6,"I have no idea what happened, but the  test did not work as supposed to. In any case, the problem is in the PPU."
:	jmp test_failed_finish

passed_1:
	; ********* Do the test again, this time using JMP instead of JSR
	print_str "JSR+RTS TEST OK",newline

	jsr console_hide
	; Set VRAM address ($2411). This is the address we will be reading from, if the test worked properly.
	jsr crash_proof_begin

	lda #$24
	ldx #$00
	jsr set_vram_pos
	
	; Now, set HALF of the other address ($2400). If the test did NOT work properly, this address will be read from.
	lda #$24
	sta PPUADDR

	; Poke the open bus again; it was wasted earlier.
	lda #$60   ; rts
	sta $2003  ; OAM index, but also populates open bus
	
	jsr do_jmp_test
	; should return here!

	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 8,"Okay,  the test  passed  when JSR was  used,  but NOT  when the opcode was JMP.   How can an emulator possibly get this result? You may congratulate  yourself  now,  for  finding  something that  is even more  unconventional than this test."

	; Poke the OTHER HALF of the address ($2411). If the RTS did a dummy read at $2002, as it should,
	; this ends up being a first HALF of a dummy address.
	lda #$11
	sta PPUADDR
	
	; Read from PPU.
	lda PPUDATA ; Discard the buffered byte; load something into buffer
	lda PPUDATA ; eject buffer. We should have $2400 contents ($55).
	pha
	 jsr crash_proof_end
	 jsr console_show
	pla
	cmp #$55
	beq passed_2
	cmp #$AA    ; $AA is the expected result if the dummy read was not implemented properly.
	beq :+
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	;
	; If we got neither $55 nor $AA, there is something else wrong.
	;
	jsr print_hex
	set_test 9,"Your  PPU  is  broken in mind-defyingly random ways."
:	jmp test_failed_finish


do_jmp_test:
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 4,"The RTS  at  $2001 was  never executed."
	jmp $2001 ; should fetch opcode from $2001, and do a dummy read at $2002

passed_2:
	print_str "JMP+RTS TEST OK",newline
	; ********* Do the test once more, this time using RTS instead of JSR

	jsr console_hide
	; Set VRAM address ($2411). This is the address we will be reading from, if the test worked properly.
	jsr crash_proof_begin

	lda #$24
	ldx #$00
	jsr set_vram_pos
	
	; Now, set HALF of the other address ($2400). If the test did NOT work properly, this address will be read from.
	lda #$24
	sta PPUADDR

	; Poke the open bus again; it was wasted earlier.
	lda #$60   ; rts
	sta $2003  ; OAM index, but also populates open bus
	
	jsr do_rts_test
	; should return here!

	;            0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 11,"The test passed  when JSR was used, and when  JMP was used, but  NOT  when RTS was  used. Caught ya! Paranoia wins."

	; Poke the OTHER HALF of the address ($2411). If the RTS did a dummy read at $2002, as it should,
	; this ends up being a first HALF of a dummy address.
	lda #$11
	sta PPUADDR
	
	; Read from PPU.
	lda PPUDATA ; Discard the buffered byte; load something into buffer
	lda PPUDATA ; eject buffer. We should have $2400 contents ($55).
	pha
	 jsr crash_proof_end
	 jsr console_show
	pla
	cmp #$55
	beq passed_3
	cmp #$AA    ; $AA is the expected result if the dummy read was not implemented properly.
	beq :+
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	;
	; If we got neither $55 nor $AA, there is something else wrong.
	;
	jsr print_hex
	set_test 12,"Your PPU gave up  reason at  the last moment."
:	jmp test_failed_finish


do_rts_test:
	set_test 10,"RTS to $2001 never returned." ; This message never gets displayed.
	lda #$20
	pha
	lda #$00
	pha
	rts

passed_3:
	print_str "RTS+RTS TEST OK",newline
	; Do the second test (JMP) once more. This time, use RTI rather than RTI.

	; Set VRAM address ($2411). This is the address we will be reading from, if the test worked properly.
	jsr console_hide
	jsr crash_proof_begin

	lda #$24
	ldx #$00
	jsr set_vram_pos
	
	; Now, set HALF of the other address ($2400). If the test did NOT work properly, this address will be read from.
	lda #$24
	sta PPUADDR

	; Poke the open bus again; it was wasted earlier.
	lda #$40   ; rti
	sta $2003  ; OAM index, but also populates open bus

	set_test 13,"JMP to $2001 never returned." ; This message never gets displayed, either.

	lda #>(:+ )
	pha
	lda #<(:+ )
	pha
	php
	jmp $2001 ; should fetch opcode from $2001, and do a dummy read at $2002
:
	
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 14,"An RTI opcode should still do a dummy  fetch  of  the  next opcode.   (The same  goes for all one-byte opcodes, really.)"

	; Poke the OTHER HALF of the address ($2411). If the RTI did a dummy read at $2002, as it should,
	; this ends up being a first HALF of a dummy address.
	lda #$11
	sta PPUADDR
	
	; Read from PPU.
	lda PPUDATA ; Discard the buffered byte; load something into buffer
	lda PPUDATA ; eject buffer. We should have $2400 contents ($55).
	pha
	 jsr crash_proof_end
	 jsr console_show
	pla
	cmp #$55
	beq passed_4
	cmp #$AA    ; $AA is the expected result if the dummy read was not implemented properly.
	beq :+
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	;
	; If we got neither $55 nor $AA, there is something else wrong.
	;
	jsr print_hex
	set_test 15,"An RTI  opcode  should  not  destroy the PPU. Somehow that still appears to be the case  here."
:	jmp test_failed_finish

passed_4:
	print_str "JMP+RTI TEST OK",newline
	; ********* Do the test again, this time using BRK instead of RTS/RTI

	jsr console_hide
	jsr crash_proof_begin

	; Set VRAM address ($2411). This is the address we will be reading from, if the test worked properly.
	lda #$24
	ldx #$00
	jsr set_vram_pos
	
	; Now, set HALF of the other address ($2400). If the test did NOT work properly, this address will be read from.
	lda #$24
	sta PPUADDR

	; Poke the open bus again; it was wasted earlier.
	lda #$00   ; brk
	sta $2003  ; OAM index, but also populates open bus
	
	lda #1
	sta brk_issued
	
	set_test 17,"JSR to $2001 never returned." ; This message never gets displayed, either.
	jmp $2001
	nop
	nop
	nop
	nop
returned_from_brk:
	nop
	nop
	nop
	nop
	
	; should return here!
	;            0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 18,"The  BRK  instruction  should issue  an automatic fetch of  the byte that follows  right after the BRK.  (The same goes for all one-byte opcodes, but with BRK  it should be  a bit more obvious than with others.)"

	; Poke the OTHER HALF of the address ($2411). If the BRK did a dummy read at $2002, as it should,
	; this ends up being a first HALF of a dummy address.
	lda #$11
	sta PPUADDR
	
	; Read from PPU.
	lda PPUDATA ; Discard the buffered byte; load something into buffer
	lda PPUDATA ; eject buffer. We should have $2400 contents ($55).
	pha
	 jsr crash_proof_end
	 jsr console_show
	pla
	cmp #$55
	beq passed_5
	cmp #$AA    ; $AA is the expected result if the dummy read was not implemented properly.
	beq :+
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	;
	; If we got neither $55 nor $AA, there is something else wrong.
	;
	jsr print_hex
	set_test 19,"A  BRK  opcode  should  not  destroy the PPU. Somehow that still appears to be the case  here."
:	jmp test_failed_finish


passed_5:
	print_str "JMP+BRK TEST OK",newline
	text_white
	jsr console_show
	jsr wait_vbl
	jmp tests_passed




	.pushseg
	.segment "RODATA"
intro:	text_white
	print_str "TEST:test_cpu_exec_space_ppuio",newline
	text_color1
	jsr print_str_
	;       0123456789ABCDEF0123456789ABCD
	 .byte "This program verifies that the",newline
	 .byte "CPU can execute code from any",newline
	 .byte "possible location that it can",newline
	 .byte "address, including I/O space.",newline
	 .byte newline
	 .byte "In addition, it will be tested",newline
	 .byte "that an RTS instruction does a",newline
	 .byte "dummy read of the byte that",newline
	 .byte "immediately follows the",newline
	 .byte "instructions.",newline
	 .byte newline,0
	text_white
	rts
	.popseg


	; Prospects (bleak) of improving this test:
	;
	;    $2000 is write only (writing updates open_bus, reading returns open_bus)
	;    $2001 is write only (writing updates open_bus, reading returns open_bus)
	;    $2002 is read only  (writing updates open_bus, reading UPDATES open_bus (but only for low 5 bits))
	;    $2003 is write only (writing updates open_bus, reading returns open_bus)
	;    $2004 is read-write (writing updates open_bus, however for %4==2, bitmask=11100011. Reading is UNRELIABLE.)
	;    $2005 is write only (writing updates open_bus, reading returns open_bus)
	;    $2006 is write only (writing updates open_bus, reading returns open_bus)
	;    $2007 is read-write (writing updates open_bus, reading UPDATES open_bus)


irq:
	; Presume we got here through a BRK opcode.
	lda brk_issued
	beq spurious_irq
	cmp #1
	beq brk_successful
	; If we got a spurious IRQ, and already warned of it once, do a regular RTI
	rti
spurious_irq:
	lda #2
	sta brk_issued
	set_test 16,"IRQ occurred uncalled"
	jmp test_failed_finish
brk_successful:
	jmp returned_from_brk
	


nmi:
	pha
	 lda maybe_crashed
	 beq :+
	 inc nmi_count
	 lda nmi_count
	 cmp #4
	 bcc :+
	 jmp test_failed_finish
:
	pla
	rti

crash_proof_begin:
	lda #$FF
	sta nmi_count
	sta maybe_crashed
	
	; Enable NMI
	lda #$80
	sta $2000
	rts

crash_proof_end:
	; Disable NMI
	lda #0
	sta $2000
	sta maybe_crashed
	rts

wrong_code_executed_somewhere:
	pha
	txa
	pha
	
	text_white
	print_str "ERROR",newline
	
	text_color1
	print_str "Mysteriously Landed at $"
	pla
	jsr print_hex
	pla
	jsr print_hex
	jsr print_newline
	text_color1
	;          0123456789ABCDEF0123456789ABC|
	print_str "CPU thinks we are at:  $"
	pla
	tax
	pla
	jsr print_hex
	txa
	jsr print_hex
	;           0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|0123456789ABCDEF0123456789ABC|
	set_test 7,"A jump to $2001 should  never execute code  from  anywhere  else than $2001"
	jmp test_failed_finish

.pushseg
.segment "WRONG_CODE_8000"
	.repeat $6200/8, I
		.byt $EA
		lda #<( $8001+ 8*I)
		ldx #>( $8001+ 8*I)
		jsr wrong_code_executed_somewhere
	.endrepeat
	; CODE BEGINS AT E200
.popseg
