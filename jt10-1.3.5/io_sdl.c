/*
 * Video implementation for libggi
 *
 */

#include <stdio.h>
#include <stdlib.h>

#define	IOdriver yes
#include "io.h"

#ifdef HAVE_SDL_SDL_H
#include <errno.h>
#include <string.h>
#include <signal.h>

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include <ctype.h>

#include "config.h"

#include <SDL.h>

#include "jt10pali.c"

extern int xres,yres, vxres, vyres;

/* Permanent field and transparent field */
static unsigned PField[24][40];
static unsigned TField[24][40];

/* Drawing destination. */
static unsigned pField[24][40];
static unsigned tField[24][40];

/* Flags, which are modified and to be (re)drawn */
static unsigned mField[24][40];

static SDL_Surface* screen;

static unsigned char pcx[16*11][16*6];

static const char merk[11][7] =
  {{"\x0\x8\x4\x1\x2\xF"},
   {"\x9\x6\xC\x5\x3\xA"},
   {"\xD\x7\xB\xE#@"},
   {"ABCDEF"},
   {"GHIJKL"},
   {"MNOPQR"},
   {"STUVXY"},
   {"Z01234"},
   {"56789W"},
   {"-.></:"},
   {"+, &()"}};

static unsigned merkxy[255];
static void makemerkarr(void)
{
	unsigned c;
	for(c=0; c<256; c++)
	{
		unsigned char n = iscorner(c) ? uncorner(c) : toupper((int)c);
		unsigned x,y, indx=2, indy=10;
		for(y=0; y<11; y++)
			for(x=0; x<6; x++)
				if(merk[y][x]==n){indx=x, indy=y;goto P1;}
	P1: merkxy[c] = ((indy<<8) | indx) << 4;
	}
}

static void PuraPCX(void)
{
	unsigned char*p=jt10pali+128,c;
	int n,x,y;
#if 0
	for(n=x=y=0;n>=0;)
		for((c=*p++)<192?n=1:(n=c-192,c=*p++);n;n--)
			if(pcx[y][x]=c, ++x==8*6 && (x=0, ++y==8*11)) { n = -1; break; }
#else
	for(n=x=y=0;n>=0;)
	{
		c = *p++;
		if(c < 192) n = 1; else n = c-192, c = *p++;
		for(; n; n--)
		{
			pcx[y][x]=c;
			if(++x==16*6)
			{
				x=0;
				if(++y==16*11)
				{
					n = -1;
					break;
	}	}	}	}
#endif
}

static void ClrScr(void)
{
	int x, y;
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
		{
			PField[y][x] = ' ';
			TField[y][x] = ' ';
			mField[y][x] = 1;
		}
}

static void RefreshScreen(int x)
{
	int y;
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
			mField[y][x] = 1;
}

typedef struct Timer
{
	int x, y, transp, time;
	unsigned merk;
	struct Timer *next;
} Timer;
static Timer *timers = NULL;

static void InsertTimer(int x, int y, unsigned merk, int transp, int time)
{
	Timer *t = (Timer *)malloc(sizeof(Timer));
	t->x = x;
	t->y = y;
	t->merk = merk;
	t->transp = transp;
	t->time = time;
	t->next = timers;
	timers = t;
}
static void DeleteTimer(Timer *tim)
{
	Timer **t;
	for(t=&timers; *t&&*t!=tim; t=&(*t)->next);
	if(*t)
	{
		*t = tim->next;
		free(tim);
	}
}
static void Build(int x,int y)
{
	Timer *t;
	pField[y][x] = PField[y][x];
	tField[y][x] = TField[y][x];
	for(t=timers; t; t=t->next)
	{
		if(t->x != x || t->y != y)continue;
		switch(t->transp)
		{
			case 2:
				tField[y][x] = ' ';
			case 0:
				pField[y][x] = t->merk;
				break;
			case 1:
				tField[y][x] = t->merk;
				break;
		}
	}
	mField[y][x] = 0;
}
static void Evaluate(void)
{
	Timer *t;
	for(t=timers; t; )
	{
		Timer *q = t->next;
		if(--t->time <= 0)
		{
			mField[t->y][t->x] = 1;
			DeleteTimer(t);
		}
		t = q;
	}
}

static void FlushScreen(void)
{
	int x, y;
	unsigned sx, sy;
	for(sy=y=0; y<24; y++, sy+=16)
		for(sx=x=0; x<40; x++, sx+=16)
		{
		  	if(mField[y][x])
			{
				unsigned nx,ny, px,py, tx,ty;
				unsigned char p1,p2;
				unsigned char t1,t2;
				unsigned char c;
				unsigned char bb[16*16], *bpos;
				Build(x, y);
				
				c = (unsigned char)pField[y][x];
				px = merkxy[c] & 255;
				py = merkxy[c] >> 8;
				
				c = (unsigned char)tField[y][x];
				tx = merkxy[c] & 255;
				ty = merkxy[c] >> 8;
				
				p1 = (pField[y][x]>>8)&15;
				p2 = (pField[y][x]>>12);
								
				t1 = (tField[y][x]>>8)&15;
				t2 = (tField[y][x]>>12);
				
				for(bpos=bb, ny=0; ny<16; ny++)
					for(nx=0; nx<16; nx++)
					{
						unsigned char a = pcx[py+ny][px+nx];
						unsigned char b = pcx[ty+ny][tx+nx];
						
						switch(c=0, b)
						{
							case 1:
								switch(a)
								{
									case 1:
										if(t2&&p2)c = p2*16+t2;
										else if(t2)c = t2*16+t2;
										else if(p2)c = p2*16+p2;
										break;
									case 2:
										if(t2)c = p1*16+t2;
										else c = p1*16+p2;
										break;
									case 3:
										c = p1*16+p1;
										break;
								}
								break;
							case 2:
								c = t1*16+t2;
								break;
							case 3:
								c = t1*16+t1;
						}
						*bpos++ = c;
					}
				 
				for(bpos=bb, ny=0; ny<16; ny++, bpos+=16)
				    memcpy( ((unsigned char*)screen->pixels) + sx + (sy+ny)*vxres,
				                 bpos,
				                 16);
			}
		}
	SDL_Flip(screen);
}

/* transp: 0=not transparent - 1=transparent - 2=over nonpermanent also
 *   time: 0=permanent       - other=disappears after this count of ticks
 *     ch: ascii character or corner combination
 *  color: combination of 1=blue, 2=green, 4=red, 8=intense
 */
static void SetChar(int x, int y, int ch, int color, int transp, int time)
{
	unsigned merk;
	
	/* Check against bounds */
	if(x<0 || x>39 || y<0 || y>23)return;
	
	merk = (color<<8) | ch;
	
	if(time)
		InsertTimer(x,y, merk, transp, time);
	else	/* Permanent */
	{
		switch(transp)
		{
			case 2:
				TField[y][x] = ' ';
				PField[y][x] = merk;
				break;
			case 0:
				if(PField[y][x] == merk)return;
				PField[y][x] = merk;
				break;
			case 1:
				if(TField[y][x] == merk)return;
				TField[y][x] = merk;
				break;
		}
	}
	mField[y][x] = 1;
}

static void UpdateVideo(int numticks)
{
	for(; numticks; numticks--)
	{
		FlushScreen();
	
		/* After the screen has been drawn,
		 * prepare already for the next frame..
		 */
		Evaluate();
	}
	//SDL_Flip(screen);
}

static void DoneVideo(void);
static void InitVideo(void)
{
	static const unsigned char R[16] = {0, 0, 0, 0,42,42,42, 42, 21, 21,21,21,63,63,63,63};
	static const unsigned char G[16] = {0, 0,42,42, 0, 0,21, 42, 21, 21,63,63,21,21,63,63};
	static const unsigned char B[16] = {0,42, 0,42, 0,42, 0, 42, 21, 63,21,63,21,63,21,63};
	SDL_Color pal[256];
	unsigned a, b;
	
    PuraPCX();
	makemerkarr();
	
	SDL_Init(SDL_INIT_VIDEO);
	SDL_InitSubSystem(SDL_INIT_VIDEO);
	
	if(!(screen = SDL_SetVideoMode(vxres,vyres, 8,0))
	&& !(screen = SDL_SetVideoMode(640,400, 8,0))
	&& !(screen = SDL_SetVideoMode(640,480, 8,0)))
	{
	ggiFail:
		DoneVideo();
		fprintf(stderr, "Could not find a suitable display mode.\n");
		exit(-1);
	}
	SDL_WM_SetCaption("Joeltris 10",0);
	
	for(a=0; a<16; a++)
		for(b=0; b<16; b++)
		{
			unsigned r1 = R[a]*255/63, g1 = G[a]*255/63, b1 = B[a]*255/63;
			unsigned r2 = R[b]*255/63, g2 = G[b]*255/63, b2 = B[b]*255/63;
			unsigned ind = a+b*16;
			
			pal[ind].r = (r1+r2)/2;
			pal[ind].g = (g1+g2)/2;
			pal[ind].b = (b1+b2)/2;
		}
	
	SDL_SetColors(screen, pal, 0, 256);
	
	ClrScr();
	
	RefreshScreen(0);
	
	SDL_EnableKeyRepeat(250, 30);
}

static void DoneVideo(void)
{
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
    SDL_Quit();
}

//static Uint8* keys = 0;
//static Uint8 prevkeys[SDLK_LAST] = {0};
static int kbhit(void)
{
    SDL_PumpEvents();
    int r = SDL_PollEvent(0);
    //fprintf(stderr, "ev: %d\n", r);
    return r;
    /*
    int numkeys, n;
    keys = SDL_GetKeyState(&numkeys);
    if(numkeys > SDLK_LAST)
    {
        fprintf(stderr, "eh?\n"); fflush(stderr);
        return 0;
    }
    fprintf(stderr, "%u keys\n", numkeys); fflush(stderr);
    for(n=0; n<numkeys; ++n)
    {
        if(keys[n]) { fprintf(stderr, "key %u=%d\n", n, keys[n]); fflush(stderr); }
        if(keys[n] && !prevkeys[n])
        {
            prevkeys[n]=1;
            fprintf(stderr, "kbhit: %u\n", n); fflush(stderr);
            return 1;
        }
        if(!keys[n]) prevkeys[n]=0;
    }
    return 0;
    */
}

static int getch(void)
{
    SDL_Event ev;
    if(!SDL_WaitEvent(&ev)) return 0; // nothing
    
    //fprintf(stderr, "got event type %u, key %u\n", ev.type, ev.key.keysym);
    
    if(ev.type == SDL_KEYDOWN)
    {
        switch(ev.key.keysym.sym)
        {
            case SDLK_KP8: case SDLK_UP: return '';
			case SDLK_KP2: case SDLK_DOWN: return '';
			case SDLK_KP4: case SDLK_LEFT: return '';
			case SDLK_KP6: case SDLK_RIGHT: return '';
			case SDLK_KP_ENTER: case SDLK_RETURN: return '\n';
			case SDLK_SPACE: return ' ';
			case SDLK_ESCAPE: case SDLK_q: return 'q';
			default: return ''; // refresh
    }   }
    return 0; // nothing
}

#else /* Does not have ggi.h */
static void InitVideo(void)
{
	fprintf(stderr, "This program was compiled without libSDL support.\n");
	exit(EXIT_FAILURE);
}
static void SetChar(int a,int b,int c,int d,int e,int f){a=b=c=d=e=f;}
static void ClrScr(void){}
static void UpdateVideo(int d){d=d;}
static void DoneVideo(void){}
static void RefreshScreen(int d){d=d;}
static int kbhit(void){return 0;}
static int getch(void){return 0;}
#endif

iodriver sdl =
{
	"sdl",
	
	InitVideo,
	DoneVideo,
	
	SetChar,
	ClrScr,
	UpdateVideo,
	RefreshScreen,
	
	kbhit,
	getch,
	
	NULL
};
