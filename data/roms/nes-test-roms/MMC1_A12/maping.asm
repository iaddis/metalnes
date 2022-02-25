;Defines NES's RAM for any games witout SRAM
;Stack isn't defined, it's use is reserved
;Also $200-$2ff is reserved for SpriteRam and isn't defined here

.memorymap
defaultslot 0
slotsize $100
slot 0 $0	;0 page RAM
slotsize $500
slot 1 $300	;BSS RAM
slotsize $4000		;PRG ROM slot (16kb)
slot 2 $8000
slotsize $4000
slot 3 $c000		;Resitant PRG slot (16kb)
.endme

;Define a CNROM structure with 32kb PRG and 32kb CHR

.rombankmap
bankstotal 8
banksize $4000		;4x 32kb PRG
banks 8
.endro