#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <sys/types.h>

#include "music.h"

#ifdef HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>
#endif

#ifdef DRIVER_ESD
#include <esd.h>
#else
/* bits of stream/sample data */
#define ESD_MASK_BITS	( 0x000F )
#define ESD_BITS8 	( 0x0000 )
#define ESD_BITS16	( 0x0001 )
/* how many interleaved channels of data */
#define ESD_MASK_CHAN	( 0x00F0 )
#define ESD_MONO	( 0x0010 )
#define ESD_STEREO	( 0x0020 )
/* whether it's a stream or a sample */
#define ESD_MASK_MODE	( 0x0F00 )
#define ESD_STREAM	( 0x0000 )
/* the function of the stream/sample, and common functions */
#define ESD_MASK_FUNC	( 0xF000 )
#define ESD_PLAY	( 0x1000 )
/* functions for streams only */
#define ESD_RECORD	( 0x2000 )
#endif

#define FMT (ESD_BITS16 | ESD_STEREO | ESD_STREAM | ESD_PLAY)

#include "audio.h"

static int row, rows, loop, xor, count, roll, tempo;

static const by *z;
static by *l=NULL;

static char s1[64], s2[64], s3[4096];

static int esdsock=0, P[12], timer, hz[4], vol[4], dah[4], note[4];

/* For four channels */
static int *CurEffect[4];

const int *CurrentMusa;
const by *CurrentData;

int LoopFlag;

static int Bits, d;
static int Get(int n){int k=1<<n,result;while(k>Bits)d+=Bits*(by)((*z
++^xor)-roll),Bits*=count;result=d&(k-1);d/=k,Bits/=k;return result;}

static void Uncompress(void)
{
	register int c,a,S,i;
	
	int compr,depf,len;
	
	z = CurrentData;
	if(!z)return;
	
	rows= CurrentMusa[1];
	loop= CurrentMusa[2];
	xor = CurrentMusa[3];
	compr=CurrentMusa[4];
	depf= CurrentMusa[5];
	len = CurrentMusa[6];
	count=CurrentMusa[7];
	roll =CurrentMusa[8];
	tempo=CurrentMusa[9];
	
	StartSilence();
	
	l = (by *)malloc(rows*8);
	
	if(!l)
	{
		DoneMusa();
		return;
	}
	
    for(Bits=1,c=4;c--;)
    	for(a=0;a<rows;)
    		if((S=Get(7)) != compr)
            	l[c+8*a+4]=S,
            	l[c+8*a++]=Get(6)^63;
            else
            	for(i=Get(depf),S=Get(len);S--;a++)
					l[a*8+4+c]=l[(a-i)*8+4+c],
					l[a*8+c]  =l[(a-i)*8+c];
}

void InitMusa(const int *mptr, const by *data)
{
	CurrentMusa = mptr;
	CurrentData = data;
	
	Uncompress();
	
	if(esdsock <= 0)
	{
		#ifdef ARCH_esd_audio_open
		
		/* This is a stupid hack because esd uses perror() */
		int bup_stderr = dup(fileno(stderr)); 
		int nul = dup2(open("/dev/null",O_WRONLY), fileno(stderr));
		
		esdsock = esd_audio_open();
			
		dup2(bup_stderr, fileno(stderr));
		close(nul);
	}
	if(esdsock < 0)
	{
		#endif	/* ARCH_esd_audio_open */
		DoneMusa();
		return;
	}
	
	row=0;
	timer=0;
	
	LoopFlag=0;
}

void SaveMusic(struct MusicSave *bup)
{
	bup->mptr = CurrentMusa;
	bup->data = CurrentData;
	bup->row  = row;
	bup->timer= timer;
}

void RestoreMusic(const struct MusicSave *bup)
{
	CurrentMusa = bup->mptr;
	CurrentData = bup->data;
	row         = bup->row;
	timer       = bup->timer;
	
	Uncompress();
}

/* This function also initializes   *
 * the pitch table and the samples. */
void StartSilence(void)
{
	int a;
	
	for(a=4; a--; vol[a]=hz[a]=dah[a]=note[a]=0);
	
	/* One octave */
	for(P[a=0]=1300; ++a<12; P[a]=P[a-1]*89/84);
	
	/* Square, triangle */
	for(a=0; a<64; a++)
	{
		/* Notice: s1 and s2 must be 64 bytes long */
		s1[a] = a<16 ? -40 : 40;
		s2[a] = (a<32 ? a : (63-a))*4 - 64;	/* 31*4=124; -64..+60 */
	}
	
	/* Noise */
	for(a=sizeof(s3); a--; s3[a] = rand() % 80 - 40);
	
	if(l)
	{
		free(l);
		l = NULL;
	}
}

/* effect format:
 *
 * [0] = channel id
 * [1] = tempo
 * [2], [3] = zero (temp)
 * [4] = length in cycles
 * [5].. data in format: note,volume; ...
 */
void PlayEff(int *eff)
{
	/* Make no division errors */
	if(!eff[EFF_TEMPO])return;
	
	CurEffect[eff[EFF_CHID]] = eff;
	CurEffect[eff[EFF_CHID]][EFF_TIMER] = 0;
	CurEffect[eff[EFF_CHID]][EFF_LINE]  = -1;
}

void TickMusa(int numticks)
{
	#ifdef DRIVER_MIDI
	static int oldnote[4];
	/* Patch (42=cello, 68=oboe, 73=flute, 118=synthdrm, 80=square) */
	static int patch[4] = {MIDI_PATCH};
	static int maxvol[4]= {MIDI_MAXVOL};
	static int inc[4]   = {MIDI_NOTEADD};
	#endif
							
	if(esdsock < 0)
	{
		usleep(1000000*numticks/MAINRATE);
		return;
	}
	
	while(numticks)
	{
		#if !(defined(DRIVER_MIDI) || defined(DRIVER_ADLIB))
		short Buf[2*RATE/MAINRATE];	
		int b=0;
		#endif
		
		int a, c;
		
		for(a=RATE/MAINRATE; a--; )
		{
			#if !(defined(DRIVER_MIDI) || defined(DRIVER_ADLIB))
			int L, R;
			#endif
			
			if(l)
			{
				if(!timer)
				{
					/* Song has four channels */
					for(c=4; c--; )
					{
						int x = note[c] = l[c+row*8+4];
						vol[c] =l[c+row*8];
						hz[c] = P[x%12] << x/12;
					}
					
					if(++row >= rows)
					{
						row=loop;
						LoopFlag=1;
					}
					
					timer = RATE * 5 / tempo;
				}
			
				timer--;
			}
			
			/* Allow four simultaneous sound effects,   *
			 * if they are on different sound channels. */
			for(c=4; c--; )
			{
				int *eff = CurEffect[c];
				
				/* Effect available? */
				if(eff)
				{
					/* Need update? */
					if(!eff[EFF_TIMER])
					{
						int x;
						
						eff[EFF_LINE]++;
						
						/* Finished? */
						if(eff[EFF_LINE] >= eff[EFF_LEN])
						{
							/* Shut down the effect */
							vol[c] = 0;
							
							/* No free() call here. The effect was given *
							 * by parameter, it was not allocated.       */
							CurEffect[c] = eff = NULL;
							
							continue;
						}
						
						eff[EFF_TIMER] = RATE * 5 / eff[EFF_TEMPO];
						
						x = eff[EFF_NOTE] = eff[EFF_LINE1 + eff[EFF_LINE]*2];
					
						/* Update */
						eff[EFF_VOL]= eff[EFF_LINE1 + eff[EFF_LINE]*2 + 1];
						eff[EFF_HZ] = P[x%12] << x/12;						
					}
				}
				
				if(eff)
				{
					eff[EFF_TIMER]--;
					/* Submit */
					vol[c] = eff[EFF_VOL];
					note[c]= eff[EFF_NOTE];
					hz[c]  = eff[EFF_HZ];
				}
			}
			
			#if !(defined(DRIVER_MIDI) || defined(DRIVER_ADLIB))
			R = (s1[((dah[1]+=hz[1])/RATE) % sizeof(s1)]) * vol[1]+
			  + (s2[((dah[2]+=hz[2])/RATE) % sizeof(s2)]) * vol[2];
			
			L = (s1[((dah[0]+=hz[0])/RATE) % sizeof(s1)]) * vol[0]+
			  + (s3[((dah[3]+=hz[3])/RATE) % sizeof(s3)]) * vol[3];
			
			Buf[b++] = L - R/3;
			Buf[b++] = R - L/3;
			#endif
		}
		
		#if defined(DRIVER_MIDI)
		
		for(a=4; a--; )
		{
			if(oldnote[a] != note[a] || a==3)
			{
				write_midi(0x80+a,oldnote[a]+inc[a],127, -1);
				write_midi(0xC0+a, patch[a]-1, -1);
			}
				
			write_midi(0xB0+a,7,vol[a]*maxvol[a]/64, -1);
			
			if(oldnote[a] != note[a] || a==3)
			{
				write_midi(0x90+a,note[a]+inc[a],127, -1);
				oldnote[a]=note[a];
		}	}
		
		#else
		
		esd_audio_write(&Buf, b*(sizeof(Buf[0])));
	/*	esd_audio_flush(); */
		
		#endif
		
		#if NOTWAVE		
		usleep(1000000/MAINRATE);		
		#endif
		
		numticks--;
	}
}

void DoneMusa(void)
{
	int c;
	/* Finish (clear) any possible sound effects */
	for(c=4; c--; CurEffect[c]=NULL);
	
	if(esdsock > 0)
	{
		esd_audio_close();
		esdsock = -1;
	}
	StartSilence();
}
