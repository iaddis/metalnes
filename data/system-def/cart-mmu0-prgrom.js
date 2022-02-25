

var module = {
    
name: "cart-mmu0-prgrom",
description: "NES Cartridge PRG ROM 32K",

modules: [
  [ "edge",      "nes-cart72",   0],
  [ "prg",       "ROM32K",      0],
],

connections: [
    //
    // internal to cart
    //
              
    // cart -> PRGROM
    [ "edge.cpu_a[14:0]",   "prg.a[14:0]"   ],
    [ "edge.cpu_d[7:0]",    "prg.d[7:0]"    ],
    [ "edge.cpu_r/w",       "prg.rw"        ],
    [ "edge.vss",           "prg./oe"       ],
    [ "edge./romsel",       "prg.cs"        ],
]


    
};
