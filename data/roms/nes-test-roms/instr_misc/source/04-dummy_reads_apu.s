; Tests dummy reads for (hopefully) ALL instructions which do them,
; including unofficial ones. Prints opcode(s) of failed
; instructions. Requires that APU implement $4015 IRQ flag reading.

.include "shell.inc"

zp_byte opcode
zp_byte errors

begin:  setb SNDMODE,0
	lda SNDCHN
	delay 30000
	setw addr,SNDCHN+3
	rts

failed:
	inc errors
	lda opcode
	jsr print_a
	jsr play_byte
	rts

.macro test_ x_, y_, instr
	.local instr_
	lda instr_
	sta opcode
	jsr begin
	ldx #x_
	ldy #y_
instr_: instr
	lda SNDCHN
	and #$40
.endmacro

.macro test_x opcode
	test_ 0,-3,{.byte opcode,<SNDCHN+3,>SNDCHN}
	beq :+
	test_ -3,0,{.byte opcode,<SNDCHN+3,>SNDCHN}
	beq :++
:       jsr failed
:
.endmacro

.macro test_y opcode
	test_ -3,0,{.byte opcode,<SNDCHN+3,>SNDCHN}
	beq :+
	test_ 0,-3,{.byte opcode,<SNDCHN+3,>SNDCHN}
	beq :++
:       jsr failed
:
.endmacro

.macro test_i opcode
	test_ -3,0,{.byte opcode,addr}
	beq :+
	test_ 0,-3,{.byte opcode,addr}
	beq :++
:       jsr failed
:
.endmacro

.macro test_xyi opcode
	test_x opcode
	test_y opcode-4
	test_i opcode-12
.endmacro

main:   
	set_test 2,"Official opcodes failed"
	
	test_xyi $1D ; ORA
	test_xyi $3D ; AND
	test_xyi $5D ; EOR
	test_xyi $7D ; ADC
	test_xyi $9D ; STA
	test_xyi $BD ; LDA
	test_xyi $DD ; CMP
	test_xyi $FD ; SBC
	
	test_x $1E ; ASL
	test_x $3E ; ROL
	test_x $5E ; LSR
	test_x $7E ; ROR
	test_x $DE ; DEC
	test_x $FE ; INC
	
	test_x $BC ; LDY
	
	test_y $BE ; LDX
	
	lda errors
	jne test_failed
	
	set_test 2,"Unofficial opcodes failed"
	
	test_x $1C ; SKW
	test_x $3C ; SKW
	test_x $5C ; SKW
	test_x $7C ; SKW
	test_x $DC ; SKW
	test_x $FC ; SKW
	
	test_xyi $1F ; ASO
	test_xyi $3F ; RLA
	test_xyi $5F ; LSE
	test_xyi $7F ; RRA
	test_xyi $DF ; DCM
	test_xyi $FF ; INS
	
	test_x $9C ; SAY
	
	test_y $BF ; LAX
	test_y $9B ; TAS
	test_y $9E ; XAS
	test_y $9F ; AXA
	test_y $BB ; LAS
	
	test_i $93 ; AXA
	test_i $B3 ; LAX
	
	lda errors
	jne test_failed
	
	jmp tests_passed
