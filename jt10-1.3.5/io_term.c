/*
 * Video implementation for vt100 terminals
 *
 * Requires that the compiler understands "char" as "signed char".
 */

#include <stdio.h>
#include <stdlib.h>

#define IOdriver yes
#include "io.h"

#if defined(HAVE_TERMIO_H)||defined(HAVE_TERMIOS_H)
/* Both contain the same, in practice */

#ifdef HAVE_TERMIO_H
#include <termio.h>
#endif
#ifdef HAVE_TERMIOS_H
#include <termios.h>
#endif

#include <errno.h>
#include <string.h>
#include <signal.h>

#ifdef HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>
#endif

#include <unistd.h>
#include <fcntl.h>

static struct termio back;

static int LINES=0, COLS=0;

#define EVERYFLUSH 0

/* Window upperleft coordinates on screen */
#define XA ((COLS -40)/2)
#define YA ((LINES-24)/2)

static int tctl(int wait)
{
	struct termio term = back;
	term.c_lflag &= ~ECHO & ~ICANON;
	term.c_cc[VMIN] = wait;         /* when set to 0, getch() will return */
	return ioctl(0, TCSETA, &term); /* immediately, if no key was pressed */
	                                /* (return value is then EOF)         */
}


static int LastNap = -1;
static int getch(void)
{
	if(LastNap >= 0)
	{
		int temp = LastNap;
		LastNap = -1;
		return temp;
	}
	tctl(1);
	return getchar();
}
static int kbhit(void) 
{
	int c;
	if(LastNap >= 0)return 1;
	tctl(0);
	c = getchar();
	if(c==EOF)
	{
		LastNap = -1;
		return 0;
	}
	LastNap = c;
	return 1;
}

static void GetWinSize(void)
{
	struct winsize ws;        /* buffer for TIOCSWINSZ */
  
	if(ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) >= 0)
	{
		LINES = ws.ws_row;
		COLS  = ws.ws_col;
	}
	if(LINES==0 || COLS==0)
	{
		printf("Unknown window size (%d,%d), setting to 80x24\n",COLS,LINES);
		LINES=24;
		COLS=80;
	}
}

static void DoneCons(void)
{
	ioctl(0, TCSETA, &back);
}

static void InitCons(void)
{ 
	GetWinSize();

#if 0
	setvbuf(stdout, NULL, _IONBF, 0);
#endif

	ioctl(0, TCGETA, &back);
	tctl(1);
}

static int TextAttr;
static int OldAttr;
static int WhereX, WhereY;

/* I hope this is big enough! */
static char OutputBuffer[16384];
static char *OutputTail = OutputBuffer;

/* This is for speed */
static char ColorDiffLen[256][256];

static void Buffaa(const char *s)
{
	/* Todo: Check buffer overflow, call Flush() if necessary */
	
	while(*s)*OutputTail++ = *s++;
}
static void Flush(void)
{
	*OutputTail = 0;
	fputs(OutputBuffer, stdout);
	fflush(stdout);
	#if EVERYFLUSH
	usleep(10000);
	#endif
	OutputTail = OutputBuffer;
}

#define SetAttr(n) (TextAttr=(n))
#define Colors 1 /* Yes, we want colors */

#ifndef DJGPP
static char *ColorDiff(int old, int new)
{
	static char Buff[16];
	char *be = Buff;
	
	/* Todo:
	 * If the background color of old and new is the same,
	 * and is writing only spaces, there is no need to
	 * change the colour - it will still look the same.
	 */
	
    if(TextAttr == OldAttr || !Colors)
    {
    	Buff[0] = 0;
    	return Buff;
    }
	be[0] = 27;
	be[1] = '[';
	be += 2;

#if !BROKEN_TERM
	if(new != 7)
#endif
    {
    	static char Swap[] = "04261537";
    	
    	int pp=0;
    	
    	if((old&0x80) > (new&0x80)
    	|| (old&0x08) > (new&0x08))
    	{
    		*be++ = '0'; pp=1;
    	#if BROKEN_TERM
    		/* Ensure all attributes are reset */
    		old = (new&0x77) ^ 0x77;
    	#else
    		old = 7;
    	#endif
    	}    	
    	
    	if((new&0x08) && !(old&0x08)){if(pp)*be++ = ';'; *be++ = '1';pp=1;}
    	if((new&0x80) && !(old&0x80)){if(pp)*be++ = ';'; *be++ = '5';pp=1;}
       	
       	if((new&0x70) != (old&0x70))
       	{
   	   		if(pp)*be++ = ';';
   	   		*be++ = '4';
   	   		*be++ = Swap[(new>>4)&7];
       		pp=1;
       	}
       	
      	if((new&7) != (old&7))
      	{
       		if(pp)*be++ = ';';
       		*be++ = '3';
       		*be++ = Swap[new&7];
       	}
       	*be = 0;
    }
    
    be[0] = 'm';
    be[1] = 0;
    
    return Buff;
}
#endif

static void FlushSetAttr()
{
    #ifdef DJGPP

	if(Colors)textattr(TextAttr);

    #else
    
	Buffaa(ColorDiff(OldAttr, TextAttr));

    #endif
    
	OldAttr = TextAttr;
}

static void UpDown(char *s, int oldy,int newy)
{
	/***/if(newy == oldy-1)sprintf(s, "\33[A");
	else if(newy == oldy+1)sprintf(s, "\33[B");
	else if(newy < oldy)sprintf(s, "\33[%dA", oldy-newy);
	else if(newy > oldy)sprintf(s, "\33[%dB", newy-oldy);
	else *s=0;
}

static void LeftRight(char *s, int oldx,int newx)
{
	/***/if(newx == oldx+1)sprintf(s, "\33[C");
	else if(newx == oldx-1)sprintf(s, "\33[D");
	else if(newx < oldx)sprintf(s, "\33[%dD", oldx-newx);
	else if(newx > oldx)sprintf(s, "\33[%dC", newx-oldx);
	else *s=0;
}

/* Permanent field - required for correctly removing the timered items */
static unsigned Field[24][40];

/* Currently visible field - required for optimized terminal output */
static unsigned VField[24][40];

/* Requested visible field - this is to be drawed to. */
static unsigned QField[24][40];

/* This is not thread safe!! */
static char *LocationDiff(int oldx,int oldy, int newx,int newy, int color)
{
	static char Buff[24];
	char *s = Buff;
	
	register int xa = XA;
	register int ya = YA;
	
	oldx += xa;
	oldy += ya;
	
	newx += xa;
	newy += ya;
	
	Buff[0]=0;
	
	if(newx==oldx && newy==oldy)return Buff;
	
	if(!newx)
	{
		#if BROKEN_TERM
		strcpy(Buff, "\r");
		s++;
		#endif
		if(newy==oldy+4) return strcat(Buff, "\n\n\n\n");
		if(newy==oldy+3) return strcat(Buff, "\n\n\n");
		if(newy==oldy+2) return strcat(Buff, "\n\n");
		if(newy==oldy+1) return strcat(Buff, "\n");
		UpDown(s, oldy,newy);
		return Buff;
	}
	
	#if 0
	if(newx==oldx-2)
	{
		*s++ = '\b';
		goto Da;
	}
	#endif
	if(newx==oldx-1)
	{
	#if 0
	Da:	
	#endif
		*s++ = '\b';
		UpDown(s, oldy,newy);
		return Buff;
	}
	if(newy == oldy)
	{
		if(newx>oldx && newx<oldx+3)
		{
			int a;
			for(a=oldx; a<newx; a++)
				if((QField[newy-ya][a-xa]>>8) != (unsigned)color)
					break;
			if(a==newx) /* yeah! */
			{
				for(a=oldx; a<newx; a++)
					*s++ = QField[newy-ya][a-xa];
				*s=0;
				return Buff;
			}
		}
	
		LeftRight(s, oldx,newx);
		return Buff;
	}
	sprintf(Buff, "\33[%d;%df", newy+1, newx+1);
	return Buff;
}

static void Locate(int x, int y)
{
	Buffaa(LocationDiff(WhereX,WhereY, x,y, TextAttr));
	WhereX = x;
	WhereY = y;
}

static void PutChar(int ch)
{
	*OutputTail++ = ch;
	
	WhereX++;
}

static int ch2char(int c)
{
	static char Mrks[16] = "#\"-'-`-^.|.<,>v+";
	                     /* 0 123456789ABCDEF          */
	                     /* &1=up, &2=lt, &4=rt, &8=dn */
		
	if(!iscorner(c))
	{
		/* We don't print confusing chars. */
		if(c < ' ')c = ' ';
		return c;
	}
	
	return Mrks[uncorner(c)];
}

static void DoneVideo(void)
{
	SetAttr(7);
	FlushSetAttr();

#if CLEAR_SCREEN_AT_END
	Buffaa("\33[2J\33[H"); /* Clear screen */
#else
	Locate(0, 24);
	Buffaa("\n");
#endif

#if HIDE_CURSOR
	Buffaa("\33[?25h");
#endif

	Flush();
	
	DoneCons();
}

static void FlushScreen(void)
{
	int x, y, JobCount=0, JobPos, JobsLeft;
	struct Job
	{
		int Done;
		int x, y;
		unsigned merk;
	} *Jobs;
	
	/* Is there a problem? */
	#define Problem(x,y) (QField[y][x] != VField[y][x])
		  
	/* There is problem, if either color or character is different */
	
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
			if(Problem(x,y))
				JobCount++;
			
	if(!JobCount)
	{
		/* Let's have a holiday. */
		return;
	}
		
	/* For entire screen redraw, Jobs can take              *
	 * sizeof(struct Job) * 40 * 24 bytes of memory.        *
	 * That is, 40*24 * 5*4, which is 40*24*20, about 19kB. */
	
	JobPos = 0;
	Jobs = (struct Job *)malloc(JobCount * (sizeof(struct Job)));
	if(!Jobs)
	{
		DoneVideo();
		printf("Out of memory in FlushScreen in "__FILE__);
		exit(ENOMEM);
	}
	
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
		{
			/* Is there a problem? */
			if(Problem(x,y))
			{
				/* Yes, we need to fix it,   *
				 * but let's handle it later */
				Jobs[JobPos].x = x;
				Jobs[JobPos].y = y;
				Jobs[JobPos].Done = 0;
				Jobs[JobPos].merk = QField[y][x];
				JobPos++;
			}
		}
		
	/* Ok, now the most exciting part. */
	
	for(JobsLeft=JobCount; JobsLeft; JobsLeft--)
	{
		int x,y, a, bp=0;
		
		/* We must select now the job which *
		 * bestly fits in our motivation... */
		 
		#if videospdlimit
		char score=100;
		
		if(JobCount > videospdlimit) /* We should not use CPU much, however */
		{
		#endif
			for(a=0; a<JobCount; a++)
				if(!Jobs[a].Done)
				{
					bp = a;
					break;
				}
		#if videospdlimit
		}
		else
			for(a=0; a<JobCount; a++)
				if(!Jobs[a].Done)
				{
					char Score = ColorDiffLen[TextAttr&255][Jobs[a].merk>>8];
					
					if(VField[Jobs[a].y][Jobs[a].x] == Jobs[a].merk)
					{
						Jobs[a].Done=1;
						goto Haa;
					}
					
					Score += (Jobs[a].x > Jobs[bp].x) ? 1 : -1;
					Score += (Jobs[a].y > Jobs[bp].y) ? 1 : -1;
					
					if(Score >= score)continue;
					
					Score += (char)strlen(
						LocationDiff(
							WhereX,WhereY,
							Jobs[a].x,Jobs[a].y,
							Jobs[a].merk>>8));
					
					if(Score < score)
					{
						score = Score;
						bp    = a;
						if(!score)break;	/* The best was found */
					}
				}
		#endif	/* videospdlimit */
				
		x = Jobs[bp].x;
		y = Jobs[bp].y;
			
		/* Then execute it. */
		SetAttr(Jobs[bp].merk>>8);
		FlushSetAttr();
		Locate(x, y);
		PutChar(Jobs[bp].merk&255);
		
		VField[y][x] = Jobs[bp].merk;
		
		/* Mark it done. */
		Jobs[bp].Done = 1;
		
		#if EVERYFLUSH
		
		Flush();
		
		#endif
		#if videospdlimit
	Haa:;
		#endif
	}
	
	/* They don't need to be prisoned... */	
	free(Jobs);
}

/* A temporary object */
static struct Temp
{
	int x, y, time;
	unsigned merk;
	struct Temp *next;
} *Temps = NULL;

static void AddTemporary(int x, int y, int time, unsigned merk)
{
	struct Temp *tmp;
	
	tmp = (struct Temp *)malloc(sizeof(struct Temp));
	if(!tmp)
	{
		DoneVideo();
		printf("Out of memory in AddTemporary in "__FILE__);
		exit(ENOMEM);
	}
	
	tmp->x = x;
	tmp->y = y;
	tmp->merk = merk;
	tmp->time = time;
	tmp->next = Temps;
	
	Temps = tmp;
}

static void ClrScr(void)
{
	int x, y;
	
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
		{
			struct Temp **Owner, *tmp;
			
			Field[y][x] = ' ' | 0x700;
			
			Owner = &Temps;
			for(;;)
			{
				if(!(tmp = *Owner))break;
				
				if(tmp->x==x && tmp->y==y)
				{
					struct Temp *tmp2;
					
					if(tmp->time > 0)
					{
						/* May not clear it from screen */
						goto Noway;
					}
					
					/* kill it! */
					tmp2 = tmp->next;
					free(tmp);
					*Owner = tmp2;
				}
				else
					Owner = &tmp->next;
			}
			
			QField[y][x] = ' ' | 0x700;
			
		Noway:;
		}
}

static void RefreshScreen(int x)
{
	int y;
	
	GetWinSize();
	
	OldAttr = -1;
	
	Flush();
	
	SetAttr(7);
	FlushSetAttr();
	Buffaa("\33[H\33[J");   /* Home cursor, clear to end of screen */
	
	#if HIDE_CURSOR	
	Buffaa("\33[?25l");		/* Hide cursor */
	#endif
	
	Flush();
	
	WhereX = -XA;
	WhereY = -YA;
	
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
			VField[y][x] = ' ' | (TextAttr << 8);
}

static void InitVideo(void)
{
	int x, y;
	
	InitCons();
	
	if(LINES<24 || COLS<40)
	{
		printf(
			"Sorry, your terminal geometry is not big enough.\n"
			"40x24 required at least.\n");
		exit(0);
	}
	
	for(x=0; x<256; x++)
		for(y=0; y<256; y++)
			ColorDiffLen[x][y] = (char)strlen(ColorDiff(x, y));
	
	ClrScr();
	
	#ifdef SIGWINCH
	 signal(SIGWINCH, RefreshScreen);
	#endif
		
	RefreshScreen(0);
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
	
	/* For vt100, we don't care about the transparency flag,
	 *            because the terminal simply does not support it...
	 */
	ch = ch2char(ch);
	
	/* This is a hack for the scoreborder and no blinking colours! */
	if(color >= 0x80)color >>= 4;
	
	merk = ch | (color<<8);
	
	if(!time)
	{
		struct Temp *tmp;
		
		if(transp != 1)
		{
			/* immediately */
			Field[y][x] = merk;
		}
		
		if(transp == 0)
		{
			for(tmp=Temps; tmp; tmp=tmp->next)
				if(tmp->x==x && tmp->y==y)
					if(tmp->time>0 || ((tmp->merk&255)!=' '))
					{
						/* May not put it on it */
						return;
					}
		}
		else	/* transp is 1 or 2 */
		{
			struct Temp **Owner = &Temps;
			for(;;)
			{
				if(!(tmp = *Owner))break;
				if(tmp->x==x && tmp->y==y && (transp==2 || tmp->time<0))
				{
					/* kill it! */
					struct Temp *tmp2 = tmp->next;
					free(tmp);
					*Owner = tmp2;
				}
				else
					Owner = &tmp->next;
			}
		}
		
		if(transp==1)
		{
			/* Make eternal! */
			AddTemporary(x, y, -1, merk);
		}
	}
	else
	{
		/* Temporarily */
		AddTemporary(x, y, time, merk);
	}
	
	QField[y][x] = merk;
}

static void Evaluate(void)
{
	struct Temp **Owner = &Temps;
	
	for(;;)
	{
		struct Temp *tmp = *Owner;
		if(!tmp)break;
		
		/* Make it older, if it is not eternal */
		if(tmp->time>0)tmp->time--;
		
		/* Is it at the end of its lifetime? */		
		if(!tmp->time)
		{
			int x=tmp->x, y=tmp->y;
			
			/* Delete it from the list */
			struct Temp *tmp2 = tmp->next;
			free(tmp);
			*Owner = tmp2;

			/* Find the correct underground for this */			
			for(tmp2=Temps; tmp2; tmp2=tmp2->next)
				if(x==tmp2->x && y==tmp2->y)
				{
					QField[y][x] = tmp2->merk;
					break;
				}
				
			/* If not found, take it from Field.      *
			 * This is the most often case, actually. */
			if(!tmp2)
				QField[y][x] = Field[y][x];
			
			continue;
		}
		
		Owner = &tmp->next;
	}
}

static void UpdateVideo(int numticks)
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
	
	Flush();
}

#else /* Does not have termios.h */
static void InitVideo(void)
{
	fprintf(stderr, "termios.h not found, terminal handling impossible\n");
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

iodriver vt100 =
{
	"vt100",
	
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
