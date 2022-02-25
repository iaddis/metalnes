; Included at beginning of program

.ifdef CUSTOM_PREFIX
	.include "custom_prefix.s"
.endif

; Sub-test in a multi-test ROM
.ifdef BUILD_MULTI
	.include "build_multi.s"
.else

; NSF music file
.ifdef BUILD_NSF
	.include "build_nsf.s"
.endif

; Devcart
.ifdef BUILD_DEVCART
	.include "build_devcart.s"
.endif

; NES internal RAM
.ifdef BUILD_NOCART
	.include "build_nocart.s"
.endif

; NES ROM (default)
.ifndef SHELL_INCLUDED
	.include "build_rom.s"
.endif

.endif ; .ifdef BUILD_MULTI
