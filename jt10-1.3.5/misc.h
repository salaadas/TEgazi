#ifndef __tetr_main_h
#define __tetr_main_h

/*  misc.h
 *
 *  Definitions (constants) for Joeltris 10
 *
 *  Miscellaneous routines like Center() and SetText()
 *
 *  Decoration routines like DrawGameBorder(),
 *  DrawScoreBorder() and DrawMainBorder().
 *
 */

/* Decrease this if you plan to play *
 * this game under slow terminals    *
 * Default value: 30                 */
#define starcount 20

/* This enables the startup tetris demo if nonzero */
#define enabletetris 1

#define mainborder 0x19
#define rakennelma 0x19	/* (building)              */
#define rakepax    1	/* Thickness of rakennelma */
#define scorecolor 0x0F
#define scoreborder 0x80
#define menucolor 9
#define menuarrow 15
#define nextcolor 4
#define namecolor 5		/* Name of computer player */
#define wipecolor 11
#define pausecolor 12
#define gameovercolor 12
#define clockcolor 8


#ifdef __GNUC__
 #define __tet_at_(x) __attribute__((x))
#else
 #define __tet_at_(x)
#endif

extern void SetText(int x,int y, int c,int tr,int time, const char *fmt, ...)
	__tet_at_(format(printf,6,7));

extern void Center(/*****/int y, int c,int tr,int time, const char *fmt, ...)
	__tet_at_(format(printf,5,6));


extern void DrawMainBorder(void);

extern void DrawScoreBorder(void);

extern void DrawGameBorder(void);


#endif	/* __tetr_main_h defined */
