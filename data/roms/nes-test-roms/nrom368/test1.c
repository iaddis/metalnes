//this example code shows how to put some text in nametable
//it assumes that you have ASCII-encoded font in the CHR tiles $00-$3f

#include "neslib.h"


//this macro is used remove need of calculation of the nametable address in runtime

#define NTADR(x,y) ((0x2000|((y)<<5)|x))


//put a string into the nametable

void put_str(unsigned int adr,const char *str)
{
	vram_adr(adr);

	while(1)
	{
		if(!*str) break;
		vram_put((*str++)-0x20);//-0x20 because ASCII code 0x20 is placed in tile 0 of the CHR
	}
}



void main(void)
{
	//rendering is disabled at the startup, and palette is all black

	pal_col(1,0x30);//set while color

	//you can't put data into vram through vram_put while rendering is enabled
	//so you have to disable rendering to put things like text or a level map
	//into the nametable

	//there is a way to update small number of nametable tiles while rendering
	//is enabled, using set_vram_update and an update list

	put_str(NTADR(2,2),"HELLO, WORLD!");
	put_str(NTADR(2,4),"THIS CODE PRINTS SOME TEXT");
	put_str(NTADR(2,5),"USING ASCII-ENCODED CHARACTER");
	put_str(NTADR(2,6),"SET WITH CAPITAL LETTERS ONLY");
	put_str(NTADR(2,8),"TO USE CHR MORE EFFICIENTLY");
	put_str(NTADR(2,9),"YOU'D NEED A CUSTOM ENCODING");
	put_str(NTADR(2,10),"AND A CONVERSION TABLE");

	ppu_on_all();//enable rendering

	while(1);//do nothing, infinite loop
}