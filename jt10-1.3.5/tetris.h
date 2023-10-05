#ifndef __tetris_h
#define __tetris_h

#include "music.h"

#define WIPESPEED 50

#define MAXLEVEL  13	/* At maxlevel, the blocks drop without any delay */

/* All the states here must be negative, except S_GAME,      *
 * which is 0. Also, S_MBLOCK must be S_INIT+1 and S_GAME-1. */
 
#define S_WIPE   -32767

#define S_PAUSE  -5			/* Pause                   */
#define S_DROP   -4			/* Dropping block          */
#define S_OVER   -3			/* Game over               */
#define S_INIT   -2			/* Just started            */
#define S_MBLOCK -1			/* Need to make new block  */
#define S_GAME    0			/* A block is falling down */


typedef int tetblock[4][4];
typedef struct
{
	int Field[40][40];	/* Allow free field size... */
	int xlev,ylev;		/* Field size               */
	
	int WipeLines[40];
	int WipeCount;
	
	int KbBuf[4], KbBufSize;
	
	int Score;
	int Lines;
	int Level;
	
	int NextColor;
	tetblock NextBlock;
	
	int ThisColor;
	tetblock ThisBlock;
	
	int asento, blnum, nextblnum;
	int blockx, blocky;
	
	int State, SavedState;
	int NeedRefresh;
	
	int dispx,dispy,nextx,statx;
	
	struct computer_t *Computer;
	int NoHumanOpponents;
	int MayMoan;
	int comp_lastbx;
	
	int StackHeight;
	int Idle, CompSpeed;
	
	struct MusicSave gameovermusicsave;
} tetris_t;

/*** Computer player settings ***/
typedef struct computer_t
{
	char Name[5];
	char *Description;  /* readonly? */
	
	int Editable;
	char *Author;       /* readonly? */
	
	/* If the computer players use the stackheight,
	 * their playing may look very funny and unsure
	 * and they may actually play worse than they
	 * could. Enable it. :)
	 */
	int UseStackHeight;
	
	/* Make unneeded moves, crash the walls */
	int Noisy;
	
	/* COMP_KEYDOWN is the key code which the computer
	 * players use to drop the block down. Using KEY_DROP
	 * is possible, but discouraged: They need to be able
	 * to slide the blocks at the last moment to little
	 * holes. Let this be KEY_DOWN.
	 */
	int KeyDown;
	
	/* Computer dropping speed when playing against human */
	int InitSpeed;
	
	/* SKY_LIMIT defines the line which above
	 * the blocks should never be placed.
	 */ 
	int SkyLimit;
	int SkyPunishment;
	
	/* SKY_BONUS is the multiplication factor
	 * which is used if SKY_LIMIT is not reached.
	 * It can as well be 0, but not negative.
	 * Very big values should not be used, because
	 * too big values override the other bonuses.
	 */
	int SkyBonus;
	
	/* Each of these four bonuses should be divisable with 12.
	 * If one is set to 0, the corresponding bonus calculation
	 * is not done.
	 */
	int LeftBonus, RightBonus, DownBonus, TopBonus;	
	
	/* The same bonuses, but comparing to the block itself */
	int LeftBonus2, RightBonus2, DownBonus2, TopBonus2;
	
	/* Multiplied by the number of holes *
	 * the block would leave below it    *
	 * *under surface*                   */
	/* Note that nonzero holepunish may  *
	 * cause significant speed decrease  *
	 * to game...                        */
	int HolePunishment;
	
	struct computer_t *next;
} computer_t;
extern computer_t *Human;

extern void InitTetris(tetris_t *tet,
	int lev,int hc,
	int x,int y,
	int nx,int sx,
	int xlev,int ylev,
	struct computer_t *Computer);
extern void KillTetris(tetris_t *tet);
extern void TickTetris(tetris_t *tet, int numticks);

/* Key values for GrantKey() - value 0 not allowed. */
#define KEY_LT		1
#define KEY_RT		2
#define KEY_DOWN	3
#define KEY_TURN1	4
#define KEY_TURN2	5
#define KEY_DROP	6
#define KEY_PAUSE	7

/* Control */
extern void GrantKey(tetris_t *tet, int key);

#endif	/* __tetris_h defined */
