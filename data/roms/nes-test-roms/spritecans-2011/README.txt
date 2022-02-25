Sprite Cans 2011

This program displays 64 soda cans bouncing slowly off the sides
of the screen.  It uses OAM cycling to make sure that no Sprite
disappears entirely for more than a frame at a time.

The music is "Celestial Soda Pop" composed by Ray Lynch.

This intro was originally released in 2000.
Changes from 2000 version to 2011 version:

* Ported from DOS-based X816 assembler to cross-platform ca65
* Switched from NerdTracker II to LJ65's far smaller music engine
* Automatic detection of NTSC, PAL, or Dendy mode; music compensates
* Vblank waiting changed from race-prone PPUSTATUS spin to waiting
  for NMI count to change
* General removal of cargo-cult code from early NES homebrew days
* Switched from O(n^2) exact gnome sort to O(n) eventual bubble sort
  for less slowdown when adding cans
* Some build tools ported from C to Python
* Pseudo-insular font replaced with standard lowercase
* Tested on PowerPak

Feel free to spread this ROM and its source code.
