#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

#include "io.h"
#include "misc.h"

static int WhichKey(void)
{
	int c = getch();
	if(c=='A'||c=='w'||c=='H')c='';
	if(c=='B'||c=='s'||c=='P')c='';
	if(c=='D'||c=='a'||c=='K')c='';
	if(c=='C'||c=='d'||c=='M')c='';
	if(c=='\r')c='\n';
	return c;
}

static struct listsel
{
	const char *text;
	const char *comment;
	int selected;
} list[18];
static int listtop=0;

static const char *tconv(const char *s)
{
	/* This is not the best, but it works */
	char *q = (char *)malloc(512);
	char *t = q;
	while(*s){if(*s=='_')*t++=(s++,' ');
		else if(*s!='\\')*t++=*s++;
		else if(*++s!='n')*t++=*s++;
		else *t++=(s++,'\n');}
	*t=0; return q;
}

static int count(const char *q, char m)
{
	int c;
	for(c=0; *q; q++)if(*q==m)c++;
	return c;
}

static void Quittah(int n)
{
	n=n;DoneVideo();
	exit(-1);
}

int main(int argc, const char **argv)
{
	int a, x, y;
	int mode='t';
	const char *title = "";
	const char *message = "";
	char InputBuf[40];
	
	signal(SIGINT, Quittah);
	
	for(x=0, a=1; a<argc; a++)
	{
		const char *s = argv[a];
		if(s[0]=='-'&&!s[2]) { mode=s[1]; continue; }
		if(a==1){title=s;continue;}
		if(mode=='t')
		{
			message=tconv(s);
			continue;
		}
		if(mode=='i')
		{
			strncpy(InputBuf, s, 39);
			InputBuf[39]=0;
			continue;
		}			
		if(mode=='r')
			switch(x++%3)
			{
				case 0: list[listtop].text = tconv(s); break;
				case 1: list[listtop].comment = tconv(s); break;
				case 2: list[listtop].selected = !strcmp(s, "on");
						listtop++;
			}
	}
	
	if((mode=='t'||mode=='?'||mode=='h')
	&& !*message)
		title = "Help",
		message =
			"Usage:                           \n"
			"\n"
			"dialog <title> ...               \n"
			"   -t <message>                  \n"
			"   -r <sel> <descr> <yesno> [...]\n"
			"   -i <default value>            \n"
			"\n"
			"With -r and -i, the selected\n"
			"choice is echoed to stderr.\n"
			"\n"
			"Copyright (C) 1992,99 Bisqwit\n"
			"http://iki.fi/bisqwit/";
	
	InstallDriver(&vt100, NULL);
	SelectDriver("vt100");
	
	InitVideo();
	
	for(y=0; y<24; y++)
		for(x=0; x<40; x++)
			SetChar(x, y, ' ', 0x17,0,0);
	
	Center(1, 0x1F, 0,0, title);
	
	switch(mode)
	{
		case 'r':
		{
			int p, l=0;
			SetText(3, a=3, 0x17, 0,0, "%s", message);
			a += 2 + count(message, '\n');
				
			for(x=y=0; y<listtop; y++)
			{
				if(list[y].selected)x=y;
				p=strlen(list[y].text);
				if(p>l)l=p;
			}
				
		Refresh:
			for(p=a, y=0; y<listtop; y++)
			{
				int h,k;
				SetText(4,    y+p, 0x1F, 0,0, y==x ? "->" : "  ");
				SetText(8,    y+p, 0x1E, 0,0, "%s", list[y].text);
				SetText(8+l+1,y+p, 0x17, 0,0, "%s", list[y].comment);
				h = count(list[y].text, '\n');
				k = count(list[y].comment, '\n');
				p += h>k?h:k;
			}
			UpdateVideo(1);
		ReKey:
			switch(WhichKey())
			{
				case '': case '':
					x = (x+listtop-1)%listtop;
					goto Refresh;
				case '': case '':
					x = (x+1)%listtop;
					goto Refresh;
				case ' ':
				case '\n':
					break;
				default:
					goto ReKey;
			}
			fprintf(stderr, "%s\n", list[x].text);
			break;
		}
		case 'i':
		{
			char *s = InputBuf;
			int cpos, len=strlen(s), max=10;
			if(len>max)s[len=max]=0;
			cpos=len;
			
			Center(y=3, 0x17, 0,0, "%s", message);
			y += 2 + count(message, '\n');
			
			for(x=10;;)
			{
				int tick=0;
				for(;;)
				{
					for(a=0; a<max; a++)
						SetChar(x+a, y, 
							a<len ? s[a] : ' ',
							tick<6&&a==cpos?0x71:0x0B, 0,0);
					UpdateVideo(1);
					if(kbhit())break;
					usleep(100000);
					if(++tick==8)tick=4;
				}
				
				switch(a=WhichKey())
				{
					case '': 
						if(cpos>0)cpos--;
						break;
					case '':
						if(cpos<len)cpos++;
						break;
					case '':
						cpos=0;
						break;
					case '':
						cpos=len;
						break;
					case 127:
					case '':
						if(!cpos)break;
						cpos--;
						/* through */
					/*case del:*/
						if(cpos <len)
						{
							memmove(s+cpos, s+1+cpos, len-cpos);
							len--;
						}
						break;
					case '\n':
					case '\r':
						goto Done;
					default:
						if(len < max && a && strchr("0123456789", a))
						{
							memmove(s+cpos+1, s+cpos, len-cpos+1);
							s[cpos++] = a;
							len++;
						}
				}
			}
		Done:;
			fprintf(stderr, "%s\n", s);
			break;
		}
		default:
			Center(4, 0x17, 0,0, "%s", message);
			Center(22, 0x1E, 0,0, "Press a key or button to continue");
			UpdateVideo(1);
			getch();
			Center(22, 0x1E, 0,0, "                                 ");
			UpdateVideo(1);
	}
	
	DoneVideo();
	
	return 0;
}
