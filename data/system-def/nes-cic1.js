/*
    nes-cic1
*/


var module = {
    
name: "nes-cic1",
    
description: "Nintendo CIC security chip",
    
pins : [
    [ 1, 'cic_2pak'	],
    [ 2, 'cic_2mb'	],
    [ 3, 'cic_seed'	],
    [ 4, 'vcc'		],
    [ 5, 'vss'		],
    [ 6, 'cic_clk0'		],
    [ 7, 'cic_rst_in'		],
    [ 8, 'vss'		],

    [16, 'vcc'  ],
    [15, 'vss'  ],
    [14, 'vss'  ],
    [13, 'vss'   ],
    [12, 'vss'   ],
    [11, 'vss'   ],
    [10, 'cic_rst1'   ],
    [ 9, 'cic_rst0'    ],
],

nodenames:
{
    vcc: 1,
    vss: 2,

    'cic_2pak'    : 10,
    'cic_2mb'     : 11,
    'cic_seed'    : 12,
    
    'cic_clk0'    : 13,
    'cic_rst_in'  : 14,
    'cic_rst0'    : 15,
    'cic_rst1'    : 16,
},

    
    
transdefs:
[
    // cic_rst_in inverter -> /cic_rst1
    ['t','cic_rst_in','cic_rst1',2],
],

segdefs:
[
    ['cic_rst1','+',0],
],

    
};
