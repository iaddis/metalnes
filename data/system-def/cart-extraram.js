

var module = {
    
name: "cart-extraram",
description: "NES Cartridge extra RAM at $6000",

modules: [
  [ "edge",       "nes-cart72",   0],
  [ "eram",       "SRAM8K",      0],
  [ "u3",         "74LS139",     0],
],

connections: [

              
      /*
                .---v---.
          1/E -o|1    16|-- Vcc
          1A0 --|2    15|o- 2/E
          1A1 --|3    14|-- 2A0
         1/Y0 -o|4    13|-- 2A1
         1/Y1 -o|5    12|o- 2/Y0
         1/Y2 -o|6    11|o- 2/Y1
         1/Y3 -o|7    10|o- 2/Y2
          GND --|8     9|o- 2/Y3
                `-------'
      */
              
      // connect CPU address lines to address decoder U3
      [ "edge.vss",         "u3.2/E" ],
      [ "edge./romsel",     "u3.2A0" ],
      [ "edge.system_clk",  "u3.2A1" ],
      [ "u3.2/Y1",          "u3.1/E",],
      [ "edge.cpu_a13",     "u3.1A0" ],
      [ "edge.cpu_a14",     "u3.1A1" ],
      
      // $6000 -> extra ram
      [ "edge.cpu_a[12:0]",    "eram.a[12:0]"   ],
      [ "edge.cpu_d[7:0]",     "eram.d[7:0]"   ],
      [ "edge.cpu_r/w",        "eram./we"   ],
      [ "edge.vss",            "eram./oe"   ],
              
      // address decoder output -> extra ram chip select
      [ "u3.1/Y3",             "eram.cs"   ],

              
]


    
};
