// Updated 2016/09/01
var nodenames = {
vcc: 1, // pads
vss: 2, // pads

// external pins

exp0:4,
exp1:3,
exp2:86,
exp3:430,
exp_in0:26,
exp_in1:25,
exp_in2:94,
exp_in3:85,
'/exp_out0':61,
'/exp_out1':60,
'/exp_out2':88,
'/exp_out3':80,

clk0:772,
_clk0:626,
pclk0:106,
pclk1:58,
pclk0_en:669,
pclk1_en:661,

int:1031,
_int:988,

sync:14,
vid:724,

res:1934,
_res:170,
_res2:128,
wr:2087,
rd:2428,
_wr:2048,
_rd:1960,

ab13:2649,
ab12:2767,
ab11:2768,
ab10:2769,
ab9:2770,
ab8:2771,
ab7:2772,
ab6:2773,
ab5:2774,
ab4:2775,
ab3:2776,
ab2:2650,
ab1:2370,
ab0:1991,
ale:1611,

db7:2772,	// same as ab7
db6:2773,	// same as ab6
db5:2774,	// same as ab5
db4:2775,	// same as ab4
db3:2776,	// same as ab3
db2:2650,	// same as ab2
db1:2370,	// same as ab1
db0:1991,	// same as ab0

_db7:1817,
_db6:1774,
_db5:1710,
_db4:1704,
_db3:1700,
_db2:1696,
_db1:1692,
_db0:1686,

io_rw:1224,
io_db0:1013,
io_db1:765,
io_db2:431,
io_db3:87,
io_db4:11,
io_db5:10,
io_db6:9,
io_db7:8,
io_ab2:7,
io_ab1:6,
io_ab0:12,
io_ce:5,

_io_rw:79,
_io_rw_buf:31,
_io_db0:105,
_io_db1:100,
_io_db2:97,
_io_db3:95,
_io_db4:30,
_io_db5:29,
_io_db6:28,
_io_db7:27,
_io_ab2:66,
_io_ab1:68,
_io_ab0:67,
_io_ce:77,
_io_dbe:13,

// logical video output levels
vid_sync_l:751,
vid_sync_h:787,
vid_burst_l:4941,
vid_burst_h:4942,
vid_luma0_l:5538,
vid_luma0_h:5556,
vid_luma1_l:5835,
vid_luma1_h:5842,
vid_luma2_l:5912,
vid_luma2_h:5925,
vid_luma3_l:5805,
vid_luma3_h:5784,
vid_emph:954, // drags all of the above voltages down by a bit

// video output levels, ordered from GND to VCC (duplicates of the above)
vid_0:751, // h sync
vid_1:4941, // colorburst L
vid_2:5538, // color 0D
vid_3:787, // colors xE and xF
vid_4:5835, // color 1D, same level as xE/xF
vid_5:4942, // colorburst H
vid_6:5912, // color 2D
vid_7:5556, // color 00
vid_8:5842, // color 10
vid_9:5805, // color 3D
vid_10:5925, // color 20
vid_11:5784, // color 30, same as vid_10 (color 20)

// internals

// scanline counter
vpos0:210,
vpos1:259,
vpos2:311,
vpos3:377,
vpos4:429,
vpos5:496,
vpos6:543,
vpos7:588,
vpos8:632,

// decoded signals based on scanline number
vpos_eq_261:847,
vpos_eq_241:848,
// The below outputs are buffered on pclk1
vpos_eq_241_2:849,
vpos_eq_0:850,
vpos_eq_240:851,
vpos_eq_261_2:852,
vpos_eq_261_3:853,

vbl_clear_flags:604,	// duplicate of ++vpos_eq_261_3
even_frame_toggle:5156,

// Extra inputs to horizontal decoder

// Uses a reg formed by 5851/5830 that's set on y = 0 and cleared on y = 240
in_vblank:1100,
vpos_gt_239:1100, // Alternate name

// False on lines 0-239 and 261 if rendering is enabled. Uses reg
// formed by 5793/5816 to check the scanline range.
not_rendering:1030,
not_rendering_2:203,
rendering_1:2064,
rendering_2:9760,

// pixel counter
hpos0:209,
hpos1:260,
hpos2:310,
hpos3:376,
hpos4:428,
hpos5:495,
hpos6:544,
hpos7:584,
hpos8:631,

// Buffered versions of hpos
'+hpos5':5696,
'+/hpos5':5774,
'++/hpos5':5847,
'++hpos5':1109, // Output
'+hpos4':5697,
'+/hpos4':5773,
'++/hpos4':5848,
'++hpos4':1159, // Output
'+hpos3':5698,
'+/hpos3':5808,
'++/hpos3':5849,
'++hpos3':1167, // Output
'+hpos2':5699,
'+/hpos2':638, // Output
'++/hpos2':5893,
'++hpos2':1173, // Output
'+hpos1':5700,
'+/hpos1':1006, // Output
'++/hpos1':5854,
'++hpos1':1179, // Output
'+hpos0_int':5701,
'+/hpos0':5775,
'+hpos0':614, // Output
'++/hpos0':5855,
'++hpos0':282, // Output

// decoded signals based on pixel counter
hpos_eq_279:827,
'+hpos_eq_279':5427,
hpos_eq_256:828,
'+hpos_eq_256':5462,
hpos_eq_65_and_rendering:829,
'+hpos_eq_65_and_rendering':5702,
'+/hpos_eq_65_and_rendering':5798,
'++/hpos_eq_65_and_rendering':5856,
'++hpos_eq_65_and_rendering':1070, // Output
hpos_eq_0_to_7_or_256_to_263:830,
'+hpos_eq_0_to_7_or_256_to_263':5703,
in_visible_frame:831, // hpos < 256 and !in_vblank
'+in_visible_frame':5704,
'+/in_visible_frame':5776,
'+in_visible_frame_outside_clip_area':5809,
'++in_visible_frame_outside_clip_area_1':5859,
'++in_visible_frame_outside_clip_area_2':5860,
'++in_clip_area_and_clipping_spr':1114, // hpos < 256 and !in_vblank and !spr_clip // Output
'++in_clip_area_and_clipping_bg':1117, // hpos < 256 and !in_vblank and !bg_clip   // Output
hpos_eq_339_and_rendering:789,
'+hpos_eq_339_and_rendering':5705,
'/hpos_eq_339_and_rendering':781,
'+/hpos_eq_339_and_rendering':5823,
'++/hpos_eq_339_and_rendering':5875,
'++hpos_eq_339_and_rendering':1096, // Output
hpos_eq_63_and_rendering:832,
'+hpos_eq_63_and_rendering':5706,
hpos_eq_255_and_rendering:854,
'+hpos_eq_255_and_rendering':5707,
'+/hpos_eq_255_and_rendering':5817,
'++/hpos_eq_255_and_rendering':5841,
'++hpos_eq_255_and_rendering':1009, // Output
'+/hpos_eq_63_255_or_339_and_rendering':5794,
'++/hpos_eq_63_255_or_339_and_rendering_int':5852,
'++hpos_eq_63_255_or_339_and_rendering':5894,
'++/hpos_eq_63_255_or_339_and_rendering':708, // Output
hpos_lt_64_and_rendering:833,
'+hpos_lt_64_and_rendering':5708,
'+/hpos_lt_64_and_rendering':5814,
'++/hpos_lt_64_and_rendering':5843,
'++hpos_lt_64_and_rendering':357, // Output
hpos_eq_256_to_319_and_rendering:834,
'+hpos_eq_256_to_319_and_rendering':5709,
'+/hpos_eq_256_to_319_and_rendering':5826,
'++/hpos_eq_256_to_319_and_rendering':5861,
'++hpos_eq_256_to_319_and_rendering':328, // Output
in_visible_frame_and_rendering:835, // hpos < 256 and !in_vblank and rendering enabled
'+in_visible_frame_and_rendering':5710,
'+/in_visible_frame_and_rendering':5783,
'++/in_visible_frame_and_rendering_int':5850,
'++in_visible_frame_and_rendering':5906,
'++/in_visible_frame_and_rendering':283, // Output
hpos_mod_8_eq_0_or_1_and_rendering:836,
'+hpos_mod_8_eq_0_or_1_and_rendering':5711,
'+/hpos_mod_8_eq_0_or_1_and_rendering':5810,
'++/hpos_mod_8_eq_0_or_1_and_rendering_int':5862,
'++hpos_mod_8_eq_0_or_1_and_rendering':5928,
'++/hpos_mod_8_eq_0_or_1_and_rendering':1051, // Output
hpos_mod_8_eq_6_or_7:837,
'+hpos_mod_8_eq_6_or_7':5712,
'+/hpos_mod_8_eq_6_or_7':5818,
'++/hpos_mod_8_eq_6_or_7':5877,
hpos_mod_8_eq_4_or_5:838,
'+hpos_mod_8_eq_4_or_5':5713,
'+/hpos_mod_8_eq_4_or_5':5811,
'++/hpos_mod_8_eq_4_or_5':5886,
hpos_eq_320_to_335_and_rendering:839,
'+hpos_eq_320_to_335_and_rendering':5714,
hpos_lt_256_and_rendering:822,
'+hpos_lt_256_and_rendering':5715,
'+/hpos_eq_0-255_or_320-335_and_rendering':5799,
'++/hpos_eq_0-255_or_320-335_and_rendering_1':5845,
'++/hpos_eq_0-255_or_320-335_and_rendering_2':5882,
'++/hpos_eq_0-255_or_320-335_and_rendering_3':5846,
'++hpos_eq_0-255_or_320-335_and_rendering':1090, // Output
hpos_mod_8_eq_2_or_3:823,
'+hpos_mod_8_eq_2_or_3':5716,
'+/hpos_mod_8_eq_2_or_3':5825,
'+hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3_and_rendering':1162, // Output
'++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_6_or_7_and_rendering':1091, // Output
'++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_4_or_5_and_rendering':1093, // Output
hpos_eq_270:840,
'+hpos_eq_270':5717,
hpos_eq_328:841,
'+hpos_eq_328':5718,
hpos_eq_279_2:824,
'+hpos_eq_279_2':5719,
hpos_eq_304:842,
'+hpos_eq_304':5720,
hpos_eq_323:843,
'+hpos_eq_323':5721,
hpos_eq_308:844,
'+hpos_eq_308':5722,
hpos_eq_340:116,
skip_dot:802,

// Regs
'+hpos_eq_270_to_327':1002,
'+/hpos_eq_270_to_327':5796,
'+hpos_eq_279_to_303':1007,
'+/hpos_eq_279_to_303':5792,
'+hpos_eq_279_to_303_and_rendering_enabled':1003, // Output
'+hpos_eq_308_to_322':5797,
'+/hpos_eq_308_to_322':5813,
'++/hpos_eq_308_to_322':5884,
'+hpos_eq_256_to_278':922,
'+/hpos_eq_256_to_278':1001,
'+hpos_eq_256_to_278_int':5791,
'++hpos_eq_256_to_278':5885,

// SPR-RAM address pointer
spr_addr0:3079,
spr_addr1:3080,
spr_addr2:3081,
spr_addr3:3082,
spr_addr4:3083,
spr_addr5:3084,
spr_addr6:3085,
spr_addr7:3086,

// secondary OAM address
spr_ptr0:4631,
spr_ptr1:4632,
spr_ptr2:4633,
spr_ptr3:4634,
spr_ptr4:4635,
spr_ptr5:37,

spr_row0:2992,
spr_row1:2976,
spr_row2:2984,
spr_row3:2968,
spr_row4:2988,
spr_row5:2972,
spr_row6:2980,
spr_row7:2964,
spr_row8:2990,
spr_row9:2974,
spr_row10:2982,
spr_row11:2966,
spr_row12:2986,
spr_row13:2970,
spr_row14:2978,
spr_row15:2962,
spr_row16:2991,
spr_row17:2975,
spr_row18:2983,
spr_row19:2967,
spr_row20:2987,
spr_row21:2971,
spr_row22:2979,
spr_row23:2963,
spr_row24:2989,
spr_row25:2973,
spr_row26:2981,
spr_row27:2965,
spr_row28:2985,
spr_row29:2969,
spr_row30:2977,
spr_row31:2961,

spr_col0:69,
spr_col1:74,
spr_col2:75,
spr_col3:70,
spr_col4:71,
spr_col5:72,
spr_col6:73,
spr_col7:76,
spr_col8:37, // same as spr_ptr5

// data coming from sprite RAM
spr_d7:359,
spr_d6:566,
spr_d5:691,
spr_d4:871,
spr_d3:870,
spr_d2:864,
spr_d1:856,
spr_d0:818,

// sprite evaluation data

// H-position
spr0_p0:10526,
spr0_p1:10415,
spr0_p2:10300,
spr0_p3:10200,
spr0_p4:10107,
spr0_p5:10043,
spr0_p6:9976,
spr0_p7:9900,

spr1_p0:10525,
spr1_p1:10414,
spr1_p2:10299,
spr1_p3:10199,
spr1_p4:10106,
spr1_p5:10042,
spr1_p6:9975,
spr1_p7:9899,

spr2_p0:10524,
spr2_p1:10413,
spr2_p2:10298,
spr2_p3:10198,
spr2_p4:10105,
spr2_p5:10041,
spr2_p6:9974,
spr2_p7:9898,

spr3_p0:10523,
spr3_p1:10412,
spr3_p2:10297,
spr3_p3:10197,
spr3_p4:10104,
spr3_p5:10040,
spr3_p6:9973,
spr3_p7:9897,

spr4_p0:10522,
spr4_p1:10411,
spr4_p2:10296,
spr4_p3:10196,
spr4_p4:10103,
spr4_p5:10039,
spr4_p6:9972,
spr4_p7:9896,

spr5_p0:10521,
spr5_p1:10410,
spr5_p2:10295,
spr5_p3:10195,
spr5_p4:10102,
spr5_p5:10038,
spr5_p6:9971,
spr5_p7:9895,

spr6_p0:10520,
spr6_p1:10409,
spr6_p2:10294,
spr6_p3:10194,
spr6_p4:10101,
spr6_p5:10037,
spr6_p6:9970,
spr6_p7:9894,

spr7_p0:10519,
spr7_p1:10408,
spr7_p2:10293,
spr7_p3:10193,
spr7_p4:10100,
spr7_p5:10036,
spr7_p6:9969,
spr7_p7:9893,

// Palette ID
spr0_c0:9528,
spr0_c1:9568,

spr1_c0:9527,
spr1_c1:9567,

spr2_c0:9526,
spr2_c1:9566,

spr3_c0:9525,
spr3_c1:9565,

spr4_c0:9530,
spr4_c1:9570,

spr5_c0:9529,
spr5_c1:9569,

spr6_c0:9520,
spr6_c1:9564,

spr7_c0:9519,
spr7_c1:9563,

// Pixel data, inverted
'spr0_/h0':1747,
'spr0_/h1':1885,
'spr0_/h2':1908,
'spr0_/h3':1931,
'spr0_/h4':1954,
'spr0_/h5':1976,
'spr0_/h6':2007,
'spr0_/h7':2038,

'spr0_/l0':1837,
'spr0_/l1':1888,
'spr0_/l2':1907,
'spr0_/l3':1930,
'spr0_/l4':1945,
'spr0_/l5':1983,
'spr0_/l6':2006,
'spr0_/l7':2037,

'spr1_/h0':1741,
'spr1_/h1':1887,
'spr1_/h2':1899,
'spr1_/h3':1929,
'spr1_/h4':1944,
'spr1_/h5':1975,
'spr1_/h6':2004,
'spr1_/h7':2036,

'spr1_/l0':1836,
'spr1_/l1':1884,
'spr1_/l2':1900,
'spr1_/l3':1919,
'spr1_/l4':1953,
'spr1_/l5':1982,
'spr1_/l6':2005,
'spr1_/l7':2041,

'spr2_/h0':1738,
'spr2_/h1':1883,
'spr2_/h2':1906,
'spr2_/h3':1933,
'spr2_/h4':1952,
'spr2_/h5':1981,
'spr2_/h6':2013,
'spr2_/h7':2035,

'spr2_/l0':1854,
'spr2_/l1':1882,
'spr2_/l2':1898,
'spr2_/l3':1928,
'spr2_/l4':1957,
'spr2_/l5':1984,
'spr2_/l6':1997,
'spr2_/l7':2034,

'spr3_/h0':1719,
'spr3_/h1':1881,
'spr3_/h2':1904,
'spr3_/h3':1932,
'spr3_/h4':1950,
'spr3_/h5':1980,
'spr3_/h6':2012,
'spr3_/h7':2032,

'spr3_/l0':1832,
'spr3_/l1':1886,
'spr3_/l2':1905,
'spr3_/l3':1927,
'spr3_/l4':1951,
'spr3_/l5':1974,
'spr3_/l6':2003,
'spr3_/l7':2033,

'spr4_/h0':1762,
'spr4_/h1':1880,
'spr4_/h2':1894,
'spr4_/h3':1926,
'spr4_/h4':1943,
'spr4_/h5':1970,
'spr4_/h6':2002,
'spr4_/h7':2031,

'spr4_/l0':1819,
'spr4_/l1':1879,
'spr4_/l2':1897,
'spr4_/l3':1925,
'spr4_/l4':1942,
'spr4_/l5':1973,
'spr4_/l6':1996,
'spr4_/l7':2040,

'spr5_/h0':1729,
'spr5_/h1':1875,
'spr5_/h2':1902,
'spr5_/h3':1924,
'spr5_/h4':1956,
'spr5_/h5':1979,
'spr5_/h6':2000,
'spr5_/h7':2029,

'spr5_/l0':1829,
'spr5_/l1':1878,
'spr5_/l2':1903,
'spr5_/l3':1918,
'spr5_/l4':1941,
'spr5_/l5':1972,
'spr5_/l6':2001,
'spr5_/l7':2030,

'spr6_/h0':1755,
'spr6_/h1':1877,
'spr6_/h2':1893,
'spr6_/h3':1923,
'spr6_/h4':1949,
'spr6_/h5':1969,
'spr6_/h6':1999,
'spr6_/h7':2039,

'spr6_/l0':1824,
'spr6_/l1':1874,
'spr6_/l2':1896,
'spr6_/l3':1922,
'spr6_/l4':1948,
'spr6_/l5':1978,
'spr6_/l6':2011,
'spr6_/l7':2028,

'spr7_/h0':1722,
'spr7_/h1':1876,
'spr7_/h2':1901,
'spr7_/h3':1920,
'spr7_/h4':1946,
'spr7_/h5':1971,
'spr7_/h6':1998,
'spr7_/h7':2026,

'spr7_/l0':1845,
'spr7_/l1':1873,
'spr7_/l2':1895,
'spr7_/l3':1921,
'spr7_/l4':1947,
'spr7_/l5':1977,
'spr7_/l6':2010,
'spr7_/l7':2027,

// Sprite Attributes
spr0_attr0:1812,
spr0_attr1:1748,
spr1_attr0:1794,
spr1_attr1:1720,
spr2_attr0:1791,
spr2_attr1:1739,
spr3_attr0:1782,
spr3_attr1:1734,
spr4_attr0:1791,
spr4_attr1:1718,
spr5_attr0:1780,
spr5_attr1:1728,
spr6_attr0:1779,
spr6_attr1:1726,
spr7_attr0:1778,
spr7_attr1:1721,

// Priority (0 = foreground, 1 = background)
spr0_prio:9593,
'/spr0_prio':9583,
'+/spr0_prio':9560,
'+spr0_prio':1796,
spr1_prio:9592,
'/spr1_prio':9580,
'+/spr1_prio':9559,
'+spr1_prio':1793,
spr2_prio:9591,
'/spr2_prio':9579,
'+/spr2_prio':9558,
'+spr2_prio':1792,
spr3_prio:9590,
'/spr3_prio':9576,
'+/spr3_prio':9557,
'+spr3_prio':1790,
spr4_prio:9599,
'/spr4_prio':9589,
'+/spr4_prio':9562,
'+spr4_prio':1803,
spr5_prio:9594,
'/spr5_prio':9586,
'+/spr5_prio':9561,
'+spr5_prio':1800,
spr6_prio:9585,
'/spr6_prio':9575,
'+/spr6_prio':9556,
'+spr6_prio':1786,
spr7_prio:9584,
'/spr7_prio':9572,
'+/spr7_prio':9555,
'+spr7_prio':1784,

// Output (pixel data inverted, attribute data not inverted)
spr_out_prio:1528,
spr_out_attr1:1525,
spr_out_attr0:1520,
'spr_out_/pat1':1674,
'spr_out_/pat0':1680,

// I/O registers
'/w2000':487,
'/w2001':481,
'/w2003':463,
'/w2004':341,
'/w2005a':297,
'/w2005b':291,
'/w2006a':255,
'/w2006b':244,
'/w2007':414,
'/r2002':205,
'/r2004':83,
'/r2007':387,
hvtog:221,

write_2000_vramaddr:2504,
write_2000_reg:1165,
'/write_2000_reg':1132,
write_2001_reg:1170,
'/write_2001_reg':1138,
read_2002_reset_hvtog:199,
read_2002_output_spr_overflow:4156,
read_2002_output_spr0_hit:7224,
read_2002_output_vblank_flag:5869,
write_2003_reg:279,
write_2004_value:234,
read_2004_enable:2910,
'/read_2004_enable':93,
write_2005_horiz:2524,
write_2005_vert:2523,
write_2006_high:2514,
write_2006_low:2090,
read_2007_trigger:2830,
read_2007_output_palette:6152,
read_2007_output_vrambuf:2828,
write_2007_trigger:10584,

// Writable Registers
_vramaddr_t14:9934,
_vramaddr_t13:9935,
_vramaddr_t12:9936,
_vramaddr_t11:9937,
_vramaddr_t10:9938,
_vramaddr_t9:9939,
_vramaddr_t8:9940,
_vramaddr_t7:9941,
_vramaddr_t6:9942,
_vramaddr_t5:9943,
_vramaddr_t4:9944,
_vramaddr_t3:9945,
_vramaddr_t2:9946,
_vramaddr_t1:9947,
_vramaddr_t0:9948,
vramaddr_t14:2339,
vramaddr_t13:2340,
vramaddr_t12:2341,
vramaddr_t11:2342,
vramaddr_t10:2343,
vramaddr_t9:2344,
vramaddr_t8:2345,
vramaddr_t7:2346,
vramaddr_t6:2332,
vramaddr_t5:2333,
vramaddr_t4:2334,
vramaddr_t3:2335,
vramaddr_t2:2336,
vramaddr_t1:2337,
vramaddr_t0:2338,
'vramaddr_/t14':9817,
'vramaddr_/t13':9818,
'vramaddr_/t12':9819,
'vramaddr_/t11':9820,
'vramaddr_/t10':9821,
'vramaddr_/t9':9822,
'vramaddr_/t8':9823,
'vramaddr_/t7':9824,
'vramaddr_/t6':9825,
'vramaddr_/t5':9826,
'vramaddr_/t4':9827,
'vramaddr_/t3':9828,
'vramaddr_/t2':9829,
'vramaddr_/t1':9830,
'vramaddr_/t0':9831,

_finex2:9931,
_finex1:9932,
_finex0:9933,
finex2:2371,
finex1:2376,
finex0:2381,
'/finex2':9814,
'/finex1':9815,
'/finex0':9816,

vramaddr_v14:9713,
vramaddr_v13:9714,
vramaddr_v12:9715,
vramaddr_v11:9716,
vramaddr_v10:9717,
vramaddr_v9:9718,
vramaddr_v8:9719,
vramaddr_v7:9720,
vramaddr_v6:9721,
vramaddr_v5:9722,
vramaddr_v4:9723,
vramaddr_v3:9724,
vramaddr_v2:9725,
vramaddr_v1:9726,
vramaddr_v0:9727,
'vramaddr_/v14':1867,
'vramaddr_/v13':1863,
'vramaddr_/v12':1872,
'vramaddr_/v11':2259,
'vramaddr_/v10':2250,
'vramaddr_/v9':2260,
'vramaddr_/v8':2261,
'vramaddr_/v7':2251,
'vramaddr_/v6':2252,
'vramaddr_/v5':2262,
'vramaddr_/v4':2253,
'vramaddr_/v3':2263,
'vramaddr_/v2':2264,
'vramaddr_/v1':2265,
'vramaddr_/v0':2254,

copy_vramaddr_hscroll:2317,
copy_vramaddr_vscroll:2318,

'/rendering_or_v11_carry_out':9571,
vramaddr_v_hpos_eq_31_and_rendering:2374,
vramaddr_v_hpos_eq_31_and_not_rendering:2359,
vramaddr_v_vpos_29_to_30_transition_and_rendering:2373, // vramaddr_v9-5 = 29 and vramaddr_v5_carry_in = 1
vramaddr_v_vpos_overflow_and_not_rendering:2379, // vramaddr_v9-5 = 31 and vramaddr_v5_carry_in = 1
'+/vramaddr_v_vpos_29_to_30_transition_and_rendering':9712, // Buffered on pclk0 + pclk1
clr_vramaddr_vtile:2088,
'/inc_vramaddr_v_by_32':2361,
fine_y_eq_7_and_rendering:2349,

// $2000
addr_inc:6047,
'/addr_inc':6169,
addr_inc_out:1277,
spr_pat:6046,
'/spr_pat':6168,
'/spr_pat_out':1182,
bkg_pat:6045,
'/bkg_pat':6167,
'/bkg_pat_out':1177,
spr_size:6044,
'/spr_size':6166,
spr_size_out:1058,
slave_mode:23,
'/slave_mode':6165,
enable_nmi:1125,
'/enable_nmi':6164,

// $2001
pal_mono:1111,
'/pal_mono':6163,
bkg_clip:6038,
'/bkg_clip':6156,
bkg_clip_out:1161,
spr_clip:6041,
'/spr_clip':6160,
spr_clip_out:1153,
bkg_enable:6040,
'/bkg_enable':6158,
spr_enable:6039,
'/spr_enable':6157,
emph0:6042,
'/emph0':6161,
'/emph0_out':1184,
emph1:6043,
'/emph1':6162,
'/emph1_out':1168,
emph2:1129,
'/emph2':6159,
'/emph2_out':1128,

rendering_disabled:1133, // bkg_enable NOR spr_enable

// $2002
spr0_hit:6776,
spr_overflow:4064,
vbl_flag:5881,
'/vbl_flag':5840,
'/spr0_hit':7106,
'/spr_overflow':3992,

set_vbl_flag:5807,
set_spr0_hit:1359,

// $2007 read buffer

inbuf7:9753,
inbuf6:9773,
inbuf5:9840,
inbuf4:9881,
inbuf3:9957,
inbuf2:10164,
inbuf1:10276,
inbuf0:10332,

// render buffer

// upper attribute bit shift register, inverted
attrib_h0:10376,
attrib_h1:10377,
attrib_h2:10378,
attrib_h3:10379,
attrib_h4:10380,
attrib_h5:10381,
attrib_h6:10382,
attrib_h7:10383,
attrib_h8:10280, // value shifted in

// lower attribute bit shift register, inverted
attrib_l0:10384,
attrib_l1:10385,
attrib_l2:10386,
attrib_l3:10387,
attrib_l4:10388,
attrib_l5:10389,
attrib_l6:10390,
attrib_l7:10391,
attrib_l8:10281, // value shifted in

// upper pattern bit shift register, NOT inverted
tile_h0:10392,
tile_h1:10393,
tile_h2:10394,
tile_h3:10395,
tile_h4:10396,
tile_h5:10397,
tile_h6:10398,
tile_h7:10399,
tile_h8:10235, // values shifted in
tile_h9:10234,
tile_h10:10249,
tile_h11:10248,
tile_h12:10247,
tile_h13:10246,
tile_h14:10245,
tile_h15:10244,

// lower pattern bit shift register, inverted
tile_l0:10400,
tile_l1:10401,
tile_l2:10402,
tile_l3:10403,
tile_l4:10404,
tile_l5:10405,
tile_l6:10406,
tile_l7:10407,
tile_l8:10243, // values shifted in
tile_l9:10242,
tile_l10:10241,
tile_l11:10240,
tile_l12:10239,
tile_l13:10238,
tile_l14:10237,
tile_l15:10236,

// Tile read buffer for the render pipeline, low bits only - this way it can copy into tile_l8+ and tile_h8+ at the same time
tile_lbuf0:10004,
tile_lbuf1:10005,
tile_lbuf2:10006,
tile_lbuf3:10007,
tile_lbuf4:10008,
tile_lbuf5:10009,
tile_lbuf6:10010,
tile_lbuf7:10011,

// Attribute table byte buffer - this gets decoded by the vramaddr_v1/v6 to decide which (inverted) bits to output to attrib_h8/attrib_l8
attrib_buf0:10019,
attrib_buf1:10015,
attrib_buf2:10018,
attrib_buf3:10014,
attrib_buf4:10017,
attrib_buf5:10013,
attrib_buf6:10016,
attrib_buf7:10012,

// BG pixel colors, sent to EXT pins
pixel_color0:1388,
pixel_color1:1391,
pixel_color2:1394,
pixel_color3:1398,

// effective palette address
pal_ptr0:1463,
pal_ptr1:1462,
pal_ptr2:1355,
pal_ptr3:1343,
pal_ptr4:1487,

// palette address signals
pal_row0:7581,
pal_row1:8148,
pal_row2:7870,
pal_row3:8450,
pal_row4:7581, // doesn't actually exist, logically same as pal_row0
pal_row5:8145,
pal_row6:7837,
pal_row7:8448,

pal_col0:1386,
pal_col1:1378,
pal_col2:1385,
pal_col3:1369,

//  #7506 => [ppu.pal_col0#1386 <> vcc#1]
'!pal_col0':7506,

// #7365 => [ppu.pal_col1#1378 <> vcc#1]
// #1356 => [#7365 <> vss#2]
'!pal_col1':7365,

// #7433 => [ppu.pal_col2#1385 <> vcc#1]
'!pal_col2':7433,

// #7295 => [ppu.pal_col3#1369 <> vcc#1]
'!pal_col3':7295,

// #1354 => [ppu.pal_col2#1385 <> vss#2]
// #1354 => [ppu.pal_col3#1369 <> vss#2]
'/pal_ptr3':1354,

// #1356 => [ppu.pal_col1#1378 <> vss#2]
// #1356 => [ppu.pal_col3#1369 <> vss#2]
'/pal_ptr2':1356,



// #8146 => [#1532 <> vss#2]
// #7828 => [#7903 <> vss#2]
// #1522 => [#7987 <> vss#2]

// #7583 => [ppu.pal_row0#7581 <> vcc#1]
// #8213 => [ppu.pal_row1#8148 <> vcc#1]
// #7904 => [ppu.pal_row2#7870 <> vss#2]
// #8487 => [ppu.pal_row3#8450 <> vss#2]

// #8028 => [ppu.pal_row5#8145 <> vcc#1]
// #1464 => [ppu.pal_row5#8145 <> vss#2]

// #7710 => [ppu.pal_row6#7837 <> vcc#1]
// #1488 => [ppu.pal_row6#7837 <> vss#2]
// #1460 => [ppu.pal_row6#7837 <> vss#2]

// #8335 => [ppu.pal_row7#8448 <> vcc#1]


'!pal_row0':7583,
'!pal_row1':8213,
'/pal_row2':7904,
'/pal_row3':8487,

'/pal_row5':1464,
'!pal_row5':8028,

'!pal_row6':7710,
'/pal_row6':1488,
'/pal_row6_2':1460,

'!pal_row7':8335,



'pal_col0_/d0':1418,
'pal_col0_d0':1410,
'pal_col1_/d0':1419,
'pal_col1_d0':1411,
'pal_col2_/d0':1412,
'pal_col2_d0':1413,
'pal_col3_/d0':1420,
'pal_col3_d0':1421,

'pal_col0_/d1':1422,
'pal_col0_d1':1423,
'pal_col1_/d1':1424,
'pal_col1_d1':1425,
'pal_col2_/d1':1426,
'pal_col2_d1':1427,
'pal_col3_/d1':1428,
'pal_col3_d1':1414,

'pal_col0_/d2':1429,
'pal_col0_d2':1430,
'pal_col1_/d2':1431,
'pal_col1_d2':1432,
'pal_col2_/d2':1433,
'pal_col2_d2':1434,
'pal_col3_/d2':1435,
'pal_col3_d2':1415,

'pal_col0_/d3':1436,
'pal_col0_d3':1437,
'pal_col1_/d3':1438,
'pal_col1_d3':1439,
'pal_col2_/d3':1440,
'pal_col2_d3':1441,
'pal_col3_/d3':1442,
'pal_col3_d3':1416,

'pal_col0_/d4':1443,
'pal_col0_d4':1417,
'pal_col1_/d4':1444,
'pal_col1_d4':1445,
'pal_col2_/d4':1446,
'pal_col2_d4':1447,
'pal_col3_/d4':1448,
'pal_col3_d4':1449,

'pal_col0_/d5':1450,
'pal_col0_d5':1451,
'pal_col1_/d5':1452,
'pal_col1_d5':1453,
'pal_col2_/d5':1454,
'pal_col2_d5':1455,
'pal_col3_/d5':1456,
'pal_col3_d5':1457,


// Renderer internals
spr_slot_0_opaque:8706,
'/spr_slot_0_opaque':1349,
'/bg_pixel_opaque':1459,
sprite_0_on_cur_scanline:5834,
sprite_0_on_next_scanline:5934,

'/spr_loadX':1311,
'/spr_loadFlag':1322,
'/spr_loadH':1329,
'/spr_loadL':1337,

//
// vpos decoding logic.
//

'+vpos_eq_241_2':5724,
'+vpos_eq_0':5725,
'+vpos_eq_240':5726,
'+vpos_eq_261_2':5727,
'+vpos_eq_261_3':5728,

'+/vpos_eq_261_3':1000,
'++/vpos_eq_261_3':5772,
// Clears the VBlank, sprite 0, and overflow flags, and interacts with the
// even/odd frame logic
'++vpos_eq_261_3':604,

// Reg

'+/vpos_eq_241_2':1015,
'++/vpos_eq_241_2':5858,
'++vpos_eq_241_2':5857,
'+++vpos_eq_241_2':5785,

// Reg
'+pos_eq_270_261_to_270_241':5821,
'+/pos_eq_270_261_to_269_241':5820,

'++/pos_eq_270_261_to_269_241':5864,
'++hpos_eq_270_to_327':5863,

// Line    261: 328-340
// Lines 0-240: 0-269 and 328-340
// Line    241: 0-269
'++in_draw_range':5915,
'++/in_draw_range':949,

// VBlank flag

'/vbl_flag_out':1014,
'/read_2002_output_vblank_flag':5729,
'/vbl_flag_read_buffer':5827,
'vbl_flag_read_buffer_out':5871,
'/vbl_flag_read_buffer_out_and_read_2002':5778,
'vbl_flag_read_buffer_out_and_read_2002':5730,

'/enable_nmi_2':5731,

//
// Logic below position decoding logic
//

'/ab_in_palette_range_and_not_rendering':6048,
'(++in_draw_range_or_read_2007_output_palette)_and_/pal_mono':1350,

'+write_2007_ended_3':6741,
'/(ab_in_palette_range_and_not_rendering_and_+write_2007_ended)':6728,
'/(ab_in_palette_range_and_not_rendering_and_+write_2007_ended)_2':1276,


//
// Nodes related to video generation
//

vpos_eq_247:845, // Old name was vpos_vsync_end
vpos_eq_244:846, // Old name was vpos_vsync_start

// Reg, possibly sync-related
pos_eq_279_244_to_278_247:5819,
'/pos_eq_279_244_to_278_247':5777,

// Lines   0-243: 279-304
// Line      244: 279-340
// Lines 245-246: Entire line
// Line      247: 0-304
// Line  248-261: 279-304
//
// Sketch (not to scale):
//
//          279  304
//           ------             0
//           ||||||
//           ------             243
//           ------------------ 244
// ---------------------------- 245
// ---------------------------- 246
// ----------------             247
//           ------             248
//           ||||||
//           ------             261
'/in_range_1':5804,
'+/in_range_1':1079,

//     257   280 304
//            -----             0
//            |||||
//            -----             243
//            ----------------- 244
// ------     ----------------- 245
// ------     ----------------- 246
// ------     -----             247
//            -----             248
//            |||||
//            -----             261
in_range_2:915,
'/in_range_2':5227,
'+/in_range_2':5157, // -> vid_sync_l

//                   309 323
//                    -----     0
//                    -----
//                    -----     243
//                              244
//                              245
//                              246
//                    -----     247
//                    -----     248
//                    -----
//                    -----     261
in_range_3:547,
'+in_range_3':511,

//
// Palette
//

'/read_2007_output_palette':1207,

//
// Sprite-related (?)
//

'+++hpos_eq_339_and_rendering':8704,
'+++/hpos_eq_339_and_rendering':8722,
'++++/hpos_eq_339_and_rendering':8705,
'++++hpos_eq_339_and_rendering':8715,
'+++++hpos_eq_339_and_rendering':8700,
'+++++/hpos_eq_339_and_rendering':1681, // I.e, delayed 2.5 pixels

// Sprite-zero-related

'/sprite_0_on_cur_scanline':1105,
'/sprite_0_on_next_scanline':5907,

'++/hpos_eq_256_to_319_and_rendering_2':5903,
'++/hpos_eq_256_to_319_and_rendering_2_and_pclk1':1107,

'++/hpos_eq_65_and_rendering_2':5890,
'++hpos_eq_65_and_rendering_and_pclk1':5876,

//
// Sprite data from OAM (prolly y coord) being subtracted from vpos
//

'+spr_d7':894,
'+spr_d6':868,
'+spr_d5':862,
'+spr_d4':859,
'+spr_d3':820,
'+spr_d2':816,
'+spr_d1':814,
'+spr_d0':4891,

'+/spr_d7':874,
'+/spr_d6':875,
'+/spr_d5':879,
'+/spr_d4':880,
'+/spr_d3':881,
'+/spr_d2':876,
'+/spr_d1':877,
'+/spr_d0':878,

'+spr_d7_gt_vpos7':902,
'+spr_d6_gt_vpos6':905,
'+spr_d5_gt_vpos5':906,
'+spr_d4_gt_vpos4':907,
'+spr_d3_gt_vpos3':908,
'+spr_d2_gt_vpos2':903,
'+spr_d1_gt_vpos1':909,
'+spr_d0_gt_vpos0':910,

'+spr_d7_ge_vpos7':5152,
'+spr_d6_ge_vpos6':938,
'+spr_d5_ge_vpos5':5153,
'+spr_d4_ge_vpos4':940,
'+spr_d3_ge_vpos3':5154,
'+spr_d2_ge_vpos2':941,
'+spr_d1_ge_vpos1':5155,
'+spr_d0_ge_vpos0':939,

'+spr_d7_lt_vpos7':5424,
'+spr_d6_lt_vpos6':5379,
'+spr_d5_lt_vpos5':5421,
'+spr_d4_lt_vpos4':5381,
'+spr_d3_lt_vpos3':5422,
'+spr_d2_lt_vpos2':5377,
'+spr_d1_lt_vpos1':5425,
'+spr_d0_lt_vpos0':5382,

'+spr_d0_eq_vpos0':982,
'+spr_d1_eq_vpos1':981,
'+spr_d2_eq_vpos2':980,
'+spr_d3_eq_vpos3':979,
'+spr_d4_eq_vpos4':978,
'+spr_d5_eq_vpos5':977,
'+spr_d6_eq_vpos6':976,
'+spr_d7_eq_vpos7':975,

// Subtractor outputs
'+vpos_minus_spr_d0':1039,
'+vpos_minus_spr_d1':1038,
'+vpos_minus_spr_d2':1037,
'+vpos_minus_spr_d3':1036,
'+vpos_minus_spr_d4':5803,
'+vpos_minus_spr_d5':5802,
'+vpos_minus_spr_d6':5801,
'+vpos_minus_spr_d7':5800,

// Logic above subtractor

'++in_visible_frame_and_hpos_ge_64_and_rendering':3825,
'/++in_visible_frame_and_hpos_ge_64_and_hpos0_and_rendering':3987,
'/+++in_visible_frame_and_hpos_ge_64_and_hpos0_and_rendering':3986,

rendering_3:509,

'++in_visible_frame_and_rendering_and_/hpos0':523, // Not powered
'++not_rendering_or_in_visible_frame_and_/hpos0':515,

'/spr_addr7':356,
'/spr_addr6':355,
'/spr_addr5':223,
'/spr_addr4':212,
'/spr_addr3':204,
'/spr_addr2':180,
'/spr_addr1':350,
'/spr_addr0':222,

spr_addr_7_carry_out:455,
'/spr_addr_7_carry_in':447,
spr_addr_7_carry_in:446,

spr_addr_6_carry_out:445, // Unused
'/spr_addr_6_carry_in':432,
spr_addr_6_carry_in:444,

spr_addr_5_carry_out:443, // Unused
'/spr_addr_5_carry_in':442,
spr_addr_5_carry_in:441,

spr_addr_4_carry_out:440, // Unused
'/spr_addr_4_carry_in':439,
spr_addr_4_carry_in:438,

spr_addr_3_carry_out:437, // Unused
'/spr_addr_3_carry_in':436,
spr_addr_3_carry_in:454,

spr_addr_2_carry_out:453, // Unused
'/spr_addr_2_carry_in':452,
spr_addr_2_carry_in:451,

spr_addr1_carry_out:435, // Unused
'/spr_addr0_carry_out':434,
spr_addr0_carry_out:450,
'/spr_addr0_carry_in':449,

spr_addr_next7:3078,
spr_addr_next6:3077,
spr_addr_next5:3076,
spr_addr_next4:3075,
spr_addr_next3:3074,
spr_addr_next2:3073,
spr_addr_next1:3072,
spr_addr_next0:3071,

// Always high after writing 2004 (as that increments spr_addr). Also high
// during sprite evaluation at points where spr_addr is bumped.
spr_addr_load_next_value:288,

'+spr_addr_7_carry_out':508,

// spr_addr after passing through powered poly (labelled "protection" in Visual 2C02)
'/spr_addr7_':3423,
'/spr_addr6_':3422,
'/spr_addr5_':3421,
'/spr_addr4_':3420,
'/spr_addr3_':3419,
'/spr_addr2_':3418,
'/spr_addr1_':3417,
'/spr_addr0_':3416,
spr_addr7_:3505,
spr_addr6_:3504,
spr_addr5_:3503,
spr_addr4_:3502,
spr_addr3_:3501,
spr_addr2_:3500,
spr_addr1_:3499,
spr_addr0_:3498,

'/spr_addr2_out':39,
'/spr_addr1_out':51,
'/spr_addr0_out':57,

'spr_addr_0-1_eq_3':119,
'spr_addr_0-1_neq_3':120,
'/spr_load_next_value_or_write_2003_reg':179,

'+delayed_write_2004_value':2956,
'+/delayed_write_2004_value':2960,
'+delayed_write_2004_value_and_pclk0':397,
'/(+delayed_write_2004_value_and_pclk0)':364,

'/spr_ptr4':689,
'/spr_ptr3':688,
'/spr_ptr2':687,
'/spr_ptr1':681,
'/spr_ptr0':686,

'+spr_ptr4_carry_out':608,
spr_ptr4_carry_out:611,
'/spr_ptr3_carry_out':624,
spr_ptr3_carry_out:623,
'/spr_ptr2_carry_out':622,
spr_ptr2_carry_out:621,
'/spr_ptr1_carry_out':620,
spr_ptr1_carry_out:619,
'/spr_ptr0_carry_out':618,
spr_ptr0_carry_out:617,
'/spr_ptr0_carry_in':616, // Always 0

spr_ptr_next4:4710,
spr_ptr_next3:4709,
spr_ptr_next2:4708,
spr_ptr_next1:4707,
spr_ptr_next0:4706,

inc_spr_ptr:735,

'+++hpos_lt_64_and_rendering':4551,
spr_eval_copy_sprite_2:4303,
'+spr_eval_copy_sprite':4550,
'/((+++hpos_lt_64_and_rendering)_or_+spr_eval_copy_sprite)':4630,
'((+++hpos_lt_64_and_rendering)_or_+spr_eval_copy_sprite)_and_/+hpos0':4627,

// First condition (before the OR) deals with increments during sprite
// evaluation. Second condition deals with increments during sprite loading.
'/((((+++hpos_lt_64_and_rendering)_or_+spr_eval_copy_sprite)_and_/+hpos0)_OR_(++hpos_eq_256_to_319_and_rendering_and_/+hpos2))':730,

'++(hpos_eq_63_255_or_339_and_rendering)_or_spr_ptr_overflow':4705,
'+(++(hpos_eq_63_255_or_339_and_rendering)_or_spr_ptr_overflow)':4624,

'/read_2002_output_spr_overflow':3753,
'/spr_overflow_out':3743,
spr_overflow_output_high:522,

// Reg
spr_ptr_overflow:300,
'/spr_ptr_overflow':4314,

'+/spr_ptr_overflow':4067,

// Reg
//  - Set by spr_addr overflow
//  - Set by sec_oam_overflow
//  - Cleared during sec. OAM clear (if rendering is enabled)
//  - Used by
//   * OAM access logic
//   * Sprite evaluation logic
end_of_oam_or_sec_oam_overflow:272,
'/end_of_oam_or_sec_oam_overflow':460,

copy_sprite_to_sec_oam:1047,
'copy_sprite_to_sec_oam_buf_++hpos0':5880,
'/copy_sprite_to_sec_oam_buf_++hpos0':5923,
'+/copy_sprite_to_sec_oam_buf_++hpos0':5897,
'+copy_sprite_to_sec_oam_buf_++hpos0':5866,
'copy_sprite_to_sec_oam_buf_2x_++hpos0':5891,
'/copy_sprite_to_sec_oam_buf_2x_++hpos0':5921,
'+/copy_sprite_to_sec_oam_buf_2x_++hpos0':5896,
'+copy_sprite_to_sec_oam_buf_2x_++hpos0':5867,
'copy_sprite_to_sec_oam_buf_3x_++hpos0':5892,
'/copy_sprite_to_sec_oam_buf_3x_++hpos0':5919,
'+/copy_sprite_to_sec_oam_buf_3x_++hpos0':5895,
'+copy_sprite_to_sec_oam_buf_3x_++hpos0':5865,

// Stays low for a while after copy_sprite_to_sec_oam_buf goes high
'/do_copy_sprite_to_sec_oam':1057,
'do_copy_sprite_to_sec_oam':5853,

// Copies in-range sprites to the secondary OAM during sprite evaluation
'/spr_eval_copy_sprite':118,
'+/spr_eval_copy_sprite':4025,
spr_eval_copy_sprite:2931,
// Sets up the 'next' values for the spr_addr bits to clear spr_addr1-0 and
// bump spr_addr7-2.
spr_addr_clear_low_bump_high_setup:156,
'/spr_addr_clear_low_bump_high_setup':231,

// High if scanline - y < 8 (or 16 if using 8x16 sprites). Checks if the upper
// 5 (or 4) bits of the difference are all zero, and avoids a false positive by
// also checking if y >= 128 while scanline < 128 (without this check, y being
// sufficiently larger than scanline would trigger the false positive).
//
// Driven low while copying the last three bytes of a sprite, to prevent other
// sprite data from being interpreted as the y coordinate.
sprite_in_range:1052,
'/sprite_in_range':1056,
'+/sprite_in_range':5878,
'+sprite_in_range':5911,

'+sprite_in_range_reg':1098,
'+/sprite_in_range_reg':5873,

// spr_ptr after passing through powered poly (labelled "protection" in Visual 2C02)
'/spr_ptr4_':4152,
'/spr_ptr3_':4151,
'/spr_ptr2_':4150,
'/spr_ptr1_':4149,
'/spr_ptr0_':4148,
spr_ptr4_:4322,
spr_ptr3_:4321,
spr_ptr2_:4320,
spr_ptr1_:4319,
spr_ptr0_:4318,

'+++/hpos_eq_63_255_or_339_and_rendering':4548,
clear_spr_ptr:743, // Also does other stuff

spr_addr_3_or_spr_ptr0_out:3740,
spr_addr_4_or_spr_ptr1_out:3741,
spr_addr_5_or_spr_ptr2_out:3742,
spr_addr_6_or_spr_ptr3_out:3735,
spr_addr_7_or_spr_ptr4_out:3701,
'/spr_addr_3_or_spr_ptr0_out':484,
'/spr_addr_4_or_spr_ptr1_out':491,
'/spr_addr_5_or_spr_ptr2_out':499,
'/spr_addr_6_or_spr_ptr3_out':510,
'/spr_addr_7_or_spr_ptr4_out':545,

// OAM row selector inverses

spr_addr_7_or_spr_ptr4_out_2:1026,
spr_addr_6_or_spr_ptr3_out_2:1034,
spr_addr_5_or_spr_ptr2_out_2:1053,
spr_addr_4_or_spr_ptr1_out_2:1071,
spr_addr_3_or_spr_ptr0_out_2:1081,

// Logic below subtractor

'+spr_d7_2':5904,
'+/spr_d7_2':5909,
'+spr_d7_and_/vpos7':5839,

'++/hpos0_2':5872,
'++hpos0_2_and_pclk_1':1077,
'++hpos_mod_8_eq_1_and_rendering':5844,
'++/hpos_mod_8_eq_1_and_rendering':5832,
'+++/hpos_mod_8_eq_1_and_rendering':5879,
'+++/hpos_mod_8_eq_1_and_rendering_and_pclk0':1084,

'/spr_size_out':5828,

// Logic below $2000/$2001 regs

'+++/in_visible_frame_and_rendering':1261,
bkg_enable_out:1280,
'/bkg_enable_out':6816,
spr_enable_out:1267,
'/spr_enable_out':6817,
'+++in_clip_area_and_clipping_bg':6738,

// In visible frame, doing render ops, sprites enabled, and not clipping sprites
'+++do_sprite_render_ops':6850,
'++++do_sprite_render_ops':6740,
'++++/do_sprite_render_ops':1283, // Doubly buffered on pclk1?

// In visible frame, doing render ops, bg enabled, and not clipping bg
'+++do_bg_render_ops':1281,

'++/hpos2_2':7073,
'++/hpos1_2':6996,
'++/hpos0_3':6997,
'++/hpos_eq_256_to_319_and_rendering_3':6998,

'++hpos_eq_256_to_319_and_hpos_mod_8_eq_3_and_rendering':1310,
'++hpos_eq_256_to_319_and_hpos_mod_8_eq_2_and_rendering':1320,
'++hpos_eq_256_to_319_and_hpos_mod_8_eq_7_and_rendering':1328,
'++hpos_eq_256_to_319_and_hpos_mod_8_eq_5_and_rendering':1338,
'+++hpos_eq_256_to_319_and_hpos_mod_8_eq_3_and_rendering':1305,
'+++hpos_eq_256_to_319_and_hpos_mod_8_eq_2_and_rendering':1321,
'+++hpos_eq_256_to_319_and_hpos_mod_8_eq_7_and_rendering':1330,
'+++hpos_eq_256_to_319_and_hpos_mod_8_eq_5_and_rendering':1336,

// Pixel selection logic

spr_out_pat1:8077,
spr_out_pat0:8078,

'spr_out_/prio':7831,
'spr_out_/attr1':7832,
'spr_out_/attr0':7833,
'spr_out_/pat1_2':7834,
'spr_out_/pat0_2':7835,

'+spr_out_/prio':7638,
'+spr_out_/attr1':7639,
'+spr_out_/attr0':7640,
'+spr_out_/pat1':7641,
'+spr_out_/pat0':7642,

'+spr_out_prio':7473,
'+spr_out_attr1':1524,
'+spr_out_attr0':1519,
'+spr_out_pat1':1514,
'+spr_out_pat0':1512,

'+vramaddr_v4_out':1541,
'+vramaddr_v3_out':1570,
'+vramaddr_v2_out':1559,
'+vramaddr_v1_out':1556,
'+vramaddr_v0_out':1551,
'+/vramaddr_v4_out':1542,
'+/vramaddr_v3_out':1569,
'+/vramaddr_v2_out':1563,
'+/vramaddr_v1_out':1557,
'+/vramaddr_v0_out':1550,

'/ab_in_palette_range_and_not_rendering_2':1535,

'bg_pixel_opaque':1458,
'+bg_pixel_opaque':7510,

'spr_pixel_transparent':1406,
'spr_pixel_opaque':7367,
'+spr_pixel_opaque':7509,
'+spr_and_bg_pixel_transparent':1499,
'+/spr_and_bg_pixel_transparent':1493,
'+spr_pixel_opaque_and_not_hidden_behind_bg_pixel':1408,
'+/spr_pixel_opaque_and_not_hidden_behind_bg_pixel':1407,
'++spr_pixel_opaque_and_not_hidden_behind_bg_pixel':7632,
'++/spr_pixel_opaque_and_not_hidden_behind_bg_pixel':7829,
// vramaddr_v4 is selected when the background palette hack is active (address
// bus points in 3FXX range)
'(++/spr_pixel_opaque_and_not_hidden_behind_bg_pixel)_or_/vramaddr_v4':10700,

// After muxing. Selects between sprite and bg.
selected_attr1:7577,
selected_attr0:7578,
selected_pat1:7579,
selected_pat0:7580,
'+/selected_attr1':7633,
'+/selected_attr0':7634,
'+/selected_pat1':7635,
'+/selected_pat0':7636,
'+selected_attr1':7823,
'+selected_attr0':7824,
'+selected_pat1':7825,
'+selected_pat0':7826,
'+selected_attr1_or_exp_in3_if_bg':10695,
'+selected_attr0_or_exp_in2_if_bg':10696,
'+selected_pat1_or_exp_in1_if_bg':10697,
'+selected_pat0_or_exp_in0_if_bg':10698,
'++selected_attr1_or_exp_in3_if_bg':8020,
'++selected_attr0_or_exp_in2_if_bg':8021,
'++selected_pat1_or_exp_in1_if_bg':8022,
'++selected_pat0_or_exp_in0_if_bg':8023,
'++/selected_attr1_or_exp_in3_if_bg':8024,
'++/selected_attr0_or_exp_in2_if_bg':8025,
'++/selected_pat1_or_exp_in1_if_bg':8026,
'++/selected_pat0_or_exp_in0_if_bg':8027,

// The vramaddr_v bits are selected when the background palette hack is active
// (address bus points in 3FXX range)
'+(++/spr_pixel_opaque_and_not_hidden_behind_bg_pixel)_or_/vramaddr_v4':1540,
'(++/selected_attr1_or_exp_in3_if_bg)_or_/vramaddr_v3':8264,
'(++/selected_attr0_or_exp_in2_if_bg)_or_/vramaddr_v2':8265,
'(++/selected_pat1_or_exp_in1_if_bg)_or_/vramaddr_v1':8266,
'(++/selected_pat0_or_exp_in0_if_bg)_or_/vramaddr_v0':8267,

//
// BG shifter logic
//

'/fine_x0':2723,
'/fine_x1':2725,
'/fine_x2':2727,

'++/hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_4_or_5_and_rendering':2593,
'++/hpos_eq_0-255_or_320-335_and_rendering_4':10201,
'++hpos_eq_0-255_or_320-335_and_rendering_and_pclk1':2722,
'++/hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_6_or_7_and_rendering':2632,
'+/hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3_and_rendering':10278,
'++/hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3_and_rendering':10110,

'++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_7_and_rendering':10111,

'++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_3_and_rendering_and_pclk1':2533,
'++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_5_and_rendering_and_pclk1':2543,
'++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_7_and_rendering_and_pclk1':2597,
'++hpos_eq_0-255_or_320-335_and_hpos_mod_8_neq_7_and_rendering_and_pclk1':2607, // Note: 'neq', not 'eq'

'++/hpos0_3b':2611,

'++++do_bg_render_ops':10165,
'++++/do_bg_render_ops':2606,

// There are other conditions on this one too, but they don't seem to matter
// (the pull-downs are always low during pclk0)
pclk0_3:2633,

'/tile_lbuf7':10052,
'/tile_lbuf6':10051,
'/tile_lbuf5':10050,
'/tile_lbuf4':10049,
'/tile_lbuf3':10048,
'/tile_lbuf2':10047,
'/tile_lbuf1':10046,
'/tile_lbuf0':10045,

// Shifter outputs, with bit selected by fine_x
tile_l_bit_out:2732,
tile_h_bit_out:2730,
attrib_l_bit_out:2729,
attrib_h_bit_out:2731,
'/tile_l_bit_out':10204,
'/attrib_l_bit_out':10203,
'/attrib_h_bit_out':10202,

'+tile_h_bit_out':10145,
'+/tile_l_bit_out':10144,
'+/attrib_l_bit_out':10143,
'+/attrib_h_bit_out':10142,

'+/tile_h_bit_out':10090,
'+tile_l_bit_out':10089,
'+attrib_l_bit_out':10088,
'+attrib_h_bit_out':10087,

'++/tile_h_bit_out':10256,
'++tile_l_bit_out':10255,
'++attrib_l_bit_out':10254,
'++attrib_h_bit_out':10253,

'/attrib_buf7':10079,
'/attrib_buf6':10083,
'/attrib_buf5':10080,
'/attrib_buf4':10084,
'/attrib_buf3':10081,
'/attrib_buf2':10085,
'/attrib_buf1':10082,
'/attrib_buf0':10086,

// Attribute bit selection logic:
//
// v:
//
// 432 10 98765 43210
// yyy NN YYYYY XXXXX
// ||| || ||||| +++++-- coarse X scroll
// ||| || +++++-------- coarse Y scroll
// ||| ++-------------- nametable select
// +++----------------- fine Y scroll
//
// http://wiki.nesdev.com/w/index.php/PPU_attribute_tables
// ,---+---+---+---.
// |   |   |   |   |
// + D1-D0 + D3-D2 +
// |   |   |   |   |
// +---+---+---+---+
// |   |   |   |   |
// + D5-D4 + D7-D6 +
// |   |   |   |   |
// `---+---+---+---'
//
// D1-D0 selected if /v1 and /v6
// D3-D2 selected if  v1 and /v6
// D5-D4 selected if /v1 and  v6
// D7-D6 selected if  v1 and  v6

'+vramaddr_v1_out_2':10224,
'+/vramaddr_v1_out_2':2648,
'+vramaddr_v1_out_3':2637,
'+/vramaddr_v6_out':2660,

attrib_h_selected_bit:2671,
attrib_h_selected_bit_sampled:10124,
'/attrib_h_selected_bit_sampled':10077,
'+/attrib_h_selected_bit_sampled':10250,

attrib_l_selected_bit:2672,
attrib_l_selected_bit_sampled:10125,
'/attrib_l_selected_bit_sampled':10078,
'+/attrib_l_selected_bit_sampled':10251,

//
// vramaddr_v logic
//

load_vramaddr_v_hscroll_next:2312,
load_vramaddr_v_vscroll_next:2313,
'/load_vramaddr_v_vscroll_next':9731,
'+/load_vramaddr_v_vscroll_next':9711,

// Incrementation logic for vramaddr_v. Each group below can be incremented
// separately.

vramaddr_v14_carry_out:2095, // Unused
'/vramaddr_v13_carry_out':2096,
vramaddr_v13_carry_out:2097,
'/vramaddr_v12_carry_out':2098,
vramaddr_v12_carry_out:2099,
'/vramaddr_v12_carry_in':2100,
vramaddr_v12_carry_in:2101,

vramaddr_v11_carry_out_and_not_rendering:2091,
'/vramaddr_v11_carry_in':2103,
vramaddr_v11_carry_in:2104,

vramaddr_v10_carry_out_and_not_rendering:2089,
'/vramaddr_v10_carry_in':2105,
vramaddr_v10_carry_in:2093,

vramaddr_v9_carry_out:2107, // Unused
'/vramaddr_v8_carry_out':2108,
vramaddr_v8_carry_out:2109,
'/vramaddr_v7_carry_out':2110,
vramaddr_v7_carry_out:2111,
'/vramaddr_v6_carry_out':2112,
vramaddr_v6_carry_out:2113,
'/vramaddr_v5_carry_out':2114,
vramaddr_v5_carry_out:2115,
'/vramaddr_v5_carry_in':2116,

vramaddr_v4_carry_out:2118, // Unused
'/vramaddr_v3_carry_out':2119,
vramaddr_v3_carry_out:2120,
'/vramaddr_v2_carry_out':2125,
vramaddr_v2_carry_out:2121,
'/vramaddr_v1_carry_out':2122,
vramaddr_v1_carry_out:2126,
'/vramaddr_v0_carry_out':2123,
vramaddr_v0_carry_out:2127,
'/vramaddr_v0_carry_in':2128,
vramaddr_v0_carry_in:2129,

// Controls vramaddr_v10_carry_in
'/(vramaddr_v_vpos_overflow_and_not_rendering)_or_(vramaddr_v_hpos_eq_31_and_rendering)':9554,
// Controls vramaddr_v11_carry_in
'/(vramaddr_v10_carry_out_and_not_rendering)_or_(vramaddr_v_vpos_29_to_30_transition_and_rendering)':9476,

// Holds the new value the vramaddr_v bits will have after being incremented
// (if the carry in for the group is set)

vramaddr_v14_next:9738,
vramaddr_v13_next:9739,
vramaddr_v12_next:9740,
vramaddr_v11_next:9741,
vramaddr_v10_next:9742,
vramaddr_v9_next:9743,
vramaddr_v8_next:9744,
vramaddr_v7_next:9745,
vramaddr_v6_next:9746,
vramaddr_v5_next:9747,
vramaddr_v4_next:9748,
vramaddr_v3_next:9749,
vramaddr_v2_next:9750,
vramaddr_v1_next:9751,
vramaddr_v0_next:9752,

// vramaddr_v output signals (renamed from vramaddr_+vN)

'vramaddr_v14_out':2271,
'vramaddr_v13_out':2272,
'vramaddr_v12_out':2273,
'vramaddr_v11_out':2274,
'vramaddr_v10_out':2275,
'vramaddr_v9_out':2066,
'vramaddr_v8_out':2072,
'vramaddr_v7_out':2076,
'vramaddr_v6_out':2267,
'vramaddr_v5_out':2268,
'vramaddr_v4_out':1538,
'vramaddr_v3_out':1574,
'vramaddr_v2_out':1573,
'vramaddr_v1_out':1565,
'vramaddr_v0_out':1558,

// Controls vramddr_v hscroll updating
'/reading_or_writing_2007_or_(++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_7_and_rendering)':9661,

'+++hpos_eq_255_and_rendering':9473,
'+++/hpos_eq_255_and_rendering':9403,
'++++/hpos_eq_255_and_rendering':9463,
'++++hpos_eq_255_and_rendering':2049,

delayed_write_2006_low:2022, // TODO: Precise delay

'/(++++hpos_eq_255_and_rendering)_or_delayed_write_2006_low':9454,

'/reading_or_writing_2007_or_hpos_eq_255_and_rendering':9660,

'++hpos_eq_279_to_303_and_rendering_enabled':8865,
'++/hpos_eq_279_to_303_and_rendering_enabled':8784,
'++hpos_eq_279_to_303_and_rendering_enabled_2':8805,

'/(++hpos_eq_279_to_303_and_rendering_enabled_and_vpos_eq_261)_or_delayed_write_2006_low':8945,

//
// Address and sprite logic above vramaddr_v
//

'rendering_and_+hpos2':1963,
'not_rendering_and_/vramaddr_v_13_out':2074,
'rendering_or_vramaddr_v_13_out':2042,
'/(rendering_and_((+hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3)_or_+hpos2))':2047,
'rendering_and_((+hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3)_or_+hpos2)':9220,
'/((rendering_and_((+hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3)_or_+hpos2))_or_write_2007_ended)':2045,
'/_ab13_2':9339,
'+/_ab13_2':9136,
_ab13:9221,
vramaddr_v12_and_not_rendering:2065,

// 1162 (+hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3_and_rendering)
// performs the attribute byte address calculation:
// vramaddr_v:        yyy NNAB CDEG HIJK
// resulting address:  10 NN11 11AB CGHI

// Address signal generation
ab12_out:9215,
ab11_out:9216,
ab10_out:9217,
ab9_out:9205,
ab8_out:9206,
ab7_out:9207,
ab6_out:9208,
ab5_out:9209,
ab4_out:9210,
ab3_out:9211,
ab2_out:9212,
ab1_out:9213,
ab0_out:9214,

// spr_d3-d0
'++vpos_minus_spr_d3':8751,
'++vpos_minus_spr_d2':8752,
'++vpos_minus_spr_d1':8753,
'++vpos_minus_spr_d0':8754,
'++/vpos_minus_spr_d3':8779,
'++/vpos_minus_spr_d2':8780,
'++/vpos_minus_spr_d1':8781,
'++/vpos_minus_spr_d0':8782,
// TODO: More specific names
'++/vpos_minus_spr_d3_buf':8747,
'++/vpos_minus_spr_d2_buf':8748,
'++/vpos_minus_spr_d1_buf':8749,
'++/vpos_minus_spr_d0_buf':8750,
'++vpos_minus_spr_d3_buf':8729,
'++vpos_minus_spr_d2_buf':8730,
'++vpos_minus_spr_d1_buf':8731,
'++vpos_minus_spr_d0_buf':8732,
'++vpos_minus_spr_d3_buf_after_ev_y_flip':8733,
'++vpos_minus_spr_d2_buf_after_ev_y_flip':8736,
'++vpos_minus_spr_d1_buf_after_ev_y_flip':8737,
'++vpos_minus_spr_d0_buf_after_ev_y_flip':8738,
'++/vpos_minus_spr_d3_buf_after_ev_y_flip':8965,
'++/vpos_minus_spr_d2_buf_after_ev_y_flip':8802,
'++/vpos_minus_spr_d1_buf_after_ev_y_flip':8803,
'++/vpos_minus_spr_d0_buf_after_ev_y_flip':8804,
'++/vpos_minus_spr_d3_buf_after_ev_y_flip_if_8x16_else_/spr_d0_buf':10711,
'(++/vpos_minus_spr_d3_buf_after_ev_y_flip_if_8x16_else_/spr_d0_buf)_if_fetching_sprites_else_+/_db0_buf':10726,
'++/vpos_minus_spr_d2_buf_after_ev_y_flip_if_fetching_sprites_else_vramaddr_/v14':10715,
'++/vpos_minus_spr_d1_buf_after_ev_y_flip_if_fetching_sprites_else_vramaddr_/v13':10716,
'++/vpos_minus_spr_d0_buf_after_ev_y_flip_if_fetching_sprites_else_vramaddr_/v12':10717,
'(+++/vpos_minus_spr_d3_buf_after_ev_y_flip_if_8x16_else_/spr_d0_buf)_if_fetching_sprites_else_++/_db0_buf':9043,
'+++/vpos_minus_spr_d2_buf_after_ev_y_flip_if_fetching_sprites_else_+vramaddr_/v14':9044,
'+++/vpos_minus_spr_d1_buf_after_ev_y_flip_if_fetching_sprites_else_+vramaddr_/v13':9045,
'+++/vpos_minus_spr_d0_buf_after_ev_y_flip_if_fetching_sprites_else_+vramaddr_/v12':9046,
'/((+++/vpos_minus_spr_d3_buf_after_ev_y_flip_if_8x16_else_/spr_d0_buf)_if_fetching_sprites_else_++/_db0_buf)':9114,
'/(+++/vpos_minus_spr_d2_buf_after_ev_y_flip_if_fetching_sprites_else_+vramaddr_/v14)':9116,
'/(+++/vpos_minus_spr_d1_buf_after_ev_y_flip_if_fetching_sprites_else_+vramaddr_/v13)':9117,
'/(+++/vpos_minus_spr_d0_buf_after_ev_y_flip_if_fetching_sprites_else_+vramaddr_/v12)':9118,

// spr_d7-d4

'/_db1':8769,
'/_db2':8767,
'/_db3':8765,
'/_db4':8763,
'/_db5':8761,
'/_db6':8759,
'/_db7':8757,

'+/_db1':8746,
'+/_db2':8745,
'+/_db3':8744,
'+/_db4':8743,
'+/_db5':8742,
'+/_db6':8741,
'+/_db7':8740,

'+_db1':8768,
'+_db2':8766,
'+_db3':8764,
'+_db4':8762,
'+_db5':8760,
'+_db6':8758,
'+_db7':8756,

'+_db1_buf':8883,
'+_db2_buf':8882,
'+_db3_buf':8881,
'+_db4_buf':8880,
'+_db5_buf':8879,
'+_db6_buf':8878,
'+_db7_buf':8877,

'+/_db1_buf':8798,
'+/_db2_buf':8796,
'+/_db3_buf':8794,
'+/_db4_buf':8792,
'+/_db5_buf':8790,
'+/_db6_buf':8788,
'+/_db7_buf':8786,

// spr_d8-1 left

'/_db0':8755,
'+/_db0':8739,
'+_db0_2':8770,
'+_db0_buf':8884,
'+/_db0_buf':8799,

'/spr_size_out_2':8801,
'/spr_size_out_3':8717,
spr_d0_buf:8885,
'/spr_d0_buf':8800,
spr_d0_buf_2:8876,
'/spr_d0_buf_2':8966,
spr_d7_buf:8886,
'/spr_d7_buf':8785,

'/spr_d0_buf_if_8x16_else_/spr_pat_out':8735,
'/(spr_d0_buf_if_8x16_else_/spr_pat_out)_if_fetching_sprites_else_/bkg_pat_out':10718,
'/spr_d7_buf_if_fetching_sprites_else_/_db7_buf':10719,
'/spr_d6_buf_if_fetching_sprites_else_/_db6_buf':10720,
'/spr_d5_buf_if_fetching_sprites_else_/_db5_buf':10721,
'/spr_d4_buf_if_fetching_sprites_else_/_db4_buf':10722,
'/spr_d3_buf_if_fetching_sprites_else_/_db3_buf':10723,
'/spr_d2_buf_if_fetching_sprites_else_/_db2_buf':10724,
'/spr_d1_buf_if_fetching_sprites_else_/_db1_buf':10725,
'+(/(spr_d0_buf_if_8x16_else_/spr_pat_out)_if_fetching_sprites_else_/bkg_pat_out)':9035,
'+(/spr_d7_buf_if_fetching_sprites_else_/_db7_buf)':9036,
'+(/spr_d6_buf_if_fetching_sprites_else_/_db6_buf)':9037,
'+(/spr_d5_buf_if_fetching_sprites_else_/_db5_buf)':9038,
'+(/spr_d4_buf_if_fetching_sprites_else_/_db4_buf)':9039,
'+(/spr_d3_buf_if_fetching_sprites_else_/_db3_buf)':9040,
'+(/spr_d2_buf_if_fetching_sprites_else_/_db2_buf)':9041,
'+(/spr_d1_buf_if_fetching_sprites_else_/_db1_buf)':9042,
'+/(/(spr_d0_buf_if_8x16_else_/spr_pat_out)_if_fetching_sprites_else_/bkg_pat_out)':9106,
'+/(/spr_d7_buf_if_fetching_sprites_else_/_db7_buf)':9107,
'+/(/spr_d6_buf_if_fetching_sprites_else_/_db6_buf)':9108,
'+/(/spr_d5_buf_if_fetching_sprites_else_/_db5_buf)':9109,
'+/(/spr_d4_buf_if_fetching_sprites_else_/_db4_buf)':9110,
'+/(/spr_d3_buf_if_fetching_sprites_else_/_db3_buf)':9111,
'+/(/spr_d2_buf_if_fetching_sprites_else_/_db2_buf)':9112,
'+/(/spr_d1_buf_if_fetching_sprites_else_/_db1_buf)':9113,

'++/hpos0_4':8806,
'++hpos_mod_8_eq_1_and_rendering_2':8807,
'++/hpos_mod_8_eq_1_and_rendering_2':8991,
'+++/hpos_mod_8_eq_1_and_rendering_2':8783,
'+++/hpos_mod_8_eq_1_and_rendering_and_pclk0_2':1870,
'++/hpos_eq_256_to_319_and_rendering_4':1910,

spr_loadflag_and_pclk0:8728,
y_flip_flag_in:1677,
y_flip_flag:1673,
'/y_flip_flag':1678,

//
// $2007 and read/write VRAM logic
//

rendering_4:10603,
'++hpos0_3':10593,
'/read_2007_output_vrambuf':10578,
read_2007_output_vrambuf_2:2327,
'+rendering_and_/hpos0_and_pclk0':10576,
'+not_rendering':10553,
'+/not_rendering':10554,
'ab_in_palette_range_and_not_rendering':10551, // ab_13-8 = 1
'ab_in_palette_range_and_not_rendering_2':1266,
'/read_2007_trigger':10601,

read_2007_reg:10580,
'/read_2007_reg':10585,
// There's probably more going on here
not_reading_2007_and_read_2007_reg:2825,
'+not_reading_2007_and_read_2007_reg':10608,
'++not_reading_2007_and_read_2007_reg':10600,
'+/not_reading_2007_and_read_2007_reg':10605,
'++/not_reading_2007_and_read_2007_reg':10606,
'++not_reading_2007_and_read_2007_reg_2':10586,
'+++not_reading_2007_and_read_2007_reg':10572,
'+++/not_reading_2007_and_read_2007_reg':2792,
'++++/not_reading_2007_and_read_2007_reg':10581,
'++++not_reading_2007_and_read_2007_reg':2811,
'+++++not_reading_2007_and_read_2007_reg':10574,
'+++++/not_reading_2007_and_read_2007_reg':10566,

// Delayed signals that go high after reading 2007, for ~one tick (TODO:
// further investigation of ranges). _1 goes high first, then _2.
// They never overlap.
read_2007_ended_1:10568,
read_2007_ended_2:2325,

write_2007_reg:10583,
'/write_2007_reg':10590,
// There's probably more going on here
not_writing_2007_and_write_2007_reg:2824,
'+not_writing_2007_and_write_2007_reg':10607,
'++not_writing_2007_and_write_2007_reg':10599,
'+/not_writing_2007_and_write_2007_reg':10604,
'++/not_writing_2007_and_write_2007_reg':10602,
'++not_writing_2007_and_write_2007_reg_2':10575,
'+++not_writing_2007_and_write_2007_reg':10579,
'+++/not_writing_2007_and_write_2007_reg':2791,
'++++/not_writing_2007_and_write_2007_reg':10573,
'++++not_writing_2007_and_write_2007_reg':2810,
'+++++not_writing_2007_and_write_2007_reg':10571,

// Delayed signals that go high after reading 2007, for ~one tick (TODO:
// further investigation of ranges). _1 goes high first, then _2.
// They never overlap.
write_2007_ended_1:2782,
write_2007_ended_2:1275,
'+write_2007_ended_2':2778,

'/reading_or_writing_2007':2749,
reading_or_writing_2007:2266,

'/write_2007_ended_2':10587,
'/write_2007_ended_2_':10592,

'/read_2007_ended_1_or_write_2007_ended_1_or_+(rendering_and_/hpos0_and_pclk0)':2793,

'/read_2007_ended_2_or_++(rendering_and_/hpos0)':10577,

'/read_2007_ended_2':2326,

'/inbuf7':9758,
'/inbuf6':9795,
'/inbuf5':9853,
'/inbuf4':9902,
'/inbuf3':9978,
'/inbuf2':10206,
'/inbuf1':10306,
'/inbuf0':10417,

db_buf_read_2007_ended7:9756,
db_buf_read_2007_ended6:9785,
db_buf_read_2007_ended5:9843,
db_buf_read_2007_ended4:9892,
db_buf_read_2007_ended3:9968,
db_buf_read_2007_ended2:10176,
db_buf_read_2007_ended1:10292,
db_buf_read_2007_ended0:10375,

//
// OAM column decoder
//

spr_addr2_out:50,
spr_addr1_out:54,
spr_addr0_out:62,

// spr_ptr5-0 directly selects the column

//
// OAM access logic
//

// Common logic
rendering_and_pclk0:237,
'++/hpos0_5':280,
// Goes high a while after write_2004_value (TODO: exact delay). Also shortened.
delayed_write_2004_value:157,
// This condition is used by the rendering logic to enable writes to the OAM
// (to write to secondary OAM). Writes can also be enabled separately by
// writing $2004.
'in_visible_frame_and_rendering_and_/spr_ptr_overflow_and_/(end_of_oam_or_sec_oam_overflow)_and_++hpos0_and_pclk1':261,
oam_write_disable:334, // !261 && !delayed_write_2004_value

// Logic next to spr_d7. It's probably the same for all bits.
'either_(_io_db7_and_not_rendering)_or_+spr_d7':3628,
'/either_(_io_db7_and_not_rendering)_or_+spr_d7':476,
set_spr_d7_in_oam:3736,
clear_spr_d7_in_oam:3699,

'+spr_d7_3':3377,
'+/spr_d7_3':3375,
'read_2004_enable_and_+spr_d7':3428,
'read_2004_enable_and_+/spr_d7':3506,
'/spr_d7':3431,
'/spr_d7_reg':3364, // Forms a reg together with spr_d7
'/spr_d7_reg_in':3508,

spr_d7_int:273,
'/spr_d7_int':253,
spr_d7_int_reg:426,
'/spr_d7_int_reg':3591,

//
// Palette logic
//

pal_d0_int:1287,
pal_d1_int:1289,
pal_d2_int:1291,
pal_d3_int:1293,
pal_d4_int:1295,
pal_d5_int:1297,

    
'/pal_d0_int':1377,
'/pal_d1_int':1372,
'/pal_d2_int':1373,
'/pal_d3_int':1374,
'/pal_d4_int':1375,
'/pal_d5_int':1376,

pal_d0_int_reg:6910,
pal_d1_int_reg:6911,
pal_d2_int_reg:6912,
pal_d3_int_reg:6913,
pal_d4_int_reg:6914,
pal_d5_int_reg:6915,

'/pal_d0_int_reg':6956,
'/pal_d1_int_reg':6957,
'/pal_d2_int_reg':6958,
'/pal_d3_int_reg':6959,
'/pal_d4_int_reg':6960,
'/pal_d5_int_reg':6961,

set_pal_d0:6731,
set_pal_d1:6732,
set_pal_d2:6733,
set_pal_d3:6734,
set_pal_d4:6735,
set_pal_d5:6736,


'/set_pal_d0':1238,
'/set_pal_d1':1241,
'/set_pal_d2':1243,
'/set_pal_d3':1245,
'/set_pal_d4':1248,
'/set_pal_d5':1251,

    
clear_pal_d0:6651,

clear_pal_d1:6652,
clear_pal_d2:6653,
clear_pal_d3:6654,
clear_pal_d4:6655,
clear_pal_d5:6656,

'/pal_d0_out':7107,
'/pal_d1_out':7108,
'/pal_d2_out':7109,
'/pal_d3_out':7110,
'/pal_d4_out':7111,
'/pal_d5_out':7112,
pal_d0_out:1215,

'+pal_d0_out':7225,
'+pal_d0_out_2':1282,
'+/pal_d0_out_2':6916,
'++/pal_d0_out_2':6851,
'++pal_d0_out_2':6810,
'read_2007_output_palette_and_++/pal_d0_out':6689,
'read_2007_output_palette_and_++pal_d0_out':6570,
'+/pal_d0_out':811, // Ouput

pal_d1_out:6565,
pal_d2_out:6566,
pal_d3_out:6567,
pal_d4_out:6564,
pal_d5_out:6568,

'+pal_d1_out':6423,
'+pal_d2_out':6457,
'+pal_d3_out':6458,
'+pal_d4_out':6419,
'+pal_d5_out':6491,


'pal_d5_preout':10692,
'pal_d4_preout':10685,
'pal_d3_preout':10684,
'pal_d2_preout':10683,
'pal_d1_preout':10688,
'pal_d0_preout':10681,

pclk0_5:6495,

'+pal_d5_out_2':7230,
'+pal_d4_out_2':7229,
'+pal_d3_out_2':7228,
'+pal_d2_out_2':7227,
'+pal_d1_out_2':7226,



'+/pal_d1_out':872, // Output
'+/pal_d2_out':810, // Output
'+/pal_d3_out':812, // Output
'+/pal_d4_out':1203,
'++/pal_d4_out':6417,
'++pal_d4_out':6493,
'+++pal_d4_out':1217,
'+++/pal_d4_out':1216,
'+++pal_d4_out_2':6335,
'+/pal_d5_out':6497,
'++/pal_d5_out':6418,
'++pal_d5_out':1249,
'+++pal_d5_out':1258,
'+++/pal_d5_out':1157,
'+++pal_d5_out_2':6266,

'++/pal_d0_out':573,
'++/pal_d1_out':752,
'++/pal_d2_out':644,
'++/pal_d3_out':559,

'++pal_d0_out':527,
'++pal_d1_out':548,
'++pal_d2_out':526,
'++pal_d3_out':3909,

'+++pal_d0_out':421,
'+++pal_d1_out':459,
'+++pal_d2_out':475,
'+++pal_d3_out':490,

'+++/pal_d0_out':3585,
'+++/pal_d1_out':473,
'+++/pal_d2_out':482,
'+++/pal_d3_out':504,

'+++pal_d0_out_2':3584,
'+++pal_d1_out_2':3627,
'+++pal_d2_out_2':3666,
'+++pal_d3_out_2':3752,

'+++pal_d3-1_eq_7':542,
'in_draw_range_and_++/pal_d3-1_eq_7':5423,
'+in_draw_range_and_++/pal_d3-1_eq_7':5298,
'/(+in_draw_range_and_++/pal_d3-1_eq_7)':918,
'/(in_range_2_or_3_or_in_draw_range_and_++/pal_d3-1_eq_7)':921,
'in_range_2_or_3_or_in_draw_range_and_++/pal_d3-1_eq_7':912,
'+in_range_2_or_3_or_in_draw_range_and_++/pal_d3-1_eq_7':892,

// Chroma Johnson counter

chroma_ring5:193,
chroma_ring4:194,
chroma_ring3:195,
chroma_ring2:196,
chroma_ring1:197,
chroma_ring0:198,

// Value saved during while master clock is low. Copied into next bit while
// master clock is high.
chroma_ring5_save:3029,
chroma_ring4_save:3030,
chroma_ring3_save:3031,
chroma_ring2_save:3032,
chroma_ring1_save:3033,
chroma_ring0_save:3034,

// Inverses delayed by half a master clock
'/chroma_ring_delayed5':226,
'/chroma_ring_delayed4':224,
'/chroma_ring_delayed3':227,
'/chroma_ring_delayed2':228,
'/chroma_ring_delayed1':229,
'/chroma_ring_delayed0':230,

// Chroma decoder

// These are also sunk by the Johnson counter above them
'pal_d3-0_eq_C':316,
'pal_d3-0_eq_5':322,
'pal_d3-0_eq_A':317,
'pal_d3-0_eq_3':323,
'pal_d3-0_eq_0':405, // Unused
'pal_d3-0_eq_8':318,
'pal_d3-0_eq_1':324,
'pal_d3-0_eq_6':325,
'pal_d3-0_eq_B':326,
'pal_d3-0_eq_4':319,
'pal_d3-0_eq_9':320,
'pal_d3-0_eq_2':331,
'pal_d3-0_eq_7':321,

chroma_waveform_out:381,

// Outputs driving luma

'pal_d5-4_eq_0_and_+in_draw_range_and_++/pal_d3-1_eq_0':1141,
'pal_d5-4_eq_3_and_+in_draw_range_and_++/pal_d3-1_eq_0':1142,
'pal_d5-4_eq_2_and_+in_draw_range_and_++/pal_d3-1_eq_0':1143,
'pal_d5-4_eq_1_and_+in_draw_range_and_++/pal_d3-1_eq_0':1140,

'/(pal_d5-4_eq_0_and_+in_draw_range_and_++/pal_d3-1_eq_0)':952,
'/(pal_d5-4_eq_3_and_+in_draw_range_and_++/pal_d3-1_eq_0)':991,
'/(pal_d5-4_eq_2_and_+in_draw_range_and_++/pal_d3-1_eq_0)':1085,
'/(pal_d5-4_eq_1_and_+in_draw_range_and_++/pal_d3-1_eq_0)':1042,

//
// Sprite-loading logic
//

spr_loadFlag_and_pclk0:9497,

'/(spr_loadFlag_and_pclk0)':9496,
x_flip_flag_in_2:9487,
'/x_flip_flag_in':1860,
x_flip_flag_in:1842,

// After eventual x flip
spr_d7_in:8874,
spr_d6_in:8962,
spr_d5_in:9032,
spr_d4_in:9130,
spr_d3_in:9204,
spr_d2_in:9315,
spr_d1_in:9400,
spr_d0_in:9464,

'/(spr_d7_in_and_+sprite_in_range_reg)':8875,
'/(spr_d6_in_and_+sprite_in_range_reg)':8963,
'/(spr_d5_in_and_+sprite_in_range_reg)':9033,
'/(spr_d4_in_and_+sprite_in_range_reg)':9131,
'/(spr_d3_in_and_+sprite_in_range_reg)':9219,
'/(spr_d2_in_and_+sprite_in_range_reg)':9316,
'/(spr_d1_in_and_+sprite_in_range_reg)':9401,
'/(spr_d0_in_and_+sprite_in_range_reg)':9474,

'++/hpos5_2':1805,
'++/hpos4_2':1802,
'++/hpos3_2':1801,

'++hpos_mod_64_eq_0-7':2228,
'++hpos_mod_64_eq_8-15':2227,
'++hpos_mod_64_eq_16-23':2225,
'++hpos_mod_64_eq_24-31':2222,
'++hpos_mod_64_eq_32-39':2231,
'++hpos_mod_64_eq_40-47':2219,
'++hpos_mod_64_eq_48-55':2216,
'++hpos_mod_64_eq_56-63':2213,

'+++hpos_mod_64_eq_0-7':9707,
'+++hpos_mod_64_eq_8-15':9706,
'+++hpos_mod_64_eq_16-23':9705,
'+++hpos_mod_64_eq_24-31':9704,
'+++hpos_mod_64_eq_32-39':9709,
'+++hpos_mod_64_eq_40-47':9708,
'+++hpos_mod_64_eq_48-55':9703,
'+++hpos_mod_64_eq_56-63':9702,

'+++/hpos_mod_64_eq_0-7':2189,
'+++/hpos_mod_64_eq_8-15':2188,
'+++/hpos_mod_64_eq_16-23':2190,
'+++/hpos_mod_64_eq_24-31':2187,
'+++/hpos_mod_64_eq_32-39':2186,
'+++/hpos_mod_64_eq_40-47':2183,
'+++/hpos_mod_64_eq_48-55':2185,
'+++/hpos_mod_64_eq_56-63':2184,

'spr_loadH_and_+++hpos_mod_64_eq_0-7_and_pclk0':1840,
'spr_loadH_and_+++hpos_mod_64_eq_8-15_and_pclk0':1857,
'spr_loadH_and_+++hpos_mod_64_eq_16-23_and_pclk0':1835,
'spr_loadH_and_+++hpos_mod_64_eq_24-31_and_pclk0':1853,
'spr_loadH_and_+++hpos_mod_64_eq_32-39_and_pclk0':1830,
'spr_loadH_and_+++hpos_mod_64_eq_40-47_and_pclk0':1849,
'spr_loadH_and_+++hpos_mod_64_eq_48-55_and_pclk0':1846,
'spr_loadH_and_+++hpos_mod_64_eq_56-63_and_pclk0':1822,

'spr_loadL_and_+++hpos_mod_64_eq_0-7_and_pclk0':1839,
'spr_loadL_and_+++hpos_mod_64_eq_8-15_and_pclk0':1858,
'spr_loadL_and_+++hpos_mod_64_eq_16-23_and_pclk0':1834,
'spr_loadL_and_+++hpos_mod_64_eq_24-31_and_pclk0':1831,
'spr_loadL_and_+++hpos_mod_64_eq_32-39_and_pclk0':1850,
'spr_loadL_and_+++hpos_mod_64_eq_40-47_and_pclk0':1827,
'spr_loadL_and_+++hpos_mod_64_eq_48-55_and_pclk0':1826,
'spr_loadL_and_+++hpos_mod_64_eq_56-63_and_pclk0':1823,

'spr_loadX_and_+++hpos_mod_64_eq_0-7_and_pclk0':2202,
'spr_loadX_and_+++hpos_mod_64_eq_8-15_and_pclk0':2201,
'spr_loadX_and_+++hpos_mod_64_eq_16-23_and_pclk0':2207,
'spr_loadX_and_+++hpos_mod_64_eq_24-31_and_pclk0':2206,
'spr_loadX_and_+++hpos_mod_64_eq_32-39_and_pclk0':2205,
'spr_loadX_and_+++hpos_mod_64_eq_40-47_and_pclk0':2204,
'spr_loadX_and_+++hpos_mod_64_eq_48-55_and_pclk0':2200,
'spr_loadX_and_+++hpos_mod_64_eq_56-63_and_pclk0':2203,

'spr_loadFlag_and_+++hpos_mod_64_eq_0-7_and_pclk0':2174,
'spr_loadFlag_and_+++hpos_mod_64_eq_8-15_and_pclk0':2173,
'spr_loadFlag_and_+++hpos_mod_64_eq_16-23_and_pclk0':2172,
'spr_loadFlag_and_+++hpos_mod_64_eq_24-31_and_pclk0':2171,
'spr_loadFlag_and_+++hpos_mod_64_eq_32-39_and_pclk0':2170,
'spr_loadFlag_and_+++hpos_mod_64_eq_40-47_and_pclk0':2169,
'spr_loadFlag_and_+++hpos_mod_64_eq_48-55_and_pclk0':2167,
'spr_loadFlag_and_+++hpos_mod_64_eq_56-63_and_pclk0':2168,

//
// Sprite hpos counters
//

'/spr0_p7':2486,
'/spr0_p6':2520,
'/spr0_p5':2550,
'/spr0_p4':2572,
'/spr0_p3':2617,
'/spr0_p2':2658,
'/spr0_p1':2687,
'/spr0_p0':2720,

spr0_p7_out:9880,
spr0_p6_out:9956,
spr0_p5_out:10027,
spr0_p4_out:2473,
spr0_p3_out:2454,
spr0_p2_out:2443,
spr0_p1_out:2427,
spr0_p0_out:2408,

spr0_p7_borrow:2398,
spr0_p6_borrow:2501,
spr0_p5_borrow:2532,
spr0_p5_borrow_in:2412,
spr0_p4_borrow:2576, // Unused
spr0_p3_borrow:2590,
spr0_p2_borrow:2629,
spr0_p1_borrow:2669,
spr0_p0_borrow:2697,

'/spr0_p6_borrow':9910,
'/spr0_p5_borrow':9986,
'/spr0_p4_borrow':10060,
'/spr0_p3_borrow':10123,
'/spr0_p2_borrow':10214,
'/spr0_p1_borrow':10314,
'/spr0_p0_borrow':10425,

spr0_p7_next:9921,
spr0_p6_next:9995,
spr0_p5_next:10068,
spr0_p4_next:10133,
spr0_p3_next:10223,
spr0_p2_next:10323,
spr0_p1_next:10436,
spr0_p0_next:10542,

spr0_load_next:2434,

'+++++hpos_eq_339_and_rendering_and_/spr0_p7_borrow_and_pclk0':2366,

// Reg
spr0_active:9804,
'/spr0_active':2383,
'spr0_active_and_++in_visible_frame_and_rendering':9781,
'+spr0_active_and_++in_visible_frame_and_rendering':9771,
'/(+spr0_active_and_++in_visible_frame_and_rendering)':1603,
'+spr0_active_and_++in_visible_frame_and_rendering_and_pclk1':1838,

//
// Sprite priority
//

use_sprite_0:1612,
use_sprite_1:1606,
use_sprite_2:1604,
use_sprite_3:1599,
use_sprite_4:1597,
use_sprite_5:1589,
use_sprite_6:1585,
use_sprite_7:1581,

//
// Position counter logic
//

'/move_to_next_line':790,
'+/move_to_next_line':4625,
'+move_to_next_line':171,
'+/move_to_next_line_2':4508,
'+clear_vpos_next':172,

'+vpos_eq_261':4471,
'+/vpos_eq_261':4509,

'/hpos_eq_340':2909,

// Vertical position counter

'/vpos8':4324,
'/vpos7':4154,
'/vpos6':3991,
'/vpos5':3824,
'/vpos4':126,
'/vpos3':168,
'/vpos2':125,
'/vpos1':155,
'/vpos0':153,

vpos8_carry_out:639, // Unused
'/vpos7_carry_out':4230,
vpos7_carry_out:598,
'/vpos6_carry_out':4069,
vpos6_carry_out:553,
'/vpos5_carry_out':3908,
vpos5_carry_out:506,
'/vpos5_carry_in':3751,
vpos5_carry_in:107,
vpos4_carry_out:462, // Unused
'/vpos3_carry_out':3589,
vpos3_carry_out:391,
'/vpos2_carry_out':3424,
vpos2_carry_out:333,
'/vpos1_carry_out':3245,
vpos1_carry_out:278,
'/vpos0_carry_out':3070,
vpos0_carry_out:220,

vpos8_next:4228,
vpos7_next:4066,
vpos6_next:3906,
vpos5_next:3748,
vpos4_next:3587,
vpos3_next:3414,
vpos2_next:3243,
vpos1_next:3068,
vpos0_next:2939,

// Horizontal position counter

'/hpos8':4323,
'/hpos7':4153,
'/hpos6':3990,
'/hpos5':3823,
'/hpos4':149,
'/hpos3':123,
'/hpos2':150,
'/hpos1':115,
'/hpos0':152,

hpos8_carry_out:637, // Unused
'/hpos7_carry_out':4229,
hpos7_carry_out:597,
'/hpos6_carry_out':4068,
hpos6_carry_out:552,
'/hpos5_carry_out':3907,
hpos5_carry_out:505,
'/hpos_5_carry_in':3750,
hpos5_carry_in:111,
hpos4_carry_out:461, // Unused
'/hpos3_carry_out':3588,
hpos3_carry_out:390,
'/hpos2_carry_out':3415,
hpos2_carry_out:335,
'/hpos1_carry_out':3244,
hpos1_carry_out:277,
'/hpos0_carry_out':3069,
hpos0_carry_out:219,
'/hpos0_carry_in':2941,

hpos8_next:4227,
hpos7_next:4065,
hpos6_next:3905,
hpos5_next:3747,
hpos4_next:3586,
hpos3_next:3413,
hpos2_next:3242,
hpos1_next:3067,
hpos0_next:2938,

//
// Address decoder and $2005/$2006 h/v toggle
//

'/_io_ab0':3205,
'/_io_ab2':3206,
'/_io_ab1':3207,
'/_io_rw':3208,

'_io_ab_2-0_eq_6_and_/io_rw_and_/hvtog':306,
'_io_ab_2-0_eq_6_and_/io_rw_and_hvtog':327,
'_io_ab_2-0_eq_5_and_/io_rw_and_/hvtog':344,
'_io_ab_2-0_eq_5_and_/io_rw_and_hvtog':365,
'_io_ab_2-0_eq_7_and_io_rw':378,
'_io_ab_2-0_eq_7_and_/io_rw':396,
'_io_ab_2-0_eq_4_and_/io_rw':419,
'_io_ab_2-0_eq_3_and_/io_rw':433,
'_io_ab_2-0_eq_2_and_io_rw':467,
'_io_ab_2-0_eq_1_and_/io_rw':478,
'_io_ab_2-0_eq_0_and_/io_rw':488,
'_io_ab_2-0_eq_4_and_io_rw':507,

'/write_2005_or_2006':250,
toggle_hvtog:214,
'/toggle_hvtog':254,
'/hvtog':2996,
// Writing $2005 or $2006 inverts hvtog into hvtog_inv, and then copies
// hvtog_inv into hvtog.
hvtog_inv:2943,
'/hvtog_inv':240,

//
// ab0/db0 logic (ab7-0 are multiplexed as the VRAM data bus)
//

// Input (data)
'/db0_int':9047,
db0_int:1958,
'/db0_int_2':9135,

// Output (address)
'_ab0_and_/_rd':1940,
'low_if_rd_else_/ab0':9252,
'low_if_rd_else_/ab0_2':9089,
low_if_rd_else_ab0:2016,

//
// Misc.
//

'/rendering_disabled':5900,
pclk0_2:6084,
pclk0_4:8920,
pclk1_2:1064,
pclk1_3:2610,
'++hpos0_2':589,
'/read_2002_outupt_spr0_hit':1253,

// Internal master clock for video generation
clk0_int:218,
'/clk0_int':245,

// Set by reset, cleared at line 261
after_reset_reg:1716,
'/after_reset_reg':1707,

vramaddr_v5_carry_in:2117,
'/vramaddr_v5_carry_in_2':9736,

// Corrections

'+vpos_eq_240-260':5816,
'+/vpos_eq_240-260':5793,
'+/vpos_eq_240-260_2':5829,

'/_ab13':2017,
'/_ab12':2008,
'/_ab11':1992,
'/_ab10':1988,
'/_ab9':1985,
'/_ab8':1966,
'/_ab7':2043,
'/_ab6':2021,
'/_ab5':2019,
'/_ab4':2014,
'/_ab3':1994,
'/_ab2':1662,
'/_ab1':1626,
'/_ab0':1616,
'/_ale':1593,

// Renamed from set_spr_overflow. Goes high when the secondary OAM is full and
// an in-range sprite is detected.
sec_oam_overflow:3910,

// The rd and wr pins are active low and should perhaps be called /rd and /wr,
// but renaming them might mess with I/O glue logic

}
