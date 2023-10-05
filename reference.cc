// Standard C++ includes:
#include <cstdio>    // for std::puts
#include <cstdlib>   // for std::rand
#include <cstring>   // for std::memcpy
#include <algorithm> // for std::abs, std::max, std::random_shuffle
#include <utility>   // for std::pair
#include <vector>    // for std::vector

// DJGPP-specific includes:
#include <conio.h>      // for kbhit,getch
#include <sys/farptr.h> // for _farpeekl, _farpokew
#include <go32.h>       // for _dos_ds
#include <dpmi.h>       // for __dpmi_yield

// Coroutine library. With thanks to Simon Tatham.
#define ccrVars      struct ccrR { int p; ccrR() : p(0) { } } ccrL
#define ccrBegin(x)  auto& ccrC=(x); switch(ccrC.ccrL.p) { case 0:;
#define ccrReturn(z) do { ccrC.ccrL.p=__LINE__; return(z); case __LINE__:; } while(0)
#define ccrFinish(z) } ccrC.ccrL.p=0; return(z)

// Field & rendering definitions
const auto Width = 12, Height = 25; // Width and height, including borders.
const auto VidWidth = 40u;
const auto Occ = 0x10000u;
const auto Empty = 0x12Eu, Border = Occ+0x7DBu, Garbage = Occ+0x6DBu;

// In order to access BIOS timer and VGA memory:
#define Timer _farpeekl(_dos_ds, 0x46C)
struct { struct Proxy { unsigned offset;
    void operator=(unsigned short value) const { _farpokew(_dos_ds, offset, value); } };
    Proxy operator[] (unsigned offset) const { return Proxy( {0xB8000+2u*offset} ); }
} const VidMem = {}; // Simulate an array that is at B800:0000

// Game engine
struct Piece
{
    struct { unsigned short s[4]; } shape;
    int x:8, y:8, color:14;
    unsigned r:2;

    template<typename T> // walkthrough operator
    bool operator>(T it) const
    {
        for(int q=shape.s[r],p=1,by=0; by<4; ++by)
            for(int bx=0; bx<4; ++bx, p<<=1)
                if((q&p) && it(x+bx, y+by)) return true;
        return false;
    }
    template<typename T> // transmogrify operator
    Piece operator*(T it) const { Piece res(*this); it(res); return res; }
};

template<bool DoDraw>
struct TetrisArea
{
    int Area[Height][Width];
    unsigned RenderX;
    unsigned n_full, list_full, animx;
    unsigned long timer;
    struct { ccrVars; } cascadescope;
public:
    TetrisArea(unsigned x=0) : RenderX(x) { }

    bool Occupied(int x,int y) const
        { return x<1 || (x>Width-2) || (y>=0 && (Area[y][x] & Occ)); }

    template<typename T>
    void DrawRow(unsigned y, T get)
    {
        for(int x=1; x<Width-1; ++x) DrawBlock(x,y, get(x));
    }

    bool TestFully(unsigned y, bool state) const
    {
        for(int x=1; x<Width-1; ++x) if(Occupied(x,y) != state) return false;
        return true;
    }

    void DrawBlock(unsigned x,unsigned y, int color)
    {
        if(x < (unsigned)Width && y < (unsigned)Height) Area[y][x] = color;
        if(DoDraw) VidMem[y*VidWidth + x + RenderX] = color;
    }

    void DrawPiece(const Piece& piece, int color)
    {
        piece>[=](int x,int y)->bool { if(y>=0) this->DrawBlock(x,y,color); return false; };
    }

    bool CollidePiece(const Piece& piece) const
    {
        return piece>[=](int x,int y) { return this->Occupied(x,y); };
    }

    bool CascadeEmpty(int FirstY)
    {
        ccrBegin(cascadescope);

        // Count full lines
        n_full = list_full = 0;
        for(int y = std::max(0,FirstY); y < Height-1; ++y)
            if(TestFully(y,true))
            {
                ++n_full;
                list_full |= 1u << y;
                if(!DoDraw) DrawRow(y, [](unsigned) { return 0; } );
            }
        if(n_full)
        {
            // Clear all full lines in Tengen Tetris style.
            for(animx = 1; DoDraw && animx < Width-1; ++animx)
            {
                for(timer=Timer; timer==Timer; ) ccrReturn(true);
                auto label = "SINGLEDOUBLETRIPLETETRIS"+(n_full-1)*6;
                for(int y = FirstY; y < Height-1; ++y)
                    if(list_full & (1u << y))
                        DrawBlock(animx,y,
                            animx-2u < 6u ? label[animx-2] + 0x100 : Empty);
            }
            // Cascade non-empty lines
            int target = Height-2, y = Height-2;
            for(; y >= 0; --y)
                if(!(list_full & (1u << y)))
                    DrawRow(target--, [=](unsigned x) { return this->Area[y][x]; });
            // Clear the top lines
            for(auto n=n_full; n-- > 0; )
                DrawRow(target--, [](unsigned) { return Empty; });
        }
        ccrFinish(false);
    }
};

class Tetris: protected TetrisArea<true>
{
public:
    Tetris(unsigned rx) : TetrisArea(rx), seq(),hudtimer(0) {}
    virtual ~Tetris() { }

protected:
    // These variables should be local to GameLoop(),
    // but because of coroutines, they must be stored
    // in a persistent wrapper instead. Such persistent
    // wrapper is provided by the game object itself.
    Piece seq[3];
    unsigned score, lines, combo;
    unsigned long hudtimer;
    bool escaped, dropping, ticked, kicked, spinned, atground;

    struct { ccrVars; } loopscope;
public:
    unsigned incoming;

    int GameLoop()
    {
        Piece &cur = *seq;
        ccrBegin(loopscope);

        // Initialize area
        for(auto y=Height; y-- > 0; )
            for(auto x=Width; x-- > 0; )
                DrawBlock(x,y, (x>0&&x<Width-1&&y<Height-1) ? Empty : Border);

        score = lines = combo = incoming = 0;
        MakeNext();
        MakeNext();

        for(escaped = false; !escaped; ) // Main loop
        {
            // Generate new piece
            MakeNext();

            dropping = false;
            timer    = Timer;
            atground = false;
            AI_Signal(0);

            // Gameover if cannot spawn piece
        re_collide:
            if(CollidePiece(cur)) break;

            ccrReturn(0);

            while(!escaped)
            {
                DrawPiece(cur, cur.color);

                // Wait for input
                for(ticked=false; ; )
                {
                    AI_Run();
                    HUD_Run();
                    ccrReturn(0);

                    if(incoming)
                    {
                        // Receive some lines of garbage from opponent
                        DrawPiece(cur, Empty);
                        for(int threshold=Height-1-incoming, y=0; y<Height-1; ++y)
                        {
                            unsigned mask = 0x1FF7FDFF >> (rand()%10);
                            DrawRow(y, [=](unsigned x) { return
                                y < threshold
                                    ? Area[y+incoming][x]
                                    : (mask & (1<<x)) ? Garbage : Empty; });
                        }
                        // The new rows may push the piece up a bit. Allow that.
                        for(; incoming-- > 0 && CollidePiece(cur); --cur.y) {}
                        incoming = 0;
                        goto re_collide;
                    }

                    ticked = Timer >= timer + std::max(atground?4:1, int( ((17-Level())*0.8)) );
                    if(ticked || MyKbHit() || dropping) break;
                }

                Piece n = cur;
                if(MyKbHit()) dropping = false;
                switch(ticked ? 's' : (MyKbHit() ? MyGetCh() : (dropping ? 's' : 0)))
                {
                    case 'H'<<8: case 'w': ++n.r; break;
                    case 'P'<<8: case 's': ++n.y; break;
                    case 'K'<<8: case 'a': --n.x; break;
                    case 'M'<<8: case 'd': ++n.x; break;
                    case 'q': case '\033': escaped = true; break;
                    case ' ': dropping = true;
                    default: continue;
                }
                if(n.x != cur.x) kicked = false;

                if(CollidePiece(n))
                {
                    if(n.y == cur.y+1) break; // fix piece if collide against ground
                    // If tried rotating, and was unsuccessful, try wall kicks
                    if(n.r != cur.r && !CollidePiece(n*[](Piece&p){++p.x;})) { kicked = true; ++n.x; } else
                    if(n.r != cur.r && !CollidePiece(n*[](Piece&p){--p.x;})) { kicked = true; --n.x; } else
                    continue; // no move
                }
                DrawPiece(cur, Empty);
                atground = CollidePiece(n*[](Piece&p){++p.y;});
                if(atground) dropping = false;
                if(n.y == cur.y+1)
                {
                    timer = Timer; // Reset autodrop timer
                    // If we're about to hit the floor, give the AI a chance for sliding.
                    AI_Signal(atground ? 2 : 1);
                }
                cur=n;
            }

            // If the piece cannot be moved sideways or up from its final position,
            // determine that it must have been spin-fixed into its place.
            // It is a bonus-worthy accomplishment if it ends up clearing lines.
            spinned = CollidePiece(cur*[](Piece&p){--p.y;})
                   && CollidePiece(cur*[](Piece&p){--p.x;})
                   && CollidePiece(cur*[](Piece&p){++p.x;});
            DrawPiece(cur, cur.color|Occ);

            while(CascadeEmpty(cur.y)) ccrReturn(0);
            if(n_full > 1) ccrReturn(n_full-1); // Send these rows to opponent

            lines += n_full;
            int multiplier = Level(), clears = ((0x85310 >> (n_full*4)) & 0xF);
            int bonus = (clears * 100 + (cur.y*50/Height));
            int extra = 0;
            if(spinned) extra = ((clears+1) * ((kicked ? 3 : 4)/2) - clears) * 100;
            combo = n_full ? combo + n_full : 0;
            int comboscore = combo > n_full ? combo*50*multiplier : 0;
            bonus *= multiplier;
            extra *= multiplier;
            score += bonus + extra + comboscore;
            HUD_Add(bonus, extra, comboscore);
        }
        ccrFinish(-1);
    }

protected:
    int Level() const { return 1 + lines/10; }

    void MakeNext()
    {
        static const Piece b[] =
        {
            { { { 0x4444,0x00F0,0x4444,0x00F0 } }, 0,0, 0xBDB,0 }, // I
            { { { 0x008E,0x0C88,0x00E2,0x0226 } }, 0,0, 0x1DB,0 }, // J
            { { { 0x002E,0x088C,0x00E8,0x0622 } }, 0,0, 0x6DB,0 }, // L
            { { { 0x0066,0x0066,0x0066,0x0066 } }, 0,0, 0xEDB,0 }, // O
            { { { 0x08C4,0x006C,0x08C4,0x006C } }, 0,0, 0xADB,0 }, // S
            { { { 0x00E4,0x04C4,0x04E0,0x0464 } }, 0,0, 0x5DB,0 }, // T
            { { { 0x0264,0x00C6,0x0264,0x00C6 } }, 0,0, 0x4DB,0 }, // Z
            // Add some pentaminos to create a challenge worth the AI:
            { { { 0x0272,0x0272,0x0272,0x0272 } }, 0,0, 0x2DB,0 }, // +
            { { { 0x0E44,0x02E2,0x044E,0x08E8 } }, 0,0, 0x9DB,0 }, // T5
            { { { 0x00AE,0x0C8C,0x00EA,0x0626 } }, 0,0, 0x3DB,0 }, // C
            { { { 0x0664,0x0E60,0x2660,0x0670 } }, 0,0, 0x7DB,0 }, // P
            { { { 0x0662,0x0760,0x4660,0x06E0 } }, 0,0, 0xFDB,0 }, // Q
            { { { 0x4444,0x00F0,0x4444,0x00F0 } }, 0,0, 0xBDB,0 }, // I
            { { { 0x0472,0x0362,0x0271,0x0236 } }, 0,0, 0xDDB,0 }, // R
            { { { 0x0172,0x0263,0x0274,0x0632 } }, 0,0, 0x8DB,0 }, // F
            // I is included twice, otherwise it's just a bit too unlikely.
        };
        int c = Empty;
        auto fx = [this]() { seq[0].x=4;       seq[0].y=-1;
                             seq[1].x=Width;   seq[1].y=Height-4;
                             seq[2].x=Width+4; seq[2].y=Height-4; };
        auto db = [&](int x,int y) { return VidMem[y*VidWidth+x+RenderX]=c,false; };
        fx();
        seq[1]>db; seq[0] = seq[1];
        seq[2]>db; seq[1] = seq[2];
        unsigned rnd = (std::rand()/double(RAND_MAX)) * (4*sizeof(b) / sizeof(*b));
        seq[2] = b[rnd / 4];
        seq[2].r = rnd % 4;
        fx();
        c=seq[1].color;               seq[1]>db;
        c=(seq[2].color&0xF00) + 176; seq[2]>db;
        HudPrint(0,  Height-5, "NEXT:","",0);
        HudPrint(12, 3, "SCORE:", "%-7u", score);
        HudPrint(12, 6, "LINES:", "%-5u", lines);
        HudPrint(12, 9, "LEVEL:", "%-3u", Level());
    }

    void HudPrint(int c, int y,const char*a,const char*b,int v=0) const
    {
        textattr(15); gotoxy(RenderX+Width+2,y);   cprintf(a);
        textattr(c);  gotoxy(RenderX+Width+2,y+1); cprintf(b,v);
    }

    void HUD_Run()
    {
        if(!hudtimer || Timer < hudtimer) return;
        HUD_Add(0,0,0);
        hudtimer = 0;
    }
    void HUD_Add(int bonus, int extra, int combo)
    {
        hudtimer = Timer + 18;
        auto b = "      ";
        HudPrint(10, 11,bonus?b      :b,bonus?"%+-6d":b, bonus);
        HudPrint(10, 14,combo?"Combo":b,combo?"%+-6d":b, combo);
        HudPrint(13, 16,extra?"Skill":b,extra?"%+-6d":b, extra);
    }

    virtual void AI_Signal(int) { }
    virtual int AI_Run() { return 0; }
    virtual int MyKbHit() = 0;
    virtual int MyGetCh() = 0;
public:
    // Return -1 = don't want sleep, +1 = want sleep, 0 = don't mind
    virtual char DelayOpinion() const { return 0; }//dropping ? -1 : 0; }
};

class TetrisHuman: public Tetris
{
public:
    TetrisHuman(unsigned rx) : Tetris(rx) { }
protected:
    virtual int MyKbHit() { return kbhit(); }
    virtual int MyGetCh() { int c; return (c = getch()) ? c : (getch() << 8); }
};

class TetrisAIengine: TetrisArea<false>
{
protected:
    typedef std::pair<int/*score*/, int/*prio*/> scoring;
    typedef std::pair<int/*x*/, int/*rotation*/> position;

    std::vector<position> positions;

    struct Recursion
    {
        // Copy of the field before this recursion level
        decltype(Area) bkup;
        // Currently testing position
        unsigned pos_no;
        // Best outcome so far from this recursion level
        scoring  best_score, base_score;
        position best_pos;
        Recursion() : best_pos( {5,1} ) { }
    } data[3];
    unsigned ply, ply_limit;

    bool confident, restart, resting;
    struct { ccrVars; } aiscope;

public:
    void AI_Signal(int signal)
    {
        // any = piece moved; 0 = new piece, 2 = at ground
        resting = false;
        if(signal != 1) restart = true;
        if(signal == 0) confident = false;
    }
    int AI_Run(const decltype(Area)& in_area, const Piece* seq)
    {
        std::memcpy(Area, in_area, sizeof(Area));
        // For AI, we use Pierre Dellacherie's algorithm,
        // but extended for arbitrary ply lookahead.
        const auto
            landingHeightPenalty = -1, erodedPieceCellMetricFactor = 2,
            rowTransitionPenalty = -2, columnTransitionPenalty     = -2,
            buriedHolePenalty    = -8, wellPenalty                 = -2;

        ccrBegin(aiscope);
        confident = false;
    Restart:
        restart   = false;
        resting   = false;

        positions.clear();
        for(int x=-1; x<Width; ++x)
            for(unsigned rot=0; rot<4; ++rot)
                positions.push_back( {x,rot} );
        std::random_shuffle(positions.begin(), positions.end());

        { int heap_room = -(seq->y+1);
        while(TestFully(heap_room,false)) ++heap_room;
        ply_limit = heap_room<=1 ? 1 : heap_room<=4 ? 2 : 3; }
        ply = 0;
        textattr(0x78); gotoxy(33,1); cprintf("COM@%u ", ply_limit);

    Recursion:
        // Take current board as testing platform
        std::memcpy(data[ply].bkup, Area, sizeof(Area));
        if(!confident) data[ply].best_score = {-99999999,0};
        for(;;)
        {
            data[ply].pos_no = 0;
            do {
                ccrReturn(0);
                if(restart) goto Restart;

                // Game might have changed the the board contents.
                std::memcpy(data[0].bkup, Area, sizeof(Area));

                // Now go on and test with the current testing platform
                std::memcpy(Area, data[ply].bkup, sizeof(Area));

                // Fix the piece in place, cascade rows, and analyze the result.
              { Piece n = seq[ply];
                n.x = positions[ data[ply].pos_no ].first;
                n.r = positions[ data[ply].pos_no ].second;
                if(ply) n.y = -1;

                // If we are analyzing a mid-fall maneuver, verify whether
                // the piece can be actually maneuvered into this position.
                if(ply==0 && n.y >= 0)
                    for(Piece q,t=*seq; t.x!=n.x && t.r!=n.r; )
                        if( (t.r == n.r || (q=t, ++t.r, CollidePiece(t)&&(t=q,true)))
                        &&  (t.x <= n.x || (q=t, --t.x, CollidePiece(t)&&(t=q,true)))
                        &&  (t.x >= n.x || (q=t, ++t.x, CollidePiece(t)&&(t=q,true))))
                            goto next_move; // no method of maneuvering.

                // Land the piece if it's not already landed
                do ++n.y; while(!CollidePiece(n)); --n.y;
                if(n.y < 0 || CollidePiece(n)) goto next_move; // cannot place piece?

                DrawPiece(n, n.color|Occ); // place piece

                // Find out the extents of this piece, and how many
                // cells of the piece contribute into full (completed) rows.
                char full[4]={-1,-1,-1,-1};
                int miny=n.y+9, maxy=n.y-9, minx=n.x+9, maxx=n.x-9, num_eroded=0;
                auto minmax=[](int&min,int&max,int v) { if(v<min)min=v; if(v>max)max=v; };
                n>[&](int x,int y) -> bool
                    { minmax(minx,maxx,x); minmax(miny,maxy,y);
                      if(full[y - n.y] < 0) full[y - n.y] = this->TestFully(y,true);
                      num_eroded += full[y - n.y];
                      return false; };

                CascadeEmpty(n.y);

                // Analyze the board and assign penalties
                int penalties = 0;
                for(int y=0; y<Height-1; ++y)
                    for(int q=1,r, x=1; x<Width; ++x, q=r)
                        if(q != (r = Occupied(x,y)))
                            penalties += rowTransitionPenalty;
                for(int x=1; x<Width-1; ++x)
                    for(int ceil=0,q=0,r, y=0; y<Height; ++y,q=r)
                    {
                        if(q != (r = Occupied(x,y))) penalties += columnTransitionPenalty;
                        if(r) { ceil=1; continue; }
                        if(ceil) penalties += buriedHolePenalty;
                        if(Occupied(x-1,y) && Occupied(x+1,y))
                            for(int y2=y; y2<Height-1 && !Occupied(x,y2); ++y2)
                                penalties += wellPenalty;
                    }

                data[ply].base_score = {
                    // score
                    (erodedPieceCellMetricFactor * int(n_full) * num_eroded +
                    penalties +
                    landingHeightPenalty * ((Height-1) * 2 - (miny+maxy))) * 4,
                    // tie-breaker
                    50 * std::abs(Width-2-minx-maxx) +
                    (minx+maxx < Width-2 ? 10 : 0) - n.r
                };
              }
                if(ply+1 < ply_limit)
                    { ++ply; goto Recursion;
                      Unrecursion: --ply; }

                if(data[ply].best_score < data[ply].base_score)
                {
                    data[ply].best_score  = data[ply].base_score;
                    data[ply].best_pos    = positions[ data[ply].pos_no ];
                }
            next_move:;
            } while(++data[ply].pos_no < positions.size());

            if(ply > 0)
            {
                data[ply-1].base_score.first += data[ply].best_score.first >> (2-ply);
                goto Unrecursion;
            }
            for(confident = resting = true; resting; ) ccrReturn(0);
        } // infinite refining loop
        ccrFinish(0);
    }
};
class TetrisAI: public Tetris, TetrisAIengine
{
protected:
    virtual void AI_Signal(int s) { TetrisAIengine::AI_Signal(s); }
    virtual int AI_Run()
    {
        return TetrisAIengine::AI_Run(Tetris::Area, seq);
    }
    virtual int MyKbHit()
    {
        return PendingAIinput ? 1 : (PendingAIinput = GenerateAIinput()) != 0;
    }
    virtual int MyGetCh()
    {
        int r = PendingAIinput;
        return r ? (PendingAIinput=0), r : GenerateAIinput();
    }
    int GenerateAIinput()
    {
        auto d = [&](char c, int maxdelay=5) { return ++delay >= maxdelay ? delay=0,c : 0; };
        if(seq->r != data[0].best_pos.second) return d('w', 0);
        if(seq->y >= 0 && seq->x > data[0].best_pos.first) return d('a');
        if(seq->y >= 0 && seq->x < data[0].best_pos.first) return d('d');
        return confident ? d('s',0) : '\0';
    }

    int PendingAIinput, delay;
public:
    virtual char DelayOpinion() const { return -1; }//!confident ? -1 : Tetris::DelayOpinion(); }

    TetrisAI(unsigned rx) : Tetris(rx), PendingAIinput(0), delay(0) {}
};

int main()
{
    textmode(C40);

    TetrisHuman player(0);
    TetrisAI computer(20);
    textattr(0x78); gotoxy(13,1); cprintf("1UP ");

    for(;;)
    {
        int a = player.GameLoop();   if(a < 0) break;
        int b = computer.GameLoop(); if(b < 0) continue;
        player.incoming   += b;
        computer.incoming += a;

        if(computer.DelayOpinion() >= 0 && player.DelayOpinion() >= 0)
        {
            __dpmi_yield(); // Low-power delay, if nothing to do
            //__asm__ volatile("hlt");
        }
    }

    // Gameover
    textmode(C80);
    std::puts("GAME OVER");
}
