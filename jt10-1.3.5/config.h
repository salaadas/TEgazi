#ifndef __jt10_config_h
#define __jt10_config_h
/* Defines for Joeltris 10 - generated automatically by ./configure */

/* io.c defs:
**    definitions for io_term:
**      Set HIDE_CURSOR to 0, if your terminal does not
**      support hiding cursor, or if you want to debug
**      the io_term module.
**      CLEAR_SCREEN_AT_END and HIDE_CURSOR are
**      only effectful for io_term module.
**      If you are using io_term module and you are
**      using xterm and the colours do not work as they
**      should or if you are going to run the game with
**      any other possible broken terminal with io_term,
**      Set BROKEN_TERM to 1.
**      DEFAULT_IO was selected with ./configure.
*/

#define HIDE_CURSOR 1
#define CLEAR_SCREEN_AT_END 0
#define BROKEN_TERM 0
#define HAVE_SYS_SOUNDCARD_H 
#define HAVE_SYS_ASOUNDLIB_H 
#define HAVE_SYS_IOCTL_H 
#define HAVE_SYS_IO_H 
#define HAVE_TERMIOS_H 
#define HAVE_TERMIO_H 
#define HAVE_LINUX_VT_H 
#define HAVE_LINUX_FB_H 
#define HAVE_GGI_GGI_H 
#define HAVE_SDL_SDL_H 
#define HAVE_ESD_H 
#define HAVE_VSNPRINTF
#undef HAVE_GGI_GGI_H
#define DEFAULT_IO "SDL"

/* sound.c defs:                           
**  Even rate 8000 sounds ok, but higher rates like
**  22kHz are recommended for better realtime audio.
**  Remember to select the correct driver here for
**  your system! For selections, see audio.c.
**  These settings were selected with ./configure.
*/
#define RATE 44100

#undef DRIVER_ALSA
#undef DRIVER_NEWALSA
#undef DRIVER_OSS
#undef DRIVER_AIX
#undef DRIVER_IRIX
#undef DRIVER_HPUX
#undef DRIVER_SOLARIS
#undef DRIVER_MKLINUX
#undef DRIVER_ESD
#undef DRIVER_MIDI
#undef DRIVER_ADLIB

/* This audio module was selected with ./configure */
#define DRIVER_OSS

/* These are the settings for the MIDI implementation.
 * Values are meaningful only of DRIVER_MIDI has been set.
 *
 * The sound system has four channels.
 * These are the default patch, maxvolume and modulation parameters.
 *
 * Examples:
 *   43=cello     69=oboe     74=flute      119=synthdrm
 *   31=gtrdistrt 25=gtrnylon 36=fretlsbass 81=squarewave
 */
#ifdef DRIVER_MIDI
#define MIDI_PATCH    31,25, 36, 119
#define MIDI_MAXVOL  150,170,127,80
#define MIDI_NOTEADD   4,16, 16, 0
#endif

#endif	/* __jt10_config_h defined */
