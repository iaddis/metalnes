/*
             .---v---.
      +5V -- |36   72| -- GND
 CIC toMB <- |35   71| <- CIC CLK
CIC toPak -> |34   70| <- CIC +RST
   PPU D3 <> |33   69| <> PPU D4
   PPU D2 <> |32   68| <> PPU D5
   PPU D1 <> |31   67| <> PPU D6
   PPU D0 <> |30   66| <> PPU D7
   PPU A0 -> |29   65| <- PPU A13
   PPU A1 -> |28   64| <- PPU A12
   PPU A2 -> |27   63| <- PPU A10
   PPU A3 -> |26   62| <- PPU A11
   PPU A4 -> |25   61| <- PPU A9
   PPU A5 -> |24   60| <- PPU A8
   PPU A6 -> |23   59| <- PPU A7
CIRAM A10 <- |22   58| <- PPU /A13
  PPU /RD -> |21   57| -> CIRAM /CE
    EXP 4    |20   56| <- PPU /WR
    EXP 3    |19   55|    EXP 5
    EXP 2    |18   54|    EXP 6
    EXP 1    |17   53|    EXP 7
    EXP 0    |16   52|    EXP 8
     /IRQ <- |15   51|    EXP 9
  CPU R/W -> |14   50| <- /ROMSEL (/A15 + /M2)
   CPU A0 -> |13   49| <> CPU D0
   CPU A1 -> |12   48| <> CPU D1
   CPU A2 -> |11   47| <> CPU D2
   CPU A3 -> |10   46| <> CPU D3
   CPU A4 -> |09   45| <> CPU D4
   CPU A5 -> |08   44| <> CPU D5
   CPU A6 -> |07   43| <> CPU D6
   CPU A7 -> |06   42| <> CPU D7
   CPU A8 -> |05   41| <- CPU A14
   CPU A9 -> |04   40| <- CPU A13
  CPU A10 -> |03   39| <- CPU A12
  CPU A11 -> |02   38| <- M2
      GND -- |01   37| <- SYSTEM CLK
             `-------'
*/




var module = {
    
name: "nes-cart72",
description: "NES 72-pin Cartrige connector",

pins: [
    [36,   'vcc'		],
    [35,   'cic_2mb'	],
    [34,   'cic_2pak'	],
    [33,   'ppu_d3'		],
    [32,   'ppu_d2'		],
    [31,   'ppu_d1'		],
    [30,   'ppu_d0'		],
    [29,   'ppu_a0'		],
    [28,   'ppu_a1'		],
    [27,   'ppu_a2'		],
    [26,   'ppu_a3'		],
    [25,   'ppu_a4'		],
    [24,   'ppu_a5'		],
    [23,   'ppu_a6'		],
    [22,   'ciram_a10'	],
    [21,   'ppu_/rd'	],
    [20,   'exp_4'		],
    [19,   'exp_3'		],
    [18,   'exp_2'		],
    [17,   'exp_1'		],
    [16,   'exp_0'		],
    [15,   '/irq'		],
    [14,   'cpu_r/w'	],
    [13,   'cpu_a0'		],
    [12,   'cpu_a1'		],
    [11,   'cpu_a2'		],
    [10,   'cpu_a3'		],
    [ 9,   'cpu_a4'		],
    [ 8,   'cpu_a5'		],
    [ 7,   'cpu_a6'		],
    [ 6,   'cpu_a7'		],
    [ 5,   'cpu_a8'		],
    [ 4,   'cpu_a9'		],
    [ 3,   'cpu_a10'	],
    [ 2,   'cpu_a11'	],
    [ 1,   'vss'		],


    [72,   'vss'		],
    [71,   'cic_clk'	],
    [70,   'cic_+rst'	],
    [69,   'ppu_d4'		],
    [68,   'ppu_d5'		],
    [67,   'ppu_d6'		],
    [66,   'ppu_d7'		],
    [65,   'ppu_a13'	],
    [64,   'ppu_a12'	],
    [63,   'ppu_a10'	],
    [62,   'ppu_a11'	],
    [61,   'ppu_a9'		],
    [60,   'ppu_a8'		],
    [59,   'ppu_a7'		],
    [58,   'ppu_/a13'	],
    [57,   'ciram_/ce'	],
    [56,   'ppu_/wr'	],
    [55,   'exp_5'		],
    [54,   'exp_6'		],
    [53,   'exp_7'		],
    [52,   'exp_8'		],
    [51,   'exp_9'		],
    [50,   '/romsel'	],
    [49,   'cpu_d0'		],
    [48,   'cpu_d1'		],
    [47,   'cpu_d2'		],
    [46,   'cpu_d3'		],
    [45,   'cpu_d4'		],
    [44,   'cpu_d5'		],
    [43,   'cpu_d6'		],
    [42,   'cpu_d7'		],
    [41,   'cpu_a14'	],
    [40,   'cpu_a13'	],
    [39,   'cpu_a12'	],
    [38,   'm2'			],
    [37,   'system_clk'	],
],
    
nodenames:
{
    vcc: 1,
    vss: 2,

    'm2':3,
    'system_clk':4,

    ppu_a0:10,
    ppu_a1:11,
    ppu_a2:12,
    ppu_a3:13,
    ppu_a4:14,
    ppu_a5:15,
    ppu_a6:16,
    ppu_a7:17,
    ppu_a8:18,
    ppu_a9:19,
    ppu_a10:20,
    ppu_a11:21,
    ppu_a12:22,
    ppu_a13:23,
    'ppu_/a13':24,

    'ciram_a10':25,
    'ciram_/ce':26,



    ppu_d0:30,
    ppu_d1:31,
    ppu_d2:32,
    ppu_d3:33,
    ppu_d4:34,
    ppu_d5:35,
    ppu_d6:36,
    ppu_d7:37,

    'ppu_/rd':38,
    'ppu_/wr':39,

    'cpu_r/w':101,
    '/irq':102,

    cpu_a0:110,
    cpu_a1:111,
    cpu_a2:112,
    cpu_a3:113,
    cpu_a4:114,
    cpu_a5:115,
    cpu_a6:116,
    cpu_a7:117,
    cpu_a8:118,
    cpu_a9:119,
    cpu_a10:120,
    cpu_a11:121,
    cpu_a12:122,
    cpu_a13:123,
    cpu_a14:124,
    '/romsel':125,

    cpu_d0:130,
    cpu_d1:131,
    cpu_d2:132,
    cpu_d3:133,
    cpu_d4:134,
    cpu_d5:135,
    cpu_d6:136,
    cpu_d7:137,



    'cic_2mb':200,
    'cic_2pak':201,
    'cic_clk':202,
    'cic_+rst':203,



    exp_0:400,
    exp_1:401,
    exp_2:402,
    exp_3:403,
    exp_4:404,
    exp_5:405,
    exp_6:406,
    exp_7:407,
    exp_8:408,
    exp_9:409,
}


    
};
