		.processor 6502
		.org $0000

		;NES
                dc.b $4e,$45,$53,$1a

                dc.b $01	;1 16kb PRG rom banks
                dc.b $00	;0 CHR rom banks
                dc.b $10	;Mapper 1 (MMC1)
                dc.b $00
                ds.b 8,0
