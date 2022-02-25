/*
    pslatch


*/


var module = {
    
name: "pslatch",
description: "A single latch with parallel/serial control",
    
pins : [
    [ 1, 'd'	],      // serial data
    [ 2, 'q'	],      // output value
    [ 3, 'p'	],      // parallel data
    [ 4, 'clk'	],      // if (0->1), load latch with d
    [ 5, 'ps'    ],     // if 1, load latch with p
    [ 6, 'clk_out'    ],      // clk output
],

nodenames:
{
    vcc: 1,
    vss: 2,

    'clk_out' : 5,
    'p'     : 6,
    'clk'     : 7,
    'ps'     : 8,
    '/ps'    : 15,
    '/p'     : 16,

    'd'      : 9,
    '/d'    : 10,
    'q'     : 11,
    '/q'    : 12,
    'set'   : 13,
    'reset' : 14,
    'd+'    : 17,
    'p+'    : 18,

    '/clk'   : 20,
    '/clk+'   : 21,
    '/clk++'  : 22,
    '/clk+++'  : 23,
    
    'strobe' : 25,



},
    
pullups:
[
 '/d',
 'd+',
 '/ps',
 '/p',
 'p+',
  'q',
  '/q',
 
  '/clk',
  '/clk+',
  '/clk++',
  '/clk+++',
  'strobe',
],
    
    
transdefs:
[
 
    // invert inputs
    ['~','d',        '/d',          2               ],
    ['~','/d',       'd+',          2               ],
    ['~','clk',      '/clk',            2               ],
    ['~','ps',       '/ps',            2               ],
    ['~','p',        '/p',            2               ],
    ['~','/p',       'p+',            2               ],

 
    // cross-coupled inverter
    ['~','q',         '/q',          2               ],
    ['~','/q',        'q',          2               ],
 
    // set/reset lines control the cross coupled inverter
    ['t','set',       '/q',          2               ],
    [ 't','reset',     'q',           2               ],

    // strobe = clk && (buffered clock)
    // this causes strobe high on 0->1 transition of clk
    ['t','/clk',      'strobe',          2               ],
    ['t','/clk+++',    'strobe',          2               ],

 
    // disable strobe if ps is high
    ['t','ps',       'strobe',            2               ],

    // feed strobe + data into set/reset
    ['t','strobe',     'd+',            'set'               ],
    ['t','strobe',     '/d',           'reset'               ],

    // feed parallel/serial control + p into set/reset
    ['t','ps',          'p+',           'set'               ],
    ['t','ps',          '/p',          'reset'               ],

 
     // invert clock 3 times to buffer it
     ['~','/clk',      '/clk+',           2               ],
     ['~','/clk+',     '/clk++',          2               ],
     ['~','/clk++',    '/clk+++',          2               ],

     ['t', 1, 'clk',    'clk_out'             ],


],

    
};
