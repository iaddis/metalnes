.define color2 $A0
.define color1 $40
.define color3 $E0

zp_res color_ptr,2

.pushseg
.segment "RODATA"
Color1Esc: .byte 27, "[0;33m", 0
Color2Esc: .byte 27, "[1;34m", 0
Color3Esc: .byte 27, "[0;37m", 0
.segment "LIB"

TextColor1:
	pha
	setw color_ptr, Color1Esc
	lda #color1
	bne ColorPrint_Sub
TextColor2:
	pha
	setw color_ptr, Color2Esc
	lda #color2
	bne ColorPrint_Sub
TextColor3:
	pha
	setw color_ptr, Color3Esc
	lda #color3
ColorPrint_Sub:
	sta text_color
	tya
	pha
	 ldy #0
@loop:
	 lda (color_ptr),y
	 beq :+
	  jsr write_text_out
	  incw color_ptr
	  bne @loop
:	pla
	tay
	pla
	rts
	


.popseg



.macro text_color1
	jsr TextColor1
.endmacro
.macro text_color2
	jsr TextColor2
.endmacro
.macro text_white
	jsr TextColor3
.endmacro

