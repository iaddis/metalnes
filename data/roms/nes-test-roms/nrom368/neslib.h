//set bg and spr palettes, data is 32 bytes array

void __fastcall__ pal_all(const char *data);

//set bg palette only, data is 16 bytes array

void __fastcall__ pal_bg(const char *data);

//set spr palette only, data is 16 bytes array

void __fastcall__ pal_spr(const char *data);

//set a palette entry, index is 0..31

void __fastcall__ pal_col(unsigned char index,unsigned char color);

//reset palette to $0f

void __fastcall__ pal_clear(void);

//set virtual bright, 0 is black, 4 is normal, 8 is white

void __fastcall__ pal_bright(unsigned char bright);


//turn off rendering and nmi

void __fastcall__ ppu_off(void);

//turn on bg, spr, and nmi

void __fastcall__ ppu_on_all(void);

//turn on bg only and nmi

void __fastcall__ ppu_on_bg(void);

//turn on spr only and nmi

void __fastcall__ ppu_on_spr(void);

//set PPU_MASK directly

;void __fastcall__ ppu_mask(unsigned char mask);



//clear OAM buffer, all the sprites are hidden

void __fastcall__ oam_clear(void);

//set sprite in OAM buffer, chrnum is tile, attr is attribute, sprid is offset in OAM in bytes
//returns sprid+4, which is offset for next sprite

unsigned char __fastcall__ oam_spr(unsigned char x,unsigned char y,unsigned char chrnum,unsigned char attr,unsigned char sprid);

//set metasprite in OAM buffer
//meta sprite is a const unsigned char array, it contains four bytes per sprite
//in order x offset, y offset, tile, attribute
//x=128 is end of a meta sprite
//returns sprid+(number of sprites*4), which is offset for next sprite

unsigned char __fastcall__ oam_meta_spr(unsigned char x,unsigned char y,unsigned char sprid,const unsigned char *data);

//hide all the sprites starting from given offset

void __fastcall__ oam_hide_rest(unsigned char sprid);



//wait NMI and sync to 50hz (with frameskip for NTSC)

void __fastcall__ ppu_waitnmi(void);



//play a music in FamiTone format

void __fastcall__ music_play(const unsigned char *data);

//stop music

void __fastcall__ music_stop(void);

//pause and unpause music

void __fastcall__ music_pause(unsigned char pause);

//play FamiTone sound effect on channel 0..3

void __fastcall__ sfx_play(unsigned char sound,unsigned char channel);



//poll controller and return flags like PAD_LEFT etc, input is pad number (0 or 1)

unsigned char __fastcall__ pad_poll(unsigned char pad);

//poll controller in trigger mode, a flag is set only on button down, not hold
//if you need to poll the pad in both normal and trigger mode, poll it in the
//trigger mode for first, then use pad_state

unsigned char __fastcall__ pad_trigger(unsigned char pad);

//get previous pad state without polling ports

unsigned char __fastcall__ pad_state(unsigned char pad);


//set scroll, including top bits

void __fastcall__ scroll(unsigned int x,unsigned int y);



//select current chr bank for sprites, 0..1

void __fastcall__ bank_spr(unsigned char n);

//select current chr bank for background, 0..1

void __fastcall__ bank_bg(unsigned char n);



//returns random number 0..255 or 0..65535

unsigned char __fastcall__ rand8(void);
unsigned char __fastcall__ rand16(void);

//set random seed

void __fastcall__ set_rand(unsigned int seed);



//set a pointer to update buffer, contents of the buffer is transferred to vram every frame
//buffer structure is MSB, LSB, byte to write, len is number of entries (not bytes)
//could be set during rendering, but only takes effect on a new frame
//number of transferred bytes is limited by vblank time

void __fastcall__ set_vram_update(unsigned char len,unsigned char *buf);

//set vram pointer to write operations if you need to write some data to vram
//works only when rendering is turned off

void __fastcall__ vram_adr(unsigned int adr);

//put a byte at current vram address, works only when rendering is turned off

void __fastcall__ vram_put(unsigned char n);

//fill a block with a byte at current vram address, works only when rendering is turned off

void __fastcall__ vram_fill(unsigned char n,unsigned int len);

//set vram autoincrement, 0 for +1 and not 0 for +32

void __fastcall__ vram_inc(unsigned char n);

//read a block from vram, works only when rendering is turned off

void __fastcall__ vram_read(unsigned char *dst,unsigned int adr,unsigned int size);

//write a block to vram, works only when rendering is turned off

void __fastcall__ vram_write(unsigned char *src,unsigned int adr,unsigned int size);


//unpack a nametable into vram

void __fastcall__ unrle_vram(const unsigned char *data,unsigned int vram);



//like a normal memcpy, but does not return anything

void __fastcall__ memcpy(void *dst,void *src,unsigned int len);


#define PAD_A			0x01
#define PAD_B			0x02
#define PAD_SELECT		0x04
#define PAD_START		0x08
#define PAD_UP			0x10
#define PAD_DOWN		0x20
#define PAD_LEFT		0x40
#define PAD_RIGHT		0x80

#define OAM_FLIP_V		0x80
#define OAM_FLIP_H		0x40
#define OAM_BEHIND		0x20

#define MAX(x1,x2)		(x1<x2?x2:x1)
#define MIN(x1,x2)		(x1<x2?x1:x2)

#define MASK_SPR		0x10
#define MASK_BG			0x08
#define MASK_EDGE_SPR	0x04
#define MASK_EDGE_BG	0x02

#define NULL			0
#define TRUE			1
#define FALSE			0