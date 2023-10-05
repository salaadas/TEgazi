#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <math.h>

/*******************************************************************/
/* globals */
int esd_audio_format = FMT;
int esd_audio_rate = RATE;

/* the audio device, /dev/dsp, file descriptor */
static int esd_audio_fd = -1;

#if 1
/* debugging messages for audio devices */
static int driver_trace = 0;
#endif

/*******************************************************************/
/* returns audio_fd for use by main prog - platform dependent */

#if defined(DRIVER_ADLIB)
 #include "audio_x86adlib.c"
#elif defined(DRIVER_MIDI)
 #include "audio_ossmidi.c"
#else
 #ifdef DRIVER_ESD
  #include "audio_esd.c"
 #else
  /* ALSA before OSS as ALSA is OSS compatible */
  #if defined(DRIVER_ALSA) || defined(DRIVER_NEWALSA) 
   #include "audio_alsa.c"
  #elif defined(DRIVER_OSS)
   #include "audio_oss.c"
  #elif defined(DRIVER_AIX)
   #include "audio_aix.c"
  #elif defined(DRIVER_IRIX)
   #include "audio_irix.c"
  #elif defined(DRIVER_HPUX)
   #include "audio_hpux.c"
  #elif defined(DRIVER_SOLARIS)
   #include "audio_solaris.c"
  #elif defined(DRIVER_MKLINUX)
   #include "audio_mklinux.c"
  #elif defined(DRIVER_STDERR)
   #include "audio_stderr.c"
  #else
   #include "audio_none.c"
  #endif
 #endif
#endif

/*******************************************************************/
/* close the audio device */
#ifndef ARCH_esd_audio_close
void esd_audio_close(void)
{
    close( esd_audio_fd );
}
#endif
/*******************************************************************/
/* make the sound device quiet for a while */
#ifndef ARCH_esd_audio_pause
void esd_audio_pause(void)
{
}
#endif

#ifndef ARCH_esd_audio_write
/*******************************************************************/
/* dump a buffer to the sound device */
int esd_audio_write( void *buffer, int buf_size )
{
    return write( esd_audio_fd, buffer, buf_size );
}
#endif

#ifndef ARCH_esd_audio_flush
/*******************************************************************/
/* flush the audio buffer */
void esd_audio_flush(void)
{
    fsync( esd_audio_fd );
}
#endif
#ifndef ARCH_write_midi
/*******************************************************************/
/* write midi data */
void write_midi(int data, ...)
{
	data=data;
}
#endif
