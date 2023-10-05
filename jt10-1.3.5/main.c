#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <setjmp.h>
#include <time.h>

#include "tetris.h"
#include "io.h"

#include "misc.h"
#include "music.h"

#include "music_cv1d.h"
#include "music_cv2b.h"
#include "music_tet1.h"
#include "music_tet4.h"
#include "music_tetb.h"
#include "music_tetk.h"
#include "music_tetl.h"
#include "music_tett.h"
#include "music_teta.h"
#include "music_tetr.h"
#include "music_teto.h"
#include "music_sols.h"
#include "music_none.h"

static jmp_buf ResetGame;
static tetris_t Game, Game2;

static int Tick(int numticks)
{
    UpdateVideo(numticks);
    TickMusa(numticks);
    return numticks;
}

static int WhichKey(void)
{
    int c = getch();
    if(c=='A'||c=='w'||c=='H')c='';
    if(c=='B'||c=='s'||c=='P')c='';
    if(c=='D'||c=='a'||c=='K')c='';
    if(c=='C'||c=='d'||c=='M')c='';
    if(c=='\r')c='\n';
    return c;
}

static void MusicReactor(int MusicNum)
{
    switch(MusicNum)
    {
        case -2:StartMusa(tet1); break; /* main */
        case -1:break;                  /* enter key */
        case 0:     StartMusa(none); break;
        case 1: StartMusa(tet4); break;
        case 2: StartMusa(cv1d); break;
        case 3: StartMusa(cv2b); break;
        case 4: StartMusa(tetl); break;
        case 5: StartMusa(tetb); break;
        case 6: StartMusa(tetk); break;
        case 7: StartMusa(tett); break;
        case 8: StartMusa(teta); break;
        case 9: StartMusa(tetr); break;
        case 10:StartMusa(sols); break;
    }
}

static computer_t *computers = NULL;

static void LoadComputerFile(void)
{
    FILE *fp;
    char Buf[512];

    /* Here I had strange problems with gcc:

       FILE *fp = fopen...
       computer_t **cptr;
       char Buf[]...
       ...
       fgets(Buf, sizeof(Buf)-1, fp)
       ... returns always NULL even though success
       ... does not detect '\n'. Reads correctly.
    */

    computer_t **cptr;

    fp = fopen("jt10.com", "rt");
    if(!fp)
    {
        perror("jt10.com");
        return;
    }

    while(computers)
    {
        computer_t *c = computers->next;
        free(computers->Description);
        free(computers->Author);
        free(computers);
        computers = c;
    }

    cptr = &computers;

NextCom:

    for(;;)
    {
        if(!fgets(Buf, sizeof(Buf) - 1, fp))
        {
            perror("jt10.com");
            goto Ret;
        }
        if(Buf[0] == '[')break;
    }

    *cptr = (computer_t *)malloc(sizeof(computer_t));
    (*cptr)->next = NULL;
    strncpy((*cptr)->Name, Buf+1, 4);
    (*cptr)->Name[4] = 0;
    (*cptr)->Description = (char *)calloc(40, 3);
    for(;;)
    {
        char *s;
        if(!fgets(Buf, sizeof(Buf) - 1, fp))goto Ret;
        if(Buf[0]=='\n'||Buf[0]==' ')
        {
            cptr = &(*cptr)->next;
            goto NextCom;
        }
        if(Buf[0]=='>')
        {
            strcat((*cptr)->Description, Buf+1);
            continue;
        }
        for(s=Buf;(*s>='A'&&*s<='Z')||*s==' ';s++);
        if(!strncmp(Buf, "EDITABLE", 8))
            (*cptr)->Editable = atoi(s);
        else if(!strncmp(Buf, "PATIENT", 7))
            (*cptr)->UseStackHeight = atoi(s);
        else if(!strncmp(Buf, "NOISY", 5))
            (*cptr)->Noisy = atoi(s);
        else if(!strncmp(Buf, "SKYLIMIT", 8))
            (*cptr)->SkyLimit = atoi(s);
        else if(!strncmp(Buf, "SKYPUNISH", 9))
            (*cptr)->SkyPunishment = atoi(s);
        else if(!strncmp(Buf, "HOLEPUNISH", 10))
            (*cptr)->HolePunishment = atoi(s);
        else if(!strncmp(Buf, "INITSPEED", 9))
            (*cptr)->InitSpeed = atof(s)SECONDS;
        else if(!strncmp(Buf, "KEYDOWN", 7))
        {
            if(!strncmp(s, "DROP", 4))
                (*cptr)->KeyDown = KEY_DROP;
            else
                (*cptr)->KeyDown = KEY_DOWN;
        }
        else if(!strncmp(Buf, "AUTHOR", 6))
        {
            (*cptr)->Author = (char *)calloc(1,strlen(s)); /* there is '\n' */
            strncpy((*cptr)->Author, s, strlen(s)-1);      /* leaves '\0'   */
        }
        else if(!strncmp(Buf, "BONUSES", 7))
        {
            int a;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->SkyBonus=a;
            if(*s==':')s++;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->LeftBonus=a;
            if(*s==':')s++;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->RightBonus=a;
            if(*s==':')s++;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->DownBonus=a;
            if(*s==':')s++;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->TopBonus=a;
        }
        else if(!strncmp(Buf, "BLOCKBONUS", 10))
        {
            int a;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->LeftBonus2=a;
            if(*s==':')s++;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->RightBonus2=a;
            if(*s==':')s++;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->DownBonus2=a;
            if(*s==':')s++;
            for(a=0; *s>='0'&&*s<='9'; a=a*10+*s++-'0'); (*cptr)->TopBonus2=a;
        }
    }

Ret:
    fclose(fp);
}

static int CompCount(void)
{
    int a;
    computer_t *t;
    for(a=0, t=computers; t; a++)t = t->next;
    return a;
}

static computer_t *GetComp(int compnro)
{
    computer_t *t;
    if(compnro < 0)return NULL;
    for(t = computers; compnro>0 && t; compnro--)t = t->next;
    return t;
}

static void CompReactor(int CompNum)
{
    computer_t *tmp = GetComp(CompNum);

    Center(19, menucolor,2,0, "%36s\n%36s\n%36s","","","");

    if(tmp)
        Center(19, menucolor,2,0, tmp->Description);
}

BEGIN_EFFECT(eff_move, CHANNEL 0, TEMPO 400, LENGTH 4)
    50, 50,
    54, 50,
    60, 50,
    74, 50
END_EFFECT;

BEGIN_EFFECT(eff_sel, CHANNEL 0, TEMPO 300, LENGTH 6)
    50, 50,
    47, 45,
    44, 40,
    41, 35,
    38, 30,
    35, 25
END_EFFECT;

/* Reactor args:
 *      -2=quit
 *      -1=affirmated
 *   other=selection no
 */
static int lmenu(void (*Reactor)(int), const char *Title, const char **args)
{
    int x, top=11, a, SelCount, Cur;
    unsigned Ticks, Longest;

    for(Longest=0, x=0, SelCount=0; ; )
    {
        const char *s = args[SelCount++];
        unsigned Len;

        if(x++ > 8)top--;

        if(!s)break;
        Len=strlen(s);
        if(Len > Longest)Longest=Len;
    }

    /* Menu is transparent - good? */
    Center(top-2, menucolor,1,0, Title);

    x = 21 - Longest/2;

    for(SelCount=0;;)
    {
        const char *s = args[SelCount];
        if(!s)break;
        SetText(x, top+SelCount++, menucolor,1,0, "%s", s);
    }

    Cur=0;

Redraw:
    if(Reactor)Reactor(Cur);
    for(a=0; a<SelCount; a++)
    {
        SetChar(x-3, top+a, a==Cur?'-':' ', menuarrow,1,0);
        SetChar(x-2, top+a, a==Cur?'>':' ', menuarrow,1,0);
    }
    for(;;)
    {
        Ticks=0;
        while(!kbhit())
        {
            Tick(1);
            if(++Ticks >= 10 SECONDS)
                longjmp(ResetGame, 1);
        }
        switch(WhichKey())
        {
            case '':
                Cur=(Cur+SelCount-1)%SelCount;
                PlayEff(eff_move);
                goto Redraw;
            case '':
                Cur=(Cur+         1)%SelCount;
                PlayEff(eff_move);
                goto Redraw;
            case '':
            case '':
                PlayEff(eff_move);
                break;
            case 'Q':
            case 'q':
                return -2;
            case '\n':
                PlayEff(eff_sel);
                if(Reactor)Reactor(-1);
                for(a=-2; a<SelCount; a++)
                    SetText(2,top+a, 7,1,0, "%36s", "");
                return Cur;
        }
    }
}
static int vmenu(void (*Reactor)(int), const char *Title, ...)
{
    unsigned argc;
    int a;
    const char **args;
    va_list ap;

    va_start(ap, Title);
    for(argc=1; va_arg(ap, char *) != NULL; argc++);
    va_end(ap);

    args = (const char **)malloc(argc * (sizeof(const char *)));

    va_start(ap, Title);
    for(argc=0; (args[argc]=va_arg(ap, const char *)) != NULL; argc++);
    va_end(ap);

    a = lmenu(Reactor, Title, args);
    free(args);
    return a;
}

static void CtrlC(int dummy)
{
    DoneVideo();
    exit(dummy);
}

/* SEGV/FPE handler */
static void Problem(int dummy)
{
    dummy=dummy;
    DoneVideo();
}

static int GameMode;
static int Handicap;
static int Level;
static int Music;

#define KEYSETUPCOUNT 5
static int KeyMode;

static const char *KeySetups[KEYSETUPCOUNT] =
{
    "rotate1,drop,stepdown",
    "rotate1,rotate2,stepdown",
    "rotate2,rotate1,drop",
    "rotate2,rotate1,stepdown",
    "rotate2,drop,stepdown"
};

static const int Key[KEYSETUPCOUNT][3] =
{
    {KEY_TURN1, KEY_DROP, KEY_DOWN},
    {KEY_TURN1, KEY_TURN2, KEY_DOWN},
    {KEY_TURN2, KEY_TURN1, KEY_DROP},
    {KEY_TURN2, KEY_TURN1, KEY_DOWN},
    {KEY_TURN2, KEY_DROP, KEY_DOWN}
};

/* Return values:
 *   1=Play once more (start from the menus)
 *   0=Do not play, end the program. (Never used)
 */
static int GameLoop(void)
{
    MusicReactor(Music);

    for(;;)
    {
        time_t Time   = time(NULL);
        struct tm *TM = localtime(&Time);
        char md[40];

        strftime(md, sizeof(md)-1, "%A\n %d.%m.%Y ", TM);
        Center(19, clockcolor,1,0, "%9s", "");
        Center(19, clockcolor,1,0, md);
        Center(21, clockcolor,1,0,
            "%2d:%02d:%02d", TM->tm_hour, TM->tm_min, TM->tm_sec);

        if(Game.Computer==Human
        && Game2.Computer==Human)
        {
            Center(8, scorecolor,1,0, "Total score");
            Center(9, scorecolor,1,0, "%d", Game.Score+Game2.Score);
        }

        switch(GameMode)
        {
            case 1:
                if(Game2.State == S_GAME)
                {
                    if(Game2.Score < Game.Score
                    && Game2.CompSpeed > 1)
                        Game2.CompSpeed--;
                    if(Game2.Score > Game.Score
                    && Game2.CompSpeed < 0.5 SECONDS)
                        Game2.CompSpeed++;
                }
                TickTetris(&Game2, 1);
            case 0:
                TickTetris(&Game, 1);
                break;
        }

        while(kbhit())
        {
            int a = WhichKey();

            switch(a)
            {
                case '':
                    a = KEY_LT;
                    break;
                case '':
                    a = KEY_RT;
                    break;
                case '':
                    RefreshScreen();
                    break;
                case '\n':
                case 'p':
                    if(Game.State == S_OVER) return 1;  /* game over */
                    a = KEY_PAUSE;
                    break;
                case '':
                    a = Key[KeyMode][0];
                    break;
                case ' ':
                    a = Key[KeyMode][1];
                    break;
                case '':
                    a = Key[KeyMode][2];
                    break;
                case 'Q':
                case 'q':
                    return 1; /* escape */
                default:
                    /* Do not confuse the game */
                    a=0;
                    break;
            }

            if(a)
            {
                if(Game.Computer == Human)GrantKey(&Game, a);
                if(Game2.Computer == Human)GrantKey(&Game2, a);
            }
        }

        Tick(1);

        if(Game.State == S_OVER)
            Game2.NoHumanOpponents=1;
    }
}

static int SelectIO(const char *drv)
{
    InstallDriver(&ggi, &vt100, &sdl, NULL);
    return SelectDriver(drv);
}

int main(int argc, const char **argv)
{
    int Comp1, Comp2;
    const char *A0 = argv[0], *drv = DEFAULT_IO;

    for(Comp1=0; --argc; )
    {
        extern int xres,yres, vxres,vyres;
        const char *s = *++argv;
        if(*s=='-')
        {
        Usage:
            printf(
                "Usage: %s [(ggi | sdl | vt100) [<xres> <yres> <vxres> <vyres>]]\n"
                "Default io driver: %s\n"
                "Default resolution: auto auto  640 384\n"
                "Read libggi documentation for help on using ggi\n",
                    A0,DEFAULT_IO);
            return 1;
        }
        switch(Comp1++)
        {
            case 0: drv=s; break;
            case 1: xres=atoi(s); break;
            case 2: yres=atoi(s); break;
            case 3: vxres=atoi(s); break;
            case 4: vyres=atoi(s); break;
            default: goto Usage;
        }
    }

    if(SelectIO(drv) < 0)
    {
        printf("IO driver '%s' is unknown\n", drv);
        goto Usage;
    }

    signal(SIGINT, CtrlC);
    #ifdef SIGPIPE
    signal(SIGPIPE, Problem);
    #endif
    #ifdef SIGFPE
    signal(SIGFPE, Problem);
    #endif
    signal(SIGSEGV, Problem);

    Randomize();

    InitVideo();

    if(setjmp(ResetGame))
        SetText(0,0, 8,1,2 SECONDS, "reset");

    ClrScr();

    MusicReactor(-2);

    Center(1, 6,1,2.2 SECONDS,
        "Playing this game with square font\n"
        "(8x8 etc) is strongly recommended");

    Center(9,  4,1,0.5 SECONDS, "Version "VERSION);

    Center(20, 1,1,2.5 SECONDS, "Written by Bisqwit");
    Center(21, 1,1,2.5 SECONDS, "http://iki.fi/bisqwit/");

    Center(8, 12,1,0, "JOELTRIS 10");
    Center(14,12,1,0, "PRESS ENTER");

    if(1)   /* Just for the subvars */
    {
    #if starcount
        int sx[starcount], sy[starcount], sd[starcount], sp[starcount], a;

        LoadComputerFile();

        for(a=starcount; a--; sd[a]=0)
        {
            sx[a]=rand()%40;
            sy[a]=rand()%24;
            sp[a]=rand()&3;
            if(!sp[a])sp[a]=rand()&3;
        }
    #endif
    #if enabletetris

        /*       level,handicap, x,y */
        InitTetris(&Game,  0,0,  0,4,  -1,-1, 24,36, GetComp(0));
        Game.NoHumanOpponents=1, Game.Level=20;
    /*  InitTetris(&Game2, 0,0, 12,4,  -1,-1, 12,36, GetComp(0));
        Game2.NoHumanOpponents=1, Game2.Level=20;
    */
    #endif

        for(;;)
        {
            while(!kbhit())
            {
            #if enabletetris
                TickTetris(&Game, 1); Game.Lines=0;
            //  TickTetris(&Game2, 1); Game2.Lines=0;
            #endif
            #if starcount
                for(a=0; a<starcount; a++)
                    #if !enabletetris
                    if(sd[a])sd[a]--;
                    else
                    #endif
                    {
                        static const int C[] = {15,7,7,8};
                        register int c;

                        #define cheka(tet) \
                            if(tet.Field[y][x]!=' ')ok=0; \
                            if(ok && tet.State>=S_GAME \
                                && x>=tet.blockx && x<=tet.blockx+4 \
                                && y>=tet.blocky && y<=tet.blocky+4) \
                                ok = tet.ThisBlock[y-tet.blocky][x-tet.blockx]==' ';

                    #if 0
                        #define checkok \
                        { \
                            int y=39-sx[a], x=sy[a]; ok=1; \
                            if(x < 12) { cheka(Game); } \
                            else { x-=12; cheka(Game2); } \
                        }
                    #else
                        #define checkok \
                        { \
                            int y=39-sx[a], x=sy[a]; ok=1; \
                            cheka(Game); \
                        }
                    #endif

                        #if enabletetris
                        register int ok;

                        checkok;
                        if(ok)
                        #endif
                            SetChar(sx[a],sy[a], ' ',7,0,0);

                        #if enabletetris
                        if(sd[a])
                            sd[a]--;
                        else
                        {
                        #endif
                            /* Timer */
                            sd[a]=sp[a];
                            if(--sx[a] < 0)sx[a]=39, sy[a]=rand()%24;
                        #if enabletetris
                        }

                        checkok;
                        if(ok)
                        {
                        #endif
                            c = sp[a]>2?'.':'-';
                            SetChar(sx[a],sy[a], c,C[sp[a]],0,0);
                        #if enabletetris
                        }
                        #endif
                    }
            #endif
                Tick(1);
            }
            if(WhichKey()=='\n')break;
        }
        #if enabletetris
        KillTetris(&Game);
    //  KillTetris(&Game2);
        #endif
    }

Over:
    Comp1 = Comp2 = -1;

    ClrScr(); /* Wipe out the stars */
    DrawMainBorder();

    Center(8,  7,1,0, "%11s", "");
    Center(14, 7,1,0, "%11s", "");

    DrawScoreBorder();

    StartSilence();     /* Stop any music */

    GameMode = vmenu(
        NULL,
        "GAME SELECT",
        "1 player",
        "versus computer",
        "intro",
        NULL);

    if(GameMode==-2)goto End;
    if(GameMode==2)longjmp(ResetGame, 1);

    if(GameMode==1)
    {
        int a, b;
        const char **n;

        LoadComputerFile();

        a = CompCount();

        n = (const char **)malloc((a+3) * sizeof(const char *));
        for(b=0; b<a; b++)n[b] = GetComp(b)->Name;
        n[b++] = "(you (twin game))";
        n[b] = "(Create new>";
        n[b+1] = NULL;

        Comp2 = lmenu(CompReactor, "COMPUTER OPPONENT SELECT", n);
        free(n);
        if(Comp2==-2)goto Over;
        if(Comp2==b)longjmp(ResetGame, 1);
    }

    KeyMode = vmenu(
        NULL,
        "KEYBOARD BINDINGS (UP, SPACE & DOWN)",
        KeySetups[0],
        KeySetups[1],
        KeySetups[2],
        KeySetups[3],
        KeySetups[4],
        NULL);
    if(KeyMode==-2)goto Over;

    Level = vmenu(
        NULL,
        "LEVEL SELECT",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        NULL);
    if(Level==-2)goto Over;

    Handicap = vmenu(
        NULL,
        "HANDICAP SELECT",
        "0", "3", "6", "9", "12",
        NULL) * 3;
    if(Handicap==-2)goto Over;

    Center(20, 1,1,3 SECONDS, "Some of the music melodies are");
    Center(21, 1,1,3 SECONDS, "(C) Nintendo and (C) Konami");

    Music = vmenu(
        MusicReactor,
        "MUSIC SELECT",
        "Silence",
        "Dance",
        "Frog",
        "Mansion",
        "Loginska",
        "Bradinsky",
        "Karinka",
        "Troika",
        "ASO Tetris theme",
        "ASO Technotris",
        "Solstice",
        NULL);
    if(Music==-2)goto Over;

    DrawGameBorder();

    switch(GameMode)
    {
        case 0:     /* 1 player */
            InitTetris(&Game,  Level,Handicap,  2,5,  2,12, 10,18, NULL);
            break;
        case 1:     /* versus computer */
            InitTetris(&Game,  Level,Handicap,  2,5,  2,12, 10,18, NULL);
            InitTetris(&Game2, Level,Handicap, 28,5, 34,24, 10,18, GetComp(Comp2));
            Game2.MayMoan=1;
            break;
    }

    if(GameLoop())goto Over;
End:

    KillTetris(&Game);
    KillTetris(&Game2);

    DoneMusa();
    DoneVideo();

    return 0;
}
