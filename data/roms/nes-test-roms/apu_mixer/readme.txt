NES APU Mixer Tests
-------------------
These tests verify proper operation of the NES APU's sound channel
mixer, including relative volumes of channels and non-linear mixing.
Tests MUST be run from a freshly-powered NES, as this is the only way to
ensure that the triangle wave doesn't interfere.

All tests beep, play a test sound, then beep again. For all but the
noise test, there should be near silence between the beeps. For the
noise test, noise will fade in and out. There shouldn't be any
noticeable tone when heard through a speaker (through headphones, faint
tones might be audible).


Internal operation
------------------
The tests have the channel under test generate a tone, then generate the
inverse waveform using the DMC DAC, canceling to (near) silence if
everything is correct.

The DMC test verifies that non-linearity of the DMC DAC. The noise and
triangle tests verify relative volume of the noise and triangle to the
DMC, and that the DMC DAC affects attenuation of them properly. Finally,
the square test verifies relative volume of the squares to the DMC,
non-linearity of the square DACs, how one square affects the other
(slightly), and that the square DAC non-linearity is separate from the
DMC.


Flashes, clicks, other glitches
-------------------------------
If a test prints "passed", it passed, even if there were some flashes or
odd sounds. Only a test which prints "done" at the end requires that you
watch/listen while it runs in order to determine whether it passed. Such
tests involve things which the CPU cannot directly test.


Alternate output
----------------
Tests generally print information on screen, but also report the final
result audibly, and output text to memory, in case the PPU doesn't work
or there isn't one, as in an NSF or a NES emulator early in development.

After the tests are done, the final result is reported as a series of
beeps (see below). For NSF builds, any important diagnostic bytes are
also reported as beeps, before the final result.


Output at $6000
---------------
All text output is written starting at $6004, with a zero-byte
terminator at the end. As more text is written, the terminator is moved
forward, so an emulator can print the current text at any time.

The test status is written to $6000. $80 means the test is running, $81
means the test needs the reset button pressed, but delayed by at least
100 msec from now. $00-$7F means the test has completed and given that
result code.

To allow an emulator to know when one of these tests is running and the
data at $6000+ is valid, as opposed to some other NES program, $DE $B0
$G1 is written to $6001-$6003.


Audible output
--------------
A byte is reported as a series of tones. The code is in binary, with a
low tone for 0 and a high tone for 1, and with leading zeroes skipped.
The first tone is always a zero. A final code of 0 means passed, 1 means
failure, and 2 or higher indicates a specific reason. See the source
code of the test for more information about the meaning of a test code.
They are found after the set_test macro. For example, the cause of test
code 3 would be found in a line containing set_test 3. Examples:

	Tones         Binary  Decimal  Meaning
	- - - - - - - - - - - - - - - - - - - - 
	low              0      0      passed
	low high        01      1      failed
	low high low   010      2      error 2


NSF versions
------------
Many NSF-based tests require that the NSF player either not interrupt
the init routine with the play routine, or if it does, not interrupt the
play routine again if it hasn't returned yet. This is because many tests
need to run for a while without returning.

NSF versions also make periodic clicks to prevent the NSF player from
thinking the track is silent and thus ending the track before it's done
testing.

-- 
Shay Green <gblargg@gmail.com>
