TV pass or fail?

This program is designed for NES and tests various aspects of the
display it is connected to.  Press the A Button to switch screens.

_____________________________________________________________________
NTSC chroma/luma crosstalk

The PPU in the PlayChoice arcade system generates RGB video, with
red, green, and blue color information on separate cables.

The PPU in the NES generates composite video, with chroma (color)
and luma (brightness) information carried on one cable at different
frequency bands.  To keep the circuit cheap, it does not perform
proper filtering to keep the chroma from bleeding into the luma.
This especially has an effect on 45 degree diagonal lines.  But an
accurate emulator must preserve the same artifacts, as games such as
Blaster Master rely on them to create the richest color palette.

This screen displays something noticeably different on an NTSC NES
PPU vs. the RGB PPU that most PC based NES emulators emulate.

Display on RGB system:            Display on NTSC system:
,---------.                       ,---------.
|  =====  |                       |  =====  |
|%%%%%%%%%|                       | PASS!   |
|         |                       |         |
| PRESS A |                       | PRESS A |
`---------'                       `---------'

_____________________________________________________________________
Pixel aspect ratio

PC displays most commonly generate square pixels.  A square pixel
on an NTSC display is 7/12 of a chroma cycle wide, but the NES PPU
did not generate square pixels.  Instead, it generated pixels 8/12
of a chroma cycle wide, which are somewhat wider than they are tall.
This made games' graphics appear stretched.  If they are displayed
with square pixels on a PC based emulator, graphics will not appear
with the intended proportions.

This screen shows three rectangles.  One is a square on NTSC NES
and PlayChoice, one is a square on PAL NES, and one is a square
with square pixels.

_____________________________________________________________________
Legal

Copyright 2007 Damian Yerrick
Do not distribute this quick and dirty preview version to the public
until it has been tested on an NES.
