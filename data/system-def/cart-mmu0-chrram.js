

var module = {
    
name: "cart-mmu0-chrram",
description: "NES Cartridge CHR RAM 8K",

modules: [
  [ "edge",      "nes-cart72",   0],
  [ "chrram",    "SRAM8K",       0],
],

connections: [
    //
    // internal to cart
    //

    // cart -> CHRRAM
    [ "edge.ppu_a[12:0]",    "chrram.a[12:0]"   ],
    [ "edge.ppu_d[7:0]",     "chrram.d[7:0]"   ],
    [ "edge.ppu_/wr",        "chrram./we"   ],
    [ "edge.ppu_/rd",        "chrram./oe"   ],
    [ "edge.ppu_a13",        "chrram.cs"   ],

]


    
};
