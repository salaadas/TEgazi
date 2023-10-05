#include <stdarg.h>
#include <string.h>
#include "io.h"

static iodriver *drv;
static iodriver *drivers = NULL;

int xres=0, yres=0;
int vxres=640,vyres=384;

void InitVideo(void)
{
	drv->Init();
}
void SetChar(int x, int y, int ch, int color, int transp, int time)
{
	drv->SetChar(x, y, ch, color, transp, time);
}
void ClrScr(void)
{
	drv->ClrScr();
}
void UpdateVideo(int numticks)
{
	drv->UpdateVideo(numticks);
}
void DoneVideo(void)
{
	drv->Done();
}
void RefreshScreen(void)
{
	drv->RefreshScreen(0);
}

int kbhit(void)
{
	return drv->kbhit();
}

int getch(void)
{
	return drv->getch();
}

void InstallDriver(iodriver *s, ...)
{
	va_list ap;
	va_start(ap, s);
	while(s)
	{
		s->next = drivers;
		drivers = s;
		
		s = va_arg(ap, iodriver *);
	}
	va_end(ap);
}

int SelectDriver(const char *s)
{
	iodriver *p;
	for(p=drivers; p; p=p->next)
		if(!strcmp(p->name, s))
		{
			drv = p;
			return 0;
		}
	return -1;
}
