#ifndef __tetr_video_h
#define __tetr_video_h

#include "config.h"

#define Random(val) ((int)(((val)-1.0)*rand()/(RAND_MAX+1.0)))
#define Randomize() srand(time(NULL))

#define c_up 1
#define c_lt 2
#define c_rt 4
#define c_dn 8

/* If you change these, you need to change *
 * the constants from video_fb.c as well.  */
#define corner(x) (0xF0-(x))
#define uncorner(x) corner(x)
#define iscorner(x) (((x)>=0xF0-15)&&((x)<=0xF0))

/* Max amount of optimizations done per frame  *
 * This number should not be very big, because *
 * doubling this value at least squares the    *
 * time used by one screen update.             */
/* This only is effectful for io_term.c.       */
#define videospdlimit 0

#ifndef IOdriver
#ifdef __cplusplus
extern "C" {
#endif
extern void InitVideo(void);
/* transp: 0=not transparent - 1=transparent - 2=over nonpermanent also
 *   time: 0=permanent       - other=disappears after this count of ticks
 *     ch: ascii character or corner combination
 *  color: combination of 1=blue, 2=green, 4=red, 8=intense
 */
extern void SetChar(int x, int y, int ch, int color, int transp, int time);
extern void ClrScr(void);
extern void UpdateVideo(int numticks);
extern void DoneVideo(void);
extern void RefreshScreen(void);

extern int kbhit(void);
extern int getch(void);
#ifdef __cplusplus
}
#endif
#endif

typedef struct iodriver
{
	const char *name;
	void (*Init)(void);
	void (*Done)(void);
	/* transp: 0=not transparent - 1=transparent - 2=over nonpermanent also
	 *   time: 0=permanent       - other=disappears after this count of ticks
	 *     ch: ascii character or corner combination
	 *  color: combination of 1=blue, 2=green, 4=red, 8=intense
	 */
	void (*SetChar)(int x, int y, int ch, int color, int transp, int time);
	void (*ClrScr)(void);
	void (*UpdateVideo)(int numticks);
	void (*RefreshScreen)(int);
	
	int (*kbhit)(void);
	int (*getch)(void);

	struct iodriver *next;
} iodriver;

#ifdef __cplusplus
extern "C" {
#endif
extern void InstallDriver(iodriver *, ...);
extern int SelectDriver(const char *);
#ifdef __cplusplus
}
#endif

/* Should these really be here? Hmm... */
extern iodriver vt100;
extern iodriver sdl;
extern iodriver ggi;

#endif	/* __tetr_video_h defined */
