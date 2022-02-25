/*
74LS139 (demultiplexer / address decoder)

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


var module = {
    
name: "74LS139",
    
description: "demultiplexer / address decoder",
    
pins : [
    [ 1, '1/E'	],
    [ 2, '1A0'	],
    [ 3, '1A1'	],
    [ 4, '1/Y0'		],
    [ 5, '1/Y1'		],
    [ 6, '1/Y2'		],
    [ 7, '1/Y3'		],
    [ 8, 'vss'		],

    [16, 'vcc'  ],
    [15, '2/E'  ],
    [14, '2A0'  ],
    [13, '2A1'   ],
    [12, '2/Y0'   ],
    [11, '2/Y1'   ],
    [10, '2/Y2'   ],
    [ 9, '2/Y3'    ],
],

nodenames :
{

    /*
     1/E -o|1    16|-- Vcc
     1A0 --|2    15|o- 2/E
     1A1 --|3    14|-- 2A0
    1/Y0 -o|4    13|-- 2A1
    1/Y1 -o|5    12|o- 2/Y0
    1/Y2 -o|6    11|o- 2/Y1
    1/Y3 -o|7    10|o- 2/Y2
     GND --|8     9|o- 2/Y3
     */


    vcc: 1,
    vss: 2,


    '1E':   101,
    '1A0':  102,
    '1A1':  103,
    '1Y0':  104,
    '1Y1':  105,
    '1Y2':  106,
    '1Y3':  107,

    '1/E':  111,
    '1/A0': 112,
    '1/A1': 113,
    '1/Y0': 114,
    '1/Y1': 115,
    '1/Y2': 116,
    '1/Y3': 117,



    '2E':   201,
    '2A0':  202,
    '2A1':  203,
    '2Y0':  204,
    '2Y1':  205,
    '2Y2':  206,
    '2Y3':  207,

    '2/E':  211,
    '2/A0': 212,
    '2/A1': 213,
    '2/Y0': 214,
    '2/Y1': 215,
    '2/Y2': 216,
    '2/Y3': 217,

},

transdefs:
[

    /*
    /E    A1    A0    /Y0    /Y1    /Y2    /Y3
    0    0    0    0    1    1    1
    0    0    1    1    0    1    1
    0    1    0    1    1    0    1
    0    1    1    1    1    1    0
    1    x    x    1    1    1    1
    */


    // Y0 =  E && !A1 && !A0
    // Y1 =  E && !A1 &&  A0
    // Y2 =  E &&  A1 && !A0
    // Y3 =  E &&  A1 &&  A0

    // Y0 = !(/E || /A1 || /A0)
    ['t','1/E',          '1E',           2               ],
    ['t','1A0',          '1/A0',         2               ],
    ['t','1A1',          '1/A1',         2               ],
    ['t','1Y0',          '1/Y0',         2               ],
    ['t','1Y1',          '1/Y1',         2               ],
    ['t','1Y2',          '1/Y2',         2               ],
    ['t','1Y3',          '1/Y3',         2               ],

    ['t','2/E',          '2E',           2               ],
    ['t','2A0',          '2/A0',         2               ],
    ['t','2A1',          '2/A1',         2               ],
    ['t','2Y0',          '2/Y0',         2               ],
    ['t','2Y1',          '2/Y1',         2               ],
    ['t','2Y2',          '2/Y2',         2               ],
    ['t','2Y3',          '2/Y3',         2               ],
 
    ['t','1/E',          '1Y0',          2               ],
    ['t','1A0',          '1Y0',          2               ],
    ['t','1A1',          '1Y0',          2               ],
 
    ['t','1/E',          '1Y1',          2               ],
    ['t','1/A0',         '1Y1',          2               ],
    ['t','1A1',          '1Y1',          2               ],
 
    ['t','1/E',          '1Y2',          2               ],
    ['t','1A0',          '1Y2',          2               ],
    ['t','1/A1',         '1Y2',          2               ],
 
    ['t','1/E',          '1Y3',          2               ],
    ['t','1/A0',         '1Y3',          2               ],
    ['t','1/A1',         '1Y3',          2               ],
 
    ['t','2/E',          '2Y0',          2               ],
    ['t','2A0',          '2Y0',          2               ],
    ['t','2A1',          '2Y0',          2               ],
 
    ['t','2/E',          '2Y1',          2               ],
    ['t','2/A0',         '2Y1',          2               ],
    ['t','2A1',          '2Y1',          2               ],
 
    ['t','2/E',          '2Y2',          2               ],
    ['t','2A0',          '2Y2',          2               ],
    ['t','2/A1',         '2Y2',          2               ],
 
    ['t','2/E',          '2Y3',          2               ],
    ['t','2/A0',         '2Y3',          2               ],
    ['t','2/A1',         '2Y3',          2               ],

],
    
segdefs:
[
 ['1E'            , '+', 0],
 ['1Y0'           , '+', 0],
 ['1Y1'           , '+', 0],
 ['1Y2'           , '+', 0],
 ['1Y3'           , '+', 0],
 ['1/A0'          , '+', 0],
 ['1/A1'          , '+', 0],
 ['1/Y0'          , '+', 0],
 ['1/Y1'          , '+', 0],
 ['1/Y2'          , '+', 0],
 ['1/Y3'          , '+', 0],
 ['2E'            , '+', 0],
 ['2Y0'           , '+', 0],
 ['2Y1'           , '+', 0],
 ['2Y2'           , '+', 0],
 ['2Y3'           , '+', 0],
 ['2/A0'          , '+', 0],
 ['2/A1'          , '+', 0],
 ['2/Y0'          , '+', 0],
 ['2/Y1'          , '+', 0],
 ['2/Y2'          , '+', 0],
 ['2/Y3'          , '+', 0],

]


};