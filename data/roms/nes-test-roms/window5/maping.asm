;Defines NES's RAM for any games witout SRAM
;Stack isn't defined, it's use is reserved
;Also $200-$2ff is reserved for SpriteRam and isn't defined here

.memorymap
defaultslot 0
slotsize $100
slot 0 $0   ;0 page RAM
slotsize $500
slot 1 $300 ;BSS RAM
slotsize $4000      ;PRG ROM slot (32kb)
slot 2 $c000
slotsize $2000      ;CHR ROM slot (8kb)
slot 3 $0
.endme

;Define a CNROM structure with 32kb PRG and 32kb CHR

.rombankmap
bankstotal 2
banksize $4000      ;1x 16kb PRG
banks 1
banksize $2000      ;1x 8kb CHR
banks 1
.endro