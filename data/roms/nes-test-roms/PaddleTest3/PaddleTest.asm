  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

;;;;;;;;;;;;;;;


;$0000-$00FF:Zeropage
;$0100-$01FF:Stack
;$0200-$02FF:Sprites
;$0300-$07FF:RAM


  .org $0000 ;Zeropage Variables
SixteenBitBackgroundPointer: .rs $02

  .org $0300 ;Normal RAM
Frame: .rs 1
PaddleButtons: .rs 1
GreenFlag: .rs 1

    
  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FF
  STA $0200, x
  INX
  BNE clrmem
  TAX
  TXS
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2
LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$20
LoadPalettesLoop:
  LDA Palette-1,x ;Run pallete loading from +$1F to +$0.
  STA $2007
  DEX
  BNE LoadPalettesLoop
  LDA Palette
  STA $2007
  LDA $2002 ;Starts background loading.
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006
  LDA #LOW(BackgroundPage)
  STA SixteenBitBackgroundPointer
  LDA #HIGH(BackgroundPage)
  STA SixteenBitBackgroundPointer+1
  LDX #$04
  LDY #$00
BackgroundLoop: ;Loop to upload 1K of data to the PPU as pointed at by the pointer in zeropage.
  LDA [SixteenBitBackgroundPointer],Y
  STA $2007
  INY
  BNE BackgroundLoop
  INC SixteenBitBackgroundPointer+1
  DEX
  BNE BackgroundLoop
  LDA Sprite ;Put scale on screen.
  STA $200
  LDA Sprite+1
  STA $201
  LDA Sprite+2
  STA $202
  LDA Sprite+3
  STA $203

LoopUpOne:
  BIT $2002
  BPL LoopUpOne
  
 LDA #%10001000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
 STA $2000

 LDA #%00011110   ; enable sprites, enable background
 STA $2001
 JSR ReadPaddle

 FOREVER:
 LDA Frame ;Get Frame number.
 CMP Frame ;Wait for it to change.
 BEQ FOREVER ;Still waiting for frame to end, will change when NMI is done.
 JSR ReadPaddle ;NMI is done, read paddle outside of NMI to save NMI resources.
 JMP FOREVER ;Wait again.
 
 
 
ReadPaddle: 
  LDA #$01 
  STA $4016 
  LDA #$00 
  STA $4016 
  LDA $4016 
  AND #$10 
  ASL A 
  ASL A 
  ASL A 
  ASL A 
  ROL PaddleButtons 
  LDA $4016 
  AND #$10 
  ASL A 
  ASL A 
  ASL A 
  ASL A 
  ROL PaddleButtons 
  LDA $4016 
  AND #$10 
  ASL A 
  ASL A
  ASL A 
  ASL A 
  ROL PaddleButtons 
  LDA $4016 
  AND #$10 
  ASL A 
  ASL A 
  ASL A 
  ASL A 
  ROL PaddleButtons 
  LDA $4016 
  AND #$10 
  ASL A 
  ASL A 
  ASL A 
  ASL A 
  ROL PaddleButtons 
  LDA $4016 
  AND #$10 
  ASL A 
  ASL A 
  ASL A 
  ASL A 
  ROL PaddleButtons 
  LDA $4016 
  AND #$10 
  ASL A 
  ASL A 
  ASL A 
  ASL A 
  ROL PaddleButtons 
  LDA $4016 
  AND #$10 
  ASL A 
  ASL A 
  ASL A 
  ASL A 
  ROL PaddleButtons
  LDA PaddleButtons
  EOR #$FF 
  STA PaddleButtons 
  RTS

NMI:
  PHA
  LDA $2002 ;Recognize interrupt
  LDA PaddleButtons
  CMP #$FF ;Paddle plugged in?
  BEQ NoController ;No, take the square off the scale.
  LDA PaddleYWhenPluggedIn ;Put square on screen, paddle is plugged in.
  STA $200
  LDA PaddleButtons ;Get paddle value.
  SEC
  SBC #$30 ;Put in range of the bar on screen.
  BCS QuickJump ;Just check for subtracting wrap.
  LDA #$00 ;If wraps for some reason, put on leftmost side of screen.
QuickJump:
  JMP SkipTextBelow
NoController:
  LDA PaddleYWhenNotPluggedIn
  STA $200 ;Paddle not reading if this runs, so put it a different sprite Y position off graph.
  LDA #$7D
SkipTextBelow:
  STA $203 ;Assign X value, either on graph value if plugged in, or middle if not plugged in.
  LDA $4016
  AND #$08 ;Button pressed?
  BEQ Red ;Nope, Red Block.
  LDA #$02 ;Yes, Green Block to show paddle button is pressed is loaded.
  JMP SetBackgroundValue
Red:
  LDA #$01 ;Red Block to show paddle button isn't pressed is loaded.
SetBackgroundValue:
  STA $201 ;Set Block color via sprite block change.
  LDA $2002 ;Reset latch to write value in text to the screen.
  LDA #$21
  STA $2006
  LDA #$72
  STA $2006
  LDA PaddleButtons
  CMP #$FF
  BEQ NotConnectedText ;Not connected/readable, put letters ND on screen.
  LSR A
  LSR A
  LSR A
  LSR A
  CLC
  ADC #$10
  STA $2007
  LDA PaddleButtons
  AND #$0F
  CLC
  ADC #$10
  STA $2007
  JMP SpritesToScreen
NotConnectedText:
  LDA #$4E
  STA $2007
  LDA #$44
  STA $2007
SpritesToScreen:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer
  LDA #$00
  STA $2005
  STA $2005 ;Reset scroll.
  INC Frame ;Tell main engine NMI is done.
  PLA
  RTI ;Return to the infinite loop.

;;;;;;;;;;;;;;
  
  
  .bank 1
  .org $E000


Palette:
  .incbin "Palette.bin"
Sprite:
  .db $FF,$01,$00,$FF
PaddleYWhenPluggedIn:
  .db $47
PaddleYWhenNotPluggedIn:
  .db $37
BackgroundPage:
  .incbin "PaddleTestScreen.bin"


  .org $FFFA
  .dw NMI
  .dw RESET
  .dw 0


;;;;;;;;;;;;;;  


  .bank 2
  .org $0000
  .incbin "PaddleTestGraphics.chr"   ;includes 8KB graphics file for game.