#include <stdarg.h>

#ifdef HAVE_SYS_IO_H
 #include <sys/io.h>
#endif

static __inline__ unsigned char inportb(const unsigned short port)
{
	register unsigned char _v;
	__asm__ volatile ("inb %1,%0" :"=a" (_v) :"d" ((unsigned short)port));
	return _v;
}

static __inline__ void outportb(const unsigned short port,
                                const unsigned char value)
{
	__asm__ volatile ("outb %0,%1"
             ::"a" ((char) value),
               "d" ((unsigned short)port));
}

static int OPLBase = 0x388;
static void OPL_Byte(unsigned char Index, unsigned char Data)
{
	register int a;
	outportb(OPLBase, Index);  for(a=0; a<6;  a++)inportb(OPLBase);
	outportb(OPLBase+1, Data); for(a=0; a<35; a++)inportb(OPLBase);
}

#define ARCH_esd_audio_open
int esd_audio_open(void)
{
	int st1, st2, a;
	
	if(ioperm(0x388, 4, 1) < 0)
		return -1;

	for(a=0; a<244; OPL_Byte(a++, 0));
	
	OPL_Byte(4, 0x60);
	OPL_Byte(4, 0x80);
	st1 = inportb(OPLBase)&0xE0;
	OPL_Byte(2, 0xFF);
	OPL_Byte(4, 0x21);
	usleep(80);
	st2 = inportb(OPLBase)&0xE0;
	OPL_Byte(4, 0x60);
	OPL_Byte(4, 0x80);
	
	return (esd_audio_fd = ((st1==0)&&(st2==0xC0)) ? 1 : -1);
}

#define ARCH_esd_audio_close
void esd_audio_close(void)
{
	if(esd_audio_fd >= 0)
	{
		int a;
		for(a=0; a<244; OPL_Byte(a++, 0));
	}
} 

#define ARCH_write_midi
void write_midi(int byte, ...)
{
	va_list ap;

	if(esd_audio_fd < 0)return;
	
	va_start(ap, byte);
	
	for(; byte>=0; )
	{
		byte = va_arg(ap, int);
		if(byte>127)byte=127; 	/* fix volumes */
	}
	
	va_end(ap);
}

#define ARCH_esd_audio_write
int esd_audio_write(void *buffer, int buf_size)
{
	buffer=buffer;
	buf_size=buf_size;
	return 0;
}
