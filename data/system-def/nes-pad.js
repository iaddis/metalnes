/*
                     
 GND -- |O\          
 CLK <- |OO\ -- +5V  
 OUT <- |OO| <- D3   
  D0 -> |OO| <- D4   
        '--'         

*/




var module = {
    
name: "nes-pad",
description: "NES D-pad",
    
pins: [
    [ 1,   'vcc'   ],
    [ 2,   'd3'    ],    
    [ 3,   'd4'    ],
    [ 4,   'd0'    ],
    [ 5,   'out'    ],
    [ 6,   'clk'    ],    
    [ 7,   'vss'    ],
       
   [ 8,   'buttons0'        ],
   [ 9,   'buttons1'        ],
   [10,   'buttons2'    ],
   [11,   'buttons3'    ],
   [12,   'buttons4'      ],
   [13,   'buttons5'    ],
   [14,   'buttons6'    ],
   [15,   'buttons7'    ]
],
  
modules: [
  [ "shift",       "4021",        0]
],
    
connections: [
    ["shift.d[]", "buttons[]"],
    ["shift.q7",  "d0"],
    ["shift.CLK", "clk"],
    ["shift.PL",  "out"],
    ["shift.DS",  "vss"],

],
    
nodenames :
{
    vcc: 1,
    vss: 2,

    out:3,
    clk:4,
    d0:5,
    d3:6,
    d4:7,

    'buttons0': 10,
    'buttons1': 11,
    'buttons2': 12,
    'buttons3': 13,
    'buttons4': 14,
    'buttons5': 15,
    'buttons6': 16,
    'buttons7': 17,
},

segdefs :
[
//    [20,'+',0],
//    [21,'+',0],
//    [22,'+',0],
//    [23,'+',0],
//    [24,'+',0],
//    [25,'+',0],
//    [26,'+',0],
//    [27,'+',0],
],
    
transdefs:
[
//    ['t00',10,20,2],
//    ['t00',11,21,2],
//    ['t00',12,22,2],
//    ['t00',13,23,2],
//    ['t00',14,24,2],
//    ['t00',15,25,2],
//    ['t00',16,26,2],
//    ['t00',17,27,2],
]


    
};
