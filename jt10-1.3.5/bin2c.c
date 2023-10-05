#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

int NoFar=0, Verbose=0;

#if !defined(DJGPP) && !defined(__BORLANDC__)
 #define stricmp strcasecmp
#endif

void convert(char *s, char *DestFile, char *Name)
{
	int a, i, l;
	char Buf2[64];
	FILE *f, *fo;

	if(!((fo = fopen(s, "rb")) != NULL))
	{
		printf("Error %d (%s) opening file %s.\n",
			errno, sys_errlist[errno], s);
		return;
	}

	sprintf(Buf2, "%s.c", DestFile);
	f = fopen(Buf2, "wt");
	fprintf(f,
		"#ifdef __DJ_size_t\n"
		"#define _SIZE_T\n"
		"#endif\n"
        "#ifdef _SIZE_T\t\t/* Kind of bad test, but... :) */\n"
		"extern \n"
        "#endif\n");
    if(!NoFar)
        fprintf(f, "#ifdef __GNUC__\n");
    fprintf(f, "unsigned char %s[]\n", Name);
    if(!NoFar)
        fprintf(f,
            "#else\n"
            "#ifdef __STDC__\n"
            "#define far /* undefined */\n"
            "#endif\n"
            "unsigned char far %s[]\n"
            "#endif\n", Name);
    fprintf(f,
		"#ifndef _SIZE_T\n"
        "=\n{\n");
	rewind(fo);

    fprintf(f, "\t/* bin2c result of %s */\n", s);
    for(l=0, a=fgetc(fo), i=0; ; i++)
	{
		if(i==0)fprintf(f, "\t");

		fprintf(f, "%d", a);
		l += 2;
		if(a>9){l++;if(a>99)l++;}

		a = fgetc(fo);
		if(a == EOF)break;

		fputc(',', f);

		if(l > 246){fprintf(f, "\n");l=0;i=-1;}
	}
	fclose(fo);

	fprintf(f, "\n}\n#endif\n;\n");

	fclose(f);

	printf("Done '%s.c'\n", DestFile);
}

int main(int argc, char **argv)
{
	--argc;

    for(;;)
    {
        char *s = argv[1];
        if(*s != '-')break;

        argc--;
        argv++;

        while(*++s)
            switch(*s)
            {
                case 'v': Verbose=1; break;
                case 'f': NoFar=1; break;
            }
    }

	if(Verbose)
        puts("bin2c Converter Version 1.1 Copyright (C) 1992,1998 Bisqwit\n");

	if(argc != 3)
	{
		puts(
            "Usage:   BIN2C [-vf] <source> <destination> <public_name>\n"
			"\n"
            "Example: BIN2C tmptmp.pcx kuvadata pcxkuva\n"
			"\n"
            "Source is the file you want to convert\n");
		return -1;
	}

    convert(argv[1], argv[2], argv[3]);

	return 0;
}
