#ifndef __tet_music_h
#define __tet_music_h

#include "config.h"

#define NOTWAVE (defined(DRIVER_MIDI)||defined(DRIVER_ADLIB))

/* 1=Melody has looped at least once */
extern int LoopFlag;
extern const int *CurrentMusa;

typedef unsigned char by;

#define StartMusa(x) InitMusa(music_##x, music_##x##_Data)

#define IsPlaying(x) (CurrentMusa == music_##x)

/* Values between 25..100 seem to work,   *
 * but the less the value is, the poorer  *
 * is the response rate of the program... */
#define MAINRATE 100

#define SECONDS *MAINRATE

extern void StartSilence(void);
extern void InitMusa(const int *mptr, const unsigned char *data);
extern void TickMusa(int numticks);
extern void DoneMusa(void);

struct MusicSave
{
	const int *mptr;
	const by *data;
	int row, timer;	
};
extern void SaveMusic(struct MusicSave *bup);
extern void RestoreMusic(const struct MusicSave *bup);

/* For effect format, see macroes BEGIN_EFFECT and END_EFFECT.
 * Data is in format: note,volume; ...
 */
extern void PlayEff(int *eff);

/* Effect structure */
#define EFF_CHID  0
#define EFF_TEMPO 1
#define EFF_TIMER 2 /* internal */
#define EFF_LINE  3 /*   -"-    */
#define EFF_VOL   4 /*   -"-    */
#define EFF_HZ    5 /*   -"-    */
#define EFF_NOTE  6 /*   -"-    */
#define EFF_LEN   7
#define EFF_LINE1 8

/* Macroes for creating effects */
#define CHANNEL
#define TEMPO
#define LENGTH
#define BEGIN_EFFECT(name, chn, tempo, length) \
	static int name[length*2+EFF_LINE1] = {chn, tempo, 0,0,0,0,0, length,
#define END_EFFECT }

#endif /* __tet_music_h */
