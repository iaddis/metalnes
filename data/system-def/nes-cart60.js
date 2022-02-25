/*



*/




var module = {
    
name: "nes-cart60",
description: "NES 60-pin Cartrige connector",

pins: [
    [30,   'vcc'		],
    [29,   'ppu_d3'		],
    [28,   'ppu_d2'		],
    [27,   'ppu_d1'		],
    [26,   'ppu_d0'		],
    [25,   'ppu_a0'		],
    [24,   'ppu_a1'		],
    [23,   'ppu_a2'		],
    [22,   'ppu_a3'		],
    [21,   'ppu_a4'		],
    [20,   'ppu_a5'		],
    [19,   'ppu_a6'		],
    [18,   'ciram_a10'	],
    [17,   'ppu_/rd'	],
    [16,   'vss'    ],
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

    [60,   'ppu_d4'		],
    [59,   'ppu_d5'		],
    [58,   'ppu_d6'		],
    [57,   'ppu_d7'		],
    [56,   'ppu_a13'	],
    [55,   'ppu_a12'	],
    [54,   'ppu_a10'	],
    [53,   'ppu_a11'	],
    [52,   'ppu_a9'		],
    [51,   'ppu_a8'		],
    [50,   'ppu_a7'		],
    [49,   'ppu_/a13'	],
    [48,   'ciram_/ce'	],
    [47,   'ppu_/wr'	],
    [46,   'sound_i'  ],    
    [45,   'sound_o'  ],    
    [44,   '/romsel'	],
    [43,   'cpu_d0'		],
    [42,   'cpu_d1'		],
    [41,   'cpu_d2'		],
    [40,   'cpu_d3'		],
    [39,   'cpu_d4'		],
    [38,   'cpu_d5'		],
    [37,   'cpu_d6'		],
    [36,   'cpu_d7'		],
    [35,   'cpu_a14'	],
    [34,   'cpu_a13'	],
    [33,   'cpu_a12'	],
    [32,   'm2'			],
    [31,   'vcc'	],
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

    sound_i:500,
    sound_o:501,
}

    
};
