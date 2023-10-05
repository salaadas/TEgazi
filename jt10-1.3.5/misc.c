#include <stdio.h>
#include <stdarg.h>
#include "io.h"
#include "misc.h"

void SetText(int x,int y, int c,int tr,int time, const char *fmt, ...)
{
	char Buf[512], *s;
	va_list ap;
	int nx=x;
	
	va_start(ap, fmt);	
	#ifdef HAVE_VSNPRINTF
	vsnprintf(Buf, sizeof(Buf)-1, fmt, ap);
	#else
	vsprintf(Buf, fmt, ap);
	#endif
	va_end(ap);
	
	for(s=Buf; *s; s++)
		switch(*s)
		{
			case '\b': x--; break;
			case '\n': y++; /* through */
			case '\r': x=nx; break;
			default:
				SetChar(x++,y,*s, c,tr,time);
		}
}

void Center(int y, int c,int tr,int time, const char *fmt, ...)
{
	char Buf[512], *s;
	va_list ap;
	int nx, x;
	
	va_start(ap, fmt);	
	#ifdef HAVE_VSNPRINTF
	vsnprintf(Buf, sizeof(Buf)-1, fmt, ap);
	#else
	vsprintf(Buf, fmt, ap);
	#endif
	va_end(ap);
	
	s=Buf;
	
GetNx:
	for(x=0; s[x] && s[x]!='\n'; x++);
	x = nx = (41-x) / 2;
	
	for(; *s; s++)
		switch(*s)
		{
			case '\b':
				x--;
				break;
			case '\n':
				y++;
				s++;
				goto GetNx;
				break;
			case '\r':
				x=nx;
				break;
			default:
				SetChar(x++,y,*s, c,tr,time);
		}
}

void DrawMainBorder(void)
{
	int x, y;
	for(y=0; y<24; y++)
	{
		SetChar( 0,y, corner(c_up+c_dn+c_rt),mainborder, 2,0);
		SetChar( 1,y, corner(c_up+c_dn+c_lt),mainborder, 2,0);
		SetChar(38,y, corner(c_up+c_dn+c_rt),mainborder, 2,0);
		SetChar(39,y, corner(c_up+c_dn+c_lt),mainborder, 2,0);
	}
	for(x=1; x<39; x++)
	{		SetChar(x, 0, corner(c_lt+c_rt),mainborder, 2,0);
		SetChar(x,23, corner(c_lt+c_rt),mainborder, 2,0);
	}
}

void DrawScoreBorder(void)
{
	int x, y;
	
	for(x=20-9; x<20+9; x++)
		SetChar(x,4, corner(c_lt+c_rt), scoreborder,1,0);
			
	for(y=1; y<=4; y++)
	{
		SetChar(20-9,y, corner(c_up+(y<4?c_dn:c_rt)), scoreborder,1,0);
		SetChar(20+9,y, corner(c_up+(y<4?c_dn:c_lt)), scoreborder,1,0);
		SetChar(20-3,y, corner(c_up+(y<4?c_dn:c_lt+c_rt)), scoreborder,1,0);
		SetChar(20+3,y, corner(c_up+(y<4?c_dn:c_lt+c_rt)), scoreborder,1,0);
	}
	
	Center(1, scorecolor,0,0, "Score\nLines\nLevel");
}

void DrawGameBorder(void)
{
	int y, x;
	
	Center(20, 7,2,0, "%31s", "");
	Center(21, 7,2,0, "%27s", "");
	
	for(x=0; x<rakepax; x++)
	{
		SetChar(27-x,23, corner(c_lt+c_rt+c_up), mainborder,2,0);
		SetChar(12+x,23, corner(c_lt+c_rt+c_up), mainborder,2,0);
	}
	for(y=5+x; y<23; y++)
		for(x=0; x<rakepax; x++)
		{
			SetChar(12+x,y, corner(c_up+c_dn), rakennelma,2,0);
			SetChar(27-x,y, corner(c_up+c_dn), rakennelma,2,0);
		}
	for(y=0; y<rakepax; y++)
		for(x=12; x<=27; x++)
		{
			int c = (x<12+y||x>27-y)
				?	c_up+c_dn
				:	(x>12+y?c_lt:c_dn) + (x<27-y?c_rt:c_dn);
			SetChar(x,5+y, corner(c), rakennelma,2,0);
		}
}
