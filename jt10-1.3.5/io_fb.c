/*
 * Video implementation for Linux framebuffer devices
 *
 * This source code does not limit on 80 column screens, based on the assumption that
 * whoever wish to edit or see this code, use bigger framebuffer screens theirselves too.
 *
 */

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <signal.h>

#include <linux/vt.h>
#include <linux/fb.h>

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "io.h"
#include "cons.h"

#include "jt10pali.c"

/* Currently visible field */
static int VField[24][40];
static int TField[24][40]; /* Currently visible transparencies */

/* The requested field */
static int vField[24][40];
static int tField[24][40]; /* Requested transparencies */

/* The current tty handle */
static int tty;

/* Framebuffer filehandle */
static int fb_fh;

int fb_xres, fb_yres, fb_width;

#define WantedXRes 640
#define WantedYRes 400

static struct fb_var_screeninfo OldScr;

static void PuraPCX(void)
{
}

static int Active;
static void SetSwitcher(void);
static void Switcher(int signal)
{
	if(signal==SIGUSR1)
	{
		ioctl(tty, VT_RELDISP, 1);
		Active=0;
	}
	if(signal==SIGUSR2)
	{
		ioctl(tty, VT_RELDISP, VT_ACKACQ);
		Active=1;
		raise(SIGWINCH);
	}
	
	SetSwitcher();
}
static void SetSwitcher(void)
{
	signal(SIGUSR1, Switcher);
	signal(SIGUSR2, Switcher);
}

void ClrScr(void)
{
	int x, y;
	
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
		{
			vField[y][x] = 0x700 | ' ';
			tField[y][x] = 0;
		}
}

void RefreshScreen(int x)
{
	int y;
	
	GetWinSize();
	
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
		{
			VField[y][x] = -1;
			TField[y][x] = -1;
		}
}

static int ReadMode(FILE *fp, char *line, struct fb_var_screeninfo *fb_var)
{
	int geometry = 0;
	int timings  = 0;
	
    /* fill in new values */
    fb_var->sync  = 0;
    fb_var->vmode = 0;
    
    while(fgets(line,79,fp) && !strstr(line,"endmode"))
    {
    	char value[16];
    	
        if(sscanf(line," geometry %d %d %d %d %d",
                  &fb_var->xres,
                  &fb_var->yres,
                  &fb_var->xres_virtual,
                  &fb_var->yres_virtual,
                  &fb_var->bits_per_pixel) == 5)
			geometry = 1;
        	
        if(sscanf(line," timings %d %d %d %d %d %d %d",
                  &fb_var->pixclock,
                  &fb_var->left_margin,  &fb_var->right_margin,
                  &fb_var->upper_margin, &fb_var->lower_margin,
                  &fb_var->hsync_len,    &fb_var->vsync_len) == 7)
			timings = 1;
            
        if(sscanf(line, " hsync %15s",value)  ==1 && !strcasecmp(value,"high"))fb_var->sync |= FB_SYNC_HOR_HIGH_ACT;
        if(sscanf(line, " vsync %15s",value)  ==1 && !strcasecmp(value,"high"))fb_var->sync |= FB_SYNC_VERT_HIGH_ACT;
        if(sscanf(line, " csync %15s",value)  ==1 && !strcasecmp(value,"high"))fb_var->sync |= FB_SYNC_COMP_HIGH_ACT;
        if(sscanf(line, " extsync %15s",value)==1 && !strcasecmp(value,"true"))fb_var->sync |= FB_SYNC_EXT;
        if(sscanf(line, " laced %15s",value)  ==1 && !strcasecmp(value,"true"))fb_var->vmode |= FB_VMODE_INTERLACED;
        if(sscanf(line, " double %15s",value) ==1 && !strcasecmp(value,"true"))fb_var->vmode |= FB_VMODE_DOUBLE;
    }
    
    return !geometry || !timings;	/* Failure flag */
}

void InitVideo(void)
{
	struct vt_mode vt_mode;
	char line[80];
	char best[32];
	FILE *fp;
	long by,bx;
	
	InitCons();
	
    if(isatty(0))
    	tty = 0;
    else if((tty = open("/dev/tty",O_RDWR)) < 0)
    {
    	perror("/dev/tty");
		DoneCons();
    	exit(errno);
    }
    
    PuraPCX();
   	
	if(ioctl(tty,VT_GETMODE, &vt_mode) < 0)
	{	
		perror("VT_GETMODE");
		DoneCons();
		exit(errno);
	}
    
    vt_mode.mode   = VT_PROCESS;
    vt_mode.waitv  = 0;
    vt_mode.relsig = SIGUSR1;
    vt_mode.acqsig = SIGUSR2;

	if(ioctl(tty,VT_SETMODE, &vt_mode) < 0)
	{
		perror("VT_SETMODE");
		DoneCons();
		exit(errno);
	}
	if((fb_fh=open("/dev/fb0", O_WRONLY)) < 0)
	{
		perror("/dev/fb0");
		DoneCons();
		exit(errno);
	}
	if(ioctl(fb_fh, FBIOGET_VSCREENINFO, &OldScr) < 0)
	{
		perror("FBIOGET_VSCREENINFO");
		DoneCons();
		exit(errno);
	}
	
    if(!(fp = fopen("/etc/fb.modes","r")))
    {
		perror("/etc/fb.modes");
		DoneCons();
		exit(errno);
	}    	
	
	bx=1000000;
	by=1000000;
	
    while(fgets(line,79,fp))
	{
        char label[32];
        if(sscanf(line, "mode \"%31[^\"]\"", label) == 1)
        {
			struct fb_var_screeninfo fb_var = OldScr;
			int xd, yd;
			
            if(ReadMode(fp, line, &fb_var))continue;
            
            if(fb_var.bits_per_pixel != 8)continue;
            
            xd = fb_var.xres-WantedXRes;
            yd = fb_var.yres-WantedYRes;
            
            if(xd*xd + yd*yd < bx+by)
            {
            	bx=xd*xd;
            	by=yd*yd;
            	strcpy(best, label);
    }	}	}
    
    rewind(fp);
    while(fgets(line,79,fp))
	{
        char label[32];
        if(sscanf(line, "mode \"%31[^\"]\"", label) == 1
        && !strcmp(label, best))
        {
			struct fb_var_screeninfo fb_var = OldScr;
			
            if(ReadMode(fp, line, &fb_var))continue;
            
            fb_width= bx = fb_var.xres;
            fb_yres = by = fb_var.yres;
            fb_xres = fb_var.xres_virtual;
            
            /* set */
            fb_var.xoffset = fb_var.yoffset = 0;
            if(ioctl(fb_fh, FBIOPUT_VSCREENINFO, &fb_var) < 0)
                perror("FBIOPUT_VSCREENINFO");
    }	}
    
	fprintf(stderr, "8-bit mode %dx%d, \"%s\" set\n", (int)bx, (int)by, best);

	ClrScr();
	
	#ifdef SIGWINCH
	signal(SIGWINCH, RefreshScreen);
	#endif
	
	SetSwitcher();
		
	RefreshScreen(0);
}

/* transp: 0=not transparent - 1=transparent - 2=over nonpermanent also
 *   time: 0=permanent       - other=disappears after this count of ticks
 *     ch: ascii character or corner combination
 *  color: combination of 1=blue, 2=green, 4=red, 8=intense
 */
void SetChar(int x, int y, int ch, int color, int transp, int time)
{
	int merk;
	
	/* Check against bounds */
	if(x<0 || x>39 || y<0 || y>23)return;
	
	merk = (color<<8) || ch;
	
	if(time)
	{
		/* Todo */
	}
	else	/* Permanent */
	{
		switch(transp)
		{
			case 0:
				vField[y][x] = merk;
				break;
			case 1:
				tField[y][x] = merk;
				break;
			case 2:
				vField[y][x] = merk;
				tField[y][x] = 0x700 | ' ';
				break;
		}
	}
}

static void FlushScreen(void)
{
	/* Todo */
}
static void Evaluate(void)
{
	/* Todo */
}

void UpdateVideo(int numticks)
{
	while(numticks)
	{
		FlushScreen();
	
		/* After the screen has been draw,
		 * prepare already for the next frame..
		 */
		Evaluate();
		 
		numticks--;
	}
}

void DoneVideo(void)
{
	DoneCons();
    if(ioctl(fb_fh, FBIOPUT_VSCREENINFO, &OldScr) < 0)
		perror("FBIOPUT_VSCREENINFO");
}
