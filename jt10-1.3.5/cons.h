#ifndef _bisq_Cons_h
#define _bisq_Cons_h

#include <stdlib.h> /* For rand(), srand() */
#include <time.h>   /* For time()          */

#ifdef __cplusplus
extern "C" {
#endif

extern void DoneCons(void);
extern void InitCons(void);
extern void GetWinSize(void);	/* Refreshes the LINES and COLS variables */

#ifdef __cplusplus
}
#endif

extern int COLS, LINES;

#endif	/* _bisq_Cons_h defined */
