; Tests instruction timing for all except the 8 branches and 12 halts
;
; Times each instruction by putting it in a loop that counts iterations
; and waits for APU length counter to expire.

CUSTOM_IRQ=1
.include "shell.inc"

zp_byte nothing_failed
zp_byte test_index
zp_byte type_mask
zp_byte saved_sp
stack_copy = $600       ; stack is copied here during instruction test
test_opcode = $705      ; test loop is copied here
irq = test_opcode+2

main:
	print_str "Instruction timing test",{newline,newline}
	print_str "Takes about 25 seconds. "
	print_str "Doesn't time the 8 branches "
	print_str "and 12 illegal instructions.",{newline,newline}
	
	set_test 5,"Timing of APU length period, INC zp, LDA abs, AND #imm, or BNE (taken) is wrong."
	lda #$29
	sta test_index
	jsr time_instr
	cmp #2
	jne test_failed
	
	set_test 0
	
	print_str "Official instructions...",newline
	lda #0
	jsr test_instrs
	bne :+
	set_test 2,"Official instruction timing is wrong"
:       
	print_str {newline,"NOPs and alternate SBC...",newline}
	lda #$80
	jsr test_instrs
	bne :+
	set_test 3,"NOPs and alternate SBC timing is wrong"
:       
	print_str {newline,"Unofficial instructions...",newline}
	lda #$40
	jsr test_instrs
	bne :+
	set_test 4,"Unofficial instruction timing is wrong"
:       
	jmp tests_done
	
	
; A -> Type to test
test_instrs:
	sta type_mask
	setb nothing_failed,1
	
	setb test_index,0
@loop:  ldx test_index
	lda instr_types,x
	and #$F0
	cmp type_mask
	bne :+
	jsr avoid_silent_nsf
	jsr @test_instr
:       inc test_index
	bne @loop
	
	lda nothing_failed
	ora test_code
	rts


; Tests current instruction in normal and page cross cases
@test_instr:    
	; No page crossing
	lda #2
	jsr time_instr
	ldy test_index
	eor instr_times,y
	beq :+
	
	jsr print_failed_instr
	jsr print_newline
	
	lda instr_times,y
	cmp instr_times_cross,y
	bne :+ ; test again only if page crossing time is different
	rts
	
	; Page crossing
:       lda #3
	jsr time_instr
	ldy test_index
	eor instr_times_cross,y
	beq :+
	
	jsr print_failed_instr
	print_str " (cross)",newline
:       rts


; Prints failed instruction times
; A -> Actual XOR correct
; X -> Actual
; Preserved: Y
print_failed_instr:
	pha
	lda test_index
	jsr print_hex
	jsr play_byte
	print_str " was "
	txa
	jsr print_dec
	pla
	print_str ", should be "
	stx temp
	eor temp
	jsr print_dec
	setb nothing_failed,0
	rts


; Times a single instruction
; test_index -> Opcode of instruction
; A -> Byte to load into X and Y before running instruction
; X, A <- Cycles instruction took
.align 256
time_instr:
	sta temp
	ldy test_index
	sty test_opcode
	
	; Copy test_opcode to RAM
	lda instr_types,y
	and #$07
	asl a
	tay
	lda test_addrs-2,y
	sta addr
	lda test_addrs-1,y
	sta addr+1
	ldy #1
:       lda (addr),y
	sta test_opcode,y
	iny
	cpy #16
	bne :-
	
	; Save copy of stack
	tsx
	stx saved_sp
:       lda $100,x
	sta stack_copy,x
	inx
	bne :-
	
	; Set zero-page values so the addressing modes use the following
	; when X and Y = $02/$03
	; zp            $FD
	; zp,x          $FF/$00
	; abs           $03FD
	; abs,x/y       $03FF/$0400
	; (ind,x)       $02FD/$0302
	; (ind),y       $02FF/$0300
	; JMP (ind)     test_opcode+3
	setb <$00,$02
	setb <$01,$03
	setb <$FD,$FD
	setb <$FE,$02
	setb <$FF,$FD
	lda temp        ; $A3 LAX (ab,X) will load X from these two
	sta $02FD
	sta $0302
	setw $03FD,test_opcode+3 ; JMP ($03FD) will use this address
	
	; Fill stack for RTS/RTI test
	ldx #$FF
	txs
	inx
	lda #>test_opcode
:       pha
	inx
	bne :-
	
	; Setup registers
	lda temp
	tay
	tax
	setb temp,0

	; Synchronize with APU length counter
	setb SNDMODE,$40
	setb SNDCHN,$01
	setb $4000,$10
	setb $4001,$7F
	setb $4002,$FF
	setb $4003,$18
	lda #$01
:       and SNDCHN
	bne :-
	
	; Setup length counter
	setb $4003,$18
	
	; ~26323 delay, so length counter will be ~3500 cycles from expiring
	setb temp3,-13
	setb temp2,-207
:       inc temp2
	bne :-
	inc temp3
	bne :-
	
	; Run instruction
	jmp test_opcode
	
raw_to_cycles: ; entry i is lowest value that qualifies for i cycles
	.byte 241, 226, 212, 200, 189, 179, 171, 163, 156, 149, 0

; Jumps here when instruction has been timed
instr_done:
	; Restore things in case instruction affected them
	sei
	cld
	
	; Convert iteration count to cycle count
	lda temp
	ldy #-1
:       iny
	cmp raw_to_cycles,y
	blt :-
	
	; Convert 10+ to 0
	cpy #10
	blt :+
	ldy #0
:       
	; Restore stack
	ldx saved_sp
	txs
:       lda stack_copy,x
	sta $100,x
	inx
	bne :-
	
	tya
	tax
	
	rts

.macro instr_template instr
:       instr
	inc temp
	lda SNDCHN
	and #$01
	bne :-
	jmp instr_done
.endmacro

test_1: instr_template nop
test_2: instr_template sta <$FD
test_3: instr_template sta $03FD
test_4: instr_template jmp test_opcode+3

test_addrs:
	.word test_1, test_2, test_3, test_4
	
; $8n = unofficial NOPs and $EB equivalent of SBC #imm
; $4n = all other unofficial opcodes
; $0n = official opcodes
; -1  = not tested
; n   = instruction length
instr_types:
	    ;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
	.byte   2,  2, -1,$42,$82,  2,  2,$42,  1,  2,  1,$42,$83,  3,  3,$43 ; 0
	.byte  -1,  2, -1,$42,$82,  2,  2,$42,  1,  3,$81,$43,$83,  3,  3,$43 ; 1
	.byte   4,  2, -1,$42,  2,  2,  2,$42,  1,  2,  1,$42,  3,  3,  3,$43 ; 2
	.byte  -1,  2, -1,$42,$82,  2,  2,$42,  1,  3,$81,$43,$83,  3,  3,$43 ; 3
	.byte   2,  2, -1,$42,$82,  2,  2,$42,  1,  2,  1,$42,  4,  3,  3,$43 ; 4
	.byte  -1,  2, -1,$42,$82,  2,  2,$42,  1,  3,$81,$43,$83,  3,  3,$43 ; 5
	.byte   3,  2, -1,$42,$82,  2,  2,$42,  1,  2,  1,$42,  3,  3,  3,$43 ; 6
	.byte  -1,  2, -1,$42,$82,  2,  2,$42,  1,  3,$81,$43,$83,  3,  3,$43 ; 7
	.byte $82,  2,$82,$42,  2,  2,  2,$42,  1,$82,  1,$42,  3,  3,  3,$43 ; 8
	.byte  -1,  2, -1,$42,  2,  2,  2,$42,  1,  3,  1,$43,$43,  3,$43,$43 ; 9
	.byte   2,  2,  2,$42,  2,  2,  2,$42,  1,  2,  1,$42,  3,  3,  3,$43 ; A
	.byte  -1,  2, -1,$42,  2,  2,  2,$42,  1,  3,  1,$43,  3,  3,  3,$43 ; B
	.byte   2,  2,$82,$42,  2,  2,  2,$42,  1,  2,  1,$42,  3,  3,  3,$43 ; C
	.byte  -1,  2, -1,$42,$82,  2,  2,$42,  1,  3,$81,$43,$83,  3,  3,$43 ; D
	.byte   2,  2,$82,$42,  2,  2,  2,$42,  1,  2,  1,$82,  3,  3,  3,$43 ; E
	.byte  -1,  2, -1,$42,$82,  2,  2,$42,  1,  3,$81,$43,$83,  3,  3,$43 ; F
	   ;   Bxx    HLT

; Clocks when no page crossing occurs
instr_times:
	    ; 0 1 2 3 4 5 6 7 8 9 A B C D E F
	.byte 7,6,0,8,3,3,5,5,3,2,2,2,4,4,6,6 ; 0
	.byte 0,5,0,8,4,4,6,6,2,4,2,7,4,4,7,7 ; 1
	.byte 6,6,0,8,3,3,5,5,4,2,2,2,4,4,6,6 ; 2
	.byte 0,5,0,8,4,4,6,6,2,4,2,7,4,4,7,7 ; 3
	.byte 6,6,0,8,3,3,5,5,3,2,2,2,3,4,6,6 ; 4
	.byte 0,5,0,8,4,4,6,6,2,4,2,7,4,4,7,7 ; 5
	.byte 6,6,0,8,3,3,5,5,4,2,2,2,5,4,6,6 ; 6
	.byte 0,5,0,8,4,4,6,6,2,4,2,7,4,4,7,7 ; 7
	.byte 2,6,2,6,3,3,3,3,2,2,2,2,4,4,4,4 ; 8
	.byte 0,6,0,6,4,4,4,4,2,5,2,5,5,5,5,5 ; 9
	.byte 2,6,2,6,3,3,3,3,2,2,2,2,4,4,4,4 ; A
	.byte 0,5,0,5,4,4,4,4,2,4,2,4,4,4,4,4 ; B
	.byte 2,6,2,8,3,3,5,5,2,2,2,2,4,4,6,6 ; C
	.byte 0,5,0,8,4,4,6,6,2,4,2,7,4,4,7,7 ; D
	.byte 2,6,2,8,3,3,5,5,2,2,2,2,4,4,6,6 ; E
	.byte 0,5,0,8,4,4,6,6,2,4,2,7,4,4,7,7 ; F
	
; Clocks when page crossing occurs
instr_times_cross:
	    ; 0 1 2 3 4 5 6 7 8 9 A B C D E F
	.byte 7,6,0,8,3,3,5,5,3,2,2,2,4,4,6,6 ; 0
	.byte 0,6,0,8,4,4,6,6,2,5,2,7,5,5,7,7 ; 1
	.byte 6,6,0,8,3,3,5,5,4,2,2,2,4,4,6,6 ; 2
	.byte 0,6,0,8,4,4,6,6,2,5,2,7,5,5,7,7 ; 3
	.byte 6,6,0,8,3,3,5,5,3,2,2,2,3,4,6,6 ; 4
	.byte 0,6,0,8,4,4,6,6,2,5,2,7,5,5,7,7 ; 5
	.byte 6,6,0,8,3,3,5,5,4,2,2,2,5,4,6,6 ; 6
	.byte 0,6,0,8,4,4,6,6,2,5,2,7,5,5,7,7 ; 7
	.byte 2,6,2,6,3,3,3,3,2,2,2,2,4,4,4,4 ; 8
	.byte 0,6,0,6,4,4,4,4,2,5,2,5,5,5,5,5 ; 9
	.byte 2,6,2,6,3,3,3,3,2,2,2,2,4,4,4,4 ; A
	.byte 0,6,0,6,4,4,4,4,2,5,2,5,5,5,5,5 ; B
	.byte 2,6,2,8,3,3,5,5,2,2,2,2,4,4,6,6 ; C
	.byte 0,6,0,8,4,4,6,6,2,5,2,7,5,5,7,7 ; D
	.byte 2,6,2,8,3,3,5,5,2,2,2,2,4,4,6,6 ; E
	.byte 0,6,0,8,4,4,6,6,2,5,2,7,5,5,7,7 ; F
