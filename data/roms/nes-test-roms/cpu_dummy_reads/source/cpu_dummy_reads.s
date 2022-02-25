; Tests instructions that do dummy reads before the real read/write
; Tests LDA and STA with modes (ZP,X), (ZP),Y and ABS,X
; Dummy reads are made for the following cases:
; LDA ABS,X or (ZP),Y when carry is generated from low byte
; STA ABS,X or (ZP),Y

.include "shell.inc"

.macro set_addr n
	lda #<n
	sta addr
	lda #>n
	sta addr+1
.endmacro

begin:  jsr wait_vbl
	delay 29800
	rts

main:   set_test 2,"$2002 must be mirrored every 8 bytes to $3FFA"
	jsr begin
	lda $3FFA
	jpl test_failed
	lda $3FFA
	jmi test_failed
	
	set_test 3,"LDA abs,x"
	jsr begin
	ldx #$22
	lda $2000,x     ; no dummy read
	jpl test_failed
	lda $2002
	jmi test_failed
	
	jsr begin
	ldx #$22
	lda $20E0,x     ; dummy read from $2002
	jmi test_failed
	lda $2002
	jmi test_failed
	
	jsr begin
	ldx #$22
	lda $20E2,x     ; dummy read from $2004
	lda $2002
	jpl test_failed
	
	jsr begin
	ldx #$22
	lda $3FE0,x     ; dummy read from $3F02
	lda $2002
	jmi test_failed
	
	set_test 4,"STA abs,x"
	jsr begin
	sta $2002       ; no dummy read
	lda $2002
	jpl test_failed
	
	jsr begin
	ldx #$22
	sta $20E0,x     ; dummy read from $2002
	jmi test_failed
	lda $2002
	jmi test_failed
	
	jsr begin
	ldx #$22
	sta $20E2,x     ; dummy read from $2004
	lda $2002
	jpl test_failed
	
	jsr begin
	ldx #$22
	sta $3FE0,x     ; dummy read from $3F02
	lda $2002
	jmi test_failed
	
	set_test 5,"LDA (z),y"
	jsr begin
	ldy #$22
	set_addr $2000
	lda (addr),y    ; no dummy read
	jpl test_failed
	lda $2002
	jmi test_failed
	
	jsr begin
	ldy #$22
	set_addr $20E0
	lda (addr),y    ; dummy read from $2002
	jmi test_failed
	lda $2002
	jmi test_failed
	
	jsr begin
	ldy #$22
	set_addr $20E2
	lda (addr),y    ; dummy read from $2004
	lda $2002
	jpl test_failed
	
	jsr begin
	ldy #$22
	set_addr $3FE0
	lda (addr),y    ; dummy read from $3F02
	lda $2002
	jmi test_failed
	
	set_test 6,"STA (z),y"
	jsr begin
	set_addr $20E0
	ldy #$22
	sta (addr),y    ; dummy read from $2002
	jmi test_failed
	lda $2002
	jmi test_failed
	
	jsr begin
	set_addr $20E2
	ldy #$22
	sta (addr),y    ; dummy read from $2004
	lda $2002
	jpl test_failed
	
	jsr begin
	set_addr $3FE0
	ldy #$22
	sta (addr),y    ; dummy read from $3F02
	lda $2002
	jmi test_failed

	set_test 7,"LDA (z,x)"
	jsr begin
	ldx #0
	set_addr $2002
	lda (addr,x)    ; no dummy read
	jpl test_failed
	
	set_test 8,"STA (z,x)"
	jsr begin
	ldx #0
	set_addr $2002
	sta (addr,x)    ; no dummy read
	lda $2002
	jpl test_failed
	
	jmp tests_passed
