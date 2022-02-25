NTSC NES MMC3 IRQ Counter Test ROMs
-----------------------------------
These ROMs test much of MMC3 IRQ counter behavior on an NTSC NES PPU.
They have been tested on an actual NES with on several MMC3 cartridges
and all give a passing result. Many tests are written specifically to
catch likely errors in an emulator.

Each ROM runs several tests and reports the result on screen and by
beeping a number of times. Failure codes for each ROM are listed below.
It's best to run the tests in order, because some earlier ROMs test
things that later ones assume will work properly.

The ROMs mainly test behavior by manually clocking the MMC3's IRQ
counter by writing to $2006 to change the current VRAM address. The last
two ROMs test different revisions of the MMC3, so at most only one will
pass on a particular emulator.

All the asm source is included, and most tests are clearly divided into
sections. The code runs on a custom devcart and assembler so it will
require some effort to assemble. Contact me if you'd like assistance
porting them to your setup.


MMC3 Operation
--------------
I have fairly thoroughly tested MMC3 IRQ counter operation and found the
following behaviors that differ as described in kevtris's (draft?) MMC3
documentation:

- The counter can be clocked manually via bit 12 of the VRAM address
even when $2000 = $00 (bg and sprites both use tiles from $0xxx).

- The IRQ flag is not set when the counter is cleared by writing to
$C001.

- I uncovered some pathological behavior that isn't covered by the test
ROMs. If $C001 is written, the counter clocked, then $C001 written
again, on the next counter clock the counter will be ORed with $80
(revision B)/frozen (revision A) and neither decremented nor reloaded.
If $C001 is written again at this point, on the next counter clock it
will be reloaded normally. I put a check in my emulator and none of the
several games I tested ever caused this situation to occur, so it's
probably not a good idea to implement this.

The MMC3 in Crystalis (referred to here as revision A) worked as
described in kevtris's document, with the above changes. The MMC3 in
Super Mario Bros. 3 and Mega Man 3 (I think revision B, but I don't have
the special screw driver) further differed when $C000 was written with
0:

- Writing 0 to $C000 works no differently than any other value written;
it will cause the counter to be reloaded every time it is clocked (once
it reaches zero).

- When the counter is clocked, if it's not zero, it is decremented,
otherwise it is reloaded with the last value written to $C000. *After*
decrementing/reloading, if the counter is zero and IRQ is enabled via
$E001, the IRQ flag is set.


1.Clocking
----------
Tests counter operation. Requires support for clocking via manual
toggling of VRAM address.

2) Counter/IRQ/A12 clocking isn't working at all
3) Should decrement when A12 is toggled via $2006
4) Writing to $C000 shouldn't cause reload
5) Writing to $C001 shouldn't cause immediate reload
6) Should reload (no decrement) on first clock after clear
7) IRQ should be set when counter is decremented to 0
8) IRQ should never be set when disabled
9) Should reload when clocked when counter is 0


2.Details
---------
Tests counter details.

2) Counter isn't working when reloaded with 255
3) Counter should run even when IRQ is disabled
4) Counter should run even after IRQ flag has been set
5) IRQ should not be set when counter reloads with non-zero
6) IRQ should not be set when counter is cleared via $C001
7) Counter should be clocked 241 times in PPU frame


3.A12 Clocking
--------------
Tests clocking via bit 12 of VRAM address.

2) Shouldn't be clocked when A12 doesn't change
3) Shouldn't be clocked when A12 changes to 0
4) Should be clocked when A12 changes to 1 via $2006 write
5) Should be clocked when A12 changes to 1 via $2007 read
6) Should be clocked when A12 changes to 1 via $2007 write


4.Scanline Timing
-----------------
Tests basic timing for scanlines 0, 1, and 240.

2) Scanline 0 time is too soon
3) Scanline 0 time is too late
4) Scanline 1 time is too soon
5) Scanline 1 time is too late
6) Scanline 239 time is too soon
7) Scanline 239 time is too late


5.MMC3 Rev A
------------
Tests MMC3 revision A differences (tested with Crystalis board).

2) IRQ should be set when reloading to 0 after clear
3) IRQ shouldn't occur when reloading after counter normally reaches 0


6.MMC3 Rev B
------------
Tests MMC3 revision B differences (tested with Super Mario Bros. 3 and
Mega Man 3 boards).

2) Should reload and set IRQ every clock when reload is 0
3) IRQ should be set when counter is 0 after reloading

-- 
Shay Green <hotpop.com@blargg> (swap to e-mail)
