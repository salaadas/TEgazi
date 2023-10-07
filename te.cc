#include <cstdint>
#include <cstdio>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>

#include <algorithm>

#define hidecursor() puts("\033[?25l")
#define showcursor() puts("\033[?25h")
#define clrscr()     puts("\033c")
#define gotoxy(x,y)  printf("\033[%d;%dH", y, x)
#define bgcolor(c1,c2,s) printf("\033[%d" c2 "m" s, c1)

const char keys[] = "awds q";
#define KEY_LEFT   0
#define KEY_ROTATE 1
#define KEY_RIGHT  2
#define KEY_DOWN   3
#define KEY_DROP   4
#define KEY_QUIT   5

static struct termios savemodes;
static int havemodes = 0;
bool quit = false;

// [#1]: For some reasons, termios x position 0 and 1 draws at the same place
// >>> For this problem, we need to set an offset to the rendered board
const auto Width = 12, Height = 25;
const auto Occ = 0x10000u, Empty = 0u, Border = 32u;

void draw__(int x, int y, int c)
{
    gotoxy(x, y);
    if (c==Empty || !c) bgcolor(c, "", "  ");
    else if (c==Border)
    {
        if (y==Height-1) bgcolor(c, ";40", "==");
        else bgcolor(c, ";40", "!!");
    }
    else bgcolor(c, "", "[]");
}

int ttyInit()
{
    // set up so that read only one key at a time
    struct termios modmodes;
    if (tcgetattr(fileno(stdin), &savemodes) < 0)
        return(-1);
    havemodes = 1;
    hidecursor();
    modmodes = savemodes;
    modmodes.c_lflag &= ~ICANON;
    modmodes.c_lflag &= ~ECHO;
    modmodes.c_cc[VMIN] = 1;
    modmodes.c_cc[VTIME] = 0;
    return tcsetattr(fileno(stdin), TCSANOW, &modmodes);
}

int ttyExit()
{
    if (!havemodes)
        return 0;
    showcursor();
    return tcsetattr(fileno(stdin), TCSANOW, &savemodes);
}

void exitHandler(int signo)
{
    (void)signo; quit = true;
}

static void alarmHandler(int signo)
{
    static long h[4];
    if (!signo) h[3] = 250*1000;
    // std::max(atground ? 4 : 1, int((17 - Level())*0.8));
    setitimer(0, (struct itimerval *)h, 0);
}

#define SIGNAL(signo, callback)                 \
    sigemptyset(&sa.sa_mask);                   \
    sigaddset(&sa.sa_mask, signo);              \
    sa.sa_flags = 0;                            \
    sa.sa_handler = callback;                   \
    sigaction(signo, &sa, nullptr)
static void sigInit()
{
    // init signals
    struct sigaction sa;
    SIGNAL(SIGINT, exitHandler);
    SIGNAL(SIGTERM, exitHandler);
    SIGNAL(SIGALRM, alarmHandler);
    alarmHandler(0); // starts updating timer
}

struct Piece
{
    uint16_t shape[4];
    // x: 8 bits; y: 8 bits
    // color: 8 bits
    // rotation: 2 bits unsigned
    int x:8, y:8, color:8;
    unsigned r:2;
    template<typename T>
    bool operator>>(T it) const
    {
        for (int rot=shape[r], t=1, by=0; by<4; ++by)
        for (int bx=0; bx<4; ++bx, t<<=1)
        if ((rot&t) && it(bx+x, by+y)) {return true;}
        return false;
    }
    template<typename T>
    Piece operator<<(T it) const
    {Piece res = *this; it(res); return res;}
};

struct TetrisPlayGround
{
    int FrontBuffer[Height][Width];
    int BackBuffer[Height][Width];
    int Arena[Height][Width];
    unsigned long nFull, nList; // temporary calculation for cascade
    int offset;

    TetrisPlayGround(unsigned o=10) : offset(o) { }
    bool Occupied(int x, int y)
    {
        if (x<1 || (x>Width-2) || (y>=0 && Arena[y][x]&Occ)) return true;
        return false;
    }

    void DrawBlock(int x, int y, int color, bool permanent=false)
    {
        if (0<=x && x<Width && 0<=y &&y<Height)
        {
            FrontBuffer[y][x] = color;
            if (permanent) Arena[y][x] = color==Empty ? Empty : Occ;
        }
    }

    template<typename T>
    void DrawRow(unsigned y, T getColor)
    {
        for (int x=1; x<Width-1; ++x) DrawBlock(x, y, getColor(x));
    }

    template<bool WantFull>
    bool TestFully(int y)
    {
        for (int x=1; x<Width-1; ++x) if (Occupied(x, y)!=WantFull) return false;
        return true;
    }

    void DrawPiece(Piece &piece, int color, bool permanent=false)
    {
        piece>>[=](int x, int y) {if (y>=0) DrawBlock(x, y, color, permanent); return false;};
    }

    bool CollidePiece(const Piece &piece)
    {
        return piece>>[=](unsigned x, unsigned y)
        {
            bool c = Occupied(x, y);
            // if (c) gotoxy(50, 27); printf("%d %d\n", x, y);
            return c;
        };
    }

    int CascadeEmpty(int FirstY)
    {
        (void)FirstY;
        int nFull = 0;
        // n! cascade algorithm
        // gotoxy(0, 28);
        for (int y=Height-2; y>0; --y)
        {
            if (TestFully<true>(y))
            {
                // printf(" %d", y);
                int t = y;
                ++nFull;
                for (int dy=y-1; dy>0; --dy, --t)
                {
                    for (int x=1; x<Width-1; ++x)
                    {
                        Arena[t][x]       = Arena[dy][x];
                        FrontBuffer[t][x] = FrontBuffer[dy][x];
                    }
                }
                ++y;
            }
        }
        return nFull;
    }
};

enum GAME_RET
{
    GAME_FINE=0,
    GAME_CONTINUE
};

struct Tetris : TetrisPlayGround
{
    int k;
    Piece storage[2];
    Piece &cur = *storage;
    unsigned long scores, lines;
    bool escaped, atground, ticked, dropping, kicked;

    Tetris()
    {
        for (int y=Height-1; y>=0; --y)
        {
            for (int x=Width-1; x>=0; --x)
            {
                FrontBuffer[y][x] = (!(x%(Width-1)) || y==Height-1) ? Border : Empty;
                Arena[y][x] = (!(x%(Width-1)) || y==Height-1) ? Occ : Empty;
            }
        }

        MakeNext();
        MakeNext();
        DrawPiece(cur, cur.color);
        escaped = false;
    }

    inline
    int Level() {return (1 + lines/10);}

    void MakeNext()
    {
        static const Piece b[] =
        {
            { { 0x4444,0x00F0,0x4444,0x00F0 }, 0,0, 41,0 }, // I
            { { 0x008E,0x0C88,0x00E2,0x0226 }, 0,0, 42,0 }, // J
            { { 0x002E,0x088C,0x00E8,0x0622 }, 0,0, 43,0 }, // L
            { { 0x0066,0x0066,0x0066,0x0066 }, 0,0, 44,0 }, // O
            { { 0x08C4,0x006C,0x08C4,0x006C }, 0,0, 45,0 }, // S
            { { 0x00E4,0x04C4,0x04E0,0x0464 }, 0,0, 46,0 }, // T
            { { 0x0264,0x00C6,0x0264,0x00C6 }, 0,0, 47,0 }, // Z
            // { { 0x0272,0x0272,0x0272,0x0272 }, 0,0, 42,0 }, // +
            // { { 0x0E44,0x02E2,0x044E,0x08E8 }, 0,0, 43,0 }, // T5
            // { { 0x00AE,0x0C8C,0x00EA,0x0626 }, 0,0, 44,0 }, // C
            // { { 0x0664,0x0E60,0x2660,0x0670 }, 0,0, 45,0 }, // P
            // { { 0x0662,0x0760,0x4660,0x06E0 }, 0,0, 46,0 }, // Q
            // { { 0x4444,0x00F0,0x4444,0x00F0 }, 0,0, 41,0 }, // I
            // { { 0x0472,0x0362,0x0271,0x0236 }, 0,0, 47,0 }, // R
            // { { 0x0172,0x0263,0x0274,0x0632 }, 0,0, 42,0 }, // F

        };
        int c = Empty;
        auto fx = [&]() {
            storage[0].x = 4; storage[0].y = -1;
            storage[1].x = Width + offset; storage[1].y = Height - 4;
        };
        fx();
        storage[1]>>[=](int x, int y) {draw__(2*x, y, Empty); return false;};
        storage[0] = storage[1];
        unsigned rnd = (std::rand() / double(RAND_MAX)) * (4 * sizeof(b) / sizeof(*b));
        storage[1] = b[rnd / 4];
        storage[1].r = rnd % 4;
        fx();
        c = storage[1].color;
        storage[1]>>[=](int x, int y) {draw__(2*x, y, c); return false;};
    }

    int Update()
    {
        int x, y;
        /* Display board. */
        for (y = 1; y < Height; y++) {
            for (x = 0; x < Width; x++) {
                if (FrontBuffer[y][x] - BackBuffer[y][x]) {
                    int c = FrontBuffer[y][x]; /* color */
                    BackBuffer[y][x] = c;
                    draw__(2*x + offset, y, c);
                }
            }
        }
        /* Update points and level */
        gotoxy(2*Width + offset, 10);
        bgcolor(6, "", "");
        printf("Keys:");
        fflush(stdout);
        return MyGetChar();
    }

    GAME_RET GameLoop()
    {
        Piece n = cur;
        bool permanent = false;
        if (k<0)
        {
            if (!CollidePiece(n<<[](Piece&p){++p.y;})) ++n.y;
            else
            {
                // gotoxy(30, 10);
                // printf("collide at %d %d", n.x, n.y);
                DrawPiece(n, n.color, true);
                ++scores;
                lines += CascadeEmpty(0);
                MakeNext();
                if (CollidePiece(cur)) k = keys[KEY_QUIT];
                return GAME_CONTINUE;
            }
        }
        if (k==keys[KEY_LEFT])
            if (!CollidePiece(n<<[](Piece&p){--p.x;})) --n.x;
        if (k==keys[KEY_RIGHT])
        {
            if (!CollidePiece(n<<[](Piece&p){++p.x;})) ++n.x;
        }
        if (k==keys[KEY_ROTATE])
        {
            ++n.r;
            if (CollidePiece(n))
            {
                // try wall kick
                if (!CollidePiece(n<<[](Piece&p){++p.x;})) {++n.x;}
                if (!CollidePiece(n<<[](Piece&p){--p.x;})) {--n.x;}
                else --n.r;
            }
        }
        if (k==keys[KEY_DOWN])
        {
            if (!CollidePiece(n<<[](Piece&p){++p.y;})) ++n.y;
        }
        if (k==keys[KEY_DROP])
        {
            for (; !CollidePiece(n<<[](Piece&p){++p.y;}); ++scores) ++n.y;
            goto finalized;
        }
        if (k==keys[KEY_QUIT]) {escaped=true; return GAME_CONTINUE;}

        // gotoxy(5, 25);
        // printf("%d", n.color);
        // gotoxy(5, 27);
        // printf("%d %d %d", n.x, n.y, n.r);

        // for (int y = 0; y < Height; ++y)
        // {
        //     gotoxy(0, y);
        //     printf("%2d", y);
        //     gotoxy(offset + 50, y);
        //     for (int x = 0; x < Width; ++x)
        //     {
        //         printf("%5.X ", Arena[y][x]);
        //     }
        //     printf("\n");
        // }
    finalized:
        // Piece shadow = n;
        // for (; !CollidePiece(shadow<<[](Piece&p){++p.y;}); )
        //     ++shadow.y;
        cur = n;
        DrawPiece(cur, cur.color, permanent);
        // DrawPiece(shadow, 47);
        k = Update();
        // DrawPiece(shadow, Empty);
        DrawPiece(cur, Empty, permanent);

        return GAME_FINE;
    }

    virtual char MyGetChar() = 0;
};

struct TetrisHuman : Tetris
{
    virtual char MyGetChar()
    {return getchar();}
};

int main()
{
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    // printf("%d %d", w.ws_row, w.ws_col);
    if (w.ws_row < 30 || w.ws_col < 156)
    {
        fprintf(stderr, "WARNING: Terminal window too small, try zooming out on your terminal\n");
        exit(1);
    }
    if (ttyInit()==-1)
        return(-1);
    sigInit();

    clrscr();
    TetrisHuman man;
    while (!(quit || man.escaped))
    {
        switch (man.GameLoop())
        {
            case GAME_CONTINUE: continue; break;
            default: break;
        }
    }
    clrscr();
    printf("Your score is %ld\n", man.scores);
    printf("You cleared %ld lines\n", man.lines);
    printf("It was hard, wasn't it\n");
    printf("But this is just the beginning\n");
    printf("This is TEgazi v0\n");
    printf("It's still a work-in-progress\n");
    printf("By salaadas, from vietnam\n");
    if (ttyExit()==-1)
        return(-1);
    return(0);
}
