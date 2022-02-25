Vaus controller test ROM by Damian Yerrick

The "Vaus" controller included with Taito's Arkanoid game for NES
has a potentiometer and a single button.  The left and right sides
of the pot's range are roughly 160 counts apart, increasing
counterclockwise.  A covered up trimpot next to the knob is
calibrated at the factory to prevent the count from wrapping
between $00 and $FF.  This is sent out as an 8-bit value, MSB
first, on one input line; the button's state is sent on another.

15-pin version for Famicom:

  $4016 D1: Button
  $4017 D1: Position (8 bits, MSB first)

7-pin version for NES:

  $4017 D3: Button
  $4017 D4: Position (8 bits, MSB first)

To control the character in the demo, press the A button on one
of the controllers, and then move the Control Pad or twist the pot.
The following controllers should work:

* NES controller 1
* Arkanoid controller in NES port 2
* Famicom controller 3 (tested only in FCEUX)
* Arkanoid controller in Famicom port (tested only in FCEUX)


== Legal ==

The demo is distributed under the following license, based on the
GNU All-Permissive License:

; Copyright 2013 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.

Taito and Arkanoid are trademarks of Taito, a Square Enix company.