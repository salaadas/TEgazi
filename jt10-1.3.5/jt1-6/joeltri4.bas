DECLARE SUB Center (y%, Text$)
DECLARE SUB Help ()
DECLARE SUB PlayGame ()
DECLARE SUB TeeTausta ()
DECLARE SUB Swappi (x%, y%)
DECLARE FUNCTION Pyorita% ()
DECLARE FUNCTION CheckRivit% ()
DECLARE FUNCTION VoiMenna% (Lx%, Ly%)
DECLARE SUB Piki (x%, y%, c1%, SetFlag%)

DIM SHARED Ml AS INTEGER, Mk AS INTEGER, Sni AS INTEGER, Ss AS INTEGER
DIM SHARED Co(10) AS INTEGER, Score AS LONG, Lines AS INTEGER
DIM SHARED OldWind(4000) AS INTEGER
Ml = 12: Mk = 25: Sni = -1: Co(1) = 7: Co(2) = 3: Ss = 100
OPEN "JOELTRI4.DAT" FOR BINARY AS #1
IF LOF(1) = 0 THEN PUT #1, , Ss: PUT #1, , Ml: PUT #1, , Mk: PUT #1, , Co(1): PUT #1, , Co(2): CLOSE : RUN
GET #1, , Ss: GET #1, , Ml: GET #1, , Mk: GET #1, , Co(1): GET #1, , Co(2): CLOSE

KEY 15, CHR$(8) + CHR$(42)
ON KEY(15) GOSUB ChangeSetup
KEY(15) ON

ON ERROR GOTO Virhe
Sni = 0
IF COMMAND$ = "" THEN GOTO VOhi
IF INSTR(UCASE$(COMMAND$), "/S") > 0 THEN Sni = 0 ELSE Sni = 1
IF INSTR(UCASE$(COMMAND$), "?") > 0 THEN Help
IF INSTR(UCASE$(COMMAND$), "H") > 0 THEN Help
GOTO VOhi
Virhe:
    RESUME NEXT
VOhi:
SCREEN 2: SCREEN 0, 0, 0, 0: WIDTH 40, 25

TYPE Pelaaja
    Nimi AS STRING * 20
    Score AS INTEGER
END TYPE
TYPE XyCoord
    x AS INTEGER
    y AS INTEGER
END TYPE

RANDOMIZE TIMER

CONST MaxPala = 12

DEFINT A-Z
DEF Fnr (x) = INT(RND * x) + 1

DIM SHARED Pala(MaxPala, 4, 4) AS XyCoord, Alue(40, 25), Mika, Ase
DIM SHARED Nx, Ny, SwapRivit(40)

KEY(15) STOP
RESTORE FirstDatas
FOR x = 1 TO MaxPala
    FOR y = 1 TO 4
        FOR z = 1 TO 4
            READ Pala(x, y, z).x, Pala(x, y, z).y
NEXT z, y, x
KEY(15) ON

TeeTausta
PlayGame
IF Sni THEN
    PLAY "mbt255l8o3fecd+d<b>c+c2"
    PLAY "mbt255l8o2aaap4ap4>ce2p4<ap4>cf2"
    PLAY "mbt255l8o3fed+ep4<ap4aa-2p4a"
END IF

WIDTH 80, 25
DIM Strinki(9) AS STRING * 60
KEY(15) OFF
RESTORE GameOver
FOR y = 1 TO 9: LOCATE y, 1: PRINT STRING$(80, 219); : READ Strinki(y): NEXT
KEY(15) ON
FOR x! = 1 TO 8 STEP .5
    COLOR 9 + INT(RND * 7), 0
    FOR y = 1 TO 9
        IF y MOD 2 = 0 THEN LOCATE y, 16 - x! ELSE LOCATE y, x!
        PRINT Strinki(y);
    NEXT
NEXT

OPEN "JOELTRI4.HAT" FOR BINARY AS #1
IF LOF(1) = 0 OR INSTR(UCASE$(COMMAND$), "/L") > 0 THEN
    Cit = 0: CLOSE : KILL "JOELTRI4.HAT"
    OPEN "JOELTRI4.HAT" FOR BINARY AS #1
    PUT #1, , Cit: CLOSE : OPEN "JOELTRI4.HAT" FOR BINARY AS #1
END IF
GET #1, , Cit: t = 0
DIM p(Cit + 1) AS Pelaaja
FOR x = 1 TO Cit
    GET #1, , p(Cit)
    IF p(Cit).Score < Score THEN EXIT FOR
NEXT
IF x = Cit + 1 THEN
    IF Cit < 10 THEN t = x: Cit = Cit + 1
ELSE
    FOR t = Cit + 1 TO x
        p(Cit) = p(Cit - 1)
    NEXT
    Cit = Cit + 1
END IF
LOCATE 11, 1
PRINT "   ∫"; "Player's name"; SPACE$(7); "∫"; "  score   "; "∫"
PRINT "   Ã"; STRING$(20, 205); "Œ"; STRING$(10, 205); "π"
FOR x = 1 TO Cit
    IF x = t THEN
        PRINT x; "∫"; SPACE$(20); "∫", Score;
        PRINT TAB(36); "∫"
    ELSE
        PRINT x; "∫"; p(x).Nimi; "∫", p(x).Score;
        PRINT TAB(36); "∫"
    END IF
NEXT
IF t > 0 THEN LOCATE 12 + t, 5: INPUT "", p(t).Nimi: p(t).Score = Score
CLOSE
OPEN "JOELTRI4.HAT" FOR BINARY AS #1
PUT #1, , Cit
FOR x = 1 TO Cit
    PUT #1, , p(Cit)
NEXT
CLOSE
OPEN "JOELTRI4.HAT" FOR BINARY AS #1
GET #1, , Cit: t = 0
FOR x = 1 TO Cit
    GET #1, , p(Cit)
NEXT
VIEW PRINT 11 TO 25: CLS : VIEW PRINT 1 TO 25
LOCATE 10, 1
PRINT "   …"; STRING$(20, 205); "À"; STRING$(10, 205); "ª"
LOCATE 10, 10: PRINT "Mestareiden"
LOCATE 10, 26: PRINT "Pistetaulu"
PRINT "   ∫"; "Player's name"; SPACE$(7); "∫"; "  score   "; "∫"
PRINT "   Ã"; STRING$(20, 205); "Œ"; STRING$(10, 205); "π"
FOR x = 1 TO Cit
    PRINT x; "∫"; p(x).Nimi; "∫", p(x).Score;
    PRINT TAB(36); "∫"
NEXT
PRINT "   »"; STRING$(20, 205); " "; STRING$(10, 205); "º"
    



KEY(15) OFF
RESTORE GameOver
FOR y = 1 TO 9: LOCATE y, 1: PRINT STRING$(80, 219); : READ Strinki(y): NEXT
KEY(15) ON
FOR x! = 1 TO 8 STEP .2
    COLOR 9 + INT(RND * 7), 0
    FOR y = 1 TO 9
        IF y MOD 2 = 0 THEN LOCATE y, 16 - x! ELSE LOCATE y, x!
        PRINT Strinki(y);
    NEXT
NEXT
          
VIEW PRINT 11 TO 25: CLS : VIEW PRINT 1 TO 25

DIM t1 AS DOUBLE, t2 AS LONG
LOCATE 11, 15: PRINT "Wait for about two seconds..."
t2 = TIMER
FOR t1 = 1 TO 2 ^ 30
    LOCATE 25, 25: PRINT "∫"; DATE$; "∫"; TIME$; "∫";
    IF TIMER - t2 > 2 THEN EXIT FOR
NEXT
LOCATE 11, 15: PRINT "If the text goes too slow, push `-'."
LOCATE 12, 20: PRINT "If it goes too fast, push `+'."
KEY(15) OFF
t1 = CLNG(CDBL(t1) / 4)
RESTORE EndTExt
FOR y = 1 TO 47
    READ y$
    FOR x = 1 TO 80
        FOR t = 1 TO t1 * 2: NEXT
        LOCATE 25, 25: PRINT "∫"; DATE$; "∫"; TIME$; "∫";
        j$ = INKEY$
        IF j$ = "-" THEN t1 = t1 - 100
        IF j$ = "+" THEN t1 = t1 + 100
        IF x + LEN(y$) > 79 THEN y$ = LEFT$(y$, (80 - x))
        LOCATE 10, x, 0, 8, 1: PRINT " "; y$;
    NEXT
NEXT
END
FirstDatas:
'Venkula 1.0
DATA 3,1, 3,4, 3,3, 3,2
DATA 1,2, 4,2, 3,2, 2,2
DATA 3,1, 3,4, 3,3, 3,2
DATA 1,2, 4,2, 3,2, 2,2

'Kuutio  1.0
DATA 2,1, 3,1, 3,2, 2,2
DATA 2,1, 3,1, 3,2, 2,2
DATA 2,1, 3,1, 3,2, 2,2
DATA 2,1, 3,1, 3,2, 2,2

'Kolmio  1.0
DATA 2,2, 1,1, 2,1, 3,1
DATA 2,1, 2,2, 2,3, 3,2
DATA 2,1, 1,2, 2,2, 3,2
DATA 3,1, 3,2, 3,3, 2,2

'Erikoinen 1.0
DATA 2,1, 2,1, 2,1, 2,1
DATA 2,1, 2,1, 2,1, 2,1
DATA 2,1, 2,1, 2,1, 2,1
DATA 2,1, 2,1, 2,1, 2,1

'Erikoinen 2.0
DATA 2,1, 3,1, 2,1, 3,1
DATA 3,1, 3,2, 3,1, 3,2
DATA 2,2, 3,2, 2,2, 3,2
DATA 2,1, 2,2, 2,1, 2,2

'Erikoinen 3.0
DATA 2,1, 3,1, 2,2, 2,2
DATA 2,1, 2,2, 3,2, 3,2
DATA 2,2, 3,2, 3,1, 3,1
DATA 2,1, 3,1, 3,2, 3,2

'Erikoinen 3.1
DATA 2,1, 3,1, 4,1, 4,1
DATA 3,1, 3,2, 3,3, 3,3
DATA 2,1, 3,1, 4,1, 4,1
DATA 3,1, 3,2, 3,3, 3,3

'Erikoinen 4.0
DATA 1,1, 1,2, 1,3, 1,4
DATA 1,1, 2,2, 3,3, 4,4
DATA 1,1, 2,1, 3,1, 4,1
DATA 1,4, 2,3, 3,2, 4,1

'SikSak  1.0
DATA 2,1, 2,2, 3,2, 3,3
DATA 2,2, 3,2, 3,1, 4,1
DATA 2,1, 2,2, 3,2, 3,3
DATA 2,2, 3,2, 3,1, 4,1

'SikSak  1.1
DATA 3,1, 3,2, 2,2, 2,3
DATA 3,2, 2,2, 2,1, 1,1
DATA 3,1, 3,2, 2,2, 2,3
DATA 3,2, 2,2, 2,1, 1,1

'éll-Ñ-vai-î 1.0
DATA 2,1, 2,2, 2,3, 3,3
DATA 1,2, 2,2, 3,2, 3,1
DATA 2,1, 3,1, 3,2, 3,3
DATA 2,1, 2,2, 3,1, 4,1

'éll-Ñ-vai-î 1.1
DATA 3,1, 3,2, 3,3, 2,3
DATA 4,2, 3,2, 2,2, 2,1
DATA 3,1, 2,1, 2,2, 2,3
DATA 3,1, 3,2, 2,1, 1,1


GameOver:
DATA "€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€"
DATA "≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤"
DATA "≤±±±±∞  ±±±±±∞ ±∞  ±∞ ±±±±±∞     ±±±   ±∞  ±∞ ±±±±±∞ ±±±±∞ ≤"
DATA "≤±∞     ±∞  ±∞ ±±∞±±∞ ±∞        ±±∞±±∞ ±∞  ±∞ ±∞     ±∞  ±∞≤"
DATA "≤±∞±±±∞ ±±±±±∞ ±∞±∞±∞ ±±±∞      ±∞  ±∞ ±±±±±∞ ±±±∞   ±±±±∞ ≤"
DATA "≤±∞  ±∞ ±∞  ±∞ ±∞  ±∞ ±∞        ±±∞±±∞  ±±±∞  ±∞     ±∞±∞≤"
DATA "≤±±±±±∞ ±∞  ±∞ ±∞  ±∞ ±±±±±∞     ±±±∞    ±∞   ±±±±±∞ ±∞ ±∞ ≤"
DATA "≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤"
DATA "€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€"
EndTExt:
DATA "Add-initial information for this game..."
DATA "This game was made by Joel Yliluoma -"
DATA "17.12.1993 in Kerava, Suomi Finland."
DATA "There is already a game named -"
DATA "JOELTris, and up to three versions of it."
DATA "This is also JOELTris, JOELTris IIII."
DATA "Why?"
DATA "JOELTris III is better than any of those elses..."
DATA "But -"
DATA "This is made by TANDY 1000 !!!!"
DATA "(C)olor (G)raphics (A)dapter is with it..."
DATA "How fast??"
DATA "In DOS, (There was Ms-Dos DOS 3.20) -"
DATA "you got to wait few seconds until textscreen -"
DATA "had updated."
DATA "So, This game is made by MS-DOS QBasic, -"
DATA "robbered from Ms-Dos 5.0 ..."
DATA "- And compiled with QuickBasic 4.5 Compiler."
DATA "You can imagine that it was very tiring to wait -"
DATA "HAS IT COMPILED IT JET!!"
DATA "Well, it compiled it in ten minutes (- surprised??)"
DATA "And I tested it -"
DATA "I surprised !! It was faster that the machine !!!"
DATA ""
DATA "The game is not so good, what YOU expected..."
DATA "(I think so...)"
DATA ""
DATA "You have all rights to register this."
DATA "How do you do it??"
DATA "Well, get 20$ somewhere."
DATA "And send it to address below:"
DATA "Joel Yliluoma"
DATA "Porvoonkatu 4C51"
DATA "04200 Kerava"
DATA "Suomi Finland"
DATA ""
DATA "Why would you register it??"
DATA "You would get source code, coded with QBasic."
DATA "File is JOELTRIS.BAS, and there is also JOELTRIS.LST,"
DATA "JOELTRIS.OBJ, JOELTRIS.MAP and -- and nothing more."
DATA "NO, YOU MUSTN'T REGISTER THIS, BUT IF YOU ARE -"
DATA "INTERESTED ABOUT SOURCE CODE, YOU CAN REGISTER IT."
DATA "  -- < BORING > --"
DATA ""
DATA ""
DATA "Ain't it ??"
DATA "Now I stop. BYE!!"

DataBase:
DATA "        JOELTris IIII         "
DATA " ∞∞∞∞ ∞∞∞∞∞ ∞∞∞∞∞ ∞∞ ∞∞ ∞∞∞∞  "
DATA "∞±±±± ±±±±± ±±±±± ±± ±± ±±±±∞ "
DATA "±±∞∞  ±∞∞ ±   ±    ± ±   ±∞±± "
DATA " ±±±∞ ±±± ∞   ±    ± ±   ±±±  "
DATA "∞∞∞±± ±∞∞∞±  ∞±∞   ±∞±  ∞±∞   "
DATA "±±±±  ±±±±±  ±±±   ±±±  ±±±  V 1.00"

ChangeSetup:
    KEY(15) OFF
    DEF SEG = &HB800: OldWind(4000) = x
    px = POS(1): py = CSRLIN
    FOR x = 0 TO 3999: OldWind(x) = PEEK(x): NEXT
DoNew:
    COLOR 9, 1: CLS
    RESTORE DataBase
    FOR x = 1 TO 7
        READ k$: LOCATE x, 5: PRINT k$;
    NEXT
    LOCATE 9, 1: PRINT "1:Area size (" + CHR$(26) + ") ["; Ml; "]";
    LOCATE 10, 1: PRINT "2:Area size () ["; Mk; "]";
    LOCATE 11, 1: PRINT "3:Normal piece color ["; Co(1); "]";
    LOCATE 12, 1: PRINT "4:Inversing piece color ["; Co(2); "]";
    LOCATE 13, 1: PRINT "5:Play sounds (" + CHR$(15 * ABS(Sni)) + ")";
    LOCATE 14, 1: PRINT "6:Set starting speed ["; Ss; "]";
    LOCATE 15, 1: PRINT "7:Write setup"
    LOCATE 16, 1: PRINT "8:Cancel changes"
    LOCATE 17, 1: PRINT "Choose number to edit, or press `Q' to quit. ";
Hae:
    DO
        RESTORE DataBase
        COLOR 15 - INT(RND * 3), 0
        FOR x = 1 TO 7
            READ k$: LOCATE x, 5: PRINT k$;
        NEXT
        x$ = INKEY$: IF UCASE$(x$) = "Q" THEN END ELSE x = VAL(x$)
    LOOP UNTIL x > 0 AND x < 9
    LOCATE 20, 1
    IF x = 8 THEN GOTO LogOff
    IF x = 7 THEN GOTO SaveFirst
    IF x = 6 THEN INPUT "Starting speed:", Ss
    IF x = 5 THEN
        LOCATE 13, 16: IF Sni = -1 THEN Sni = 0 ELSE Sni = -1
        PRINT CHR$(15 * ABS(Sni)); : GOTO Hae
    END IF
    IF x = 4 OR x = 3 THEN INPUT "New color:", Co(x - 2)
    IF x < 3 THEN PRINT "New size:";
    IF x = 1 THEN INPUT "", Ml
    IF x = 2 THEN INPUT "", Mk
    IF Ml > 20 THEN Ml = 12
    IF Ml < 4 THEN Ml = 12
    IF Mk > 25 THEN Mk = 25
    IF Mk < 5 THEN Mk = 25
    GOTO DoNew
SaveFirst:
    KILL "JOELTRI4.DAT"
    OPEN "JOELTRI4.DAT" FOR BINARY AS #1
    PUT #1, , Ss: PUT #1, , Ml: PUT #1, , Mk: PUT #1, , Co(1): PUT #1, , Co(2): CLOSE
    PRINT "Now ending...": WHILE INKEY$ <> "": WEND: WHILE INKEY$ = "": WEND: SYSTEM
LogOff:
    FOR x = 0 TO 3999: POKE x, OldWind(x): NEXT
    x = OldWind(4000): LOCATE py, px
    KEY(15) ON
    RETURN

SUB Center (y%, Text$)
    LOCATE y%, 41 - LEN(Text$) / 2: PRINT Text$;
END SUB

FUNCTION CheckRivit
    DIM Ali, Yli, Op, Ip: Yli = 0: Ali = 0: Op = 0
    FOR y = 2 TO Mk - 1
        FOR x = 20 - Ml / 2 + 1 TO 20 + Ml / 2 - 1
            IF Alue(x, y) = 0 THEN EXIT FOR
        NEXT
        IF Yli = 0 THEN IF x = 20 - Ml / 2 + 1 THEN Yli = y
        IF x = 20 + Ml / 2 THEN
            IF Ali < y THEN Ali = y: Op = 1
            Ip = Ip + 1: Lines = Lines + 1
            FOR x = 20 - Ml / 2 + 1 TO 20 + Ml / 2 - 1
                SOUND x + 37, .3
                Piki x, y, 0, 1
            NEXT
        END IF
    NEXT
    IF Ali > 0 THEN
        FOR Ip = Ip TO 1 STEP -1
            FOR y = Ali TO Yli STEP -1
                FOR x = 20 - Ml / 2 + 1 TO 20 + Ml / 2 - 1
                    Piki x, y, Alue(x, y - 1), 1
                NEXT
            NEXT
            FOR x = 20 - Ml / 2 + 1 TO 20 + Ml / 2 - 1
                Piki x, 2, 0, 1
            NEXT
        NEXT
    END IF
    SELECT CASE Ip
        CASE 0: CheckRivit = Fnr(50)
        CASE 1: CheckRivit = 100
        CASE 2: CheckRivit = 250
        CASE 3: CheckRivit = 400
        CASE 4: CheckRivit = 800
    END SELECT
END FUNCTION

SUB Help
    SCREEN 0, 0, 0, 0: WIDTH 80, 25: VIEW PRINT 1 TO 25
    DEF SEG = &HB800
    FOR x = 0 TO 3999: OldWind(x) = PEEK(x): NEXT
    COLOR 7, 1: CLS
    Center 1, "JOELTRIS IIII"
    Center 3, "Usage : JOELTRI4.EXE [/S] [/L] [{/H}|{/?}]"
    Center 5, "/S: if typed, then no sounds are heard in PC-speaker. "
    Center 6, "/L: if typed, then high-scores-list would be destroyed "
    Center 7, "/? or /H: this help screen"
    Center 10, "You mustn't type `/x', you can type exclusive `-x'."
    Center 15, "This version was last cracked by Joel Yliluoma 17.12.93"
    Center 16, "(Cracked?!?!?? Joel made this game!!)"
    Center 24, "More information you get, when you play this game. "
    Center 25, "Good luck, have a nice DOS˝ !!"
    WHILE INKEY$ <> "": WEND: WHILE INKEY$ = "": WEND
    FOR x = 0 TO 3999: POKE x, OldWind(x): NEXT
    SYSTEM
END SUB

SUB Piki (x, y, c1, SetFlag)
    DIM c2, c3
    DEF SEG = &HB800
    IF c1 = 0 THEN c3 = 7: c2 = 0 ELSE c2 = c1: c3 = c2
    IF c2 > 7 THEN c2 = c2 - 8
    IF c3 > 7 THEN c3 = c3 - 8
    POKE 1 + (y - 1) * 80 + (x - 1) * 2, c3 + 16 * c2
    IF SetFlag THEN Alue(x, y) = c1
END SUB

SUB PlayGame
    DIM LodX(4), LodY(4), Tar(5): Tar(5) = 1
    Score = 0
    WHILE GameOver = 0
        Mika = Fnr(MaxPala): Ase = 1: Lr = 0
        Nx = 18: Ny = 1: Colr = Co(1): IF RND > .9 THEN Colr = Co(2)
        FOR x = 1 TO 4
            LodX(x) = Nx + Pala(Mika, Ase, x).x
            LodY(x) = Ny + Pala(Mika, Ase, x).y
            Piki LodX(x), LodY(x), Colr, 0
        NEXT
        PalaMaassa = 0
        Space = 0
        WHILE PalaMaassa = 0
            IF ti >= Ss OR Space = 1 THEN ti = 0: y$ = CHR$(0) + "P": Lr = 0 ELSE y$ = INKEY$: Lr = 0: ti = ti + 1
            IF y$ = CHR$(0) + "K" THEN ti = ti + 1: IF VoiMenna(-1, 0) THEN Nx = Nx - 1: GOSUB PiirraPalaPaikkaan ELSE GOSUB Snoudi
            IF y$ = CHR$(0) + "M" THEN ti = ti + 1: IF VoiMenna(1, 0) THEN Nx = Nx + 1: GOSUB PiirraPalaPaikkaan ELSE GOSUB Snoudi
            IF y$ = CHR$(0) + "P" THEN ti = ti + 2: IF VoiMenna(0, 1) THEN Ny = Ny + 1: GOSUB PiirraPalaPaikkaan ELSE GOSUB Snoudi: PalaMaassa = 1: Lr = 1: GOSUB PiirraPalaPaikkaan
            IF y$ = CHR$(13) AND Colr = Co(2) THEN
                FOR x = 1 TO 4
                    Swappi Nx + Pala(Mika, 1, x).x, Ny + Pala(Mika, 1, x).y
                NEXT
                FOR x = 1 TO 4: SwapRivit(Nx + Pala(Mika, 1, x).x) = 0: NEXT
                FOR x = 1 TO 4: Piki Nx + Pala(Mika, Ase, x).x, Ny + Pala(Mika, Ase, x).y, 0, 1: NEXT
                GOTO ExitWhile
            END IF
            IF y$ = CHR$(0) + "H" THEN p = Pyorita: GOSUB PiirraPalaPaikkaan: IF p THEN GOSUB Snoudi
            IF y$ = " " THEN Space = 1
        WEND
ExitWhile:
        Score = Score + CheckRivit
        LOCATE 1, 1: PRINT "Game score:"
        LOCATE 2, 1: PRINT USING "###########"; Score
        LOCATE 3, 1: PRINT "Filled lines:"
        LOCATE 4, 1: PRINT USING "#####"; Lines

        IF Ny < 3 THEN GameOver = 1
    WEND
    EXIT SUB
PiirraPalaPaikkaan:
   
    FOR x = 1 TO 4
        FOR y = 1 TO 4
            IF LodX(x) = Nx + Pala(Mika, Ase, y).x AND LodY(x) = Ny + Pala(Mika, Ase, y).y THEN EXIT FOR
        NEXT
        IF y = 5 THEN
            Piki LodX(x), LodY(x), 0, 0
            FOR z = 1 TO 4: Tar(z) = 1: NEXT
        ELSE
            Tar(y) = 0
        END IF
    NEXT
    FOR x = 1 TO 4
        IF Lr = 0 THEN WHILE Tar(x) = 0: x = x + 1: WEND: IF x = 5 THEN EXIT FOR
        Piki Nx + Pala(Mika, Ase, x).x, Ny + Pala(Mika, Ase, x).y, Colr, Lr
    NEXT
    FOR x = 1 TO 4: LodX(x) = Nx + Pala(Mika, Ase, x).x: LodY(x) = Ny + Pala(Mika, Ase, x).y: NEXT
    RETURN
Snoudi:
    IF Sni THEN SOUND 37, 1: SOUND 40, .5: SOUND 100, .5
    RETURN
END SUB

FUNCTION Pyorita
    Ase = Ase + 1: IF Ase = 5 THEN Ase = 1
    IF VoiMenna(0, 0) THEN Pyorita = 0: EXIT FUNCTION ELSE Ase = Ase - 1: Pyorita = 1: IF Ase = 0 THEN Ase = 4
END FUNCTION

SUB Swappi (x, y)
    IF SwapRivit(x) = 1 THEN EXIT SUB ELSE SwapRivit(x) = 1
    FOR z = y TO 24
        IF Alue(x, z) = 0 THEN Alue(x, z) = Co(1) ELSE Alue(x, z) = 0
        Piki x, z, Alue(x, z), 1
    NEXT
END SUB

SUB TeeTausta
    FOR x = 20 - Ml / 2 TO 20 + Ml / 2
        LOCATE 1, x, 0: PRINT "";
        Alue(x, 1) = 1: Alue(x, Mk) = 1
        LOCATE Mk, x, 0: PRINT "";
    NEXT
    FOR y = 2 TO Mk - 1
        LOCATE y, 20 - Ml / 2, 0: PRINT ""; STRING$((20 + Ml / 2) - (20 - Ml / 2) - 1, ".");
        Alue(20 - Ml / 2, y) = 1: Alue(20 + Ml / 2, y) = 1
        LOCATE y, 20 + Ml / 2, 0: PRINT "";
    NEXT
END SUB

FUNCTION VoiMenna (Lx, Ly)
    FOR x = 1 TO 4
        IF Alue(Nx + Pala(Mika, Ase, x).x + Lx, Ny + Pala(Mika, Ase, x).y + Ly) > 0 THEN EXIT FOR
    NEXT
    IF x = 5 THEN VoiMenna = -1
END FUNCTION

