;
; File: apu.inc
; Namespace: apu_ / APU_
; Code Segment: APULIB
; Copyright (c) 2011 Mathew Brenaman (see 'LICENSE' for details)
; Assembled with ca65
;
; General purpose APU library
;

.ifndef APU_INC
APU_INC = 1

; APU I/O locations

SQ1_VOL = $4000
SQ1_SWEEP = $4001
SQ1_LO = $4002
SQ1_HI = $4003
SQ2_VOL = $4004
SQ2_SWEEP = $4005
SQ2_LO = $4006
SQ2_HI = $4007
TRI_LINEAR = $4008
TRI_LO = $400A
TRI_HI = $400B
NOISE_VOL = $400C
NOISE_LO = $400E
NOISE_HI = $400F
DMC_FREQ = $4010
DMC_RAW = $4011
DMC_START = $4012
DMC_LEN = $4013
SND_CHN = $4015

.endif

