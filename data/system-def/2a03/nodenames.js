
var nodenames ={
// power pins
vcc:10000,
vss:10001,

// other external pins
res:10004,
rw:10092,
db0:11819,
db1:11966,
db2:12056,
db3:12091,
db4:12090,
db5:12089,
db6:12088,
db7:12087,
ab0:10020,
ab1:10019,
ab2:10030,
ab3:10091,
ab4:10335,
ab5:10489,
ab6:10727,
ab7:11521,
ab8:11628,
ab9:11817,
ab10:11965,
ab11:12055,
ab12:12084,
ab13:12083,
ab14:12085,
ab15:12086,
clk_in:11669,
phi2:10743,
nmi:10331,
irq:10488,
dbg:11214,
out0:10007,
out1:10008,
out2:10005,
joy1:10006,
joy2:10029,
snd1:10018,
snd2:10017,

// the current macros.js needs these
rdy:10758,
so:11246,
sync:11547,

// clocks
clk0:11235,
clk1out:10357,
clk2out:10843,

// 6502 pins
c_res: 159,       // pads: reset
c_rw: 1156,       // pads: read not write
c_db0: 1005,      // pads: databus
c_db1: 82,
c_db3: 650,
c_db2: 945,
c_db5: 175,
c_db4: 1393,
c_db7: 1349,
c_db6: 1591,
c_ab0: 268,       // pads: address bus
c_ab1: 451,
c_ab2: 1340,
c_ab3: 211,
c_ab4: 435,
c_ab5: 736,
c_ab6: 887,
c_ab7: 1493,
c_ab8: 230,
c_ab9: 148,
c_ab12: 1237,
c_ab13: 349,
c_ab10: 1443,
c_ab11: 399,
c_ab14: 672,
c_ab15: 195,
c_sync: 539,      // pads
c_so: 1672,       // pads: set overflow
c_clk0: 1171,     // pads
c_clk1out: 1163,  // pads
c_clk2out: 421,   // pads
c_rdy: 89,        // pads: ready
c_nmi: 1297,      // pads: non maskable interrupt
c_irq: 103,       // pads

// 6502 internals
a0: 737,        // machine state: accumulator
a1: 1234,
a2: 978,
a3: 162,
a4: 727,
a5: 858,
a6: 1136,
a7: 1653,
y0: 64,         // machine state: y index register
y1: 1148,
y2: 573,
y3: 305,
y4: 989,
y5: 615,
y6: 115,
y7: 843,
x0: 1216,       // machine state: x index register
x1: 98,
x2: 1,
x3: 1648,
x4: 85,
x5: 589,
x6: 448,
x7: 777,
pcl0: 1139,     // machine state: program counter low (first storage node output)
pcl1: 1022,
pcl2: 655,
pcl3: 1359,
pcl4: 900,
pcl5: 622,
pcl6: 377,
pcl7: 1611,
pclp0: 488,    // machine state: program counter low (pre-incremented?, second storage node)
pclp1: 976,
pclp2: 481,
pclp3: 723,
pclp4: 208,
pclp5: 72,
pclp6: 1458,
pclp7: 1647,
"#pclp0": 1227,    // machine state: program counter low (pre-incremented?, inverse second storage node)
"~pclp0": 1227,     // automatic alias replacing hash with tilde
"#pclp1": 1102,
"~pclp1": 1102, // automatic alias replacing hash with tilde
"#pclp2": 1079,
"~pclp2": 1079, // automatic alias replacing hash with tilde
"#pclp3": 868,
"~pclp3": 868, // automatic alias replacing hash with tilde
"#pclp4": 39,
"~pclp4": 39, // automatic alias replacing hash with tilde
"#pclp5": 1326,
"~pclp5": 1326, // automatic alias replacing hash with tilde
"#pclp6": 731,
"~pclp6": 731, // automatic alias replacing hash with tilde
"#pclp7": 536,
"~pclp7": 536, // automatic alias replacing hash with tilde
pch0: 1670,     // machine state: program counter high (first storage node)
pch1: 292,
pch2: 502,
pch3: 584,
pch4: 948,
pch5: 49,
pch6: 1551,
pch7: 205,
pchp0: 1722,     // machine state: program counter high (pre-incremented?, second storage node output)
pchp1: 209,
pchp2: 1496,
pchp3: 141,
pchp4: 27,
pchp5: 1301,
pchp6: 652,
pchp7: 1206,
"#pchp0": 780,     // machine state: program counter high (pre-incremented?, inverse second storage node)
"~pchp0": 780,      // automatic alias replacing hash with tilde
"#pchp1": 113,
"~pchp1": 113, // automatic alias replacing hash with tilde
"#pchp2": 114,
"~pchp2": 114, // automatic alias replacing hash with tilde
"#pchp3": 124,
"~pchp3": 124, // automatic alias replacing hash with tilde
"#pchp4": 820,
"~pchp4": 820, // automatic alias replacing hash with tilde
"#pchp5": 33,
"~pchp5": 33, // automatic alias replacing hash with tilde
"#pchp6": 751,
"~pchp6": 751, // automatic alias replacing hash with tilde
"#pchp7": 535,
"~pchp7": 535, // automatic alias replacing hash with tilde
                // machine state: status register (not the storage nodes)
p0: 32,         // C bit of status register (storage node)
p1: 627,        // Z bit of status register (storage node)
p2: 1553,       // I bit of status register (storage node)
p3: 348,        // D bit of status register (storage node)
p4: 1119,       // there is no bit4 in the status register! (not a storage node)
p5: -1,         // there is no bit5 in the status register! (not a storage node)
p6: 77,         // V bit of status register (storage node)
p7: 1370,       // N bit of status register (storage node)

                // internal bus: status register outputs for push P
Pout0: 687,
Pout1: 1444,
Pout2: 1421,
Pout3: 439,
Pout4: 1119,    // there is no bit4 in the status register!
Pout5: -1,      // there is no bit5 in the status register!
Pout6: 77,
Pout7: 1370,

s0: 1403,       // machine state: stack pointer
s1: 183,
s2: 81,
s3: 1532,
s4: 1702,
s5: 1098,
s6: 1212,
s7: 1435,
ir0: 328,       // internal state: instruction register
ir1: 1626,
ir2: 1384,
ir3: 1576,
ir4: 1112,
ir5: 1329,      // ir5 distinguishes branch set from branch clear
ir6: 337,
ir7: 1328,
notir0: 194,    // internal signal: instruction register inverted outputs
notir1: 702,
notir2: 1182,  
notir3: 1125,  
notir4: 26,
notir5: 1394,
notir6: 895,
notir7: 1320,
irline3: 996,   // internal signal: PLA input - ir0 AND ir1
clock1: 1536,   // internal state: timing control aka #T0
clock2: 156,    // internal state: timing control aka #T+
t2: 971,        // internal state: timing control
t3: 1567,
t4: 690,
t5: 909,
noty0: 1025,    // datapath state: not Y register
noty1: 1138,
noty2: 1484,
noty3: 184,
noty4: 565,
noty5: 981,
noty6: 1439,
noty7: 1640,
notx0: 987,     // datapath state: not X register
notx1: 1434,
notx2: 890,
notx3: 1521,
notx4: 485,
notx5: 1017,
notx6: 730,
notx7: 1561,
nots0: 418,     // datapath state: not stack pointer
nots1: 1064,
nots2: 752,
nots3: 828,
nots4: 1603,
nots5: 601,
nots6: 1029,
nots7: 181,
notidl0: 116,   // datapath state: internal data latch (first storage node)
notidl1: 576,
notidl2: 1485,
notidl3: 1284,
notidl4: 1516,
notidl5: 498,
notidl6: 1537,
notidl7: 529,
idl0: 1597,     // datapath signal: internal data latch (driven output)
idl1: 870,
idl2: 1066,
idl3: 464,
idl4: 1306,
idl5: 240,
idl6: 1116,
idl7: 391,
sb0: 54,        // datapath bus: special bus
sb1: 1150,
sb2: 1287,
sb3: 1188,
sb4: 1405,
sb5: 166,
sb6: 1336,
sb7: 1001,
notalu0: 394,   // datapath state: alu output storage node (inverse) aka #ADD0
notalu1: 697,
notalu2: 276,
notalu3: 495,
notalu4: 1490,
notalu5: 893,
notalu6: 68,
notalu7: 1123,
alu0: 401,      // datapath signal: ALU output aka ADD0out
alu1: 872,
alu2: 1637,
alu3: 1414,
alu4: 606,
alu5: 314,
alu6: 331,
alu7: 765,
		// datapath signal: decimally adjusted special bus
dasb0: 54,      // same node as sb0
dasb1: 1009,
dasb2: 450,
dasb3: 1475,
dasb4: 1405,    // same node as sb4
dasb5: 263,
dasb6: 679,
dasb7: 1494,
adl0: 413,      // internal bus: address low
adl1: 1282,
adl2: 1242,
adl3: 684,
adl4: 1437,
adl5: 1630,
adl6: 121,
adl7: 1299,
adh0: 407,      // internal bus: address high
adh1: 52,
adh2: 1651,
adh3: 315,
adh4: 1160,
adh5: 483,
adh6: 13,
adh7: 1539,
idb0: 1108,     // internal bus: data bus
idb1: 991,
idb2: 1473,
idb3: 1302,
idb4: 892,
idb5: 1503,
idb6: 833,
idb7: 493,
notdor0: 222,   // internal state: data output register (storage node)
notdor1: 527,
notdor2: 1288,
notdor3: 823,
notdor4: 873,
notdor5: 1266,
notdor6: 1418,
notdor7: 158,
dor0: 97,       // internal signal: data output register
dor1: 746,
dor2: 1634,
dor3: 444,
dor4: 1088,
dor5: 1453,
dor6: 1415,
dor7: 63,
"pd0.clearIR": 1622,       // internal state: predecode register output (anded with not ClearIR)
"pd1.clearIR": 809,
"pd2.clearIR": 1671,
"pd3.clearIR": 1587,
"pd4.clearIR": 540,
"pd5.clearIR": 667,
"pd6.clearIR": 1460,
"pd7.clearIR": 1410,
pd0: 758,       // internal state: predecode register (storage node)
pd1: 361,
pd2: 955,
pd3: 894,
pd4: 369,
pd5: 829,
pd6: 1669,
pd7: 1690,
                // internal signals: predecode latch partial decodes
"PD-xxxx10x0": 1019,
"PD-1xx000x0": 1294,
"PD-0xx0xx0x": 365,
"PD-xxx010x1": 302,
"PD-n-0xx0xx0x": 125,
"#TWOCYCLE": 851,
"~TWOCYCLE": 851, // automatic alias replacing hash with tilde
"#TWOCYCLE.phi1": 792,
"~TWOCYCLE.phi1": 792, // automatic alias replacing hash with tilde
"ONEBYTE": 778,

abl0: 1096,     // internal bus: address bus low latched data out (inverse of inverted storage node)
abl1: 376,
abl2: 1502,
abl3: 1250,
abl4: 1232,
abl5: 234,
abl6: 178,
abl7: 567,
"#ABL0": 153,   // internal state: address bus low latched data out (storage node, inverted)
"~ABL0": 153,    // automatic alias replacing hash with tilde
"#ABL1": 107,
"~ABL1": 107, // automatic alias replacing hash with tilde
"#ABL2": 707,
"~ABL2": 707, // automatic alias replacing hash with tilde
"#ABL3": 825,
"~ABL3": 825, // automatic alias replacing hash with tilde
"#ABL4": 364,
"~ABL4": 364, // automatic alias replacing hash with tilde
"#ABL5": 1513,
"~ABL5": 1513, // automatic alias replacing hash with tilde
"#ABL6": 1307,
"~ABL6": 1307, // automatic alias replacing hash with tilde
"#ABL7": 28,
"~ABL7": 28, // automatic alias replacing hash with tilde
abh0: 1429,     // internal bus: address bus high latched data out (inverse of inverted storage node)
abh1: 713,
abh2: 287,
abh3: 422,
abh4: 1143,
abh5: 775,
abh6: 997,
abh7: 489,
"#ABH0": 1062,  // internal state: address bus high latched data out (storage node, inverted)
"~ABH0": 1062,   // automatic alias replacing hash with tilde
"#ABH1": 907,
"~ABH1": 907, // automatic alias replacing hash with tilde
"#ABH2": 768,
"~ABH2": 768, // automatic alias replacing hash with tilde
"#ABH3": 92,
"~ABH3": 92, // automatic alias replacing hash with tilde
"#ABH4": 668,
"~ABH4": 668, // automatic alias replacing hash with tilde
"#ABH5": 1128,
"~ABH5": 1128, // automatic alias replacing hash with tilde
"#ABH6": 289,
"~ABH6": 289, // automatic alias replacing hash with tilde
"#ABH7": 429,
"~ABH7": 429, // automatic alias replacing hash with tilde

"branch-back": 626,           // distinguish forward from backward branches
"branch-forward.phi1": 1110,  // distinguish forward from backward branches
"branch-back.phi1": 771,      // distinguish forward from backward branches in IPC logic
notRdy0: 248,           // internal signal: global pipeline control
"notRdy0.phi1": 1272,   // delayed pipeline control
"notRdy0.delay": 770,   // global pipeline control latched by phi1 and then phi2
"#notRdy0.delay": 559,  // global pipeline control latched by phi1 and then phi2 (storage node)
"~notRdy0.delay": 559,   // automatic alias replacing hash with tilde
Reset0: 67,     // internal signal: retimed reset from pin
C1x5Reset: 926, // retimed and pipelined reset in progress
notRnWprepad: 187, // internal signal: to pad, yet to be inverted and retimed
RnWstretched: 353, // internal signal: control datapad output drivers, aka TRISTATE
"#DBE": 1035,      // internal signal: formerly from DBE pad (6501)
"~DBE": 1035,       // automatic alias replacing hash with tilde
cp1: 710,       // internal signal: clock phase 1
cclk: 943,      // unbonded pad: internal non-overlappying phi2
fetch: 879,     // internal signal
clearIR: 1077,  // internal signal
H1x1: 1042,     // internal signal: drive status byte onto databus

                // internal signal: pla outputs block 1 (west/left edge of die)
                // often 130 pla outputs are mentioned - we have 131 here
"op-sty/cpy-mem": 1601,        // pla0
"op-T3-ind-y": 60,             // pla1
"op-T2-abs-y": 1512,           // pla2
"op-T0-iny/dey": 382,          // pla3
"x-op-T0-tya": 1173,           // pla4
"op-T0-cpy/iny": 1233,         // pla5

                // internal signal: pla outputs block 2
"op-T2-idx-x-xy": 258,         // pla6
"op-xy": 1562,                 // pla7
"op-T2-ind-x": 84,             // pla8
"x-op-T0-txa": 1543,           // pla9
"op-T0-dex": 76,               // pla10
"op-T0-cpx/inx": 1658,         // pla11
"op-from-x": 1540,             // pla12
"op-T0-txs": 245,              // pla13
"op-T0-ldx/tax/tsx": 985,      // pla14
"op-T+-dex": 786,              // pla15
"op-T+-inx": 1664,             // pla16
"op-T0-tsx": 682,              // pla17
"op-T+-iny/dey": 1482,         // pla18
"op-T0-ldy-mem": 665,          // pla19
"op-T0-tay/ldy-not-idx": 286,  // pla20

                // internal signal: pla outputs block 3
                // not pla, feed through
"op-T0-jsr": 271,              // pla21
"op-T5-brk": 370,              // pla22
"op-T0-php/pha": 552,          // pla23
"op-T4-rts": 1612,             // pla24
"op-T3-plp/pla": 1487,         // pla25
"op-T5-rti": 784,              // pla26
"op-ror": 244,                 // pla27
"op-T2": 788,                  // pla28
"op-T0-eor": 1623,             // pla29
"op-jmp": 764,                 // pla30
"op-T2-abs": 1057,             // pla31
"op-T0-ora": 403,              // pla32
"op-T2-ADL/ADD":204,           // pla33 
"op-T0":1273,                  // pla34 
"op-T2-stack":1582,            // pla35 
"op-T3-stack/bit/jmp":1031,    // pla36 

                // internal signal: pla outputs block 4
"op-T4-brk/jsr":804,           //  pla37
"op-T4-rti":1311,              //  pla38
"op-T3-ind-x":1428,            //  pla39
"op-T4-ind-y":492,             //  pla40
"op-T2-ind-y":1204,            //  pla41
"op-T3-abs-idx":58,            //  pla42
"op-plp/pla":1520,             //  pla43
"op-inc/nop":324,              //  pla44
"op-T4-ind-x":1259,            //  pla45
"x-op-T3-ind-y":342,           //  pla46
"op-rti/rts":857,              //  pla47
"op-T2-jsr":712,               //  pla48
"op-T0-cpx/cpy/inx/iny":1337,  //  pla49
"op-T0-cmp":1355,              //  pla50
"op-T0-sbc":787,               //  pla51   //  52:111XXXXX  1  0  T0SBC
"op-T0-adc/sbc":575,           //  pla52   //  51:X11XXXXX  1  0  T0ADCSBC
"op-rol/ror":1466,             //  pla53

                // internal signal: pla outputs block 5
"op-T3-jmp":1381,              //  pla54
"op-shift":546,                //  pla55
"op-T5-jsr":776,               //  pla56
"op-T2-stack-access":157,      //  pla57
"op-T0-tya":257,               //  pla58
"op-T+-ora/and/eor/adc":1243,  //  pla59
"op-T+-adc/sbc":822,           //  pla60
"op-T+-shift-a":1324,          //  pla61
"op-T0-txa":179,               //  pla62
"op-T0-pla":131,               //  pla63
"op-T0-lda":1420,              //  pla64
"op-T0-acc":1342,              //  pla65
"op-T0-tay":4,                 //  pla66
"op-T0-shift-a":1396,          //  pla67
"op-T0-tax":167,               //  pla68
"op-T0-bit":303,               //  pla69
"op-T0-and":1504,              //  pla70
"op-T4-abs-idx":354,           //  pla71
"op-T5-ind-y":1168,            //  pla72

                // internal signal: pla outputs block 6
"op-branch-done":1721,         //  pla73    // has extra non-pla input
"op-T2-pha":1086,              //  pla74
"op-T0-shift-right-a":1074,    //  pla75
"op-shift-right":1246,         //  pla76
"op-T2-brk":487,               //  pla77
"op-T3-jsr":579,               //  pla78
"op-sta/cmp":145,              //  pla79
"op-T2-branch":1239,           //  pla80      //  T2BR, 83 for Balazs
"op-T2-zp/zp-idx":285,         //  pla81
                // not pla, feed through
                // not pla, feed through
"op-T2-ind":1524,              //  pla82
"op-T2-abs-access":273,        //  pla83      // has extra pulldown: pla97
"op-T5-rts":0,                 //  pla84
"op-T4":341,                   //  pla85
"op-T3":120,                   //  pla86
"op-T0-brk/rti":1478,          //  pla87
"op-T0-jmp":594,               //  pla88
"op-T5-ind-x":1210,            //  pla89
"op-T3-abs/idx/ind":677,       //  pla90      // has extra pulldown: pla97

                // internal signal: pla outputs block 7
"x-op-T4-ind-y":461,           //  pla91
"x-op-T3-abs-idx":447,         //  pla92
"op-T3-branch":660,            //  pla93
"op-brk/rti":1557,             //  pla94
"op-jsr":259,                  //  pla95
"x-op-jmp":1052,               //  pla96
                // gap
"op-push/pull":791,            //  pla97      // feeds into pla83 and pla90 (no normal pla output)
"op-store":517,                //  pla98
"op-T4-brk":352,               //  pla99
"op-T2-php":750,               //  pla100
"op-T2-php/pha":932,           //  pla101
"op-T4-jmp":1589,              //  pla102
                // gap
"op-T5-rti/rts":446,           //  pla103
"xx-op-T5-jsr":528,            //  pla104

                // internal signal: pla outputs block 8
"op-T2-jmp-abs":309,           //  pla105
"x-op-T3-plp/pla":1430,        //  pla106
"op-lsr/ror/dec/inc":53,       //  pla107
"op-asl/rol":691,              //  pla108
"op-T0-cli/sei":1292,          //  pla109
                // gap
"op-T+-bit":1646,              //  pla110
"op-T0-clc/sec":1114,          //  pla111
"op-T3-mem-zp-idx":904,        //  pla112
"x-op-T+-adc/sbc":1155,        //  pla113
"x-op-T0-bit":1476,            //  pla114
"op-T0-plp":1226,              //  pla115
"x-op-T4-rti":1569,            //  pla116
"op-T+-cmp":301,               //  pla117
"op-T+-cpx/cpy-abs":950,       //  pla118
"op-T+-asl/rol-a":1665,        //  pla119

                // internal signal: pla outputs block 9
"op-T+-cpx/cpy-imm/zp":1710,   //  pla120
"x-op-push/pull":1050,         //  pla121    // feeds into pla130 (no normal pla output)
"op-T0-cld/sed":1419,          //  pla122
"#op-branch-bit6":840,         //  pla123    // IR bit6 used only to detect branch type
"~op-branch-bit6":840,          // automatic alias replacing hash with tilde
"op-T3-mem-abs":607,           //  pla124
"op-T2-mem-zp":219,            //  pla125
"op-T5-mem-ind-idx":1385,      //  pla126
"op-T4-mem-abs-idx":281,       //  pla127
"#op-branch-bit7":1174,        //  pla128    // IR bit7 used only to detect branch type
"~op-branch-bit7":1174,         // automatic alias replacing hash with tilde
"op-clv":1164,                 //  pla129
"op-implied":1006,             //  pla130    // has extra pulldowns: pla121 and ir0

// internal signals: derived from pla outputs
"#op-branch-done": 1048,
"~op-branch-done": 1048, // automatic alias replacing hash with tilde
"#op-T3-branch": 1708,
"~op-T3-branch": 1708, // automatic alias replacing hash with tilde
"op-ANDS": 1228,
"op-EORS": 1689,
"op-ORS": 522,
"op-SUMS": 1196,
"op-SRS": 934,
"#op-store": 925,
"~op-store": 925, // automatic alias replacing hash with tilde
"#WR": 1352,
"~WR": 1352, // automatic alias replacing hash with tilde
"op-rmw": 434,
"short-circuit-idx-add": 1185,
"short-circuit-branch-add": 430,
"#op-set-C": 252,
"~op-set-C": 252, // automatic alias replacing hash with tilde

// internal signals: control signals
nnT2BR: 967,    // doubly inverted
BRtaken: 1544,  // aka #TAKEN

// internal signals and state: interrupt and vector related
// segher says:
//   "P" are the latched external signals.
//   "G" are the signals that actually trigger the interrupt.
//   "NMIL" is to do the edge detection -- it's pretty much just a delayed NMIG.
//   INTG is IRQ and NMI taken together.
IRQP: 675,
"#IRQP": 888,
"~IRQP": 888, // automatic alias replacing hash with tilde
NMIP: 1032,
"#NMIP": 297,
"~NMIP": 297, // automatic alias replacing hash with tilde
"#NMIG": 264,
"~NMIG": 264, // automatic alias replacing hash with tilde
NMIL: 1374,
RESP: 67,
RESG: 926,
VEC0: 1465,
VEC1: 1481,
"#VEC": 1134,
"~VEC": 1134, // automatic alias replacing hash with tilde
D1x1: 827,         // internal signal: interrupt handler related
"brk-done": 1382,  // internal signal: interrupt handler related
INTG: 1350,        // internal signal: interrupt handler related

// internal state: misc pipeline state clocked by cclk (phi2)
"pipe#VEC": 1431,     // latched #VEC
"pipe~VEC": 1431,      // automatic alias replacing hash with tilde
"pipeT-SYNC": 537,
pipeT2out: 40,
pipeT3out: 706,
pipeT4out: 1373,
pipeT5out: 940,
pipeIPCrelated: 832,
pipeUNK01: 1530,
pipeUNK02: 974,
pipeUNK03: 1436,
pipeUNK04: 99,
pipeUNK05: 44,
pipeUNK06: 443,
pipeUNK07: 215,
pipeUNK08: 338,
pipeUNK09: 199,
pipeUNK10: 215,
pipeUNK11: 1011,
pipeUNK12: 1283,
pipeUNK13: 1442,
pipeUNK14: 1607,
pipeUNK15: 1577, // inverse of H1x1, write P onto idb (PHP, interrupt)
pipeUNK16: 1051,
pipeUNK17: 1078,
pipeUNK18: 899,
pipeUNK19: 832,
pipeUNK20: 294,
pipeUNK21: 1176,
pipeUNK22: 561, // becomes dpc22
pipeUNK23: 596,
pipephi2Reset0: 449,
pipephi2Reset0x: 1036, // a second copy of the same latch
pipeUNK26: 1321,
pipeUNK27: 73,
pipeUNK28: 685,
pipeUNK29: 1008,
pipeUNK30: 1652,
pipeUNK31: 614,
pipeUNK32: 960,
pipeUNK33: 848,
pipeUNK34: 56,
pipeUNK35: 1713,
pipeUNK36: 729,
pipeUNK37: 197,
"pipe#WR.phi2": 1131,
"pipe~WR.phi2": 1131, // automatic alias replacing hash with tilde
pipeUNK39: 151,
pipeUNK40: 456,
pipeUNK41: 1438,
pipeUNK42: 1104,
"pipe#T0": 554,   // aka #T0.phi2
"pipe~T0": 554,    // automatic alias replacing hash with tilde

// internal state: vector address pulldown control
pipeVectorA0: 357,
pipeVectorA1: 170,
pipeVectorA2: 45,

// internal signals: vector address pulldown control
"0/ADL0": 217,
"0/ADL1": 686,
"0/ADL2": 1193,

// internal state: datapath control drivers
pipedpc28: 683,

// internal signals: alu internal (private) busses
alua0: 1167,
alua1: 1248,
alua2: 1332,
alua3: 1680,
alua4: 1142,
alua5: 530,
alua6: 1627,
alua7: 1522,
alub0: 977,
alub1: 1432,
alub2: 704,
alub3: 96,
alub4: 1645,
alub5: 1678,
alub6: 235,
alub7: 1535,

// alu carry chain and decimal mode
C01: 1285,
C12: 505,
C23: 1023,
C34: 78,
C45: 142,
C56: 500,
C67: 1314,
C78: 808,
"C78.phi2": 560,
DC34: 1372,   // lower nibble decimal carry
DC78: 333,    // carry for decimal mode
"DC78.phi2": 164,
"#C01": 1506,
"~C01": 1506, // automatic alias replacing hash with tilde
"#C12": 1122,
"~C12": 1122, // automatic alias replacing hash with tilde
"#C23": 1003,
"~C23": 1003, // automatic alias replacing hash with tilde
"#C34": 1425,
"~C34": 1425, // automatic alias replacing hash with tilde
"#C45": 1571,
"~C45": 1571, // automatic alias replacing hash with tilde
"#C56": 427,
"~C56": 427, // automatic alias replacing hash with tilde
"#C67": 592,
"~C67": 592, // automatic alias replacing hash with tilde
"#C78": 1327,
"~C78": 1327, // automatic alias replacing hash with tilde
"DA-C01": 623,
"DA-AB2": 216,
"DA-AxB2": 516,
"DA-C45": 1144,
"#DA-ADD1": 901,
"~DA-ADD1": 901, // automatic alias replacing hash with tilde
"#DA-ADD2": 699,
"~DA-ADD2": 699, // automatic alias replacing hash with tilde

// misc alu internals
"#(AxBxC)0": 371,
"~(AxBxC)0": 371, // automatic alias replacing hash with tilde
"#(AxBxC)1": 965,
"~(AxBxC)1": 965, // automatic alias replacing hash with tilde
"#(AxBxC)2": 22,
"~(AxBxC)2": 22, // automatic alias replacing hash with tilde
"#(AxBxC)3": 274,
"~(AxBxC)3": 274, // automatic alias replacing hash with tilde
"#(AxBxC)4": 651,
"~(AxBxC)4": 651, // automatic alias replacing hash with tilde
"#(AxBxC)5": 486,
"~(AxBxC)5": 486, // automatic alias replacing hash with tilde
"#(AxBxC)6": 1197,
"~(AxBxC)6": 1197, // automatic alias replacing hash with tilde
"#(AxBxC)7": 532,
"~(AxBxC)7": 532, // automatic alias replacing hash with tilde
AxB1: 425,
AxB3: 640,
AxB5: 1220,
AxB7: 1241,
"(AxB)0.#C0in": 555,
"(AxB)0.~C0in": 555, // automatic alias replacing hash with tilde
"(AxB)2.#C12": 193,
"(AxB)2.~C12": 193, // automatic alias replacing hash with tilde
"(AxB)4.#C34": 65,
"(AxB)4.~C34": 65, // automatic alias replacing hash with tilde
"(AxB)6.#C56": 174,
"(AxB)6.~C56": 174, // automatic alias replacing hash with tilde
"#(AxB1).C01": 295,
"~(AxB1).C01": 295, // automatic alias replacing hash with tilde
"#(AxB3).C23": 860,
"~(AxB3).C23": 860, // automatic alias replacing hash with tilde
"#(AxB5).C45": 817,
"~(AxB5).C45": 817, // automatic alias replacing hash with tilde
"#(AxB7).C67": 1217,
"~(AxB7).C67": 1217, // automatic alias replacing hash with tilde
"#A.B0": 1628,
"~A.B0": 1628, // automatic alias replacing hash with tilde
"#A.B1": 841,
"~A.B1": 841, // automatic alias replacing hash with tilde
"#A.B2": 681,
"~A.B2": 681, // automatic alias replacing hash with tilde
"#A.B3": 350,
"~A.B3": 350, // automatic alias replacing hash with tilde
"#A.B4": 1063,
"~A.B4": 1063, // automatic alias replacing hash with tilde
"#A.B5": 477,
"~A.B5": 477, // automatic alias replacing hash with tilde
"#A.B6": 336,
"~A.B6": 336, // automatic alias replacing hash with tilde
"#A.B7": 1318,
"~A.B7": 1318, // automatic alias replacing hash with tilde
"A+B0": 693,
"A+B1": 1021,
"A+B2": 110,
"A+B3": 1313,
"A+B4": 918,
"A+B5": 1236,
"A+B6": 803,
"A+B7": 117,
"#(A+B)0": 143,
"~(A+B)0": 143, // automatic alias replacing hash with tilde
"#(A+B)1": 155,
"~(A+B)1": 155, // automatic alias replacing hash with tilde
"#(A+B)2": 1691,
"~(A+B)2": 1691, // automatic alias replacing hash with tilde
"#(A+B)3": 649,
"~(A+B)3": 649, // automatic alias replacing hash with tilde
"#(A+B)4": 404,
"~(A+B)4": 404, // automatic alias replacing hash with tilde
"#(A+B)5": 1632,
"~(A+B)5": 1632, // automatic alias replacing hash with tilde
"#(A+B)6": 1084,
"~(A+B)6": 1084, // automatic alias replacing hash with tilde
"#(A+B)7": 1398,
"~(A+B)7": 1398, // automatic alias replacing hash with tilde
"#(AxB)0": 1525,
"~(AxB)0": 1525, // automatic alias replacing hash with tilde
"#(AxB)2": 701,
"~(AxB)2": 701, // automatic alias replacing hash with tilde
"#(AxB)4": 308,
"~(AxB)4": 308, // automatic alias replacing hash with tilde
"#(AxB)6": 1459,
"~(AxB)6": 1459, // automatic alias replacing hash with tilde
"#(AxB)1": 953,
"~(AxB)1": 953, // automatic alias replacing hash with tilde
"#(AxB)3": 884,
"~(AxB)3": 884, // automatic alias replacing hash with tilde
"#(AxB)5": 1469,
"~(AxB)5": 1469, // automatic alias replacing hash with tilde
"#(AxB)7": 177,
"~(AxB)7": 177, // automatic alias replacing hash with tilde
"#aluresult0": 957,   // alu result latch input
"~aluresult0": 957,    // automatic alias replacing hash with tilde
"#aluresult1": 250,
"~aluresult1": 250, // automatic alias replacing hash with tilde
"#aluresult2": 740,
"~aluresult2": 740, // automatic alias replacing hash with tilde
"#aluresult3": 1071,
"~aluresult3": 1071, // automatic alias replacing hash with tilde
"#aluresult4": 296,
"~aluresult4": 296, // automatic alias replacing hash with tilde
"#aluresult5": 277,
"~aluresult5": 277, // automatic alias replacing hash with tilde
"#aluresult6": 722,
"~aluresult6": 722, // automatic alias replacing hash with tilde
"#aluresult7": 304,
"~aluresult7": 304, // automatic alias replacing hash with tilde

// internal signals: datapath control signals

"ADL/ABL": 639,      // load ABL latches from ADL bus
"ADH/ABH": 821,      // load ABH latches from ADH bus

dpc0_YSB: 801,       // drive sb from y
dpc1_SBY: 325,       // load y from sb
dpc2_XSB: 1263,      // drive sb from x
dpc3_SBX: 1186,      // load x from sb
dpc4_SSB: 1700,      // drive sb from stack pointer
dpc5_SADL: 1468,     // drive adl from stack pointer
dpc6_SBS: 874,       // load stack pointer from sb
dpc7_SS: 654,        // recirculate stack pointer
dpc8_nDBADD: 1068,   // alu b side: select not-idb input
dpc9_DBADD: 859,     // alu b side: select idb input

dpc10_ADLADD: 437,   // alu b side: select adl input
dpc11_SBADD: 549,    // alu a side: select sb
dpc12_0ADD: 984,     // alu a side: select zero
dpc13_ORS: 59,       // alu op: a or b
dpc14_SRS: 362,      // alu op: logical right shift
dpc15_ANDS: 574,     // alu op: a and b
dpc16_EORS: 1666,    // alu op: a xor b (?)
dpc17_SUMS: 921,     // alu op: a plus b (?)
alucin: 910,         // alu carry in
notalucin: 1165,
"dpc18_#DAA": 1201,  // decimal related (inverted)
"dpc18_~DAA": 1201,   // automatic alias replacing hash with tilde
dpc19_ADDSB7: 214,   // alu to sb bit 7 only

dpc20_ADDSB06: 129,  // alu to sb bits 6-0 only
dpc21_ADDADL: 1015,  // alu to adl
alurawcout: 808,     // alu raw carry out (no decimal adjust)
notalucout: 412,     // alu carry out (inverted)
alucout: 1146,       // alu carry out (latched by phi2)
"#alucout": 206,
"~alucout": 206, // automatic alias replacing hash with tilde
"##alucout": 465,
"~~alucout": 465, // automatic alias replacing hash with tilde
notaluvout: 1308,    // alu overflow out
aluvout: 938,        // alu overflow out (latched by phi2)

"#DBZ": 1268,   // internal signal: not (databus is zero)
"~DBZ": 1268,    // automatic alias replacing hash with tilde
DBZ: 744,       // internal signal: databus is zero
DBNeg: 1200,    // internal signal: databus is negative (top bit of db) aka P-#DB7in

"dpc22_#DSA": 725,   // decimal related/SBC only (inverted)
"dpc22_~DSA": 725,    // automatic alias replacing hash with tilde
dpc23_SBAC: 534,     // (optionalls decimal-adjusted) sb to acc
dpc24_ACSB: 1698,    // acc to sb
dpc25_SBDB: 1060,    // sb pass-connects to idb (bi-directionally)
dpc26_ACDB: 1331,    // acc to idb
dpc27_SBADH: 140,    // sb pass-connects to adh (bi-directionally)
dpc28_0ADH0: 229,    // zero to adh0 bit0 only
dpc29_0ADH17: 203,   // zero to adh bits 7-1 only

dpc30_ADHPCH: 48,    // load pch from adh
dpc31_PCHPCH: 741,   // load pch from pch incremented
dpc32_PCHADH: 1235,  // drive adh from pch incremented
dpc33_PCHDB: 247,    // drive idb from pch incremented
dpc34_PCLC: 1704,    // pch carry in and pcl FF detect?
dpc35_PCHC: 1334,    // pcl 0x?F detect - half-carry
"dpc36_#IPC": 379,   // pcl carry in (inverted)
"dpc36_~IPC": 379,    // automatic alias replacing hash with tilde
dpc37_PCLDB: 283,    // drive idb from pcl incremented
dpc38_PCLADL: 438,   // drive adl from pcl incremented
dpc39_PCLPCL: 898,   // load pcl from pcl incremented

dpc40_ADLPCL: 414,   // load pcl from adl
"dpc41_DL/ADL": 1564,// pass-connect adl to mux node driven by idl
"dpc42_DL/ADH": 41,  // pass-connect adh to mux node driven by idl
"dpc43_DL/DB": 863,  // pass-connect idb to mux node driven by idl

// internal signals connected to external pins
_ab0:10056,
_ab1:10055,
_ab2:10088,
_ab3:11249,
_ab4:11255,
_ab5:10719,
_ab6:10822,
_ab7:11497,
_ab8:11600,
_ab9:11776,
_ab10:11886,
_ab11:11908,
_ab12:11935,
_ab13:11967,
_ab14:11992,
_ab15:12015,
_db7:10656,
_db6:10616,
_db5:10551,
_db4:10490,
_db3:10257,
_db2:10671,
_db1:10192,
_db0:10146,
_dbg:11115,
_res:10057,
_out0:10035,
_out1:10037,
_out2:10036,
_rw:10844,
_nmi:10458,
_irq:10701,

// internal signals not directly connected to external pins
__nmi:11193,
__irq:13407,
__rw:10756,
__ab15:12026,
__ab14:12007,
__ab13:11985,
__ab12:11956,
__ab11:11923,
__ab10:11901,
__ab9:11879,
__ab8:11855,
__ab7:11831,
__ab6:11794,
__ab5:11744,
__ab4:11700,
__ab3:11682,
__ab2:11666,
__ab1:11630,
__ab0:11607,

// internals
rw_buf:11133,
dbe:10938,
dbg_en:10946,
ab_use_cpu:11567,
ab_use_pcm:11576,
ab_use_spr_r:11099,
ab_use_spr_w:10764,

// $4000-$401F I/O
apureg_rd:11365,
'apureg_/rd':11166,
apureg_wr:11356,
'apureg_/wr':11265,

r4018:10527,
r401a:10763,
r4015:10749,
w4002:10134,
w4001:10559,
w4005:10580,
w4006:10133,
w4008:13348,
w400a:13371,
w400b:13398,
w400e:13436,
w4013:13457,
w4012:13491,
w4010:13514,
w4014:13542,

r4019:10759,
w401a:10773,
w4003:13264,
w4007:13273,
w4004:13290,
w400c:13300,
w4000:13322,
w4015:13356,
w4011:13375,
w400f:13415,
r4017:13444,
r4016:13474,
w4016:10174,
w4017:13520,


// Square 0
// $4002-$4003
sq0_p0:10149,
sq0_p1:10190,
sq0_p2:10223,
sq0_p3:10259,
sq0_p4:10297,
sq0_p5:10341,
sq0_p6:10368,
sq0_p7:10401,
sq0_p8:10424,
sq0_p9:10445,
sq0_p10:10473,
'sq0_/p0':10152,
'sq0_/p1':10194,
'sq0_/p2':10227,
'sq0_/p3':10261,
'sq0_/p4':10304,
'sq0_/p5':10342,
'sq0_/p6':10370,
'sq0_/p7':10405,
'sq0_/p8':10426,
'sq0_/p9':10447,
'sq0_/p10':10479,

// timer, duty cycle counter
sq0_t0:12253,
sq0_t1:12319,
sq0_t2:12385,
sq0_t3:12446,
sq0_t4:12527,
sq0_t5:12588,
sq0_t6:12651,
sq0_t7:12713,
sq0_t8:12768,
sq0_t9:12823,
sq0_t10:12893,
'sq0_+t0':12259,
'sq0_+t1':12325,
'sq0_+t2':12392,
'sq0_+t3':12452,
'sq0_+t4':12532,
'sq0_+t5':12593,
'sq0_+t6':12658,
'sq0_+t7':12720,
'sq0_+t8':12775,
'sq0_+t9':12840,
'sq0_+t10':12898,
'sq0_/t0':10135,
'sq0_/t1':10178,
'sq0_/t2':10215,
'sq0_/t3':10249,
'sq0_/t4':10283,
'sq0_/t5':10328,
'sq0_/t6':10361,
'sq0_/t7':10396,
'sq0_/t8':10418,
'sq0_/t9':10439,
'sq0_/t10':10466,

sq0_c0:12930,
sq0_c1:12980,
sq0_c2:13031,
'sq0_+c0':10493,
'sq0_+c1':12985,
'sq0_+c2':12993,
'sq0_/c0':10498,
'sq0_/c1':10561,
'sq0_/c2':10615,

// $4001
sq0_swpb0:10497,
sq0_swpb1:10504,
sq0_swpb2:10506,
'sq0_/swpb0':13029,
'sq0_/swpb1':13071,
'sq0_/swpb2':13139,

sq0_swpdir:10112,
'sq0_/swpdir':12978,

sq0_swpp0:10686,
sq0_swpp1:10647,
sq0_swpp2:10608,
'sq0_/swpp0':13140,
'sq0_/swpp1':13068,
'sq0_/swpp2':13027,

sq0_swpen:10546,
'sq0_/swpen':10514,

sq0_swpt0:13115,
sq0_swpt1:13057,
sq0_swpt2:13018,
'sq0_+swpt0':13104,
'sq0_+swpt1':13052,
'sq0_+swpt2':13006,
'sq0_/swpt0':10689,
'sq0_/swpt1':10652,
'sq0_/swpt2':10612,

// $4000
sq0_envp0:10138,
sq0_envp1:10184,
sq0_envp2:10216,
sq0_envp3:10251,
'sq0_/envp0':12209,
'sq0_/envp1':12282,
'sq0_/envp2':12347,
'sq0_/envp3':12415,

sq0_envmode:10294,
'sq0_/envmode':12541,

sq0_lenhalt:10338,
'sq0_/lenhalt':12601,

sq0_duty0:10687,
sq0_duty1:10643,
'sq0_/duty0':13142,
'sq0_/duty1':13074,

// envelope timer
sq0_envt0:12249,
sq0_envt1:12315,
sq0_envt2:12381,
sq0_envt3:12447,
'sq0_+envt0':12261,
'sq0_+envt1':12327,
'sq0_+envt2':12394,
'sq0_+envt3':12456,
'sq0_/envt0':10139,
'sq0_/envt1':10179,
'sq0_/envt2':10217,
'sq0_/envt3':10246,

// envelope counter (gets used for volume)
sq0_envc0:12714,
sq0_envc1:12766,
sq0_envc2:12824,
sq0_envc3:12894,
'sq0_+envc0':12685,
'sq0_+envc1':12665,
'sq0_+envc2':12647,
'sq0_+envc3':12639,
'sq0_/envc0':10397,
'sq0_/envc1':10419,
'sq0_/envc2':10440,
'sq0_/envc3':10467,

// length counter
sq0_len0:15089,
sq0_len1:15045,
sq0_len2:14998,
sq0_len3:14945,
sq0_len4:14877,
sq0_len5:14827,
sq0_len6:14771,
sq0_len7:14726,
'sq0_+len0':15088,
'sq0_+len1':15044,
'sq0_+len2':14997,
'sq0_+len3':14944,
'sq0_+len4':14876,
'sq0_+len5':14826,
'sq0_+len6':14770,
'sq0_+len7':14725,
'sq0_/len0':12019,
'sq0_/len1':11998,
'sq0_/len2':11970,
'sq0_/len3':11944,
'sq0_/len4':11913,
'sq0_/len5':11892,
'sq0_/len6':11868,
'sq0_/len7':11845,

// enabled (write $4015), active (read $4015)
sq0_en:14632,
'sq0_/en':14638,
sq0_on:11765,
'sq0_/on':14653,
sq0_len_reload:11748,
sq0_silence:10524,

// actual output
sq0_out0:10086,
sq0_out1:10083,
sq0_out2:10084,
sq0_out3:10085,

// Square 1
// $4006-$4007
sq1_p0:10148,
sq1_p1:10191,
sq1_p2:10221,
sq1_p3:10256,
sq1_p4:10295,
sq1_p5:10339,
sq1_p6:10364,
sq1_p7:10402,
sq1_p8:10423,
sq1_p9:10444,
sq1_p10:10474,
'sq1_/p0':10153,
'sq1_/p1':10193,
'sq1_/p2':10228,
'sq1_/p3':10260,
'sq1_/p4':10303,
'sq1_/p5':10343,
'sq1_/p6':10371,
'sq1_/p7':10404,
'sq1_/p8':10425,
'sq1_/p9':10446,
'sq1_/p10':10477,

// timer, duty cycle counter
sq1_t0:12250,
sq1_t1:12316,
sq1_t2:12382,
sq1_t3:12445,
sq1_t4:12524,
sq1_t5:12585,
sq1_t6:12648,
sq1_t7:12712,
sq1_t8:12767,
sq1_t9:12820,
sq1_t10:12890,
'sq1_+t0':12258,
'sq1_+t1':12324,
'sq1_+t2':12391,
'sq1_+t3':12451,
'sq1_+t4':12531,
'sq1_+t5':12592,
'sq1_+t6':12657,
'sq1_+t7':12719,
'sq1_+t8':12774,
'sq1_+t9':12839,
'sq1_+t10':12897,
'sq1_/t0':10137,
'sq1_/t1':10183,
'sq1_/t2':10214,
'sq1_/t3':10250,
'sq1_/t4':10285,
'sq1_/t5':10327,
'sq1_/t6':10360,
'sq1_/t7':10395,
'sq1_/t8':10416,
'sq1_/t9':10441,
'sq1_/t10':10465,

sq1_c0:12929,
sq1_c1:12979,
sq1_c2:13030,
'sq1_+c0':10492,
'sq1_+c1':12982,
'sq1_+c2':12992,
'sq1_/c0':10495,
'sq1_/c1':10558,
'sq1_/c2':10610,

// $4005
sq1_swpb0:10496,
sq1_swpb1:10502,
sq1_swpb2:10501,
'sq1_/swpb0':13028,
'sq1_/swpb1':13070,
'sq1_/swpb2':13138,

sq1_swpdir:10127,
'sq1_/swpdir':12977,

sq1_swpp0:10682,
sq1_swpp1:10649,
sq1_swpp2:10607,
'sq1_/swpp0':13137,
'sq1_/swpp1':13067,
'sq1_/swpp2':13026,

sq1_swpen:10545,
'sq1_/swpen':10513,

sq1_swpt0:13114,
sq1_swpt1:13056,
sq1_swpt2:13017,
'sq1_+swpt0':13103,
'sq1_+swpt1':13051,
'sq1_+swpt2':13005,
'sq1_/swpt0':10684,
'sq1_/swpt1':10648,
'sq1_/swpt2':10603,

// $4004
sq1_envp0:10136,
sq1_envp1:10182,
sq1_envp2:10213,
sq1_envp3:10248,
'sq1_/envp0':12208,
'sq1_/envp1':12279,
'sq1_/envp2':12344,
'sq1_/envp3':12412,

sq1_envmode:10292,
'sq1_/envmode':12538,

sq1_lenhalt:10337,
'sq1_/lenhalt':12600,

sq1_duty0:10683,
sq1_duty1:10644,
'sq1_/duty0':13141,
'sq1_/duty1':13073,

// envelope timer
sq1_envt0:12248,
sq1_envt1:12314,
sq1_envt2:12380,
sq1_envt3:12444,
'sq1_+envt0':12256,
'sq1_+envt1':12322,
'sq1_+envt2':12389,
'sq1_+envt3':12455,
'sq1_/envt0':10140,
'sq1_/envt1':10181,
'sq1_/envt2':10212,
'sq1_/envt3':10247,

// envelope counter (gets used for volume)
sq1_envc0:12711,
sq1_envc1:12763,
sq1_envc2:12819,
sq1_envc3:12889,
'sq1_+envc0':12684,
'sq1_+envc1':12664,
'sq1_+envc2':12646,
'sq1_+envc3':12638,
'sq1_/envc0':10394,
'sq1_/envc1':10414,
'sq1_/envc2':10438,
'sq1_/envc3':10468,

// length counter
sq1_len0:15086,
sq1_len1:15042,
sq1_len2:14995,
sq1_len3:14942,
sq1_len4:14874,
sq1_len5:14824,
sq1_len6:14768,
sq1_len7:14723,
'sq1_+len0':15087,
'sq1_+len1':15043,
'sq1_+len2':14996,
'sq1_+len3':14943,
'sq1_+len4':14875,
'sq1_+len5':14825,
'sq1_+len6':14769,
'sq1_+len7':14724,
'sq1_/len0':12017,
'sq1_/len1':11996,
'sq1_/len2':11973,
'sq1_/len3':11943,
'sq1_/len4':11912,
'sq1_/len5':11888,
'sq1_/len6':11867,
'sq1_/len7':11844,

// enabled (write $4015), active (read $4015)
sq1_en:14631,
'sq1_/en':14637,
sq1_on:11768,
'sq1_/on':14652,
sq1_len_reload:11752,
sq1_silence:10522,

// actual output
sq1_out0:10082,
sq1_out1:10081,
sq1_out2:10080,
sq1_out3:10079,

// Triangle
// $4008
tri_lin0:10952,
tri_lin1:10991,
tri_lin2:11105,
tri_lin3:11140,
tri_lin4:11185,
tri_lin5:11220,
tri_lin6:11262,
'tri_/lin0':13232,
'tri_/lin1':13271,
'tri_/lin2':13306,
'tri_/lin3':13376,
'tri_/lin4':13452,
'tri_/lin5':13521,
'tri_/lin6':13584,
tri_lin_en:11304,
'tri_/lin_en':13653,

// linear counter
tri_lc0:13257,
tri_lc1:13287,
tri_lc2:13336,
tri_lc3:13408,
tri_lc4:13481,
tri_lc5:13551,
tri_lc6:13615,
'tri_+lc0':13260,
'tri_+lc1':13293,
'tri_+lc2':13346,
'tri_+lc3':13418,
'tri_+lc4':13489,
'tri_+lc5':13559,
'tri_+lc6':13624,
'tri_/lc0':10951,
'tri_/lc1':10990,
'tri_/lc2':11104,
'tri_/lc3':11137,
'tri_/lc4':11187,
'tri_/lc5':11218,
'tri_/lc6':11261,

// period ($400A/$400B)
tri_p0:11420,
tri_p1:11400,
tri_p2:11377,
tri_p3:11357,
tri_p4:11334,
tri_p5:11305,
tri_p6:11272,
tri_p7:11224,
tri_p8:11190,
tri_p9:11144,
tri_p10:11112,
'tri_/p0':13960,
'tri_/p1':13905,
'tri_/p2':13856,
'tri_/p3':13803,
'tri_/p4':13742,
'tri_/p5':13684,
'tri_/p6':13628,
'tri_/p7':13562,
'tri_/p8':13494,
'tri_/p9':13422,
'tri_/p10':13352,

// timer
tri_t0:13938,
tri_t1:13887,
tri_t2:13834,
tri_t3:13778,
tri_t4:13720,
tri_t5:13663,
tri_t6:13602,
tri_t7:13539,
tri_t8:13471,
tri_t9:13395,
tri_t10:13325,
'tri_+t0':13937,
'tri_+t1':13886,
'tri_+t2':13833,
'tri_+t3':13777,
'tri_+t4':13719,
'tri_+t5':13662,
'tri_+t6':13601,
'tri_+t7':13538,
'tri_+t8':13470,
'tri_+t9':13394,
'tri_+t10':13324,
'tri_/t0':11425,
'tri_/t1':11405,
'tri_/t2':11380,
'tri_/t3':11360,
'tri_/t4':11338,
'tri_/t5':11310,
'tri_/t6':11281,
'tri_/t7':11228,
'tri_/t8':11192,
'tri_/t9':11156,
'tri_/t10':11116,

tri_c0:13929,
tri_c1:13876,
tri_c2:13821,
tri_c3:13761,
tri_c4:13703,
'tri_+c0':11413,
'tri_+c1':11394,
'tri_+c2':11372,
'tri_+c3':11349,
'tri_+c4':11325,
'tri_/c0':11418,
'tri_/c1':11397,
'tri_/c2':11375,
'tri_/c3':11355,
'tri_/c4':11329,

// length counter
tri_len0:15085,
tri_len1:15041,
tri_len2:14994,
tri_len3:14941,
tri_len4:14873,
tri_len5:14823,
tri_len6:14767,
tri_len7:14722,
'tri_+len0':15084,
'tri_+len1':15040,
'tri_+len2':14993,
'tri_+len3':14940,
'tri_+len4':14872,
'tri_+len5':14822,
'tri_+len6':14766,
'tri_+len7':14721,
'tri_/len0':12020,
'tri_/len1':11997,
'tri_/len2':11972,
'tri_/len3':11940,
'tri_/len4':11911,
'tri_/len5':11891,
'tri_/len6':11869,
'tri_/len7':11843,

// enabled (write $4015), active (read $4015)
tri_en:14630,
'tri_/en':14636,
tri_on:11767,
'tri_/on':14651,
tri_len_reload:11750,
tri_silence:11346,

// output bits
tri_out0:13941,
tri_out1:13890,
tri_out2:13832,
tri_out3:13776,

// Noise
// $400E
noi_freq0:11597,
noi_freq1:11678,
noi_freq2:11625,
noi_freq3:11663,
'noi_/freq0':14373,
'noi_/freq1':14533,
'noi_/freq2':14429,
'noi_/freq3':14487,

noi_lfsrmode:11419,
'noi_/lfsrmode':13931,

// Timer LFSR - triggers on 10000000000
noi_t0:14156,
noi_t1:14179,
noi_t2:14206,
noi_t3:14234,
noi_t4:14256,
noi_t5:14285,
noi_t6:14309,
noi_t7:14371,
noi_t8:11523,
noi_t9:14449,
noi_t10:11519,
'noi_/t0':14153,
'noi_/t1':14173,
'noi_/t2':14202,
'noi_/t3':14228,
'noi_/t4':14253,
'noi_/t5':14280,
'noi_/t6':14305,
'noi_/t7':14365,
'noi_/t8':14406,
'noi_/t9':14439,
'noi_/t10':14478,

// Duty cycle LFSR
noi_c0:14066,
noi_c1:14105,
noi_c2:14127,
noi_c3:14146,
noi_c4:14168,
noi_c5:14198,
noi_c6:14223,
noi_c7:14249,
noi_c8:14277,
noi_c9:14299,
noi_c10:14361,
noi_c11:14400,
noi_c12:14435,
noi_c13:14472,
noi_c14:14507,
'noi_+c0':14077,
'noi_+c1':14116,
'noi_+c2':14138,
'noi_+c3':14158,
'noi_+c4':14182,
'noi_+c5':14213,
'noi_+c6':14236,
'noi_+c7':14258,
'noi_+c8':14286,
'noi_+c9':14311,
'noi_+c10':14372,
'noi_+c11':14415,
'noi_+c12':14454,
'noi_+c13':14483,
'noi_+c14':11477,
'noi_/c0':14073,
'noi_/c1':14115,
'noi_/c2':14131,
'noi_/c3':14155,
'noi_/c4':14176,
'noi_/c5':14205,
'noi_/c6':14231,
'noi_/c7':14255,
'noi_/c8':14284,
'noi_/c9':14308,
'noi_/c10':14369,
'noi_/c11':14410,
'noi_/c12':14448,
'noi_/c13':14479,
'noi_/c14':14518,

// $400C
noi_envp0:11450,
noi_envp1:11479,
noi_envp2:11494,
noi_envp3:11517,
'noi_/envp0':14007,
'noi_/envp1':14050,
'noi_/envp2':14084,
'noi_/envp3':14132,

noi_envmode:11536,
'noi_/envmode':14165,

noi_lenhalt:11553,
'noi_/lenhalt':14209,

// envelope timer
noi_envt0:14027,
noi_envt1:14069,
noi_envt2:14124,
noi_envt3:14154,
'noi_+envt0':14025,
'noi_+envt1':14064,
'noi_+envt2':14121,
'noi_+envt3':14149,
'noi_/envt0':11449,
'noi_/envt1':11478,
'noi_/envt2':11493,
'noi_/envt3':11516,

// envelope counter (gets used for volume)
noi_envc0:14521,
noi_envc1:14469,
noi_envc2:14414,
noi_envc3:14354,
'noi_+envc0':14519,
'noi_+envc1':14467,
'noi_+envc2':14412,
'noi_+envc3':14353,
'noi_/envc0':11680,
'noi_/envc1':11664,
'noi_/envc2':11629,
'noi_/envc3':11602,

// length counter
noi_len0:15082,
noi_len1:15038,
noi_len2:14991,
noi_len3:14938,
noi_len4:14870,
noi_len5:14820,
noi_len6:14764,
noi_len7:14719,
'noi_+len0':15083,
'noi_+len1':15039,
'noi_+len2':14992,
'noi_+len3':14939,
'noi_+len4':14871,
'noi_+len5':14821,
'noi_+len6':14765,
'noi_+len7':14720,
'noi_/len0':12018,
'noi_/len1':11995,
'noi_/len2':11972,
'noi_/len3':11942,
'noi_/len4':11910,
'noi_/len5':11890,
'noi_/len6':11866,
'noi_/len7':11842,

// enabled (write $4015), active (read $4015)
noi_en:14629,
'noi_/en':14635,
noi_on:11766,
'noi_/on':14650,
noi_len_reload:11747,
noi_silence:11696,

// actual output
noi_out0:14538,
noi_out1:14489,
noi_out2:14434,
noi_out3:11401,

// DPCM

// bit counter
pcm_bits0:14204,
pcm_bits1:14243,
pcm_bits2:14283,
'pcm_+bits0':14211,
'pcm_+bits1':14246,
'pcm_+bits2':14287,
'pcm_/bits0':11546,
'pcm_/bits1':11561,
'pcm_/bits2':11571,

// next sample buffer
pcm_buf0:11106,
pcm_buf1:11138,
pcm_buf2:11186,
pcm_buf3:11219,
pcm_buf4:11264,
pcm_buf5:11301,
pcm_buf6:11330,
pcm_buf7:11352,
'pcm_/buf0':13308,
'pcm_/buf1':13378,
'pcm_/buf2':13451,
'pcm_/buf3':13518,
'pcm_/buf4':13586,
'pcm_/buf5':13651,
'pcm_/buf6':13705,
'pcm_/buf7':13765,

// sample shift register
pcm_sr0:11060,
pcm_sr1:11131,
pcm_sr2:11178,
pcm_sr3:11213,
pcm_sr4:11248,
pcm_sr5:11296,
pcm_sr6:11323,
pcm_sr7:11347,
'pcm_/sr0':11101,
'pcm_/sr1':13384,
'pcm_/sr2':13456,
'pcm_/sr3':13525,
'pcm_/sr4':13590,
'pcm_/sr5':13655,
'pcm_/sr6':13709,
'pcm_/sr7':13767,
'pcm_+/sr0':13344,
'pcm_+/sr1':13405,
'pcm_+/sr2':13480,
'pcm_+/sr3':13549,
'pcm_+/sr4':13614,
'pcm_+/sr5':13672,
'pcm_+/sr6':13729,
'pcm_+/sr7':13787,

// $4010
pcm_freq0:11707,
pcm_freq1:11688,
pcm_freq2:11670,
pcm_freq3:11635,
'pcm_/freq0':14576,
'pcm_/freq1':14535,
'pcm_/freq2':14486,
'pcm_/freq3':14431,

pcm_loop:11510,
'pcm_/loop':14375,

pcm_irqen:11584,
'pcm_/irqen':14296,

// Timer LFSR - triggers on 100000000
pcm_t0:14457,
pcm_t1:14419,
pcm_t2:14379,
pcm_t3:14332,
pcm_t4:11579,
pcm_t5:14262,
pcm_t6:14239,
pcm_t7:14215,
pcm_t8:11544,
'pcm_+t0':14470,
'pcm_+t1':14432,
'pcm_+t2':14399,
'pcm_+t3':14359,
'pcm_+t4':14298,
'pcm_+t5':14276,
'pcm_+t6':14248,
'pcm_+t7':14222,
'pcm_+t8':14200,
'pcm_/t0':14476,
'pcm_/t1':14443,
'pcm_/t2':14408,
'pcm_/t3':14366,
'pcm_/t4':14306,
'pcm_/t5':14281,
'pcm_/t6':14254,
'pcm_/t7':14229,
'pcm_/t8':14203,

// $4012 - start address
pcm_sa0:11764,
pcm_sa1:11807,
pcm_sa2:11838,
pcm_sa3:11859,
pcm_sa4:11883,
pcm_sa5:11907,
pcm_sa6:11927,
pcm_sa7:11961,
'pcm_/sa0':14599,
'pcm_/sa1':14668,
'pcm_/sa2':14708,
'pcm_/sa3':14757,
'pcm_/sa4':14810,
'pcm_/sa5':14860,
'pcm_/sa6':14914,
'pcm_/sa7':14982,

// current address
pcm_a0:14326,
pcm_a1:14402,
pcm_a2:14459,
pcm_a3:14511,
pcm_a4:14559,
pcm_a5:14589,
pcm_a6:14642,
pcm_a7:14695,
pcm_a8:14733,
pcm_a9:14785,
pcm_a10:14837,
pcm_a11:14886,
pcm_a12:14956,
pcm_a13:15008,
pcm_a14:15054,
'pcm_+a0':11595,
'pcm_+a1':11623,
'pcm_+a2':11645,
'pcm_+a3':11676,
'pcm_+a4':11694,
'pcm_+a5':11725,
'pcm_+a6':11783,
'pcm_+a7':11818,
'pcm_+a8':11847,
'pcm_+a9':11871,
'pcm_+a10':11894,
'pcm_+a11':11916,
'pcm_+a12':11949,
'pcm_+a13':11976,
'pcm_+a14':12000,
'pcm_/a0':11586,
'pcm_/a1':11613,
'pcm_/a2':11636,
'pcm_/a3':11667,
'pcm_/a4':11686,
'pcm_/a5':11708,
'pcm_/a6':11763,
'pcm_/a7':11808,
'pcm_/a8':11836,
'pcm_/a9':11860,
'pcm_/a10':11882,
'pcm_/a11':11905,
'pcm_/a12':11928,
'pcm_/a13':11963,
'pcm_/a14':11988,

// $4013 - sample length
pcm_l0:11358,
pcm_l1:11335,
pcm_l2:11306,
pcm_l3:11273,
pcm_l4:11223,
pcm_l5:11191,
pcm_l6:11142,
pcm_l7:11113,
'pcm_/l0':13804,
'pcm_/l1':13743,
'pcm_/l2':13685,
'pcm_/l3':13629,
'pcm_/l4':13563,
'pcm_/l5':13495,
'pcm_/l6':13423,
'pcm_/l7':13353,

// length counter
pcm_lc0:13992,
pcm_lc1:13940,
pcm_lc2:13889,
pcm_lc3:13836,
pcm_lc4:13780,
pcm_lc5:13722,
pcm_lc6:13665,
pcm_lc7:13604,
pcm_lc8:13541,
pcm_lc9:13473,
pcm_lc10:13397,
pcm_lc11:13327,
'pcm_+lc0':13991,
'pcm_+lc1':13939,
'pcm_+lc2':13888,
'pcm_+lc3':13835,
'pcm_+lc4':13779,
'pcm_+lc5':13721,
'pcm_+lc6':13664,
'pcm_+lc7':13603,
'pcm_+lc8':13540,
'pcm_+lc9':13472,
'pcm_+lc10':13396,
'pcm_+lc11':13326,
'pcm_/lc0':11441,
'pcm_/lc1':11424,
'pcm_/lc2':11404,
'pcm_/lc3':11381,
'pcm_/lc4':11361,
'pcm_/lc5':11337,
'pcm_/lc6':11311,
'pcm_/lc7':11282,
'pcm_/lc8':11226,
'pcm_/lc9':11195,
'pcm_/lc10':11152,
'pcm_/lc11':11119,

// enabled (write $4015), active (read $4015)
// these are actually the same register
pcm_en:11481,
'pcm_+en':14060,
'pcm_/en':14068,
pcm_on:11481,

// output value
pcm_out0:11279,
pcm_out1:11240,
pcm_out2:11202,
pcm_out3:11251,
pcm_out4:10939,
pcm_out5:10916,
pcm_out6:10881,
_pcm_out4:11143,
_pcm_out5:11103,
_pcm_out6:10984,

// specials
pcm_decrement:10819,
pcm_increment:10944,
pcm_doadjust:11386,
pcm_overflow:10818,

// Sprite DMA
// value written to $4014
spr_page0:13824,
spr_page1:13854,
spr_page2:13878,
spr_page3:13908,
spr_page4:13935,
spr_page5:13966,
spr_page6:13988,
spr_page7:14015,
'spr_/page0':13831,
'spr_/page1':13861,
'spr_/page2':13891,
'spr_/page3':13916,
'spr_/page4':13945,
'spr_/page5':13975,
'spr_/page6':13995,
'spr_/page7':14021,

// Sprite DMA address counter
spr_addr0:13337,
spr_addr1:13409,
spr_addr2:13482,
spr_addr3:13552,
spr_addr4:13617,
spr_addr5:13675,
spr_addr6:13730,
spr_addr7:13790,
spr_addr8:13824,
spr_addr9:13854,
spr_addr10:13878,
spr_addr11:13908,
spr_addr12:13935,
spr_addr13:13966,
spr_addr14:13988,
spr_addr15:14015,
'spr_+addr0':11122,
'spr_+addr1':11162,
'spr_+addr2':11199,
'spr_+addr3':11232,
'spr_+addr4':11285,
'spr_+addr5':11314,
'spr_+addr6':11340,
'spr_+addr7':11364,
'spr_+addr8':13822,
'spr_+addr9':13853,
'spr_+addr10':13877,
'spr_+addr11':13906,
'spr_+addr12':13933,
'spr_+addr13':13963,
'spr_+addr14':13987,
'spr_+addr15':14014,
'spr_/addr0':11107,
'spr_/addr1':11139,
'spr_/addr2':11188,
'spr_/addr3':11221,
'spr_/addr4':11263,
'spr_/addr5':11302,
'spr_/addr6':11331,
'spr_/addr7':11354,
'spr_/addr8':13831,
'spr_/addr9':13861,
'spr_/addr10':13891,
'spr_/addr11':13916,
'spr_/addr12':13945,
'spr_/addr13':13975,
'spr_/addr14':13995,
'spr_/addr15':14021,

spr_data0:13254,
spr_data1:13253,
spr_data2:13252,
spr_data3:13251,
spr_data4:13250,
spr_data5:13249,
spr_data6:13248,
spr_data7:13247,
'spr_/data0':13204,
'spr_/data1':13203,
'spr_/data2':13202,
'spr_/data3':13201,
'spr_/data4':13200,
'spr_/data5':13199,
'spr_/data6':13198,
'spr_/data7':13197,

// current address being output - either spr_addr or $2004
spr_a0:11129,
spr_a1:11175,
spr_a2:11211,
spr_a3:11247,
spr_a4:11294,
spr_a5:11321,
spr_a6:11345,
spr_a7:11370,
spr_a8:11379,
spr_a9:11390,
spr_a10:11403,
spr_a11:11412,
spr_a12:11423,
spr_a13:11436,
spr_a14:11442,
spr_a15:11453,

// Frame Counter

// value written to $4017
frm_intmode:10713,
'frm_/intmode':13160,
frm_seqmode:10669,
'frm_/seqmode':10660,

// timer LFSR
frm_t0:12470,
frm_t1:12517,
frm_t2:12564,
frm_t3:12595,
frm_t4:12634,
frm_t5:12674,
frm_t6:12708,
frm_t7:12736,
frm_t8:12781,
frm_t9:12810,
frm_t10:12857,
frm_t11:12888,
frm_t12:12911,
frm_t13:10218,
frm_t14:10225,
'frm_/t0':12458,
'frm_/t1':12510,
'frm_/t2':12551,
'frm_/t3':12580,
'frm_/t4':12620,
'frm_/t5':12666,
'frm_/t6':12701,
'frm_/t7':12731,
'frm_/t8':12762,
'frm_/t9':12789,
'frm_/t10':12851,
'frm_/t11':12881,
'frm_/t12':12908,
'frm_/t13':12931,
'frm_/t14':12953,

// frame phases
frm_a:10245, // 100001100000100
frm_b:10185, // 110000000110110
frm_c:10231, // 110010110011010
frm_d:10154, // 111110000101000 AND frm_seqmode = 1
frm_e:10170, // 101000011000111
frm_f:10244, // 000000000000000

// frame phase triggers
frm_quarter:10293,
frm_half:10563,

// APU clock phases
apu_clk1:11434,
'apu_/clk2':10533,
apu_clk2a:11505, // $4015
apu_clk2b:10130, // sq0
apu_clk2c:10131, // sq1
apu_clk2d:10180, // $4016
apu_clk2e:10988, // PCM-related

// IRQ sources
pcm_irq:11522,
'/pcm_irq':11492,
set_pcm_irq:14120,
pcm_irq_out:10753,

frame_irq:13110,
'/frame_irq':10697,

irq_internal:10775,
irq_external:11198,

// $401A bit 7
snd_halt:10658,
}
