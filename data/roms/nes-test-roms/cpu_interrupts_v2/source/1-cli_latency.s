; Tests the delay in CLI taking effect, and some basic aspects of IRQ
; handling and the APU frame IRQ (needed by the tests). It uses the APU's
; frame IRQ and first verifies that it works well enough for the tests.
; 
; The later tests execute CLI followed by SEI and equivalent pairs of
; instructions (CLI, PLP, where the PLP sets the I flag). These should
; only allow at most one invocation of the IRQ handler, even if it doesn't
; acknowledge the source of the IRQ. RTI is also tested, which behaves
; differently. These tests also *don't* disable interrupts after the first
; IRQ, in order to test whether a pair of instructions allows only one
; interrupt or causes continuous interrupts that block the main code from
; continuing.

CUSTOM_IRQ=1
.include "shell.inc"

zp_byte irq_count
zp_byte irq_flags
zp_res  irq_addr,2
zp_byte irq_data

begin_test:
	sei
	lda #0
	sta irq_count
	sta irq_flags
	sta irq_addr
	sta irq_addr + 1
	rts

irq:    sta irq_data
	pla                     ; save status flags and return addr from stack
	sta irq_flags
	pla
	sta irq_addr
	pla
	sta irq_addr + 1
	pha                     ; restore return addr and status flags on stack
	lda irq_addr
	pha
	lda irq_flags
	pha
	inc irq_count
	bpl :+
	pla
	ora #$04                ; set I flag in saved status to disable IRQ
	pha
:       lda irq_data
	rti

; Reports error if none or more than one interrupt occurred,
; or if return address within handler doesn't match YX.
end_test:
	sei
	nop
	cmp irq_count
	jne test_failed
	cpx irq_addr
	jne test_failed
	cpy irq_addr + 1
	jne test_failed
	rts


.align 256
main:
	setb SNDMODE,0
	delay_msec 40
	; APU frame IRQ should be active by now
	
	set_test 2,"RTI should not adjust return address (as RTS does)"
	lda #>addr2
	pha
	lda #<addr2
	pha
	php
	ldx #0
	rti
	inx
	inx
addr2:  inx
	inx
	cpx #2
	jne test_failed

	set_test 3,"APU should generate IRQ when $4017 = $00"
	jsr begin_test
	lda #$80        ; have IRQ handler set I flag after first invocation
	sta irq_count
	cli
	ldy #0
:       dey
	bne :-
	sei
	nop
	lda irq_count
	cmp #$81
	jne test_failed
	
	set_test 4,"Exactly one instruction after CLI should execute before IRQ is taken"
	jsr begin_test
	lda #$80        ; have IRQ handler set I flag after first invocation
	sta irq_count
	cli
	nop
irq3:
	ldx #<irq3
	ldy #>irq3
	lda #$81
	jsr end_test
	
	set_test 5,"CLI SEI should allow only one IRQ just after SEI"
	jsr begin_test
	lda #$80        ; have IRQ handler set I flag after first invocation
	sta irq_count
	cli
	sei
irq4:
	ldx #<irq4
	ldy #>irq4
	lda #$81
	jsr end_test
	
	set_test 6,"In IRQ allowed by CLI SEI, I flag should be set in saved status flags"
	jsr begin_test
	cli
	sei
	nop
	nop
	lda irq_flags
	and #$04
	jeq test_failed
	
	set_test 7,"CLI PLP should allow only one IRQ just after PLP"
	jsr begin_test
	php
	cli
	plp
irq5:
	ldx #<irq5
	ldy #>irq5
	lda #1
	jsr end_test
	
	set_test 8,"PLP SEI should allow only one IRQ just after SEI"
	jsr begin_test
	lda #0
	pha
	plp
	sei
irq6:
	ldx #<irq6
	ldy #>irq6
	lda #1
	jsr end_test
	
	set_test 9,"PLP PLP should allow only one IRQ just after PLP"
	jsr begin_test
	php
	lda #0
	pha
	plp
	plp
irq7:
	ldx #<irq7
	ldy #>irq7
	lda #1
	jsr end_test

	set_test 10,"CLI RTI should not allow any IRQs"
	jsr begin_test
	lda #>rti1
	pha
	lda #<rti1
	pha
	php
	cli
	rti
rti1:   nop
	nop
	lda irq_count
	jne test_failed

	set_test 11,"Unacknowledged IRQ shouldn't let any mainline code run"
	jsr begin_test
	cli
	nop
	; IRQ should keep firing here until counter reaches $80
	nop
	lda irq_count
	cmp #$80
	jne test_failed
	
	set_test 12,"RTI RTI shouldn't let any mainline code run"
	jsr begin_test
	lda #>rti3
	pha
	lda #<rti3
	pha
	php
	lda #>rti2
	pha
	lda #<rti2
	pha
	lda #0
	pha
	rti
rti2:   rti
rti3:   nop
	lda irq_count
	cmp #$80
	jne test_failed
	
	jmp tests_passed
