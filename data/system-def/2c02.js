/*

    2C02

          ___  ___
         |*  \/   |
 R/W  >01]        [40<  VCC
  D0  [02]        [39>  ALE
  D1  [03]        [38]  AD0
  D2  [04]        [37]  AD1
  D3  [05]        [36]  AD2
  D4  [06]        [35]  AD3
  D5  [07]        [34]  AD4
  D6  [08]        [33]  AD5
  D7  [09]        [32]  AD6
  A2  >10]  2C02  [31]  AD7
  A1  >11]        [30>  A8
  A0  >12]        [29>  A9
 /CS  >13]        [28>  A10
EXT0  [14]        [27>  A11
EXT1  [15]        [26>  A12
EXT2  [16]        [25>  A13
EXT3  [17]        [24>  /R
 CLK  >18]        [23>  /W
/VBL  <19]        [22<  /SYNC
 VEE  >20]        [21>  VOUT
          ________|
*/


var module = {
    
name: "2C02",
    
description: "NES custom PPU",
    
pins : [
    [ 1, 'io_rw'	],
    [ 2, 'io_db0'	],
    [ 3, 'io_db1'	],
    [ 4, 'io_db2'	],
    [ 5, 'io_db3'	],
    [ 6, 'io_db4'	],
    [ 7, 'io_db5'	],
    [ 8, 'io_db6'	],
    [ 9, 'io_db7'   ],
    [10, 'io_ab2'   ],
    [11, 'io_ab1'   ],
    [12, 'io_ab0'   ],
    [13, 'io_ce'    ],
    [14, 'exp0'     ],
    [15, 'exp1'     ],
    [16, 'exp2'     ],
    [17, 'exp3'     ],
    [18, 'clk0'     ],
    [19, 'int'      ],
    [20, 'vss'      ],

    [40, 'vcc'  ],
    [39, 'ale'  ],
    [38, 'ab0'  ],
    [37, 'ab1'  ],
    [36, 'ab2'  ],
    [35, 'ab3'  ],
    [34, 'ab4'  ],
    [33, 'ab5'  ],
    [32, 'ab6'  ],
    [31, 'ab7'  ],
    [30, 'ab8'  ],
    [29, 'ab9'  ],
    [28, 'ab10' ],
    [27, 'ab11' ],
    [26, 'ab12' ],
    [25, 'ab13' ],
    [24, 'rd'   ],
    [23, 'wr'   ],
    [22, 'sync' ],
    [21, 'vid'  ],
],

segdefs:
[
    ['int','+',0],  // pull up interrupt pin (cpu.nmi)
],


transdefs: [
  ['t4041',         'vid_sync_l',            'vid',                   'vss',                   [1312,1414,6582,6687],[207,197,5,2,1010],false],
  ['t4415',         'vid_sync_h',            'vid',                   'vss',                   [1228,1424,6554,6559],[196,196,5,1,980],false],
  ['t4630',         'vid_burst_l',           'vid',                   'vss',                   [1228,1424,6472,6477],[196,196,5,1,980],false],
  ['t4748',         'vid_burst_h',           'vid',                   'vss',                   [1228,1424,6447,6452],[196,196,5,1,980],false],
  ['t6093',         'vid_luma0_l',           'vid',                   'vss',                   [1228,1423,6061,6066],[195,195,5,1,975],false],
  ['t6216',         'vid_luma0_h',           'vid',                   'vss',                   [1228,1423,6036,6041],[195,195,5,1,975],false],
  ['t6576',         'vid_luma3_h',           'vid',                   'vss',                   [1228,1424,5909,5914],[196,196,5,1,980],false],
  ['t6623',         'vid_luma3_l',           'vid',                   'vss',                   [1228,1424,5884,5889],[196,196,5,1,980],false],
  ['t6836',         'vid_luma1_l',           'vid',                   'vss',                   [1228,1423,5756,5761],[195,195,5,1,975],false],
  ['t6886',         'vid_luma1_h',           'vid',                   'vss',                   [1228,1423,5731,5736],[195,195,5,1,975],false],
  ['t7167',         'vid_luma2_l',           'vid',                   'vss',                   [1228,1423,5604,5609],[195,195,5,1,975],false],
  ['t7209',         'vid_luma2_h',           'vid',                   'vss',                   [1228,1423,5579,5584],[195,195,5,1,975],false],
],

nodenames_files:   ["2c02/nodenames.js", "2c02/nodenames_palram.js", "2c02/nodenames_oamram.js"],
transdefs_files:  ["2c02/transdefs_named.js"],
segdefs_files:    ["2c02/segdefs.js"],

forceCompute:[
      "spr_d[]",
  ],
    
};
