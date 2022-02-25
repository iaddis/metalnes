NES APU Frame Counter Update
----------------------------

I have run more tests on the NES APU and come up with new information
about the exact timing of the frame counter and length counter, and some
subtle behavior. The information here either extends or contradicts what
is stated in the NES APU reference and on the nesdev wiki.

Not documented here is a delay when changing modes by writing to $4017.
This is quite complex and I haven't fully worked out its exact
operation. Once determined, documented, and tested, the information here
should still be valid. This delay when changing modes involves the
current mode running a few clocks before switching to the new mode, so
it only affects the rare case where $4017 is written within a few clocks
of a frame counter step. This delay does not cause the steps to occur
any later than shown below; it only causes the first few clocks of the
new mode to be transparent, allowing the previous mode to "show
through".

Also not documented is the exact operation of the envelope, sweep, and
triangle's linear counter when register writes occur close to clocking.

Refer to tests.txt for a description of the test ROMs included.

I have not yet fully updated my APU emulator and tested it with this
information, so report any problems you have with implementation.

Shay <hotpop.com@blargg> (swap to e-mail)


Clock Jitter
------------
Changes to the mode by writing to $4017 only occur on *even* internal
APU clocks; if written on an odd clock, the first step of the mode is
delayed by one clock. At power-up and reset, the APU is randomly in an
odd or even cycle with respect to the first clock of the first
instruction executed by the CPU.

      ; assume even APU and CPU clocks occur together
      lda   #$00
      sta   $4017       ; mode begins in one clock
      sta   <0          ; delay 3 clocks
      sta   $4017       ; mode begins immediately


Mode 0 Timing
-------------
-5    lda   #$00
-3    sta   $4017
0     (write occurs here)
1
2
3
...
      Step 1
7459  Clock linear
...
      Step 2
14915 Clock linear & length
...
      Step 3
22373 Clock linear
...
      Step 4
29830 Set frame irq
29831 Clock linear & length and set frame irq
29832 Set frame irq
...
      Step 1
37289 Clock linear
...
etc.


Mode 1 Timing
-------------
-5    lda   #$80
-3    sta   $4017
0     (write occurs here)
      Step 0
1     Clock linear & length
2
...
      Step 1
7459  Clock linear
...
      Step 2
14915 Clock linear & length
...
      Step 3
22373 Clock linear
...
      Step 4
29829 (do nothing)
...
      Step 0
37283 Clock linear & length
...
etc.


Length Halt
-----------
Write to halt flag is delayed by one clock:

      $10->$4000  clear halt flag
0     $00->$4017  begin mode 0
14914 $30->$4000  set halt flag
14915 Length not clocked

      $10->$4000  clear halt flag
0     $00->$4017  begin mode 0
14915 $30->$4000  set halt flag
      Length clocked

      $30->$4000  set halt flag
0     $00->$4017  begin mode 0
14914 $10->$4000  clear halt flag
14915 Length clocked

      $30->$4000  set halt flag
0     $00->$4017  begin mode 0
14915 $10->$4000  clear halt flag
      Length not clocked
      


Length Reload
-------------
Length reload is completely ignored if written during length clocking
and length counter is non-zero before clocking:

      $38->$4003  make length non-zero
0     $00->$4017
14914 Write to $4003
      Length reloaded
14915 Length clocked

      $38->$4003  make length non-zero
0     $00->$4017
14915 Write to $4003
      Length not reloaded
      Length clocked

      $00->$4015  clear length counter
      $01->$4015
0     $00->$4017
14915 Write to $4003
      Length reloaded
      Length not clocked

Misc
----
- The frame IRQ flag is cleared only when $4015 is read or $4017 is
written with bit 6 set ($40 or $c0).

- The IRQ handler is invoked at minimum 29833 clocks after writing $00
to $4017 (assuming the frame IRQ flag isn't already set, and nothing
else generates an IRQ during that time).

- After reset or power-up, APU acts as if $4017 were written with $00
from 9 to 12 clocks before first instruction begins. It is as if this
occurs (this generates a 10 clock delay):

      lda   #$00
      sta   $4017       ; 1
      lda   <0          ; 9 delay
      nop
      nop
      nop
reset:
      ...

- As shown, the frame irq flag is set three times in a row. Thus when
polling it, always read $4015 an extra time after the flag is found to
be set, to be sure it's clear afterwards,

wait: bit   $4015       ; V flag reflects frame IRQ flag
      bvc   wait
      bit   $4015       ; be sure irq flag is clear

or better yet, clear it before polling it:

      bit   $4015       ; clear flag first
wait: bit   $4015       ; V flag reflects frame IRQ flag
      bvc   wait

