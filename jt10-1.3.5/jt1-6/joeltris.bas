'
'
'
'
'
'
'
'              Q B A S I C     J O E L T r i s
'
'
'
'
'
'
'
'                   Paina  Shift+F5 aloittaaksesi pelin
'                Paina Alt,F,X,N mennÑksesi (4)DOSiin
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'
'

DECLARE SUB Aseta (ed%, ta%, xd%, yd%, cg$)
DECLARE SUB CF (X%, y%, c1%, c2%, c$)
DECLARE SUB Pyorita (X%, y%, z%)
DECLARE FUNCTION Lapi! (X%, y%)
DECLARE SUB TeeSaveFile (Fr%)
DECLARE SUB Set (X%, y%, c%)
DECLARE SUB Pet (X%, y%, c%)
DECLARE SUB Tutkirivit ()
DECLARE SUB TeeTausta ()
DECLARE SUB Poista (z%)

READ Maara%

Start = TIMER: FOR a = 1 TO 600: NEXT: Endi = TIMER
IF Endi - Start > .6 THEN
    PRINT "Pahoittelen, tÑmÑ kone on liian hidas"
    PRINT ", jotta voisit pelata peliÑ JOELTris."
    END
END IF

DIM SHARED Alue%(12, 25), Mika%, SetX%(4), SetY%(4), PoisMaara%, Riveja%
DIM SHARED NytX%(4), NytY%(4), MuuX%(Maara%, 4, 4), MuuY%(Maara%, 4, 4)
DIM SHARED Pisteet AS LONG, hi$(20), Tas%(20), Pis(20) AS LONG

DEF FnR (X%) = INT(RND * X%) + 1
DEF SEG = &HB800
SCREEN 0: CLS
WIDTH 80, 25

RANDOMIZE TIMER * VAL(DATE$)

TeeTausta
FOR a% = 1 TO Maara%
    FOR b% = 1 TO 4
        FOR c% = 1 TO 4
            READ MuuX%(a%, c%, b%), MuuY%(a%, c%, b%)
NEXT: NEXT: NEXT

Uusi% = FnR(Maara%)
PoisM% = 0
Nopeus% = 0
VisNopeus% = 0

WHILE PeliOhi% = 0
    Mika% = Uusi%
    Uusi% = FnR(Maara%)
    PalaM% = 0
    COLOR 15, 6: LOCATE 6, 36: PRINT "SEURAAVA"
    COLOR Uusi%, 0: LOCATE 7, 39
    PRINT "      "
    LOCATE 8, 39
    SELECT CASE Uusi%
        CASE 1: PRINT " ‹‹‹‹ "
        CASE 2: PRINT " ‹€ﬂ  "
        CASE 3: PRINT " ‹€‹  "
        CASE 4: PRINT " €‹‹  "
        CASE 5: PRINT " €€   "
        CASE 6: PRINT " ‹‹€  "
        CASE 7: PRINT " ﬂ€‹  "
        CASE 8: PRINT " €‹   "
        CASE 9: PRINT " ‹ﬂ‹  "
    END SELECT
    LOCATE 9, 39
    PRINT "      "
    X% = 3: y% = 1: Pyori% = 1
    FOR a% = 1 TO 4
        NytX%(a%) = MuuX%(Mika%, a%, 1): OldX%(a%) = 4
        NytY%(a%) = MuuY%(Mika%, a%, 1): OldY%(a%) = 4
    NEXT
    s% = 1
    SELECT CASE MoneskoPala%
        CASE 1:
            FOR a% = 1 TO 10
                Aseta 4, 6, 1, a%, STRING$(25, 219)
            NEXT
            Aseta 14, 12, 4, 5, "The JOELTris - game"
            Aseta 14, 12, 5, 6, "(C) Joel Yliluoma"
    END SELECT

    WHILE PalaM% = 0
Tsecki:
        FOR b% = 1 TO 4
            IF Lapi(X% + NytX%(b%), y% + NytY%(b%) + 1) = 0 THEN EXIT FOR
        NEXT
        IF b% = 5 THEN
            y% = y% + 1
        ELSE
            PalaM% = 1
            FOR b% = 1 TO 4
                Set OldX%(b%), OldY%(b%), 0
            NEXT
            FOR b% = 1 TO 4
                Set X% + NytX%(b%), y% + NytY%(b%), Mika%
            NEXT
            GOTO TutkimisenOhi
        END IF
        FOR a% = 1 TO 450 - Nopeus%
            IF y$ = " " AND UusPala = 0 THEN GOTO InkkarinOhi
            y$ = INKEY$
InkkarinOhi:
            IF y$ = CHR$(0) + "H" THEN
                Pyorita X%, y%, Pyori%: s% = 1
            END IF
            IF y$ = CHR$(0) + "P" OR y$ = " " THEN s% = 1: UusPala = 0: GOTO Tsecki
            IF y$ = CHR$(0) + "M" THEN
                FOR b% = 1 TO 4
                    IF Lapi(X% + NytX%(b%) + 1, y% + NytY%(b%)) = 0 THEN EXIT FOR
                NEXT
                IF b% = 5 THEN X% = X% + 1: s% = 1
            END IF
            IF y$ = CHR$(0) + "K" THEN
                FOR b% = 1 TO 4
                    IF Lapi(X% + NytX%(b%) - 1, y% + NytY%(b%)) = 0 THEN EXIT FOR
                NEXT
                IF b% = 5 THEN X% = X% - 1: s% = 1
            END IF
            IF s% = 1 THEN
                FOR b% = 1 TO 4
                    Pet OldX%(b%), OldY%(b%), 0
                NEXT
                FOR b% = 1 TO 4
                    Pet X% + NytX%(b%), y% + NytY%(b%), Mika%
                    OldX%(b%) = X% + NytX%(b%)
                    OldY%(b%) = y% + NytY%(b%)
                NEXT
                FOR ap = 5 TO 1 STEP -1
                        FOR op = 1 TO 6
                            SOUND ap * op + 37, .027
                NEXT: NEXT
                s% = 0
            END IF
            IF y$ = CHR$(0) + ";" THEN COLOR 30, 6: LOCATE 5, 38: PRINT "Tauko": SLEEP 80: LOCATE 5, 38: PRINT "     "
        NEXT
TutkimisenOhi:
        s% = 1
    WEND
    DO: LOOP UNTIL INKEY$ = ""
    FOR op = 17 TO 1 STEP -1: FOR ap = 1 TO 7: SOUND ap * op + 37, .03: NEXT: NEXT
    UusPala = 1
    MoneskoPala% = MoneskoPala% + 1
    IF y% < 2 THEN PeliOhi% = 1
    Tutkirivit
    IF INT(RND * 13) = 1 THEN
        FOR a% = 3 TO 18
            FOR b% = 2 TO 11
                Set b%, a%, Alue%(b%, a% + 1)
            NEXT
        NEXT
        FOR a% = 2 TO 11
            Set a%, 19, INT(RND * 8)
        NEXT
    END IF
    VisNopeus% = Nopeus% / 4
    IF MoneskoPala% MOD 10 = 0 THEN MoneskoPala% = MoneskoPala% + 1: Nopeus% = Nopeus% + 4
    COLOR 4, 6: LOCATE 21, 51: PRINT STRING$(25, 219);
    LOCATE 22, 51: PRINT STRING$(25, 219);
    COLOR 15, 4: LOCATE 21, 51: PRINT "Pisteet :"; Pisteet
    LOCATE 22, 51: PRINT "Nopeus :"; VisNopeus%; "/62"
WEND
OPEN "Hisc.dat" FOR INPUT AS #1: CLS
Fr% = ASC(INPUT$(1, #1))
FOR a% = 1 TO Fr%
    INPUT #1, hi$(a%), Tas%(a%), Pis(a%)
    FOR b% = 1 TO LEN(hi$(a%))
        MID$(hi$(a%), b%, 1) = CHR$(255 - ASC(MID$(hi$(a%), b%, 1)))
    NEXT
    Tas%(a%) = 900 - Tas%(a%)
NEXT

' ***********************
' *  Datojen lajittelu  *
' ***********************

Limit = Fr%: DO: Switch = 0: FOR a% = 1 TO (Limit - 1): IF Pis(a%) > Pis(a% + 1) THEN SWAP Pis(a%), Pis(a% + 1): SWAP Tas%(a%), Tas%(a% + 1): SWAP hi$(a%), hi$(a% + 1): Switch = a%
NEXT: Limit = Switch: LOOP WHILE Switch
IF Pisteet > 200 THEN
    FOR a% = 1 TO Fr%
        IF (Pis(a%) > Pisteet AND Pis(a% - 1) < Pisteet) OR (a% = Fr% AND Pis(a% + 1) < Pisteet) THEN
            FOR b% = Fr% TO a% STEP -1
                Pis(b% + 1) = Pis(b%)
                Tas%(b% + 1) = Tas%(b%)
                hi$(b% + 1) = hi$(b%)
            NEXT
UusiInput:
            INPUT "Nimi:", hi$(a%):                                                          FOR F% = 1 TO LEN(hi$(a%)): IF MID$(hi$(a%), F%, 1) = "Â" THEN PRINT "Merkki 'Â' ei kÑy nimeen, yritÑ uudelleen !": GOTO UusiInput
            NEXT: Pis(a%) = Pisteet: Tas%(a%) = VisNopeus%: Fr% = Fr% + 1
            EXIT FOR
        END IF
    NEXT: CLS
    Limit = Fr%: DO: Switch = 0: FOR a% = 1 TO (Limit - 1): IF Pis(a%) > Pis(a% + 1) THEN SWAP Pis(a%), Pis(a% + 1): SWAP Tas%(a%), Tas%(a% + 1): SWAP hi$(a%), hi$(a% + 1): Switch = a%
    NEXT: Limit = Switch: LOOP WHILE Switch
ELSE
    PRINT "Pisteet jÑivÑt alle kahden sadan, valitan !"
END IF
FOR a% = Fr% TO 1 STEP -1
    PRINT Fr% + 1 - a%; "."; hi$(a%); " jÑi tasolle"; Tas%(a%); " pistein"; Pis(a%)
NEXT
TeeSaveFile Fr%

DATA 9

DATA 3,1, 3,2, 3,3, 3,4
DATA 1,3, 2,3, 3,3, 4,3
DATA 2,1, 2,2, 2,3, 2,4
DATA 1,2, 2,2, 3,2, 4,2

DATA 3,3, 4,3, 2,4, 3,4
DATA 2,2, 3,3, 2,3, 3,4
DATA 3,3, 4,3, 2,4, 3,4
DATA 2,2, 3,3, 2,3, 3,4

DATA 3,2, 3,3, 2,3, 4,3
DATA 4,1, 3,2, 4,2, 4,3
DATA 2,2, 3,2, 4,2, 3,3
DATA 2,2, 2,3, 2,4, 3,3

DATA 2,2, 2,3, 3,3, 4,3
DATA 3,2, 3,3, 3,4, 2,4
DATA 1,2, 2,2, 3,2, 3,3
DATA 2,1, 3,1, 2,2, 2,3

DATA 2,2, 3,2, 3,3, 2,3
DATA 2,2, 3,2, 3,3, 2,3
DATA 2,2, 3,2, 3,3, 2,3
DATA 2,2, 3,2, 3,3, 2,3

DATA 2,3, 3,3, 4,3, 2,4
DATA 3,2, 3,3, 3,4, 4,4
DATA 3,1, 1,2, 2,2, 3,2
DATA 1,1, 2,1, 2,2, 2,3

DATA 2,2, 3,2, 3,3, 4,3
DATA 4,2, 4,3, 3,3, 3,4
DATA 2,2, 3,2, 3,3, 4,3
DATA 4,2, 4,3, 3,3, 3,4

DATA 2,2, 3,2, 2,3, 2,3
DATA 2,2, 3,2, 3,3, 3,3
DATA 3,2, 3,3, 2,3, 2,3
DATA 2,2, 2,3, 3,3, 3,3

DATA 1,1, 2,2, 3,1, 3,1
DATA 1,1, 2,2, 1,3, 1,3
DATA 2,1, 1,2, 3,2, 3,2
DATA 2,1, 1,2, 2,3, 2,3

SUB Aseta (ed%, ta%, xd%, yd%, cg$)
    COLOR ed%, ta%
    LOCATE yd% + 10, xd% + 50: PRINT cg$
END SUB

SUB CF (X%, y%, c1%, c2%, c$)
    POKE (y% - 1) * 160 + (X% - 1) * 2 + 1, c1% + 16 * c2%
    POKE (y% - 1) * 160 + (X% - 1) * 2, ASC(c$)
END SUB

FUNCTION Lapi (X%, y%)
    IF Alue%(X%, y%) > 0 THEN Lapi = 0 ELSE Lapi = 1
END FUNCTION

SUB Pet (X%, y%, c%)
    dy% = y% + 1
    dx% = X% * 2 + 4
    IF c% = 0 THEN
        CF dx%, dy%, 4, 0, "."
        CF dx% - 1, dy%, 4, 0, " "
    ELSE
        CF dx%, dy%, c%, 0, "€"
        CF dx% - 1, dy%, c%, 0, "€"
    END IF

END SUB

SUB Poista (z%)
    FOR a% = z% TO 3 STEP -1
        FOR b% = 2 TO 11
            Set b%, a%, Alue%(b%, a% - 1)
            SOUND a% * b% + 37, .1
        NEXT
    NEXT
END SUB

SUB Pyorita (X%, y%, z%)
    z% = z% + 1
    IF z% > 4 THEN z% = z% - 4
Uusiks:
    IF z% < 1 THEN z% = z% + 4
    FOR a% = 1 TO 4
        NytX%(a%) = MuuX%(Mika%, a%, z%)
        NytY%(a%) = MuuY%(Mika%, a%, z%)
        IF Lapi(X% + NytX%(a%), y% + NytY%(a%)) = 0 THEN
            z% = z% - 1: GOTO Uusiks
        END IF
        SOUND a% * 487, .03
    NEXT
END SUB

SUB Set (X%, y%, c%)
    Alue%(X%, y%) = c%
    dy% = y% + 1
    dx% = X% * 2 + 4
    IF c% = 0 THEN
        CF dx%, dy%, 4, 0, "."
        CF dx% - 1, dy%, 4, 0, " "
    ELSE
        CF dx%, dy%, c%, 0, "€"
        CF dx% - 1, dy%, c%, 0, "€"
    END IF

END SUB

SUB TeeSaveFile (Fr%)
    CLOSE : OPEN "hisc.dat" FOR OUTPUT AS #1: COLOR 15, 6: PRINT #1, CHR$(Fr%); : FOR b% = 1 TO Fr%: FOR a% = 1 TO LEN(hi$(b%)): MID$(hi$(b%), a%, 1) = CHR$(255 - ASC(MID$(hi$(b%), a%, 1))): NEXT: PRINT #1, hi$(b%): PRINT #1, 900 - Tas%(b%): PRINT # _
1, Pis(b%): NEXT: CLOSE
END SUB

SUB TeeTausta
    COLOR 6: LOCATE 1, 1: PRINT STRING$(2000 - 160, 219)
    COLOR 14, 6: FOR a% = 1 TO 22: LOCATE a%, 3: PRINT "∞∞∞±±±±≤≤≤≤≤≤≤≤≤≤≤≤≤≤±±±±∞∞∞"; : NEXT
    FOR a% = 1 TO 12
        Set a%, 1, 14
        Set a%, 20, 14
    NEXT
    FOR a% = 1 TO 20
        Set 1, a%, 14
        Set 12, a%, 14
    NEXT
    FOR a% = 2 TO 19
        FOR b% = 2 TO 11
            Set b%, a%, 0
    NEXT: NEXT
END SUB

SUB Tutkirivit
    COLOR , 6: LOCATE 23, 53: PRINT "                   "
    Riveja% = Pmra%
    FOR a% = 2 TO 19
        FOR b% = 2 TO 11
            IF Lapi(b%, a%) THEN EXIT FOR
        NEXT
        IF b% = 12 THEN
            Pmra% = Pmra% + 1: Poista a%
        END IF
    NEXT
    COLOR 12, 6
    gr% = INT(RND * 20) + 1
    SELECT CASE Pmra% - Riveja%
        CASE 1: LOCATE 23, 53: PRINT "Yksi rivi = + 50 p  ": Pisteet = Pisteet + 50
        CASE 2: LOCATE 23, 53: PRINT "Kaksi riviÑ = + 150 p  ": Pisteet = Pisteet + 150
        CASE 3: LOCATE 23, 53: PRINT "Kolme riviÑ = + 300 p  ": Pisteet = Pisteet + 300
        CASE 4: LOCATE 23, 53: PRINT "NeljÑ riviÑ = + 600 p  ": Pisteet = Pisteet + 600
        CASE ELSE: LOCATE 23, 53: PRINT "Nolla riviÑ = +"; gr%; "p   ": Pisteet = Pisteet + gr%
    END SELECT
    IF Riveja% = Pmra% THEN Riveja% = 0 ELSE Riveja% = 1
END SUB

