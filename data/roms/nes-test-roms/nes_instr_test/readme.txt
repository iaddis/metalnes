NES CPU Instruction Behavior Tests
----------------------------------
These tests verify most instruction behavior fairly thoroughly,
including unofficial instructions. Failing instructions are listed by
their opcode and name. Serious errors in behavior of basic opcodes might
cause many false errors.

The *_singles/ test all instructions, but test the official ones first,
so you can tell whether you pass those even if your emulator hangs on
the unofficial ones.

The nsf_singles builds audibly report the opcodes of any failed
instructions before the final result.


Internal operation
------------------
Most instructions are tested by setting many combinations of input
values for registers, flags, and memory, running the instruction under
test, then updating a running checksum with the resulting values. After
trying all interesting input combinations, the checksum is compared with
the correct one (what a NES gives) to find whether the instruction
passed. This approach makes it very easy to write the tests, since the
instructions don't have to be each coded for separately; instead, only
the different addressing modes need separate tests.


Instructions
------------
U = Unofficial
X = Freezes CPU, so not tested
? = Inconsistent/unknown behavior, so not tested

00   BRK #n
01   ORA (z,X)
02 X KIL
03 U SLO (z,X)
04 U DOP z
05   ORA z
06   ASL z
07 U SLO z
08   PHP
09   ORA #n
0A   ASL A
0B U AAC #n
0C U TOP abs
0D   ORA a
0E   ASL a
0F U SLO abs
10   BPL r
11   ORA (z),Y
12 X KIL
13 U SLO (z),Y
14 U DOP z,X
15   ORA z,X
16   ASL z,X
17 U SLO z,X
18   CLC
19   ORA a,Y
1A U NOP
1B U SLO abs,Y
1C U TOP abs,X
1D   ORA a,X
1E   ASL a,X
1F U SLO abs,X
20   JSR a
21   AND (z,X)
22 X KIL
23 U RLA (z,X)
24   BIT z
25   AND z
26   ROL z
27 U RLA z
28   PLP
29   AND #n
2A   ROL A
2B U AAC #n
2C   BIT a
2D   AND a
2E   ROL a
2F U RLA abs
30   BMI r
31   AND (z),Y
32 X KIL
33 U RLA (z),Y
34 U DOP z,X
35   AND z,X
36   ROL z,X
37 U RLA z,X
38   SEC
39   AND a,Y
3A U NOP
3B U RLA abs,Y
3C U TOP abs,X
3D   AND a,X
3E   ROL a,X
3F U RLA abs,X
40   RTI
41   EOR (z,X)
42 X KIL
43 U SRE (z,X)
44 U DOP z
45   EOR z
46   LSR z
47 U SRE z
48   PHA
49   EOR #n
4A   LSR A
4B U ASR #n
4C   JMP a
4D   EOR a
4E   LSR a
4F U SRE abs
50   BVC r
51   EOR (z),Y
52 X KIL
53 U SRE (z),Y
54 U DOP z,X
55   EOR z,X
56   LSR z,X
57 U SRE z,X
58   CLI
59   EOR a,Y
5A U NOP
5B U SRE abs,Y
5C U TOP abs,X
5D   EOR a,X
5E   LSR a,X
5F U SRE abs,X
60   RTS
61   ADC (z,X)
62 X KIL
63 U RRA (z,X)
64 U DOP z
65   ADC z
66   ROR z
67 U RRA z
68   PLA
69   ADC #n
6A   ROR A
6B U ARR #n
6C   JMP (a)
6D   ADC a
6E   ROR a
6F U RRA abs
70   BVS r
71   ADC (z),Y
72 X KIL
73 U RRA (z),Y
74 U DOP z,X
75   ADC z,X
76   ROR z,X
77 U RRA z,X
78   SEI
79   ADC a,Y
7A U NOP
7B U RRA abs,Y
7C U TOP abs,X
7D   ADC a,X
7E   ROR a,X
7F U RRA abs,X
80 U DOP #n
81   STA (z,X)
82 U DOP #n
83 U AAX (z,X)
84   STY z
85   STA z
86   STX z
87 U AAX z
88   DEY
89 U DOP #n
8A   TXA
8B ? XAA #n
8C   STY a
8D   STA a
8E   STX a
8F U AAX abs
90   BCC r
91   STA (z),Y
92 X KIL
93 ? AXA (z),Y
94   STY z,X
95   STA z,X
96   STX z,Y
97 U AAX z,Y
98   TYA
99   STA a,Y
9A   TXS
9B ? XAS abs,Y
9C U SYA abs,X
9D   STA a,X
9E U SXA abs,Y
9F ? AXA abs,Y
A0   LDY #n
A1   LDA (z,X)
A2   LDX #n
A3 U LAX (z,X)
A4   LDY z
A5   LDA z
A6   LDX z
A7 U LAX z
A8   TAY
A9   LDA #n
AA   TAX
AB U ATX #n
AC   LDY a
AD   LDA a
AE   LDX a
AF U LAX abs
B0   BCS r
B1   LDA (z),Y
B2 X KIL
B3 U LAX (z),Y
B4   LDY z,X
B5   LDA z,X
B6   LDX z,Y
B7 U LAX z,Y
B8   CLV
B9   LDA a,Y
BA   TSX
BB ? LAR abs,Y
BC   LDY a,X
BD   LDA a,X
BE   LDX a,Y
BF U LAX abs,Y
C0   CPY #n
C1   CMP (z,X)
C2 U DOP #n
C3 U DCP (z,X)
C4   CPY z
C5   CMP z
C6   DEC z
C7 U DCP z
C8   INY
C9   CMP #n
CA   DEX
CB U AXS #n
CC   CPY a
CD   CMP a
CE   DEC a
CF U DCP abs
D0   BNE r
D1   CMP (z),Y
D2 X KIL
D3 U DCP (z),Y
D4 U DOP z,X
D5   CMP z,X
D6   DEC z,X
D7 U DCP z,X
D8   CLD
D9   CMP a,Y
DA U NOP
DB U DCP abs,Y
DC U TOP abs,X
DD   CMP a,X
DE   DEC a,X
DF U DCP abs,X
E0   CPX #n
E1   SBC (z,X)
E2 U DOP #n
E3 U ISC (z,X)
E4   CPX z
E5   SBC z
E6   INC z
E7 U ISC z
E8   INX
E9   SBC #n
EA   NOP
EB U SBC #n
EC   CPX a
ED   SBC a
EE   INC a
EF U ISC abs
F0   BEQ r
F1   SBC (z),Y
F2 X KIL
F3 U ISC (z),Y
F4 U DOP z,X
F5   SBC z,X
F6   INC z,X
F7 U ISC z,X
F8   SED
F9   SBC a,Y
FA U NOP
FB U ISC abs,Y
FC U TOP abs,X
FD   SBC a,X
FE   INC a,X
FF U ISC abs,X


Multi-tests
-----------
The NES/NSF builds in the main directory consist of multiple sub-tests.
When run, they list the subtests as they are run. The final result code
refers to the first sub-test that failed. For more information about any
failed subtests, run them individually from nes_singles/ and
nsf_singles/.


Multi-tests
-----------
The NES/NSF builds in the main directory consist of multiple sub-tests.
When run, they list the subtests as they are run. The final result code
refers to the first sub-test that failed. For more information about any
failed subtests, run them individually from nes_singles/ and
nsf_singles/.


Flashes, clicks, other glitches
-------------------------------
Some tests might need to turn the screen off and on, or cause slight
audio clicks. This does not indicate failure, and should be ignored.
Only the test result reported at the end is important, unless stated
otherwise.


Text output
-----------
Tests generally print information on screen. They also output the same
text as a zero-terminted string beginning at $6004, allowing examination
of output in an NSF player, or a NES emulator without a working PPU. The
tests also work properly if the PPU doesn't set the VBL flag properly or
doesn't implement it at all.

The final result is displayed and also written to $6000. Before the test
starts, $80 is written there so you can tell when it's done. If a test
needs the NES to be reset, it writes $81 there. In addition, $DE $B0 $G1
is written to $6001-$6003 to allow an emulator to detect when a test is
being run, as opposed to some other NES program. In NSF builds, the
final result is also reported via a series of beeps (see below).

See the source code for more information about a particular test and why
it might be failing. Each test has comments and correct output at the
top.


NSF versions
------------
Many NSF-based tests require that the NSF player either not interrupt
the init routine with the play routine, or if it does, not interrupt the
play routine again if it hasn't returned yet. This is because many tests
need to run for a while without returning.

NSF versions also make periodic clicks to avoid the NSF player from
thinking the track is silent and thus ending the track before it's done
testing.

In addition to the other text output methods described above, NSF builds
report essential information bytes audibly, including the final result.
A byte is reported as a series of tones. The code is in binary, with a
low tone for 0 and a high tone for 1, and with leading zeroes skipped.
The first tone is always a zero. A final code of 0 means passed, 1 means
failure, and 2 or higher indicates a specific reason as listed in the
source code by the corresponding set_code line. Examples:

Tones         Binary  Decimal  Meaning
- - - - - - - - - - - - - - - - - - - - 
low              0      0      passed
low high        01      1      failed
low high low   010      2      error 2

-- 
Shay Green <gblargg@gmail.com>
