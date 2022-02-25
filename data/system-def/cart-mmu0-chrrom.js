

var module = {
    
name: "cart-mmu0-chrrom",
description: "NES Cartridge CHR ROM 8K",

modules: [
  [ "edge",      "nes-cart72",   0],
  [ "chr",       "ROM8K",       0],
],

connections: [
    //
    // internal to cart
    //

    // cart -> CHRROM
    [ "edge.ppu_a[12:0]",    "chr.a[12:0]"   ],
    [ "edge.ppu_d[7:0]",    "chr.d[7:0]"   ],
    [ "edge.ppu_/wr",  "chr.rw"   ],
    [ "edge.ppu_/rd",  "chr./oe"   ],
    [ "edge.ppu_a13",  "chr.cs"   ],
              
]


    
};
