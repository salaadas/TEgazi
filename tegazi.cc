#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <termios.h>
#include <unistd.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/wait.h>

#include <algorithm>
#include <chrono>

// #define clrscr()       puts ("\033[2J\033[1;1H")
// #define gotoxy(x,y)    printf("\033[%d;%dH", y, x)
// #define hidecursor()   puts ("\033[?25l")
// #define showcursor()   puts ("\033[?25h")
// #define bgcolor(c,s)   printf("\033[%dm" s, c ? c + 40 : 0)

#define hidecursor() puts("\033[?25l")
#define showcursor() puts("\033[?25h")
#define clrscr()     puts("\033c")
#define gotoxy(x,y)  printf("\033[%d;%dH", y, x)
#define bgcolor(c,s) printf("\033[%dm" s, c ? c + 40 : 0)

const char keys[] = "asd q";
#define KEY_LEFT   0
#define KEY_ROTATE 1
#define KEY_RIGHT  2
#define KEY_DROP   3
#define KEY_QUIT   4

static struct termios savemodes;
static int havemodes = 0;

// [#1]: For some reasons, termios x position 0 and 1 draws at the same place
const auto Width = 12, Height = 25;
const auto Occ = 0x10000u, Empty = 0u, Border = 2u;

int FrontBuffer[Height][Width];
int BackBuffer[Height][Width];
int Arena[Height][Width];
constexpr int offset = 10; // without this, it is weird, see [#1]

unsigned long nFull, nList; // temporary calculation for cascade
bool escaped=false, atground, ticked, dropping, kicked;
unsigned long scores, lines;

unsigned long Timer()
{
    using namespace std::chrono;
    auto now = system_clock::now();
    auto ms = time_point_cast<milliseconds>(now);
    auto value = ms.time_since_epoch();
    return value.count();
}

inline
int Level() {return (1 + lines/10);}

void draw__(int x, int y, int c, const char *s=" ")
{gotoxy(x, y); bgcolor(c, s);}

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
    (void)signo; escaped = true;
}

static void alarmHandler(int signo)
{
    static long h[4];
    if (!signo) h[3] = 500*1000;
    // std::max(atground ? 4 : 1, int((17 - Level())*0.8));
    h[3] -= h[3] / (3000 - 10 * Level());
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

bool Occupied(int x, int y)
{
    if (x<1 || (x>Width-2) || (y>=0 && Arena[y][x]&Occ)) return true;
    return false;
}

void DrawBlock(int x, int y, int color, const char *s=" ", bool permanent=false)
{
    if (0<=x && x<Width && 0<=y &&y<Height)
    {
        FrontBuffer[y][x] = color;
        if (permanent) Arena[y][x] = Occ;
    }
}

template<typename T>
void DrawRow(unsigned y, T getColor)
{
    for (int x=1; x<Width-1; ++x) DrawBlock(x, y, getColor(x, y));
}

template<bool WantFull>
bool TestFully(int y)
{
    for (int x=1; x<Width-1; ++x) if (Occupied(x, y)!=WantFull) return false;
    return true;
}

void DrawPiece(Piece &piece, int color, bool permanent=false)
{
    piece>>[=](int x, int y) {if (y>=0) DrawBlock(x, y, color, " ", permanent); return false;};
}

bool CollidePiece(const Piece &piece)
{
    return piece>>[=](unsigned x, unsigned y)
    {
        bool c = Occupied(x, y);
        if (c)
        {gotoxy(50, 27); printf("%d %d\n", x, y);}
        return c;
    };
}

int CascadeEmpty()
{
    static unsigned nFull, listFull;
    nFull = nList = 0;
    for (int y=0; y<Height-1; ++y)
    {
        if (TestFully<true>(y))
        {
            ++nFull;
            listFull |= 1u<<y;
        }
    }
    if (nFull)
    {
        int animx;
        for (animx=1; animx<Width-1; ++animx)
        {
            auto label = "SINGLEDOUBLETRIPLETETRIS"+(nFull-1)*6;
            for (int y=0; y<Height-1;++y)
                if (listFull & (1u<<y))
                    DrawBlock(animx, y, animx-2u < 6u ? 3 : Empty, animx-2u < 6u ? label[animx-2] : " ");
        }
        int target=Height-2, y=Height-2;
        for (; y>=0; --y)
        {
            if (!listFull & (1u<<y))
            {
                DrawRow(target--, [=](unsigned x) {return FrontBuffer[y][x];});
            }
        }


Piece storage[2];
void MakeNext()
{
    static const Piece b[] =
        {
            { { 0x4444,0x00F0,0x4444,0x00F0 }, 0,0, 1,0 }, // I
            { { 0x008E,0x0C88,0x00E2,0x0226 }, 0,0, 2,0 }, // J
            { { 0x002E,0x088C,0x00E8,0x0622 }, 0,0, 3,0 }, // L
            { { 0x0066,0x0066,0x0066,0x0066 }, 0,0, 4,0 }, // O
            { { 0x08C4,0x006C,0x08C4,0x006C }, 0,0, 5,0 }, // S
            { { 0x00E4,0x04C4,0x04E0,0x0464 }, 0,0, 6,0 }, // T
            { { 0x0264,0x00C6,0x0264,0x00C6 }, 0,0, 7,0 }, // Z
        };
    int c = Empty;
    auto fx = []() {
        storage[0].x = 4; storage[0].y = -1;
        storage[1].x = Width + offset; storage[1].y = Height - 4;
    };

    fx();
    storage[1]>>[=](int x, int y) {draw__(x, y, Empty); return false;};
    storage[0] = storage[1];
    unsigned rnd = (std::rand() / double(RAND_MAX)) * (4 * sizeof(b) / sizeof(*b));
    storage[1] = b[rnd / 4];
    storage[1].r = rnd % 4;
    fx();
    c = storage[1].color;
    storage[1]>>[=](int x, int y) {draw__(x, y, c); return false;};
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
                draw__(x + offset, y, c);
            }
        }
    }
    /* Update points and level */
    gotoxy(Width + offset, 10);
    printf("Keys:");
    fflush(stdout);
    return getchar();
}

int main()
{
    if (ttyInit()==-1)
        return(-1);
    sigInit();
    clrscr();
    for (int y=Height-1; y>=0; --y)
        for (int x=Width-1; x>=0; --x)
        {
            FrontBuffer[y][x] = (!(x%(Width-1)) || y==Height-1) ? Border : Empty;
            Arena[y][x] = (!(x%(Width-1)) || y==Height-1) ? Occ : 0;
        }
    int k;
    MakeNext();
    MakeNext();
    Piece &cur = *storage;
    DrawPiece(cur, cur.color);
    while (!escaped)
    {
        Piece n = cur;
        bool per=false;
        if (k<0)
        {
            if (!CollidePiece(n<<[](Piece&p){++p.y;})) ++n.y;
            else
            {
                gotoxy(30, 10);
                printf("collide at %d %d", n.x, n.y);
                DrawPiece(n, n.color, true);
                ++scores;
                lines += CascadeEmpty();
                MakeNext();
                if (CollidePiece(cur)) k = keys[KEY_QUIT];
                continue;
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
            }
        }
        if (k==keys[KEY_DROP])
        {
            for (; !CollidePiece(n<<[](Piece&p){++p.y;}); ++scores)
                ++n.y;
        }
        if (k==keys[KEY_QUIT]) {break;}

        gotoxy(5, 25);
        printf("%d", n.color);
        gotoxy(5, 27);
        printf("%d %d %d", n.x, n.y, n.r);

        for (int y = 0; y < Height; ++y)
        {
            gotoxy(offset + 50, y);
            for (int x = 0; x < Width; ++x)
            {
                printf("%d ", FrontBuffer[y][x]);
            }
            printf("\n");
        }

        DrawPiece(cur, Empty);
        cur = n;
        DrawPiece(cur, cur.color);
        k = Update();
    }
    // clrscr();
    // printf("Your score is %ld\n", scores);
    // printf("You cleared %ld lines\n", lines);
    // printf("It was hard, wasn't it\n");
    // printf("But this is just the beginning\n");
    // printf("This is TEgazi v0\n");
    // printf("It's still a work-in-progress\n");
    // printf("By salaadas, from vietnam\n");
    if (ttyExit()==-1)
        return(-1);
    return(0);
}
