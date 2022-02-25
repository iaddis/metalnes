; Tests immediate NMI behavior when enabling while VBL flag is already set

CUSTOM_NMI=1
.include "shell.inc"

zp_byte nmi_count

nmi:    inc nmi_count
	rti

; Waits until NMI is about to occur
begin:  lda #0
	sta $2000
	jsr wait_vbl
	delay 29600
	lda #0
	sta nmi_count
	rts

; Enables NMI, waits, then reads NMI count
end:    lda #$80
	sta $2000
	delay 200
	lda nmi_count
	rts

main:   set_test 2,"Shouldn't occur when disabled"
	jsr begin
	delay 200
	lda nmi_count
	jne test_failed
	
	set_test 3,"Should occur when enabled and VBL begins"
	jsr begin
	jsr end
	jeq test_failed
	
	set_test 4,"$2000 should be mirrored every 8 bytes"
	jsr begin
	lda #$80
	sta $2FF8
	delay 200
	lda nmi_count
	jeq test_failed
	
	set_test 5,"Should occur immediately if enabled while VBL flag is set"
	jsr begin
	delay 200       ; VBL flag set during this time
	jsr end         ; NMI is enabled here, and should occur immediately
	cmp #1
	jne test_failed
	
	set_test 6,"Shouldn't occur if enabled while VBL flag is clear"
	jsr begin
	delay 200
	lda $2002       ; clear VBL flag
	jsr end
	jne test_failed
	
	set_test 7,"Shouldn't occur again if writing $80 when already enabled"
	jsr begin
	lda #$80
	sta $2000
	delay 200       ; NMI occurs here
	jsr end         ; writes $80 again, shouldn't occur again
	cmp #1          ; only 1 NMI should have occurred
	jne test_failed
	
	set_test 8,"Shouldn't occur again if writing $80 when already enabled 2"
	jsr begin
	delay 200       ; VBL flag set during this time
	lda #$80        ; enable NMI, which should result in immediate NMI
	sta $2000
	jsr end         ; writes $80 again, shouldn't occur again
	cmp #1          ; only 1 NMI should have occurred
	jne test_failed
	
	set_test 9,"Should occur again if enabling after disabled"
	jsr begin
	lda #$80
	sta $2000
	delay 200       ; NMI occurs here
	lda #$00        ; disable NMI
	sta $2000
	jsr end         ; NMI is enabled again, and should occur immediately
	cmp #2          ; 2 NMIs should have occurred
	jne test_failed
	
	set_test 10,"Should occur again if enabling after disabled 2"
	jsr begin
	delay 200       ; VBL flag set during this time
	lda #$80        ; enable NMI, which should result in immediate NMI
	sta $2000
	lda #$00        ; disable NMI
	sta $2000
	jsr end         ; NMI is enabled again, and should occur immediately
	cmp #2          ; 2 NMIs should have occurred
	jne test_failed
	
	set_test 11,"Immediate occurence should be after NEXT instruction"
	jsr begin
	delay 200       ; VBL flag set during this time
	ldx #0
	lda #$80        ; enable NMI, which should result in immediate NMI
	sta $2000       ; after NEXT instruction
	stx nmi_count   ; clear nmi_count
	; NMI should occur here
	lda nmi_count
	jeq test_failed
	
	jmp tests_passed
