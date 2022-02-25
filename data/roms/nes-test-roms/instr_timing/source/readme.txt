NES Tests Source Code
---------------------

Building with ca65
------------------
To assemble a test ROM with ca65, use the following commands:

	ca65 -I common -o test.o source_filename_here.s
	ld65 -C nes.cfg test.o -o test.nes

To assemble as an NSF music file:

	ca65 -I common -o test.o source_filename_here.s -D BUILD_NSF
	ld65 -C nsf.cfg test.o -o test.nsf

Note that some tests might only work when built as a ROM or NSF file,
but not both.

Some tests might include a ROM/NSF that has all the tests combined.
Building such a multi-test is complex and the necessary files aren't
included. Also, tests you build won't print their name if they fail,
since that requires special arrangements due to ca65's inability to
define strings on the command-line.


Shell
-----
Most tests are in a single source file, and make use of several library
source files from common/. This framework provides common services and
reduces code to only that which performs the actual test. Virtually all
tests include "shell.inc" at the beginning, which sets things up and
includes all the appropriate library files.

The reset handler does NES hardware initialization, clears RAM and PPU
nametables, then runs main. Main can exit by returning or jumping to
"exit" with an error code in A. Exit reports the code then goes into an
infinite loop. If the code is 0, it doesn't do anything, otherwise it
reports the code. Code 1 is reported as "Failed", and the rest as "Error
<code>".

Several routines are available to print values and text to the console.
The first time a line of text is completed, the console initializes the
PPU. Most print routines update a running CRC-32 checksum which can be
checked with check_crc. This allows ALL the output to be checked very
easily. If the checksum doesn't match, it is printed, so during
development the code can be run on a NES to get the correct checksum,
which is then typed into the test code. The checksum is also useful when
comparing different outputs; rather than having to examine all the
output, one need only compare checksums.

The default is to build an iNES ROM. Defining BUILD_NSF will build as an
NSF. The other build types aren't supported by the included code, due to
their complexity.


Macros
------
Some macros are used to make common operations more convenient, defined
in common/macros.inc. The left is equivalent to the right:

	Macro               Equivalent
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	blt                 bcc
	
	bge                 bcs
	
	jne label           beq skip
						jmp label
						skip:
	etc.
	
	setb addr,byte      lda #byte
						sta addr
	
	setw addr,word      lda #<word
						sta addr
						lda #>word
						sta addr+1
	
	ldxy #value         ldx #>value
						ldy #<value
	
	incw addr           inc addr
						bne skip
						inc addr+1
						skip:
	
	inxy                iny         ; actual macro differs slightly,
						bne skip    ; to always take 7 clocks
						inx
						skip:
	
	zp_byte name        .zeropage
						name: .res 1
						.code
	
	zp_res name,n       .zeropage   ; if n is omitted, uses 1
						name: .res n
						.code
	
	bss_res name,n      .bss        ; if n is omitted, uses 1
						name: .res n
						.code
	
	nv_res name,n       .segment "NVRAM"    ; if n is omitted, uses 1
						name: .res n
						.code
	
	for_loop routine,begin,end,step
						calls routine with A set to successive values
						from begin through end, with given step
	
	loop_n_times routine,count
						calls routine with A from 0 to count-1

"NVRAM" is a section for variables that aren't cleared by the shell.
This is useful for values that are written in a custom reset handler and
later read from main, or values that are saved across resets.

-- 
Shay Green <gblargg@gmail.com>
