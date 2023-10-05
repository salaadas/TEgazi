/*
 * For stderr audio
 */

#define ARCH_esd_audio_open
int esd_audio_open()
{
	return(esd_audio_fd = fileno(stderr));
}