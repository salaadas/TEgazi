#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include "music.h"
#include "music_mm31.h"

int main(void)
{
	int a;
	fcntl(STDIN_FILENO, F_SETFL, (a=fcntl(STDIN_FILENO,F_GETFL))|O_NONBLOCK);
	
	StartMusa(mm31);
	
	puts(
		"Playing Mega Man 3 theme...\n"
		"Press enter to stop when you know your audio hardware is working allright...");
	while(getchar()==EOF)TickMusa(1);
	
	puts("Closing down");
	
	fcntl(STDIN_FILENO, F_SETFL, a);
	
	DoneMusa();
	
	puts(
	#if NOTWAVE
		""
	#else
		"\n"
		"Disclaimer: I think this proves quite well how good quality of sound\n"
		"            did NES have even though the hardware was quite simple.\n"
	#endif
	);
	
	return 0;
}
