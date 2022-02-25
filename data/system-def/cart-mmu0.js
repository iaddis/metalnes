

var module = {
    
name: "cart-mmu0",
description: "NES Cartridge MMU0",

modules: [
  [ "edge",      "nes-cart72",   0],
],

connections: [
    //
    // internal to cart
    //
              
    // disable IRQ
    [ "edge./irq",    "edge.vcc"   ],
    
    // use VRAM for nametables
    [ "edge.ciram_/ce", "edge.ppu_/a13"   ],


    // vertical mirroring...
    [ "edge.ciram_a10", "edge.ppu_a10"   ],
    
    // horizontal mirroring
//    [ "edge.ciram_a10", "edge.ppu_a11"   ],

]


    
};
