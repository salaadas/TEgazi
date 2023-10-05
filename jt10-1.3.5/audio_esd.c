#include <esd.h>

#define ARCH_esd_audio_open
#define ARCH_esd_audio_close
#define ARCH_esd_audio_pause
#define ARCH_esd_audio_flush
#define ARCH_esd_audio_write
#define ARCH_esd_audio_read

int esd_audio_open(void)
{
	return (esd_audio_fd = esd_play_stream_fallback(
			FMT, RATE, "127.0.0.1", NULL));
}
