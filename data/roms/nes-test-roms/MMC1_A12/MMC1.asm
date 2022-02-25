;MMC1 write handler
.define R0 $9fff
.define R1 $bfff
.define R2 $dfff
.define R3 $f000

.section "MMC1" FREE
WriteR0
	sta R0
	lsr A
	sta R0
	lsr A
	sta R0
	lsr A
	sta R0
	lsr A
	sta R0
	rts

WriteR1
	sta R1
	lsr A
	sta R1
	lsr A
	sta R1
	lsr A
	sta R1
	lsr A
	sta R1
	rts

WriteR2
	sta R2
	lsr A
	sta R2
	lsr A
	sta R2
	lsr A
	sta R2
	lsr A
	sta R2
	rts

ProgramSwitch1
	sta BankLatch1
ProgramSwitch2
	sta BankLatch2
WriteR3
	tax
	lda M2000
	and #$7f
	sta $2000
	txa
	sta R3
	lsr A
	sta R3
	lsr A
	sta R3
	lsr A
	sta R3
	lsr A
	sta R3
	lda M2000
	sta $2000
	rts
.ends