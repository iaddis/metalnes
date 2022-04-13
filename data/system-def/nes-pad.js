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
    [ 1,   'vss'        ],
    [ 2,   'oe'    ],
    [ 3,   'out'    ],
    [ 4,   'd0'        ],
    [ 5,   'vcc'        ],
    [ 6,   'd3'        ],
    [ 7,   'd4'        ],
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
    ["d1",  "vcc"],
    ["d2",  "vss"],
    ["d3",  "vss"],
    ["d4",  "vss"],

],
    
nodenames :
{
    vcc: 1,
    vss: 2,

    out:3,
    clk:4,
    oe:4,
    d0:5,
    d1:6,
    d2:7,
    d3:8,
    d4:9,


    
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
