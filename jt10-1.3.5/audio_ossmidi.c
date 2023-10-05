#include <stdarg.h>

#define SEQUENCER_DEV "/dev/sequencer"

#ifdef HAVE_MACHINE_SOUNDCARD_H
#  include <machine/soundcard.h>
#else
#  ifdef HAVE_SOUNDCARD_H
#    include <soundcard.h>
#  else
#    include <sys/soundcard.h>
#  endif
#endif

SEQ_DEFINEBUF(128);

/* defined extern in soundcard.h, may not be static */
void seqbuf_dump(void)
{
	if(_seqbufptr && esd_audio_fd > 0)
	{
		write(esd_audio_fd, _seqbuf, _seqbufptr);
		_seqbufptr = 0;
	}
}

#define ARCH_esd_audio_open
int esd_audio_open(void)
{
	return (esd_audio_fd = open(SEQUENCER_DEV, O_RDWR, 0));
}

#define ARCH_write_midi
void write_midi(int byte, ...)
{
	va_list ap;

	if(esd_audio_fd < 0)return;
	
	va_start(ap, byte);
	
	for(; byte>=0; )
	{
		SEQ_MIDIOUT(1, byte);
		byte = va_arg(ap, int);
		if(byte>127)byte=127; 	/* fix volumes */
	}
	
	SEQ_DUMPBUF();
	
	va_end(ap);
}

#define ARCH_esd_audio_write
int esd_audio_write(void *buffer, int buf_size)
{
	buffer=buffer;
	buf_size=buf_size;
	return 0;
}
