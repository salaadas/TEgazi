#include <stdio.h>
#include <stdlib.h>
#include "misc.h"
#include "io.h"
int main(int argc, const char **argv)
{
	int x=0,y;const char*s,*d=DEFAULT_IO,*A0=*argv;
	for(InstallDriver(&ggi,&vt100,&sdl,0);--argc;)
	{
		extern int xres,yres, vxres,vyres;
		if(*(s=*++argv)=='-')
		{
		Usage:
			printf(
				"Usage: %s [(ggi | vt100) [<xres> <yres> <vxres> <vyres>]]\n"
				"Default io driver: %s\n"
				"Default resolution: auto auto  640 384\n"
				"Read libggi documentation for help on using ggi\n",
					A0,DEFAULT_IO);
			return 1;
		}
		switch(x++)
		{
			case 0: d=s; break;
			case 1: xres=atoi(s); break;
			case 2: yres=atoi(s); break;
			case 3: vxres=atoi(s); break;
			case 4: vyres=atoi(s); break;
			default: goto Usage;
		}
	}
	if(SelectDriver(d)<0){printf("IO driver `%s' is unknown\n",d);return 1;}
	InitVideo();ClrScr();
	
	Center(0,0x1F,0,0, "White on black. Press a key.");
	for(y=1; y<24; y++)for(x=0; x<40; x++)SetChar(x,y, 'A', 7,0,0);
	UpdateVideo(1); while(!getch());

	Center(0,0x1F,0,0, "Bright cyan on green. Press a key.");
	for(y=1; y<24; y++)for(x=0; x<40; x++)SetChar(x,y, 'A', 0x2B,0,0);
	UpdateVideo(1); while(!getch());

	Center(0, 0x1F,0,0,  "    Black on white. Press a key.   ");
	for(y=1; y<24; y++)for(x=0; x<40; x++)SetChar(x,y, 'A', 0x70,0,0);
	Center(21,0x71,0,0, "See also: ./dialog");
	Center(22,0x71,0,0, "(supplied as part of the configuration)");
	UpdateVideo(1); while(!getch());

	DoneVideo();return 0;
}
