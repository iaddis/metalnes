NES Precise NMI Synchronization
-------------------------------
This library allows synchronizing exactly to the PPU from within a
normal NMI handler. It allows PPU writes from within an NMI handler of
the same precision that is otherwise only possible using completely
cycle-timed code. It supports NTSC and PAL.

The code is written for the ca65 assembler. Other assemblers will
require minor changes.

For more about how the technique works, see
http://wiki.nesdev.com/w/index.php/Consistent_frame_synchronization .


Demos
-----
NTSC and PAL demos are included. These show minimal use of this library
to manually draw a line using timed writes. They manually draw a line by
setting bit 0 of $2001 to enable monochrome mode. The time of the write
determines the position on screen, so any synchronization problems will
cause the line's left side to move. Reference lines are shown above and
below the manually-drawn one, showing the correct left edge position.

On the NTSC version, the left pixel of the middle line will be darker,
since it's flashing:
	
	********************
	                 ***
	-*******************
	                 ***
	********************

On the PAL version, the left pixel or two will be darker, since it's
flashing. The left edge's general position will change randomly each
time you press reset. The upper line shows the farthest left it can ever
be after reset, and the lower line shows the farthest right it can be.
It may appear as one of the following:

	********************
	                 ***
	-*******************
	                 ***
	  ******************


	********************
	                 ***
	 -******************
	                 ***
	  ******************


	********************
	                 ***
	  -*****************
	                 ***
	  ******************


Usage
-----
To use this library:

* Include "nmi_sync.s".

* Call init_nmi_sync[_pal] before synchronization is needed, then wait
in a loop that calls wait_nmi, does anything that is necessary between
NMIs, then loops back.

* Inside NMI, call begin_nmi_sync, do sprite DMA, delay appropriately,
then call end_nmi_sync. If running on NTSC NES, sprite and/or background
rendering MUST be enabled before calling end_nmi_sync. It can be
disabled again after it returns.

* On frames where synchronization isn't needed, but will be needed a few
frames later, call track_nmi_sync. If it won't be needed for a long
time, nothing needs to be done, and init_nmi_sync can be called again
later to re-synchronize and start over.

After end_nmi_sync returns, the next instruction will be synchronized to
2286 (NTSC)/7471 (PAL) cycles after the frame began.

If the NMI handler's timing is off by even one cycle, synchronization
will fail sometimes. To verify timing, write an odd value to $2001 after
synchronization. The point where monochrome mode begins on the scanline
should be very stable. If it ever jiggles, then something is wrong in
your code.

The following demonstrates:

	.include "nmi_sync.s"
	
	reset:
		...
		jsr init_nmi_sync/init_nmi_sync_pal
		
	loop:
		jsr wait_nmi
		...anything done outside of NMI...
		jmp loop
	
	nmi:
		...save registers...
		jsr begin_nmi_sync  ; count as 6 cycles
		...
		
		; Instructions between nmi: and STA $4014 must take an even
		; number of cycles. STA $4014 must be done as a part of
		; synchronization.
		sta $4014           ; count as 4 cycles
		...
		
		; Instructions between nmi: and here must take
		; 1715 (NTSC)/6900 (PAL) cycles.
		
		delay 1715 - ...    ; NTSC
		delay 6900 - ...    ; PAL
		
		; On NTSC, sprite and/or background rendering MUST be
		; enabled at this point, or else synchronization will
		; be lost.
		
		jsr end_nmi_sync
		
		; Sprite and background rendering can be disabled again
		; at this point, if it's not needed.
		
		; Next instruction is now synchronized to exactly
		; 2286 (NTSC)/7471 (PAL) cycles after cycle that
		; frame began in.
		...
		
		...restore registers...
		rti


NTSC Timing
-----------
Given the following NMI handler

	nmi:
		...
		jsr end_nmi_sync
		delay N cycles
		lda #$01
		sta $2001   ; writes 2286+N+5 cycles into frame

The $2001 write will be 2286+N+5 cycles after frame began. To have the
$2001 write at a particular pixel, calculate N with

	pixel = y * 341 + x
	N = (pixel + 290) / 3

For example, to write at y=121 x=80, N should be 13877.

The pixel position can be calculated from N with

	pixel = N * 3 - 290
	y = pixel / 341
	x = pixel - (y * 341)

where y=0 x=0 is the top-left pixel. For example, if the delay is 13877,
then the $2001 write will occur at y=121 x=80.

After init_nmi_sync is called, the first, third, fifth, etc. frames have
the above timing. On the second, fourth, sixth, etc. frames, the write
is one pixel LATER (x=81 in the example). This one-pixel jitter is an
unavoidable hardware limitation.

The above applies to enabling monochrome mode by setting bit 0 of $2001;
other registers take effect at slightly different times. For some
registers, the pixel written can vary slightly after pressing reset.
It's best to use the above as a guide, reduce delay until glitches occur
due to it occurring too early, increase delay until glitches occur as
well, then choose a delay in the middle of those two extremes.
 

PAL Timing
----------
Given the following NMI handler

	nmi:
		...
		jsr end_nmi_sync
		delay N cycles
		lda #$01
		sta $2001   ; writes 7471+N+5 cycles into frame

The $2001 write will be 7471+N+5 cycles after frame began. To have the
$2001 write at a particular pixel, calculate N with

	pixel = y * 341 + x
	N = (pixel * 5 + 1444) / 16

For example, to write at y=121 x=82, N should be 13009.

The pixel position can be calculated from N with

	pixel = (N * 16 - 1444 + extra) / 5
	y = pixel / 341
	x = pixel - (y * 341)

where y=0 x=0 is the top-left pixel, and extra is an additional delay
that depends on whether it's an even or odd frame, and also a random
offset selected when reset is pressed. For example, if the delay is
13009, then the $2001 write will occur no earlier than y=121 x=81.

After init_nmi_sync is called, the first, third, fifth, etc. frames have
the above timing. On the second, fourth, sixth, etc. frames, extra is 8
greater, causing the write to be one or two pixels LATER (x=83 or 84 in
the example). This jitter is an unavoidable hardware limitation.

After pressing reset, extra is set to a random value from 0 to 7,
causing writes to be one or two pixels later. This doesn't change until
reset is pressed. This is also unavoidable.

The above applies to enabling monochrome mode by setting bit 0 of $2001;
other registers take effect at slightly different times. For some
registers, the pixel written can vary slightly after pressing reset.
It's best to use the above as a guide, reduce delay until glitches occur
due to it occurring too early, increase delay until glitches occur as
well, then choose a delay in the middle of those two extremes.


Limitations
-----------
* DMC samples can't be played, since they introduce too much timing
variation. A normal NMI performs just as well/poorly in this case.

* If NMI occurs while executing an instruction that takes more than
three cycles, synchronization will be upset for that frame. Note that a
taken branch counts as more than three cycles, due to an obscure detail.
To avoid this, call wait_nmi each frame, or sit in a loop of
instructions two/three-cycle instructions. I have found some workarounds
that allow NMI to occur during almost any instruction, but they require
some extra helper sprites and use of the sprite overflow flag; contact
me for details.

* Every frame from that point, NMI must either call begin/end_nmi_sync,
or track_nmi_sync, or else synchronization will be lost and
init_nmi_sync will need to be called again.

* The NMI handler must not read $2002 until after end_nmi_sync has been
called.

* After synchronizing, NMI and rendering must be enabled by the next
frame, and left enabled (rendering can be disabled on PAL since it
doesn't affect PPU timing). If rendering isn't desired, it can be
enabled just before calling end_nmi_sync, then disabled afterwards.

* Sprite DMA must be done on frames needing synchronization, even if no
sprites are being used.

* Even when perfectly synchronized, frames don't always begin exactly on
a cycle. On NTSC, a given cycle will toggle between two adjacent pixels.
On PAL, it will toggle between the calculated pixel and one or two
pixels after. These effects are hardware limitations; this library
synchronizes as precisely as is possible in software.


Thanks
------
* Bregalad for his initial questions that inspired the idea, and for
trying an early version.


-- 
Shay Green <gblargg@gmail.com>
