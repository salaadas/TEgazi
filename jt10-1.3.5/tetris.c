#include <stdlib.h>

#include "music_teto.h"
#include "tetris.h"
#include "io.h"
#include "music.h"
#include "misc.h"

static computer_t human =
{
	/* This is a fake computer player for human players */
	"NEXT",
	NULL,
	0,				/* Editable                        */
	"Bisqwit",		/* Author                          */
	0,				/* UseStackHeight                  */
	1,				/* Noisy                           */
	KEY_DOWN,		/* KeyDown                         */
	0.2 SECONDS,	/* InitSpeed                       */
	0, 0, 0,   		/* SkyLimit, -Punishment and Bonus */
	0, 0, 0, 0, 	/* Bonuses: Left,right,down,top    */
	0, 0, 0, 0,		/* The same for block itself       */
	0,              /* HolePunishment                  */
	NULL			/* "next"                          */
};
computer_t *Human = &human;

/* There IS a reason for that the blocks are here, static */
static const char Blocks[7][20][4] =
{
	{
		"XXXX", " X  ", "XXXX", " X  ",	"XXXX",   /* 4C */
		"    ", " X  ", "    ", " X  ", "    ",
		"    ", " X  ", "    ", " X  ", "    ",
		"    ", " X  ", "    ", " X  ", "    "
	},
	{
		"XX  ", "XX  ", "XX  ", "XX  ", "  XX",   /* 39 */
		"XX  ", "XX  ", "XX  ", "XX  ", "  XX",
		"    ", "    ", "    ", "    ", "    ",
		"    ", "    ", "    ", "    ", "    "
	},
	{
		" XX ", "X   ", " XX ", "X   ", "  XX",   /* 28 */
		"XX  ", "XX  ", "XX  ", "XX  ", " XX ",
		"    ", " X  ", "    ", " X  ", "    ",
		"    ", "    ", "    ", "    ", "    "
	},
	{
		"XX  ", " X  ", "XX  ", " X  ", " XX ",   /* 31 */
		" XX ", "XX  ", " XX ", "XX  ", "  XX",
		"    ", "X   ", "    ", "X   ", "    ",
		"    ", "    ", "    ", "    ", "    "
	},
	{
		" X  ", "X   ", "XX  ", "XXX ", "   X",   /* 6E */
		" X  ", "XXX ", "X   ", "  X ", "   X",
		"XX  ", "    ", "X   ", "    ", "  XX",
		"    ", "    ", "    ", "    ", "    "
	},
	{
		"X   ", "XXX ", "XX  ", "  X ", "  X ",   /* 5D */
		"X   ", "X   ", " X  ", "XXX ", "  X ",
		"XX  ", "    ", " X  ", "    ", "  XX",
		"    ", "    ", "    ", "    ", "    "
	},
	{
		"X   ", "XXX ", " X  ", " X  ", "  X ",   /* 62 */
		"XX  ", " X  ", "XX  ", "XXX ", "  XX",
		"X   ", "    ", " X  ", "    ", "  X ",
		"    ", "    ", "    ", "    ", "    "
	}
};

/* Hack. There may no be blocks of color "scoreborder". */
static const int BlockColor[7] = {0x4C, 0x39, 0x28, 0x31, 0x6E, 0x5D, 0x62};

static int LevelColor(int lev)
{
	static const int C[] =
			{0x78, 0x4C, 0x62, 0x31, 0x6C, 0x5D, 0x23, 0x3B, 0x51, 0x24};
			/* Remember, no blinking backgrounds!      */
	return C[lev % 10];
}

static void CleanBuffer(tetris_t *tet)
{
	tet->KbBufSize = 0;
}
static void Bufferoi(tetris_t *tet, int key)
{
	if(tet->KbBufSize < 4)
		tet->KbBuf[tet->KbBufSize++] = key;
}
static void UnBuffer(tetris_t *tet)
{
	int a = -1;
	
	if(tet->KbBufSize)
	{
		int b;
		a = tet->KbBuf[0];
		tet->KbBufSize--;
		for(b=0; b<tet->KbBufSize; b++)tet->KbBuf[b]=tet->KbBuf[b+1];
	}
	
//	CleanBuffer(tet);
	
	if(a >= 0)GrantKey(tet, a);
}

void InitTetris(tetris_t *tet,
	int lev,int hc,
	int x,int y,
	int nx,int sx,
	int xlev,int ylev,
	struct computer_t *Computer)
{
	tet->Score = 0;
	tet->Lines = 0;
	tet->Level = lev;
	tet->dispx = x;
	tet->dispy = y;
	tet->nextx = nx;
	tet->statx = sx;
	tet->Computer = Computer ? Computer : Human;
	tet->NoHumanOpponents = 0;
	tet->MayMoan = 0;
	tet->Idle  = 0;
	tet->CompSpeed = tet->Computer->InitSpeed;
	tet->StackHeight=0;
	tet->xlev = xlev;
	tet->ylev = ylev;
	
	CleanBuffer(tet);
	
	for(y=ylev; y--; )
	{
		int hole = rand()%xlev;
		for(x=xlev; x--; )
			tet->Field[y][x] = 
				(y >= (ylev-hc)) && (x!=hole)
					?	corner(0)
					:	' ';
	}
		
	tet->State = S_INIT;
}
void KillTetris(tetris_t *tet)
{
	/* What should this do? */
	tet=tet;
}

/*
c c# d d# e f f# g g# a a# b
0 1  2 3  4 5 6  7 8  9 10 11
*/

BEGIN_EFFECT(eff_pause1, CHANNEL 1, TEMPO 200, LENGTH 23)
	68,64, 68,55, 68,50, 68,48,
	65,64, 65,55, 65,50, 65,48,
	68,64, 68,55, 68,50, 69,48,
	65,64, 65,55, 65,50, 65,48,
	65,45, 65,40, 65,35, 65,30,	
	64,25, 63,23, 62,21
END_EFFECT;

BEGIN_EFFECT(eff_pause2, CHANNEL 1, TEMPO 200, LENGTH 23)
	68,64, 68,55, 68,50, 68,48,
	65,64, 65,55, 65,50, 65,48,
	68,64, 68,55, 68,50, 69,48,
	65,64, 65,55, 65,50, 65,48,
	65,45, 65,40, 65,35, 65,30,	
	66,25, 67,23, 68,21
END_EFFECT;

BEGIN_EFFECT(eff_advancelevel, CHANNEL 0, TEMPO 100, LENGTH 24)
	30,64, 30,50, 34,64, 34,50, 37,64, 37,50, 42,64, 42,50,	
	30,64, 30,50, 34,64, 34,50, 37,64, 37,50, 42,64, 42,50,	
	30,64, 30,50, 34,64, 34,50, 37,64, 37,50, 42,64, 42,50
END_EFFECT;

BEGIN_EFFECT(eff_wipe, CHANNEL 1, TEMPO 500, LENGTH 34)
	40,64, 40,50, 44,64, 44,50, 47,64, 47,50, 52,64, 52,50,	
	43,64, 43,50, 47,64, 47,50, 50,64, 50,50, 55,64, 55,50,	
	47,64, 47,50, 51,64, 51,50, 54,64, 54,50, 58,64, 58,50,
	52,64, 52,50, 56,64, 56,50, 59,64, 59,50, 64,64, 64,40, 64,30, 64,20
END_EFFECT;

BEGIN_EFFECT(eff_ground, CHANNEL 3, TEMPO 400, LENGTH 6)
	40, 64,
	24, 60,
	19, 55,
	14, 50,
	10, 40,
	 7, 20
END_EFFECT;

BEGIN_EFFECT(eff_hit1, CHANNEL 2, TEMPO 200, LENGTH 6)
	35, 50,
	30, 10,
	22, 40,
	17, 10,
	15, 30,
	12, 10,
END_EFFECT;

BEGIN_EFFECT(eff_hit2, CHANNEL 3, TEMPO 200, LENGTH 5)
	30, 30,
	25, 20,
	22, 15,
	18, 8,
	10, 4
END_EFFECT;

static void CopyBlock(int blnum,int asento, tetblock *bl)
{
	int x, y;
	
	for(y=4; y--; )
		for(x=4; x--; )
			(*bl)[y][x] = Blocks[blnum][y*5+asento][x];
			
	for(y=4; y--; )
		for(x=4; x--; )
		{
			int c=0;
			
			if(x>0)if((*bl)[y][x-1]!=' ')c|=c_lt;
			if(x<3)if((*bl)[y][x+1]!=' ')c|=c_rt;
			if(y>0)if((*bl)[y-1][x]!=' ')c|=c_up;
			if(y<3)if((*bl)[y+1][x]!=' ')c|=c_dn;
			
			(*bl)[y][x] = (*bl)[y][x]!=' '?corner(c):' ';
		}
}

/* Return value:
 *     0 = Block can't be moved there
 * other = Score for computer players
 */
static int LeftWindow;
static int BlockOk(tetris_t *tet, int bx, int by)
{
	int x, y;
	char Mask[4] = {0,0,0,0};
	
	/* Areas */
	int left=0;
	int leftop=4;
	int down=0;
	int top=0;
	int right=0;
	int rightop=4;
	int score=0;
	
	for(y=4; y--; )
		for(x=4; x--; )
		{
			int nx, ny;
			
			if(tet->ThisBlock[y][x] == ' ')continue;
			
			nx = bx+x;
			ny = by+y;
			
			Mask[x]++;
			
			if(nx<0 || nx>=tet->xlev || ny>=tet->ylev)
			{
				/* No, not ok */
				goto Exit;
			}
			
			if(ny<0)continue;
			
			if(tet->Field[ny][nx] != ' ')goto Exit;
			
			if(x==0 || tet->ThisBlock[y][x-1] == ' ')left++;
			if(x==3 || tet->ThisBlock[y][x+1] == ' ')right++;
			if(y==3 || tet->ThisBlock[y+1][x] == ' ')down++;
			if(y==0 || tet->ThisBlock[y-1][x] == ' ')top++;
		}
		
	/* Over anything, avoid placing the blocks too high */
	score = by * tet->Computer->SkyBonus;
	if(by < tet->Computer->SkyLimit)score += tet->Computer->SkyPunishment;
	
	LeftWindow=0;
	
	if(tet->Computer->HolePunishment)
	{
		int space=0;
		for(x=4; x--; )
		{
			register int nx=bx+x;
			register int ny;
			int spa;
			if(!Mask[x] || nx<0 || nx>=tet->xlev)continue;
			for(y=4; y--; )
				if(tet->ThisBlock[y][x] != ' ')break;
			ny = by+y+1;
			spa = 0;
			while(ny<tet->ylev && tet->Field[ny][nx]==' ')ny++, spa++;
			if(spa > space)space = spa;
		}
		
		for(x=4; x--; )
		{
			register int nx=bx+x;
			register int ny;
			if(!Mask[x] || nx<0 || nx>=tet->xlev)continue;
			for(y=4; y--; )
				if(tet->ThisBlock[y][x] != ' ')break;
			ny = by+y+1 + space;
			while(ny<tet->ylev)
			{
				if(tet->Field[ny][nx]==' ')
					score += tet->Computer->HolePunishment * Mask[x];
				ny++;
			}					
		}
	}
	
	/* Ok, now calculate the score */
	for(y=4; y--; )
		for(x=4; x--; )
		{
			register int nx, ny;
			
			if(tet->ThisBlock[y][x] == ' ')continue;
			
			ny = by+y;
			
			if(ny < 0)continue;
			
			nx = bx+x;
			
			if(x==0 || tet->ThisBlock[y][x-1] == ' ')
			{
				if(nx<=0 || tet->Field[ny][nx-1] != ' ')
				{
					score += tet->Computer->LeftBonus/left;
					if(y<leftop)leftop=y;
				}
				else
					if(y>leftop)LeftWindow++;
			}
			else
				score += tet->Computer->LeftBonus2;
			
			if(x==3 || tet->ThisBlock[y][x+1] == ' ')
			{
				if(nx>=tet->xlev || tet->Field[ny][nx+1] != ' ')
				{
					score += tet->Computer->RightBonus/right;
					if(y<rightop)rightop=y;
				}
				else
					if(y>rightop)LeftWindow++;
			}
			else
				score += tet->Computer->RightBonus2;
				
			if(y==3 || tet->ThisBlock[y+1][x] == ' ')
			{
				if(ny>=tet->ylev-1 || tet->Field[ny+1][nx] != ' ')
					score += tet->Computer->DownBonus/down;
				else
					LeftWindow++;
			}
			else
				score += tet->Computer->DownBonus2;
				
			if(y==0 || tet->ThisBlock[y-1][x] == ' ')
			{
				if(ny<=0 || tet->Field[ny-1][nx] != ' ')
					score += tet->Computer->TopBonus/top;
			}
			else 
				score += tet->Computer->TopBonus2;
		}
		
	if(!score)score=1; /* Avoid "can't pass" flag */
	
Exit:
	return score;
}

static void FieldChar(tetris_t *tet, int x, int y, int ch, int color, int transp, int time)
{
	if(tet->nextx == -1)	/* Hack. Introscreen tetris demo. */
	{
		if(iscorner(ch))
		{
			int c = uncorner(ch);
			ch = 0;
			if(c&c_up)ch|=c_rt;
			if(c&c_dn)ch|=c_lt;
			if(c&c_lt)ch|=c_up;
			if(c&c_rt)ch|=c_dn;
			ch = corner(ch);
		}
		SetChar(39-tet->dispy-y, tet->dispx+x, ch,color, 0,0);
	}
	else
		SetChar(tet->dispx+x, tet->dispy+y, ch,color, transp,time);
}

static void Refresh(tetris_t *tet)
{
	int x, y, lc, sx;
	int dx=tet->dispx, dy=tet->dispy;
	int bx=tet->blockx, by=tet->blocky;
	int tc=tet->ThisColor, nc=tet->NextColor;
	int xle=tet->xlev;
	
	sx = tet->statx;
	
	if(sx >= 0)
	{
		SetText(
			sx, 2, scorecolor,1,0,
			tet->statx>20?"%-5d\n%-5d":"%5d\n%5d",
			tet->Lines,
			tet->Level);
			
		if(sx<20 && tet->Score>99999)sx--;
		
		SetText(sx, 1, scorecolor,1,0, tet->statx>20?"%-5d":"%5d", tet->Score);
	}
		
	if(tet->State == S_PAUSE)
	{
		for(y=-3; y<tet->ylev; y++)
			for(x=xle; x--; )
					SetChar(dx+x, dy+y, ' ', 7, 0, 0);
					
		SetText(tet->nextx, 1, pausecolor,1,0, "    ");
		SetText(dx+3, dy+(tet->ylev+1)/2, pausecolor,1,0, "PAUSE");
		
		return;
	}
	
	if(tet->nextx >= 0)
	{
		SetText(dx+3, dy+(tet->ylev+1)/2, pausecolor,1,0, "     ");
	
		SetText(tet->nextx, 1,
			tet->Computer->Description?namecolor:nextcolor,
			1,0, tet->Computer->Name);
	}
		
	lc = LevelColor(tet->Level);
	
	for(y=-3; y<tet->ylev; y++)
		for(x=xle; x--; )
		{
			if(y < 0)
			{
				/* This is magic. Don't ask me. */
				/* 20-(xle-3) and 20+(xle-3)    */
				if(dx+x<23-xle || dx+x>17+xle)
					FieldChar(tet, x, y, '.', 4, 0, 0);
				else
					FieldChar(tet, x, y, ' ', scorecolor, 0, 0);
			}
			else
			{
				register int c = tet->Field[y][x];
				FieldChar(tet, x, y, c, c==' '?7:lc, 0, 0);
			}
		}
			
	for(y=4; y--; )
		for(x=4; x--; )
		{
			if(tet->NextBlock[y][x] != ' ' && tet->Computer == Human)
				if(tet->nextx >= 0)
					SetChar(tet->nextx+x, 2+y, tet->NextBlock[y][x], nc, 0,0);
				
			if(tet->ThisBlock[y][x] != ' ')
				FieldChar(tet, bx+x, by+y, tet->ThisBlock[y][x], tc,0,0);
		}


	if(tet->State == S_OVER)
	{
		SetText(dx, dy+7, gameovercolor,1,0,
			"          \n"
			"   GAME   \n"
			"   OVER   \n"
			"          ");
	}
	if(tet->Computer!=Human && tet->State >= 0)
	{
		int a, x, y, re=0, bx=0, ba=0;
		int sure=0, left,right;
		int top = 1/*(tet->MayMoan && tet->NoHumanOpponents)
		           || !tet->Computer->UseStackHeight*/
					?	256
					:	tet->ylev - tet->StackHeight + tet->ylev/2;
		tetblock temp;

		memcpy(&temp, &tet->ThisBlock, sizeof(temp));
		
/*		SetText(tet->dispx, tet->dispy, 11, 1, 1 SECONDS,
				"%3d", tet->StackHeight);
*/
		
		if(tet->blocky < tet->ylev-tet->StackHeight-6)
		{
			if(tet->blocky > top || tet->NoHumanOpponents)sure=1;
			goto BlahDown;
		}
		
		for(a=0; a<4; a++)
		{
			/* Regenerate it in the rotated form */
			CopyBlock(tet->blnum, a&3, &tet->ThisBlock);
		
			for(y=0; y<=top; y++)
			{
				int okei=0;
				left = -tet->blockx;
				right= xle - tet->blockx - 1;
				
				for(x=0;;)
				{	
					int Ok = BlockOk(tet, tet->blockx+x, tet->blocky+y);
					if(!Ok)
					{
						if(!x){sure=1;}
						/* Poikki, ei voi liikkua enemp‰‰ */
						/*else if(x < 0)left = x;
						else if(x > 0)right = x+1;*/
					}
					okei++;
					if(Ok > re) /* Suurempi pistem‰‰r‰ */
					{
						re=Ok;  /* Pisteet talteen */
						bx=x;   /* Liikesuunta ja -m‰‰r‰ talteen */
						ba=a;   /* Asento talteen */
					}
					if(x <= 0)x--;else x++;
					if(x < left)x=1;
					if(x == right)break;
				}
				if(!okei)break;
			}
		}
		
		memcpy(&tet->ThisBlock, &temp, sizeof(temp));
		
		if(ba == tet->asento)
		{
			if(bx < 0)GrantKey(tet, KEY_LT);
			else if(bx > 0)GrantKey(tet, KEY_RT);
			else if(tet->comp_lastbx)
			{
				/* For a sound effect... */
				if(!BlockOk(tet, tet->blockx+tet->comp_lastbx, tet->blocky) && tet->Computer->Noisy)
					GrantKey(tet, tet->comp_lastbx<0 ? KEY_LT : KEY_RT);
			}			
			tet->comp_lastbx = bx;
		}
		else if(((tet->asento+3)&3) == ba)
			GrantKey(tet, KEY_TURN2);
		else
			GrantKey(tet, KEY_TURN1);
		if(bx || ba!=tet->asento)
			tet->NeedRefresh=1;
		else BlahDown:
		{
			int sure2 = BlockOk(tet, tet->blockx, tet->blocky+1);
			if((tet->NoHumanOpponents || (tet->Idle > tet->CompSpeed))
			&& (sure || (sure2 && !tet->Computer->UseStackHeight)))
				GrantKey(tet, tet->Computer->KeyDown);
		}
	}
}

static void UpdateStackHeight(tetris_t *tet)
{
	int x, y, h;
	register int xl=tet->xlev, yl=tet->ylev;
	
	/* Update stackheight */
	for(h=0, y=yl; y--; h++)
	{
		for(x=0; x<xl; x++)if(tet->Field[y][x] != ' ')break;
		if(x==xl)break;
	}
	/* h = pinon koko */
	tet->StackHeight = h;
}

static void WipeOut(tetris_t *tet)
{
	static const char txt[][6] = 
		{"SINGLE","DOUBLE","TRIPLE","TETRIS"};
	int sx = (tet->State - S_WIPE-6) * WIPESPEED / MAINRATE; /* -6..xlev+7 */
	int x, w=tet->WipeCount-1;
	register int xl=tet->xlev, yl=tet->ylev;
	
	if(w>4)w=4;
	
	for(x=0; x<xl; x++)
	{
		int nx = sx-x, c, y;
		if(nx<0)continue;
		c = (nx>5) ? ' ' : txt[w][5-nx];
		for(y=yl; y--; )
			if(tet->WipeLines[y])
				FieldChar(tet, x, y, c, wipecolor,0,0);
	}
		
	if(sx==tet->xlev+6)
	{
		int y;
		tet->State = S_MBLOCK;
		for(y=0; y<yl; y++)
			if(tet->WipeLines[y])
				for(w=y; w>=0; w--)
					for(x=xl; x--; )
						tet->Field[w][x] = w>0 ? tet->Field[w-1][x] : ' ';
						
		UpdateStackHeight(tet);
	}
	else
		tet->State++;
}

/* This routine also checks the field and updates score */
/* Return value: Score amount added */
static int MaterializeBlock(tetris_t *tet)
{
	int x, y, lc, top=tet->blocky;
	register int xl=tet->xlev, yl=tet->ylev;
	
	for(y=4; y--; )
		for(x=4; x--; )
		{
			int nx = tet->blockx + x;
			int ny = tet->blocky + y;
			
			if(tet->ThisBlock[y][x] == ' ' || ny<0 || nx<0 || nx>=xl || ny>=yl)
				continue;
				
			tet->Field[ny][nx] = tet->ThisBlock[y][x];
		}
	
	lc=0;
	
	for(y=yl; y--; )
	{
		for(x=0; x<xl; x++)if(tet->Field[y][x] == ' ')break;
		
		tet->WipeLines[y] = (x==xl) ? lc++, 1 : 0;
	}
	
	if(top < 0)top=yl; /* Give no score for skyhighs & fix gameovers */
	
	y = (yl-top) * 2;
	
	switch(tet->WipeCount = lc)
	{
		case 0: UpdateStackHeight(tet); break;
		case 1: y += 100; break;
		case 2: y += 400; break;
		case 3: y += 900; break;
		case 4: y += 2500; break;
		#if 0	/* Enable this if it ever happens */
		default:y += 10000; /* miracle */
		#endif
	}
	
	tet->Lines += lc;
	tet->Score += y;
	
	x = tet->Lines / 30;
	if(x > tet->Level)
	{
		tet->Level = x;
		PlayEff(eff_advancelevel);
	}
	
	if(tet->nextx >= 0)
	{
		x = tet->dispx;
		if(x<20)
			x += tet->xlev;
		else
		{
			x -= 2;
			if(y>9)x--;
			if(y>99)x--;
			if(y>999)x--;
			#if 0	/* Enable this if it ever happens */
			if(y>9999)x--;
			#endif
		}
		SetText(x, tet->dispy+top, 11, 1, 1 SECONDS, "%+d", y);
		SetText(x, tet->dispy+top, 11, 1, 1 SECONDS, "%+d", y);
	}
	
	if(lc)
	{
		tet->State = S_WIPE;
		if(tet->nextx >= 0)PlayEff(eff_wipe);
	}
	
	return y;
}

/* Move the block to direction, if possible   */
/* Return value is nonzero if did not succeed */
static int Move(tetris_t *tet, int dx, int dy)
{
	int free_to_move = BlockOk(tet, tet->blockx + dx, tet->blocky + dy);
	
	if(free_to_move)
	{
		tet->NeedRefresh = 1;
				
		tet->blockx += dx;
		tet->blocky += dy;
		
		return 0;
	}
	else if(dx==0 && dy==1)	/* At ground? */
	{
		BlockOk(tet, tet->blockx, tet->blocky);
		
		tet->NeedRefresh = 1;				
		tet->State = S_MBLOCK;
		
		if(MaterializeBlock(tet) <= 0)tet->State = S_OVER;
		
		if(tet->MayMoan && tet->State!=S_WIPE && LeftWindow)
		{
			/* Computers may moan to their human
			 * opponents if they think they left
			 * windows on the field.
			 */			
			SetText(
				tet->dispx+tet->blockx,
				tet->dispy+tet->blocky-1,
				4, 1, 0.5 SECONDS, "damn");
		}
		
		PlayEff(eff_ground);
	}
	else if(tet->nextx >= 0) /* No, hit wall */
	{
		PlayEff(eff_hit1);
		PlayEff(eff_hit2);
	}
	
	return 1;
}

void TickTetris(tetris_t *tet, int numticks)
{
	while(numticks)
	{
		switch(tet->State)
		{
			case S_INIT:
			case S_MBLOCK:
			{
				int b = rand()%7;
				
				tet->gameovermusicsave.mptr = NULL;
				
				tet->blnum = tet->nextblnum;
				tet->asento    = 0;
				
				CopyBlock(tet->blnum,tet->asento, &tet->ThisBlock);
				
				tet->ThisColor = tet->NextColor;
				
				tet->NextColor = BlockColor[b];
				tet->nextblnum = b;
				
				CopyBlock(b,tet->dispx>20?4:0, &tet->NextBlock);
				
				/* Advance to the next state */
				tet->State++;
				
				tet->blockx = 4;
				tet->blocky = -3;
				
				tet->NeedRefresh = 1;
				
				CleanBuffer(tet);
				break;
			}
			case S_OVER:
				if(!IsPlaying(teto) && !tet->gameovermusicsave.mptr)
				{
					SaveMusic(&tet->gameovermusicsave);
					StartMusa(teto);
				}
				if(LoopFlag && IsPlaying(teto) && tet->gameovermusicsave.mptr)
					RestoreMusic(&tet->gameovermusicsave);		
				break;
			case S_PAUSE:
				break;
				
			case S_DROP:
				if(!BlockOk(tet, tet->blockx, tet->blocky+2))
					tet->State = MAINRATE/10;
				/* Pass through to S_GAME */
			case S_GAME: /* 0 */
				/* Move the block one step down */
				Move(tet, 0, 1);
				
				/* If it did not find ground, and not dropping */
				if(tet->State == S_GAME)
				{
					int lev = tet->Level;
					
					if(lev >= MAXLEVEL)lev = MAXLEVEL-1;
					
					/* Make enough idle time */
					tet->State = MAINRATE * (MAXLEVEL - lev) / MAXLEVEL;
					if(!tet->State)
						tet->State=1; /* Don't make the game impossible */
					
					/* Which means, level 0 blocktime is one second,  *
					 *              level MAXLEVEL blocktime is 1,    *
					 *              and the rest are between that.    */
				}
				break;
			default:
				if(tet->State > 0)
				{
					tet->State--;	/* Idle */
					UnBuffer(tet);
				}
				else
					WipeOut(tet);	/* Wipe */
		}
		numticks--;
		tet->Idle++;
	}
	
	if(tet->NeedRefresh ||
	  (tet->Computer!=Human && tet->State>0 && tet->Idle > tet->CompSpeed))
	{
		tet->NeedRefresh=0;
		Refresh(tet);
	}
}

void GrantKey(tetris_t *tet, int key)
{
	int turningway=1;
	
	tet->Idle = 0;
	
	switch(key)
	{
		case KEY_LT:
			if(tet->State > 0)Move(tet, -1, 0);
			else Bufferoi(tet, key);
			break;
		case KEY_RT:
			if(tet->State > 0)Move(tet, 1, 0);
			else Bufferoi(tet, key);
			break;
		case KEY_DOWN:
			if(tet->State > 0)tet->State = S_GAME;
			else Bufferoi(tet, key);
			break;
		case KEY_DROP:
			if(tet->State > 0)tet->State = S_DROP;
			else Bufferoi(tet, key);
			break;
		case KEY_PAUSE:
			tet->NeedRefresh=1;
			if(tet->State == S_PAUSE)
			{
				PlayEff(eff_pause1);
				tet->State = tet->SavedState;
			}
			else
			{
				PlayEff(eff_pause2);
				tet->SavedState = tet->State;
				tet->State = S_PAUSE;
			}
			break;
		case KEY_TURN1:
			goto Turner;
			
		case KEY_TURN2:
			turningway=3;
		Turner:			
			if(tet->State > 0)
			{
				int tests[7] = {0,-1,1,-2,2,-3,3};
				int b = tet->asento, c;
				tetblock temp;
				memcpy(&temp, &tet->ThisBlock, sizeof(temp));
				
				/* Rotate the block */
				tet->asento = (b+turningway)&3;
				
				/* Regenerate it in the rotated form */
				CopyBlock(tet->blnum, tet->asento, &tet->ThisBlock);
				
				/* Todo:
				 * The blocks can accidentally teleport
				 * here through small walls.
				 * But it happens so rarely that only
				 * computer players seem to be able
				 * to notice when it is possible.
				 */			 
				for(c=0; c<7; c++)	/* try all tests */
					if(!Move(tet, tests[c], 0))
						break;
				
				if(c==7)
				{
					/* All tests failed, don't rotate the block. Undo. */
					memcpy(&tet->ThisBlock, &temp, sizeof(temp));
					tet->asento = b;
				}
			}
			else
				Bufferoi(tet, key);
			break;
	}
}
