; Tests some instructions that do dummy reads before the real read/write.
; Doesn't test all instructions.
;
; Tests LDA and STA with modes (ZP,X), (ZP),Y and ABS,X
; Dummy reads for the following cases are tested:
;
; LDA ABS,X or (ZP),Y when carry is generated from low byte
; STA ABS,X or (ZP),Y
; ROL ABS,X always

.include "shell.inc"

no_read:
	lda PPUSTATUS
single_read:
	jpl test_failed
dummy_read:
	lda PPUSTATUS
double_read:
	jmi test_failed
	lda PPUSTATUS
	jmi test_failed
begin:  jsr wait_vbl
	delay PPU_FRAMELEN + 20
	ldx #$22
	ldy #$22
	rts

main:   jsr begin
	
	set_test 2,"Test requires $2002 mirroring every 8 bytes to $3FFA"
	lda $3FFA
	jsr single_read
	
	set_test 3,"LDA abs,x"
	lda $2000,x     ; $2022
	jsr single_read
	lda $20E0,x     ; $2002, $2102
	jsr double_read
	lda $20E2,x     ; $2004, $2104
	jsr no_read
	lda $3FE0,x     ; $3F02, $4002
	jsr dummy_read
	
	set_test 4,"STA abs,x"
	sta $2002
	jsr no_read
	sta $20E0,x     ; $2002, $2102 (write)
	jsr dummy_read
	sta $20E2,x     ; $2004, $2104 (write)
	jsr no_read
	sta $3FE0,x     ; $3F02, $4002 (write)
	jsr dummy_read
	
	set_test 5,"LDA (z),y"
	setw addr,$2000
	lda (addr),y    ; $2022
	jsr single_read
	setw addr,$20E0
	lda (addr),y    ; $2002, $2102
	jsr double_read
	setw addr,$20E2
	lda (addr),y    ; $2004, $2104
	jsr no_read
	setw addr,$3FE0
	lda (addr),y    ; $3F02, $4002
	jsr dummy_read
	
	set_test 6,"STA (z),y"
	setw addr,$20E0
	sta (addr),y    ; $2002, $2102 (write)
	jsr dummy_read
	setw addr,$20E2
	sta (addr),y    ; $2004, $2104 (write)
	jsr no_read
	setw addr,$3FE0
	sta (addr),y    ; $3F02, $4002 (write)
	jsr dummy_read

	set_test 7,"LDA (z,x)"
	ldx #0
	setw addr,$2002
	lda (addr,x)    ; no dummy read
	jsr single_read
	
	set_test 8,"STA (z,x)"
	ldx #0
	setw addr,$2002
	sta (addr,x)    ; no dummy read
	jsr no_read
	
	set_test 9,"ROL abs"
	rol $2022       ; $2022
	ror a
	jsr single_read
	
	set_test 10,"ROL abs,x"
	rol $2000,x     ; $2022, $2022
	ror a
	jsr double_read
	rol $3FE0,x     ; $3F02, $4002
	jsr dummy_read
	
	jmp tests_passed
