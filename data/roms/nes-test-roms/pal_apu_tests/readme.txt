PAL NES APU Tests
-----------------
These tests verify the PAL APU's frame sequencer timing. They have been tested
on a PAL NES and all give a passing result.

Each .nes file runs several tests and reports the result on screen and by
beeping a number of times. See below for the meaning of failure codes for each
test. It's best to run the tests in order, because later tests depend on things
tested by earlier tests and will give erroneous results if any earlier ones
failed.

Source code for each test is included, and most tests are clearly divided into
sections. Support code is also included, but it runs on a custom devcart and
assembler so it will require some effort to assemble. Contact me if you'd like
assistance porting them to your setup.


Frame sequencer timing
----------------------
See blargg_apu_2005.07.30 for more information about frame sequencer timing
subtleties. This only lists timing differences.

Mode 0: 4-step sequence

Action      Envelopes &     Length Counter& Interrupt   Delay to next
			Linear Counter  Sweep Units     Flag        NTSC     PAL
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$4017=$00   -               -               -           7459    8315
Step 1      Clock           -               -           7456    8314
Step 2      Clock           Clock           -           7458    8312
Step 3      Clock           -               -           7458    8314
Step 4      Clock           Clock       Set if enabled  7458    8314


Mode 1: 5-step sequence

Action      Envelopes &     Length Counter& Interrupt   Delay to next
			Linear Counter  Sweep Units     Flag        NTSC     PAL
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$4017=$80   -               -               -              1       1
Step 1      Clock           Clock           -           7458    8314
Step 2      Clock           -               -           7456    8314
Step 3      Clock           Clock           -           7458    8312
Step 4      Clock           -               -           7458    8314
Step 5      -               -               -           7452    8312

Note: the IRQ flag is actually effectively set three clocks in a row, starting
one clock earlier than shown. NTSC and PAL times shown for comparison.


01.len_ctr
----------
Tests basic length counter operation

1) Passed tests
2) Problem with length counter load or $4015
3) Problem with length table, timing, or $4015
4) Writing $80 to $4017 should clock length immediately
5) Writing $00 to $4017 shouldn't clock length immediately
6) Clearing enable bit in $4015 should clear length counter
7) When disabled via $4015, length shouldn't allow reloading
8) Halt bit should suspend length clocking


02.len_table
------------
Tests all length table entries.

1) Passed
2) Failed. Prints four bytes $II $ee $cc $02 that indicate the length load
value written (ll), the value that the emulator uses ($ee), and the correct
value ($cc).


03.irq_flag
-----------
Tests basic operation of frame irq flag.

1) Tests passed
2) Flag shouldn't be set in $4017 mode $40
3) Flag shouldn't be set in $4017 mode $80
4) Flag should be set in $4017 mode $00
5) Reading flag clears it
6) Writing $00 or $80 to $4017 doesn't affect flag
7) Writing $40 or $c0 to $4017 clears flag


04.clock_jitter
---------------
Tests for APU clock jitter. Also tests basic timing of frame irq flag since
it's needed to determine jitter. It's OK if you don't implement jitter, in
which case you'll get error #5, but you can still run later tests without
problem.

1) Passed tests
2) Frame irq is set too soon
3) Frame irq is set too late
4) Even jitter not handled properly
5) Odd jitter not handled properly


05.len_timing_mode0
-------------------
Tests length counter timing in mode 0.

1) Passed tests
2) First length is clocked too soon
3) First length is clocked too late
4) Second length is clocked too soon
5) Second length is clocked too late
6) Third length is clocked too soon
7) Third length is clocked too late


06.len_timing_mode1
-------------------
Tests length counter timing in mode 1.

1) Passed tests
2) First length is clocked too soon
3) First length is clocked too late
4) Second length is clocked too soon
5) Second length is clocked too late
6) Third length is clocked too soon
7) Third length is clocked too late


07.irq_flag_timing
------------------
Frame interrupt flag is set three times in a row 33255 clocks after writing
$4017 with $00.

1) Success
2) Flag first set too soon
3) Flag first set too late
4) Flag last set too soon 
5) Flag last set too late 


08.irq_timing
-------------
IRQ handler is invoked at minimum 33257 clocks after writing $00 to $4017.

1) Passed tests
2) Too soon
3) Too late
4) Never occurred


10.len_halt_timing
------------------
Changes to length counter halt occur after clocking length, not before.

1) Passed tests
2) Length shouldn't be clocked when halted at 16628
3) Length should be clocked when halted at 16629
4) Length should be clocked when unhalted at 16628
5) Length shouldn't be clocked when unhalted at 16629


11.len_reload_timing
--------------------
Write to length counter reload should be ignored when made during length
counter clocking and the length counter is not zero.

1) Passed tests
2) Reload just before length clock should work normally
3) Reload just after length clock should work normally
4) Reload during length clock when ctr = 0 should work normally
5) Reload during length clock when ctr > 0 should be ignored

-- 
Shay Green <gblargg@gmail.com>
