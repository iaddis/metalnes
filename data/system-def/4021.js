/*
    4021 


*/


var module = {
    
name: "4021",
description: "8-stage static shift register",
    
pins : [
    [ 1, 'd7'	],
    [ 2, 'q5'	],
    [ 3, 'q7'	],
    [ 4, 'd3'		],
    [ 5, 'd2'		],
    [ 6, 'd1'		],
    [ 7, 'd0'		],
    [ 8, 'vss'		],

    [16, 'vcc'  ],
    [15, 'd6'  ],
    [14, 'd5'  ],
    [13, 'd4'   ],
    [12, 'q6'   ],
    [11, 'DS'   ],
    [10, 'CLK'   ],
    [ 9, 'PL'    ],
],

    

modules: [
  [ "L0",       "pslatch",        0],
  [ "L1",       "pslatch",        0],
  [ "L2",       "pslatch",        0],
  [ "L3",       "pslatch",        0],
  [ "L4",       "pslatch",        0],
  [ "L5",       "pslatch",        0],
  [ "L6",       "pslatch",        0],
  [ "L7",       "pslatch",        0],
          
],

    
    
    
nodenames:
{
    vcc: 1,
    vss: 2,
    
//    'func<shift>':5,

    'clk'   : 3,
    'CLK'   : 3,
    'DS'    : 4,
    'PL'    : 12,
    
    'd0'    : 20,
    'd1'    : 21,
    'd2'    : 22,
    'd3'    : 23,
    'd4'    : 24,
    'd5'    : 25,
    'd6'    : 26,
    'd7'    : 27,

    'q5'    : 35,
    'q6'    : 36,
    'q7'    : 37,
},
    
connections:
[
 // this ordering from 7 to 0 is important for the shifting to work
 ["CLK", "L7.clk"],
 ["CLK", "L6.clk"],
 ["CLK", "L5.clk"],
 ["CLK", "L4.clk"],
 ["CLK", "L3.clk"],
 ["CLK", "L2.clk"],
 ["CLK", "L1.clk"],
 ["CLK", "L0.clk"],
 
 ["vss",  "L0.d"],
 ["L0.q", "L1.d"],
 ["L1.q", "L2.d"],
 ["L2.q", "L3.d"],
 ["L3.q", "L4.d"],
 ["L4.q", "L5.d"],
 ["L5.q", "L6.d"],
 ["L6.q", "L7.d"],
 

 ["L5.q", "q5"],
 ["L6.q", "q6"],
 ["L7.q", "q7"],

 
 ["d[7:0]", "L[7:0].p"],
 ["PL", "L[7:0].ps"],

],
    
    
};
