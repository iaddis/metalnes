/*
  NES system
*/




var module = {
    
name: "nes-001",
description: "Nintendo Entertainment System (rev 001)",

modules: [
  [ "ppu",       "2c02",        0],
  [ "cpu",       "2a03",        0],
  [ "u1",        "SRAM2K",      0],
  [ "u2",        "74LS373",     0],
  [ "u3",        "74LS139",     0],
  [ "u4",        "SRAM2K",      0],
  [ "u7",        "74LS368",     0],  // logic inverter
  [ "u8",        "74LS368",     0],  // logic inverter
  [ "u9",        "74HC04",      0],  // simple logic inverter
  [ "u10",       "nes-cic1",    0],
  [ "port0",     "nes-pad",     0],  // left controller port
  [ "port1",     "nes-pad",     0],  // right controller port
  [ "cart.edge", "nes-cart72",  0],  // cartridge interface


],

nodenames: {
  vcc: 1,
  vss: 2,
    
  'func<clock>': 8,
    
  'ppu.func<video_out>': 9,
  'cpu.func<audio_out>': 10,
    
  'clk' : 4,
  'res' : 5,
  '/ppures' : 6,
  '/cpures' : 7,

  'BD0' : 200,
  'BD1' : 201,
  'BD2' : 202,
  'BD3' : 203,
  'BD4' : 204,
  'BD5' : 205,
  'BD6' : 206,
  'BD7' : 207,

  'BA0' : 100,
  'BA1' : 101,
  'BA2' : 102,
  'BA3' : 103,
  'BA4' : 104,
  'BA5' : 105,
  'BA6' : 106,
  'BA7' : 107,
  'BA8' : 108,
  'BA9' : 109,
  'BA10' : 110,
  'BA11' : 111,
  'BA12' : 112,
  'BA13' : 113,
  'BA14' : 114,
  'BA15' : 115,
},
    
    
segdefs:
[
//    ['cpu.nmi','+',0],
//    ['ppu.int','+',0],
],
    
connections:
[
     // connect power and ground to all components
     [ "vss", "*.vss" ],
     [ "vcc", "*.vcc" ],

    [ "clk", "ppu.clk0" ],
    [ "clk", "cpu.clk_in" ],

    
    // ppu <-> cpu
    [ "ppu.io_ab[2:0]", "cpu.ab[2:0]" ],
    [ "ppu.io_db[7:0]", "cpu.db[7:0]" ],
    [ "cpu.nmi", "ppu.int" ],
    [ "cpu.rw", "ppu.io_rw" ],


    // set ppu exp pins to 0, this defines the background color when no BG/OBJ
    [ "vss", "ppu.exp_in[]" ],


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
     // _cpu_clk0 -> 14
     //_cpu_ab13 -> 2
     //_cpu_ab14 -> 3
     //_cpu_ab15 -> 13
     // 5 --> _ppu_io_ce
     // 4 --> _sram_io_cs
     // 1 --> 11
    */
            
    // connect CPU to address decoder U3
    [ "vss",      "u3.2/E" ],
    [ "cpu.clk0", "u3.2A0" ],
    [ "cpu.ab15", "u3.2A1" ],
    [ "u3.2/Y1",  "u3.1/E",],
    [ "cpu.ab13", "u3.1A0" ],
    [ "cpu.ab14", "u3.1A1" ],

    // decoder feeds into PPU  for writes to $2xxx
    [ "u3.1/Y1",  "ppu.io_ce" ],


    // connect cpu -> SRAM
    [ "cpu.ab[10:0]", "u1.a[10:0]"   ],
    [ "cpu.db[7:0]", "u1.d[7:0]"   ],

    [ "vss",     "u1./oe"   ],
    [ "cpu.rw",  "u1./we"   ],

    // decoder feeds into SRAM for writes to $0xxx
    [ "u3.1/Y0", "u1.cs"   ],

    [ "ppu.ale",   "u2.LE"   ],
    [ "vss",       "u2.OE"   ],
    [ "ppu.ab[7:0]",    "BD[7:0]"   ],
    
    // data -> latch
    [ "BD[7:0]",        "u2.d[7:0]"   ],
    

    // latch -> ppu address
    [ "u2.o[7:0]",      "BA[7:0]"   ],
    
    // connect ppu to address bus
    [ "ppu.ab[13:8]",   "BA[13:8]"   ],

    
  
    // wire up inverter for ppu a13
    [ "ppu.ab13",  "u9.3A"   ],
    [ "u9.3Y",     "cart.edge.ppu_/a13"   ],
    
    
    // data <->  VRAM
    [ "BD[7:0]",        "u4.d[7:0]"   ],
    [ "ppu.rd",    "u4./oe"   ],
    [ "ppu.wr",    "u4./we"   ],

    [ "BA[9:0]",        "u4.a[9:0]"   ],
    
              
  //
  // controller ports
  //


     // left controller
     [ "cpu.out0",   "port0.out" ],
  
     [ "u7./1OE",   "cpu.joy1" ],
     [ "u7./2OE",   "cpu.joy1" ],

     [ "u7.1A1",  "cpu.clk0"  ],
     [ "u7.1A2",  "port0.d0"  ],
     [ "u7.1A3",  "vcc"  ],
     [ "u7.1A4",  "vss"  ],
     [ "u7.2A1",  "vss"  ],
     [ "u7.2A2",  "vss"  ],
     
     [ "u7./1Y1", "port0.clk"  ],
     [ "u7./1Y2", "cpu.db0" ],
     [ "u7./1Y3", "cpu.db1"  ],
     [ "u7./1Y4", "cpu.db2"  ],
     [ "u7./2Y1", "cpu.db3"  ],
     [ "u7./2Y2", "cpu.db4"  ],

     
     // right controller
     [ "cpu.out0",   "port1.out" ],

     [ "u8./1OE",  "cpu.joy2" ],
     [ "u8./2OE",  "cpu.joy2" ],

     [ "u8.1A1",  "cpu.clk0"  ],
     [ "u8.1A2",  "port1.d0"  ],
     [ "u8.1A3",  "vcc"  ],
     [ "u8.1A4",  "vss"  ],
     [ "u8.2A1",  "vss"  ],
     [ "u8.2A2",  "vss"  ],
     
     [ "u8./1Y1", "port1.clk"  ],
     [ "u8./1Y2", "cpu.db0" ],
     [ "u8./1Y3", "cpu.db1"  ],
     [ "u8./1Y4", "cpu.db2"  ],
     [ "u8./2Y1", "cpu.db3"  ],
     [ "u8./2Y2", "cpu.db4"  ],
    
              
    // wire from cart to VRAM A10 and CS lines
    [ "cart.edge.ciram_a10", "u4.a10"   ],
    [ "cart.edge.ciram_/ce", "u4.cs"   ],
    
    [ "cart.edge.cpu_r/w",   "cpu.rw" ],
    [ "cart.edge.ppu_/rd",   "ppu.rd" ],
    [ "cart.edge.ppu_/wr",   "ppu.wr" ],
    [ "cart.edge.m2",        "cpu.clk0" ],
    [ "cart.edge./romsel",   "u3.2/Y3" ],
 
    // wire up /IRQ line
    [ "cart.edge./irq",      "cpu.irq" ],
 
 
    [ "cart.edge.cpu_a[14:0]",     "cpu.ab[14:0]" ],
    [ "cart.edge.cpu_d[7:0]",      "cpu.db[7:0]" ],
    [ "cart.edge.ppu_a[13:0]",     "BA[13:0]" ],
    [ "cart.edge.ppu_d[7:0]",      "BD[7:0]" ],

 
    // wire from cart to cic
    [ "cart.edge.cic_2mb",  "u10.cic_2mb"   ],
    [ "cart.edge.cic_2pak", "u10.cic_2pak"   ],
    [ "cart.edge.cic_clk",  "u10.cic_clk0"   ],
    [ "cart.edge.cic_+rst", "u10.cic_rst1"   ],
 
 
    // connect reset switch to cic
    [ "res",     "u10.cic_rst_in" ],

    // hook cic up to ppu/cpu reset 
    [ "u10.cic_rst1",     "ppu.res" ],
    [ "u10.cic_rst1",     "cpu.res" ],

 

],
    

    
};


