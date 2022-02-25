; Text output as expanding zero-terminated string at text_out_base

; The final exit result byte is written here
final_result = $6000

; Text output is written here as an expanding
; zero-terminated string
text_out_base = $6004

bss_res text_out_temp
zp_res text_out_addr,2

init_text_out:
	ldx #0
	
	; Executing from $6000 already
	lda #>init_text_out
	bpl :+
	
	; Disable if there's no RAM there
	lda $6000
	eor #$FF
	sta $6000
	cmp $6000
	bne :+
	
	; Disable if changes to $6000 affect $E000,
	; as on my devcart
	ldy $E000
	eor #$FF
	sta $6000       ; restore original data in RAM
	cpy $E000       ; see if $E000 changed as well
	bne :+
	
	; Terminate output string
	setb text_out_base,0
	
	setb final_result,$80
	
	; Signature that tells emulator data is valid
	setb text_out_base-3,$DE
	setb text_out_base-2,$B0
	setb text_out_base-1,$61
	
	ldx #>text_out_base
:       stx text_out_addr+1
	setb text_out_addr,<text_out_base
	rts


; Sets final result byte in memory
set_final_result:
	sta final_result
	rts


; Writes character to text output
; A -> Character to write
; Preserved: A, X, Y
write_text_out:
	sty text_out_temp
	
	ldy text_out_addr+1
	beq @off
	
	; Write new terminator FIRST, then new char before it,
	; in case emulator looks at string in middle of this routine.
	ldy #1
	pha
	lda #0
	sta (text_out_addr),y
	dey
	pla
	sta (text_out_addr),y
	
	inc text_out_addr
	bne :+
	inc text_out_addr+1
:       
@off:
	ldy text_out_temp
	rts
