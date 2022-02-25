	enum 0
	ystart1 db 0
	ystart2 db 0
	ystart3 db 0
	yline1 db 0
	yline2 db 0
	yline3 db 0
	IRQline db 0
	fly_x db 0
	fly_y db 0
	fly_frame db 0
	light dw 0
	timingtoggle db 0
	ende
	
do_mmc5test
	lda #0
	sta fly_frame
	sta timingtoggle
	
	lda #120
	sta fly_y
	sta fly_x
	
	lda #0
	sta $5101	;CHR mode: 8k switchable
	lda #0
	sta $5127	;BG bank 0
	lda #0
	sta $512b

	lda #%00000000
	sta $5105	;mirror

	setVADDR $2000
	ldx #0
-	lda brick,x
	sta $2007
	inx
	bne -
-	lda brick+$100,x
	sta $2007
	inx
	bne -
-	lda brick+$200,x
	sta $2007
	inx
	bne -
-	lda brick+$300,x
	sta $2007
	inx
	bne -
	
	jsr clearsprites
	jsr setpal
	
	lda #$00
	sta $202
	sta $206
	lda #$01
	sta $20a
	sta $20e
	
	setNMI mmc5nmi
	
	lda #$80
	bit $2002
	sta $2000	;NMI on
	
-	jmp -

;------------------
mmc5nmi:
	jsr move_fly
	lda #2
	sta $4014	;spriteDMA

	setVADDR $3f13
	ldx #$39
	lda fly_frame
	beq +
	ldx #$19
+	stx $2007

	lda #0
	sta $2005
	sta $2005	;scroll reset
	
        jsr readjoypad
        and #joySTART
        beq +
        lda timingtoggle
        eor #1
        sta timingtoggle
+
	lda #%10100000
	sta $2000	;8x16 obj
	lda #%11111110		;2
	sta $2001	;screen on

	setIRQ mmc5irq1
	
	lda #$80	;IRQen
	 sta $5204
	lda fly_y		;IRQline
	 sta $5203	 
	 sta IRQline

	plp		;"cli"
	pla
	pla
	jmp IRQwait

move_fly
	lda fly_frame
	eor #2
	sta fly_frame
	tax
	lda anim,x
	sta $201
	lda anim+1,x
	sta $205
	lda anim+4,x
	sta $209
	lda anim+5,x
	sta $20d
	lda lighttbl,x
	sta light
	lda lighttbl+1,x
	sta light+1
	inc fly_x
	lda fly_x
	sta $203
	clc
	adc #4
	sta $20b
	clc
	adc #4
	sta $207
	clc
	adc #4
	sta $20f
	ldy fly_x
	lda div3,y
	ldx timingtoggle
	clc
	bne +
	adc #7
+	sta timingdelay
	lda tbl_sin2,y
	lsr
	adc #60
	sta $200
	sta $204
	clc
	adc #4
	sta $208
	sta $20c
	sec
	ldx fly_frame
	sbc light_y,x
	sta fly_y
	rts
light_y	dw 31,27
lighttbl
	dw light1,light2
anim db 1,3,5,7,9,11,13,15
	i = 255
div3	rept 256
        db 26+i/3
	i=i-1
        endr
;---------------
mmc5irq1		;12
	lda $5204	;4
	plp		;4
	pla		;4
	pla		;4	=28
	inc IRQline	;5
	lda IRQline	;3
	sta $5203	;4	=40
	eatcycles(113-40)
	;---
	sei		;2
	lda $5204	;4
	cli		;2



	lda timingdelay
	jsr timingloop
	jmp (light)
macro flame1(start,end,third)
	lda #%01111110		;2
	ldx #%11111110		;2
	eatcycles(start+4)
	sta $2001		;4
	eatcycles(end-start-4)
	stx $2001		;4
	eatcycles(114-end-12-third)
endm
macro flame2(start1,start2,end2,end1,third)
	lda #%01111110		;2
	ldx #%00011110		;2
	ldy #%11111110		;2
	eatcycles(start1+2)
	sta $2001		;4
	eatcycles(start2-start1-4)
	stx $2001		;4
	eatcycles(end2-start2-4)
	sta $2001		;4
	eatcycles(end1-end2-4)
	sty $2001		;4
	eatcycles(114-end1-12-third)
endm

light1
	flame1(17,24,0)
	flame1(15,26,0)
	flame1(13,28,1)
	flame1(12,29,0)
	flame1(11,30,0)
	flame1(10,31,1)
	flame1(9,32,0)
	flame1(8,33,0)
	flame1(7,34,1)
	flame1(7,34,0)
	flame1(6,35,0)
	flame1(6,35,1)
	flame1(5,36,0)
	flame1(5,36,0)
	flame1(4,37,1)
	flame1(4,37,0)
	flame1(3,38,0)
	flame2(3,18,24,38,1)
	flame2(3,16,25,38,0)
	flame2(2,15,26,39,0)
	flame2(2,14,27,39,1)
	flame2(2,13,28,39,0)
	flame2(2,13,28,39,0)
	flame2(1,12,29,40,1)
	flame2(1,11,30,40,0)
	flame2(1,11,30,40,0)
	flame2(1,11,30,40,1)
	flame2(1,10,31,40,0)
	flame2(1,10,31,40,0)
	flame2(0,10,31,41,1)
	flame2(0,10,31,41,0)
	flame2(0,9,32,41,0)
	flame2(0,9,32,41,1)
	flame2(0,9,32,41,0)
	flame2(0,9,32,41,0)
	flame2(0,9,32,41,1)
	 flame2(0,9,32,41,0)
	flame2(0,9,32,41,0)
	flame2(0,9,32,41,1)
	flame2(0,9,32,41,0)
	flame2(0,9,32,41,0)
	flame2(0,9,32,41,1)
	flame2(0,10,31,41,0)
	flame2(0,10,31,41,0)
	flame2(1,10,31,40,1)
	flame2(1,10,31,40,0)
	flame2(1,11,30,40,0)
	flame2(1,11,30,40,1)
	flame2(1,11,30,40,0)
	flame2(1,12,29,40,0)
	flame2(2,13,28,39,1)
	flame2(2,13,28,39,0)
	flame2(2,14,27,39,0)
	flame2(2,15,26,39,1)
	flame2(3,16,25,38,0)
	flame2(3,18,24,38,0)
	flame1(3,38,1)
	flame1(4,37,0)
	flame1(4,37,0)
	flame1(5,36,1)
	flame1(5,36,0)
	flame1(6,35,0)
	flame1(6,35,1)
	flame1(7,34,0)
	flame1(7,34,0)
	flame1(8,33,1)
	flame1(9,32,0)
	flame1(10,31,0)
	flame1(11,30,1)
	flame1(12,29,0)
	flame1(13,28,0)
	flame1(15,26,1)
	flame1(17,24,0)
-	jmp -
light2
	flame1(17,24,0)
	flame1(15,26,0)
	flame1(13,28,1)
	flame1(12,29,0)
	flame1(11,30,0)
	flame1(10,31,1)
	flame1(9,32,0)
	flame1(8,33,0)
	flame1(7,34,1)
	flame1(7,34,0)
	flame1(6,35,0)
	flame1(6,35,1)
	flame1(5,36,0)
	flame1(5,36,0)
	flame1(4,37,1)
	flame2(4,18,24,37,0)
	flame2(4,16,25,37,0)
	flame2(3,15,26,38,1)
	flame2(3,14,27,38,0)
	flame2(3,14,27,38,0)
	flame2(2,13,28,39,1)
	flame2(2,12,29,39,0)
	flame2(2,12,29,39,0)
	flame2(2,12,29,39,1)
	flame2(2,11,30,39,0)
	flame2(1,11,30,40,0)
	flame2(1,11,30,40,1)
	flame2(1,10,31,40,0)
	flame2(1,10,31,40,0)
	flame2(1,10,31,40,1)
	flame2(1,10,31,40,0)
	flame2(1,10,31,40,0)
	 flame2(1,10,31,40,1)
	flame2(1,10,31,40,0)
	flame2(1,10,31,40,0)
	flame2(1,10,31,40,1)
	flame2(1,10,31,40,0)
	flame2(1,10,31,40,0)
	flame2(1,11,30,40,1)
	flame2(1,11,30,40,0)
	flame2(2,11,30,39,0)
	flame2(2,12,29,39,1)
	flame2(2,12,29,39,0)
	flame2(2,12,29,39,0)
	flame2(2,13,28,39,1)
	flame2(3,14,27,38,0)
	flame2(3,14,27,38,0)
	flame2(3,15,26,38,1)
	flame2(4,16,25,37,0)
	flame2(4,18,24,37,0)
	flame1(4,37,1)
	flame1(5,36,0)
	flame1(5,36,0)
	flame1(6,35,1)
	flame1(6,35,0)
	flame1(7,34,0)
	flame1(7,34,1)
	flame1(8,33,0)
	flame1(9,32,0)
	flame1(10,31,1)
	flame1(11,30,0)
	flame1(12,29,0)
	flame1(13,28,1)
	flame1(15,26,0)
	flame1(17,24,0)

-	jmp -
;---
setpal
	lda #$3f	;set palette
	sta $2006
	lda #$00
	sta $2006
	ldx #0
-	lda pal,x
	sta $2007
	inx
	cpx #32
	bne -
	rts

pal	dc.b $0d,$1d,$05,$07, $0d,$0d,$11,$31, $0d,$0d,$13,$33, $0d,$0d,$19,$39
	dc.b $0d,$10,$18,$39, $0d,$0d,$0d,$0d, $0d,$0d,$0d,$0d, $0d,$0d,$0d,$0d

	align $100
brick	incbin mmc5test\brick.nam
	incbin mmc5test\brick.atr