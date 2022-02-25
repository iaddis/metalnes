;
; NES sound testing program
; Written by SnowBro <kentmhan@online.no>
;
; Yep, I know there's a program similar to this already around, but I
; wanted to write one on my own. Partly to try and figure out more about
; how the NES sound registers work, and partly to get some experience
; with 6502 programming, which I'm pretty rusty at. I tried to keep the
; code small, but was a bit lazy here and there. Same goes for the lacking
; comments in some areas. The font was disrespectfully ripped from
; Castlevania 3.
;
; This code hasn't been tested on a real NES, so I don't know if it will
; work properly (sigh). If anyone has the chance to try it, please report
; back to me. It has been tested with most reliable NES emulators and
; should work fine on them.
;
; The program is simple: it lets you set individual bits of the NES sound
; registers for each channel and then test the output.
; The joypad buttons do the following:
;
;       Select:     Select channel
;       Up/Down:    Select register of current channel
;       Right/Left: Select bit of current register
;       A:          Toggle current bit
;       Start:      Play channel
;
; The code was assembled with X816, a great S/NES assembler by minus.
; Modify the code as you wish.
;
; Check out my webpage at http://home.sol.no/~kenhanse/nes/ for some
; of the other stuff I've written.
;
; Kent Hansen 01/01/99
;

.mem 8
.index 8
.org $C000

;------------------------------[ Define stuff ]-------------------------------

RIGHT_BUTTON    EQU %00000001
LEFT_BUTTON     EQU %00000010
DOWN_BUTTON     EQU %00000100
UP_BUTTON       EQU %00001000
START_BUTTON    EQU %00010000
SELECT_BUTTON   EQU %00100000
B_BUTTON        EQU %01000000
A_BUTTON        EQU %10000000

; Zero page addresses for where to store data

SND_REGS        EQU     $00     ; data for 4 channels, 4 bytes each
CUR_CHN         EQU     $10     ; current channel (0...3)
CUR_REG         EQU     $11     ; current register of channel (0...3)
CUR_BIT         EQU     $12     ; current bit of register
JOY_STAT        EQU     $FC     ; byte containing status of joypad
OLD_STAT        EQU     $FD     ; joypad status from previous refresh
ADDR_LO         EQU     $FE
ADDR_HI         EQU     $FF

;---------------------------[ Create font table ]-----------------------------

.asctable
cleartable
20h      = 00h
"A".."Z" = 01h
"0".."9" = 20h
":"      = 2Ah
.end

;---------------------------------[ Data ]------------------------------------

chn_text        .asc "CHANNEL: 0"
                .db 0FFh

palette         .db 0Fh,0Fh,0Fh,20h
                .db 0Fh,0Fh,0Fh,20h
                .db 0Fh,0Fh,0Fh,20h
                .db 0Fh,0Fh,0Fh,20h

                .db 0Fh,0Fh,0Fh,20h
                .db 0Fh,0Fh,0Fh,20h
                .db 0Fh,0Fh,0Fh,20h
                .db 0Fh,0Fh,0Fh,20h

;---------------------------------[ Code ]------------------------------------

reset:
cld             ; clear decimal mode
sei             ; disable interrupts
lda     #$00
sta     $2000   ; disable various stuff
sta     $2001   ; ditto
ldx     #$FF
txs             ; set stack pointer

jsr     clear_ram
jsr     wait_vblank
jsr     set_palette
jsr     clear_nametable
jsr     setup_screen ; writes some text info to the name table

lda     #%00011110
sta     $2001   ; enable bg & sprites

lda     #%10000000
sta     $2000   ; enable NMI

main_loop:
lda     #$00
sta     $2005   ; hscroll = 0
sta     $2005   ; vscroll = 0
jsr     wait_vblank
jsr     print_regs      ; print the regs in binary format
jsr     set_cursors     ; show the ChannelCursor and BitCursor

; the next piece of code handles button presses

lda     #RIGHT_BUTTON
and     JOY_STAT
beq     +
and     OLD_STAT ; If this AND results in a non-zero result, it means
bne     +        ;  the button was pressed last refresh too, so do nothing.
jsr     b0       ; Do appropriate action for this button
+       ; Repeat for the other 7 buttons...
lda     #LEFT_BUTTON
and     JOY_STAT
beq     +
and     OLD_STAT
bne     +
jsr     b1
+
lda     #DOWN_BUTTON
and     JOY_STAT
beq     +
and     OLD_STAT
bne     +
jsr     b2
+
lda     #UP_BUTTON
and     JOY_STAT
beq     +
and     OLD_STAT
bne     +
jsr     b3
+
lda     #START_BUTTON
and     JOY_STAT
beq     +
and     OLD_STAT
bne     +
jsr     b4
+
lda     #SELECT_BUTTON
and     JOY_STAT
beq     +
and     OLD_STAT
bne     +
jsr     b5
+
lda     #A_BUTTON
and     JOY_STAT
beq     +
and     OLD_STAT
bne     +
jsr     b6
+
lda     #B_BUTTON
and     JOY_STAT
beq     +
and     OLD_STAT
bne     +
jsr     b7
+

-                       ; This code is NESticle-specific, as NESticle
lda     $2002           ;  doesn't seem to reset the 7th bit of $2002 when
bmi     -               ;  it's read, only when the VBlank is actually over.
                        ;  The program is buggy in NESticle if I remove this
                        ;  loop.
jmp     main_loop

;-----------------------------------------------------------------------------

b0:
dec     CUR_BIT
lda     CUR_BIT
and     #$07
sta     CUR_BIT
rts

b1:
inc     CUR_BIT
lda     CUR_BIT
and     #$07
sta     CUR_BIT
rts

b2:
inc     CUR_REG
lda     CUR_REG
and     #$03
sta     CUR_REG
rts

b3:
dec     CUR_REG
lda     CUR_REG
and     #$03
sta     CUR_REG
rts

b4:
lda     #$01
ldx     CUR_CHN
beq     +
-
asl
dex
bne     -
+
sta     $4015   ; enable sound channel

ldy     #$10
ldx     #$00
-
lda     SND_REGS,x
sta     $4000,x
inx
dey
bne     -
rts

b5:
inc     CUR_CHN
lda     CUR_CHN
and     #$03
sta     CUR_CHN

lda     #$20
sta     $2006
lda     #$69
sta     $2006
lda     CUR_CHN
ora     #$20
sta     $2007
rts

b6:
lda     #$01
ldx     CUR_BIT
beq     +
clc
-
asl
dex
bne     -
+
pha
lda     CUR_CHN
asl
asl
clc
adc     CUR_REG
tax
pla
eor     SND_REGS,x
sta     SND_REGS,x
rts

b7:
rts

;-----------------------------------------------------------------------------

print_regs:
lda     #$20
sta     ADDR_HI
lda     #$C8
sta     ADDR_LO

lda     CUR_CHN
asl
asl
tax

print_one_reg:
lda     ADDR_HI
sta     $2006
lda     ADDR_LO
sta     $2006
lda     SND_REGS,x
ldy     #$08
-
asl
pha
lda     #$00
rol
ora     #$20
sta     $2007
pla
dey
bne     -
lda     ADDR_LO
clc
adc     #$40
sta     ADDR_LO
bcc     +
inc     ADDR_HI
+
inx
txa
and     #$03
bne     print_one_reg
rts

set_cursors:
lda     #$00
sta     $2003
lda     CUR_REG
asl
asl
asl
asl
clc
adc     #$30
sta     $2004
lda     #$30
sta     $2004
lda     #$00
sta     $2004
lda     #$38
sta     $2004

lda     CUR_REG
asl
asl
asl
asl
clc
adc     #$38
sta     $2004
lda     #$31
sta     $2004
lda     #$00
sta     $2004
lda     CUR_BIT
eor     #$07
asl
asl
asl
clc
adc     #$40
sta     $2004
rts

setup_screen:
lda     #$20
sta     $2006
lda     #$60
sta     $2006
ldx     #$00
-
lda     chn_text,x
cmp     #$FF
beq     end_text
sta     $2007
inx
bne     -
end_text:

lda     #$20
sta     ADDR_HI
lda     #$C0
sta     ADDR_LO
ldy     #$20
-
lda     ADDR_HI
sta     $2006
lda     ADDR_LO
sta     $2006
lda     #$12    ; "R"
sta     $2007
lda     #$05    ; "E"
sta     $2007
lda     #$07    ; "G"
sta     $2007
lda     #$00    ; " "
sta     $2007
sty     $2007
lda     #$2A    ; ":"
sta     $2007
lda     ADDR_LO
clc
adc     #$40
sta     ADDR_LO
bcc     +
inc     ADDR_HI
+
iny
cpy     #$24
bne     -
rts

wait_vblank:
lda     $2002
bpl     wait_vblank
rts

; Clear RAM at $0000-$07FF
; ========================

clear_ram:
lda     #$07    ; high byte of last RAM page
sta     ADDR_HI
lda     #$00    ; low byte of last RAM page
sta     ADDR_LO
clear_it:
ldy     ADDR_HI ; load high byte of address
cpy     #$01    ; if it equals 1...
beq     +       ; ... skip (don't mess with stack at $0100-$01FF)
ldy     #$00
-
sta     (ADDR_LO),y
iny
bne     -
+
dec     ADDR_HI ; decrement high byte of address
bpl     clear_it
rts

; Read joypad
; ===========
; Returns: JOY_STAT = status of all buttons

read_joypad:
ldy     #$01
sty     $4016   ; reset strobe
dey
sty     $4016   ; clear strobe
sty     JOY_STAT ; JOY_STAT = 0 (clear all button bits)
ldy     #$08    ; do all 8 buttons
read_button:
lda     $4016   ; load button status
and     #$01    ; only keep lowest bit
lsr     a       ; transfer to carry flag
rol     JOY_STAT
dey
bne     read_button
rts

; Clear nametable
; ===============
; A     : Select nametable (range 0...3)

clear_nametable:
lda     #$20
sta     $2006   ; write high byte of name table address
lda     #$00
sta     $2006   ; write low byte of name table address

ldx     #$04
ldy     #$00
lda     #$00
-
sta     $2007
dey
bne     -
dex
bne     -
rts

; Set palette
; ===========

set_palette:
lda     #$3F
sta     $2006
lda     #$00
sta     $2006
ldx     #$00
ldy     #$20
-
lda     palette,x
sta     $2007
inx
dey
bne     -
rts

nmi:
pha             ; push A on stack
txa
pha             ; push X on stack
tya
pha             ; push Y on stack

lda     JOY_STAT
sta     OLD_STAT
jsr     read_joypad

pla
tay             ; restore Y
pla
tax             ; restore X
pla             ; restore A
rti

.pad $FFFA

.dw nmi,reset,reset

.end
