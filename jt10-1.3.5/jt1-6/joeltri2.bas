DECLARE SUB AlustaOhjausNappaimet (Players!)
DECLARE SUB TutkiRivit (d%, Players!)
DECLARE SUB CF (x%, y%, c1%, c2%, c$)
DECLARE SUB Pyorita (x%, y%, z%, d%)
DECLARE FUNCTION Lapi! (x%, y%, d%)
DECLARE SUB TeeTausta (Players!)
DECLARE SUB Set (x%, y%, c%, d%)
DECLARE SUB Pet (x%, y%, c%, d%)
DECLARE SUB TeeSaveFile (Fr%)
DECLARE SUB Poista (z%, d%)
Maara% = 7

DIM SHARED Alue%(12, 25, 2), Mika%(2), PoisMaara%(2), Riveja%(2), Pena AS INTEGER
DIM SHARED NytX%(4, 2), NytY%(4, 2), MuuX%(Maara%, 4, 4), MuuY%(Maara%, 4, 4)
DIM SHARED Pisteet(2) AS LONG, hi$(20), Tas%(20), Pis(20) AS LONG, Ylo$(2), Ala$(2), Vas$(2), Oik$(2)

CONST Reg = "REKISTER™IMŽT™N"

DEF FnR (x%) = INT(RND * x%) + 1
DEF SEG = &HB800
SCREEN 0: CLS
WIDTH 80, 25

RANDOMIZE TIMER * VAL(DATE$)
KysyPelaajat:
INPUT "Tuleeko toiselle pelaajalle rivej„, kun toinen saa rivej„ pois?", Penal$
IF LEFT$(Penal$, 1) = "Y" OR LEFT$(Penal$, 1) = "y" OR LEFT$(Penal$, 1) = "K" OR LEFT$(Penal$, 1) = "k" THEN Pena = 1
IF LEFT$(Reg, 1) = "R" THEN PRINT "TŽMŽ VERSIO ON REKISTER™IMŽT™N - - REKKAUSOHJEET FILESSŽ REGISTER.DOC": Players = 1: SLEEP 100: SLEEP 100 ELSE INPUT "Kuinka monta pelaajaa ? (1 tai 2)", Players
IF Players < 1 OR Players > 2 THEN GOTO KysyPelaajat
IF LEFT$(Reg, 1) <> "R" THEN IF Players = 1 THEN CLS : PRINT "Pelaat siis yksin.  Suosittelisin ett„ hankkisit pelin JOELTris, sen": PRINT "yksinpeli ei nyi; t„ss„ peliss„ nykii sek„ yksin- ett„ kaksinpeli.": PRINT  _
"Jos sattumalta keksit ratkaisun nykimisen poistoon, ": PRINT "ilmoita se pelin tekij„lle osoitteeseen :": PRINT : PRINT "Porvoonkatu 4C51": PRINT "04200 Kerava": PRINT "Suomi Finland": WHILE INKEY$ = "": PLAY  _
"mbt254o1ab>cde<aa2b>cdef<bb2>cdefgcc2defgaf": PLAY "mbt254o2ab>c<b>c<ag+aedec<b>c<ag+a2": PLAY "mbt254l4o2ba+bgf+ged+ec<b>c<g+gg+2": WEND: PLAY "mbt254l4o1b>cdp4ep4edc<b2l16b>c<b>c<b>c<b>c<b>c<bl2a2b2>c2e2a1p4<a"
AlustaOhjausNappaimet Players

TeeTausta Players

FOR a% = 1 TO Maara%
    FOR b% = 1 TO 4
        FOR c% = 1 TO 4
            READ MuuX%(a%, b%, c%), MuuY%(a%, b%, c%)
NEXT: NEXT: NEXT
FOR w% = 1 TO Players
    Uusi%(w%) = FnR(Maara%)
    Mika%(w%) = Uusi%(w%)
    PoisM%(w%) = 0
    Nopeus%(w%) = 0
    PalaM%(w%) = 0
    x%(w%) = 4: y%(w%) = 2
    Pyori%(w%) = 1
    Riveja%(w%) = 1
    FOR b% = 1 TO 4
        NytX%(b%, w%) = MuuX%(Mika%(w%), Pyori%(w%), b%): OldX%(b%, w%) = 4
        NytY%(b%, w%) = MuuY%(Mika%(w%), Pyori%(w%), b%): OldY%(b%, w%) = 1
    NEXT
NEXT
  
Looppi:
    FOR w% = 1 TO Players
        IF PalaM%(w%) AND PeliOhi%(w%) = 0 THEN
            'FOR op = 17 TO 1 STEP -1: FOR ap = 1 TO 7: SOUND ap * op + 37, .03: NEXT: NEXT
            IF y%(w%) < 4 THEN PeliOhi%(w%) = 1
            FOR b% = 1 TO 4
                Pet OldX%(b%, w%), OldY%(b%, w%), 0, w%
            NEXT
            FOR b% = 1 TO 4
                Set x%(w%) + NytX%(b%, w%), y%(w%) + NytY%(b%, w%), Mika%(w%), w%
            NEXT
            IF PalaM%(w%) = 1 THEN TutkiRivit w%, Players
            Mika%(w%) = Uusi%(w%)
            Uusi%(w%) = FnR(Maara%)
            PalaM%(w%) = 0: y%(w%) = 2: Pyori%(w%) = 1: x%(w%) = 4
            FOR b% = 1 TO 4
                NytX%(b%, w%) = MuuX%(Mika%(w%), Pyori%(w%), b%): OldX%(b%, w%) = 4
                NytY%(b%, w%) = MuuY%(Mika%(w%), Pyori%(w%), b%): OldY%(b%, w%) = 1
            NEXT
        END IF
        IF PeliOhi%(w%) = 1 AND Teot%(w%) = 0 THEN
            FOR gy% = 2 TO 19
                FOR gx% = 2 TO 11
                    Set gx%, gy%, 0, w%
                    SOUND gx% * gy% + 337, .5
            NEXT: NEXT
            IF w% = 1 THEN LOCATE 14, 10: PRINT "Game Over !" ELSE LOCATE 14, 63: PRINT "Game Over !"
            Teot%(w%) = 1
        END IF
    NEXT
    IF Players = 2 THEN
        IF PeliOhi%(1) = 1 AND PeliOhi%(2) = 1 THEN GOTO Listat
    ELSE
        IF PeliOhi%(1) = 1 THEN GOTO Listat
    END IF
    FOR w% = 1 TO Players
        IF PeliOhi%(w%) = 0 THEN
            FOR b% = 1 TO 4
                Pet OldX%(b%, w%), OldY%(b%, w%), 0, w%
            NEXT
            FOR b% = 1 TO 4
                Pet x%(w%) + NytX%(b%, w%), y%(w%) + NytY%(b%, w%), Mika%(w%), w%
                OldX%(b%, w%) = x%(w%) + NytX%(b%, w%)
                OldY%(b%, w%) = y%(w%) + NytY%(b%, w%)
            NEXT
            FOR ap = 5 TO 1 STEP -1
                FOR op = 1 TO 6
                    'SOUND ap * op + 37, .027
            NEXT: NEXT
        END IF
        IF PeliOhi%(w%) = 1 AND Eka% = 0 THEN IF w% = 1 THEN Eka% = 2 ELSE Eka% = 1
    NEXT
    FOR Viive% = 1 TO 790 - Nopeus%
        y$ = INKEY$
        FOR w% = 1 TO Players
            IF PeliOhi%(w%) = 0 THEN
                IF y$ = Ylo$(w%) THEN
                    Pyorita x%(w%), y%(w%), Pyori%(w%), w%: fg%(w%) = 1
                END IF
                IF y$ = Vas$(w%) THEN
                    FOR b% = 1 TO 4
                        IF Lapi(x%(w%) - 1 + NytX%(b%, w%), y%(w%) + NytY%(b%, w%), w%) = 0 THEN EXIT FOR
                    NEXT
                    IF b% = 5 THEN x%(w%) = x%(w%) - 1: fg%(w%) = 1
                END IF
                IF y$ = Oik$(w%) THEN
                    FOR b% = 1 TO 4
                        IF Lapi(x%(w%) + 1 + NytX%(b%, w%), y%(w%) + NytY%(b%, w%), w%) = 0 THEN EXIT FOR
                    NEXT
                    IF b% = 5 THEN x%(w%) = x%(w%) + 1: fg%(w%) = 1
                END IF
                IF y$ = Ala$(w%) THEN
                    FOR b% = 1 TO 4
                        IF Lapi(x%(w%) + NytX%(b%, w%), y%(w%) + 1 + NytY%(b%, w%), w%) = 0 THEN EXIT FOR
                    NEXT
                    IF b% = 5 THEN y%(w%) = y%(w%) + 1: fg%(w%) = 1
                END IF
            END IF
        NEXT
       FOR w% = 1 TO Players
           IF PeliOhi%(w%) = 0 AND fg%(w%) = 1 THEN
               FOR b% = 1 TO 4
                   Pet OldX%(b%, w%), OldY%(b%, w%), 0, w%
               NEXT
               FOR b% = 1 TO 4
                   Pet x%(w%) + NytX%(b%, w%), y%(w%) + NytY%(b%, w%), Mika%(w%), w%
                   OldX%(b%, w%) = x%(w%) + NytX%(b%, w%)
                   OldY%(b%, w%) = y%(w%) + NytY%(b%, w%)
               NEXT
               fg%(w%) = 0
               FOR ap = 5 TO 1 STEP -1
                   FOR op = 1 TO 6
                       'SOUND ap * op + 37, .027
               NEXT: NEXT
           END IF
           IF PeliOhi%(w%) = 1 AND Eka% = 0 THEN IF w% = 1 THEN Eka% = 2 ELSE Eka% = 1
       NEXT
    NEXT
    FOR w% = 1 TO Players
        FOR b% = 1 TO 4
            IF Lapi(x%(w%) + NytX%(b%, w%), y%(w%) + NytY%(b%, w%) + 1, w%) = 0 THEN EXIT FOR
        NEXT
        IF b% = 5 AND PeliOhi%(w%) = 0 THEN
            y%(w%) = y%(w%) + 1
        ELSE
            PalaM%(w%) = 1
        END IF
        IF Riveja%(w%) MOD 20 = 0 THEN Riveja%(w%) = Riveja%(w%) + 1: Pisteet(w%) = Pisteet(w%) + 1000: PLAY "mbt254l4o2e2fg2eg2fef2d2f2ga2fa2gfe2": PLAY "mbt254l4o3c2e2d2edc2ede2<g2>f2de2gfdgfe2c2": PLAY  _
"mbt254l4o3e1fedc1e1fedc1gfga2agfe2fedfedfedfedcdcd<a>d<a>dcdcd<a>d<a>dc1"
    NEXT
    LOCATE 1, 3: PRINT "Pisteet :"; Pisteet(1)
    IF Players = 2 THEN LOCATE 1, 50: PRINT "Pisteet :"; Pisteet(2)
GOTO Looppi

Listat:

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
IF Pisteet(Eka%) > 200 OR (Players = 1 AND Pisteet(1) > 200) THEN
    FOR a% = 1 TO Fr%
        IF Pis(a%) > Pisteet(Eka%) AND Pis(a% - 1) < Pisteet(Eka%) THEN
            FOR b% = Fr% TO a% STEP -1
                Pis(b% + 1) = Pis(b%)
                Tas%(b% + 1) = Tas%(b%)
                hi$(b% + 1) = hi$(b%)
            NEXT
UusiInput:
            INPUT "Nimi:", hi$(a%):                                                          FOR f% = 1 TO LEN(hi$(a%)): IF MID$(hi$(a%), f%, 1) = "å" THEN PRINT "Merkki 'å' ei k„y nimeen, yrit„ uudelleen !": GOTO UusiInput
            NEXT: Pis(a%) = Pisteet(Eka%): Tas%(a%) = Nopeus%: Fr% = Fr% + 1
            EXIT FOR
        END IF
    NEXT: CLS
ELSE
    PRINT "Pisteet j„iv„t alle kahden sadan, valitan !"
END IF
FOR a% = Fr% TO 1 STEP -1
    PRINT hi$(a%); " j„i tasolle"; Tas%(a%); " pistein"; Pis(a%)
NEXT
TeeSaveFile Fr%


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

SUB AlustaOhjausNappaimet (Players)
    WHILE INKEY$ <> "": WEND: CLS
    FOR a% = 1 TO Players
        LOCATE 1, 1: PRINT " Pelaajan "; a%; " yl”sp„in -nappi :          "
        Ylo$(a%) = INKEY$
        WHILE Ylo$(a%) = ""
            Ylo$(a%) = INKEY$
        WEND
        LOCATE 1, 1: PRINT " Pelaajan "; a%; " alasp„in -nappi :          "
        Ala$(a%) = INKEY$
        WHILE Ala$(a%) = ""
            Ala$(a%) = INKEY$
        WEND
        LOCATE 1, 1: PRINT " Pelaajan "; a%; " vasen -nappi :             "
        Vas$(a%) = INKEY$
        WHILE Vas$(a%) = ""
            Vas$(a%) = INKEY$
        WEND
        LOCATE 1, 1: PRINT " Pelaajan "; a%; " oikea -nappi :             "
        Oik$(a%) = INKEY$
        WHILE Oik$(a%) = ""
            Oik$(a%) = INKEY$
        WEND
    NEXT
END SUB

SUB Aseta (ed%, ta%, xd%, yd%, cg$)
    COLOR ed%, ta%
    LOCATE yd% + 10, xd% + 50: PRINT cg$
END SUB

SUB CF (x%, y%, c1%, c2%, c$)
    POKE (y% - 1) * 160 + (x% - 1) * 2 + 1, c1% + 16 * c2%
   
    POKE (y% - 1) * 160 + (x% - 1) * 2, ASC(c$)
END SUB

FUNCTION Lapi (x%, y%, d%)
    IF Alue%(x%, y%, d%) > 0 THEN Lapi = 0 ELSE Lapi = 1
END FUNCTION

SUB Pet (x%, y%, c%, d%)
    dy% = y% + 1
    IF d% = 1 THEN dx% = x% * 2 + 4 ELSE dx% = x% * 2 + 51
    IF c% = 0 THEN
        CF dx%, dy%, 4, 0, "."
        CF dx% - 1, dy%, 4, 0, " "
    ELSE
        CF dx%, dy%, c%, 0, "Û"
        CF dx% - 1, dy%, c%, 0, "Û"
    END IF

END SUB

SUB Poista (z%, d%)
    FOR a% = 2 TO 11
        Set a%, z%, 0, d%
    NEXT
    FOR a% = z% TO 3 STEP -1
        FOR b% = 2 TO 11
            Set b%, a%, Alue%(b%, a% - 1, d%), d%
            SOUND a% * b% + 37, .1
        NEXT
    NEXT

END SUB

SUB Pyorita (x%, y%, z%, d%)
    z% = z% + 1
    IF z% > 4 THEN z% = z% - 4
Uusiks:
    IF z% < 1 THEN z% = z% + 4
    FOR a% = 1 TO 4
        NytX%(a%, d%) = MuuX%(Mika%(d%), z%, a%)
        NytY%(a%, d%) = MuuY%(Mika%(d%), z%, a%)
        IF Lapi(x% + NytX%(a%, d%), y% + NytY%(a%, d%), d%) = 0 THEN
            z% = z% - 1: GOTO Uusiks
        END IF
    NEXT
END SUB

SUB Set (x%, y%, c%, d%)
    Alue%(x%, y%, d%) = c%
    dy% = y% + 1
    IF d% = 1 THEN dx% = x% * 2 + 4 ELSE dx% = x% * 2 + 51
    IF c% = 0 THEN
        CF dx%, dy%, 4, 0, "."
        CF dx% - 1, dy%, 4, 0, " "
    ELSE
        CF dx%, dy%, c%, 0, "Û"
        CF dx% - 1, dy%, c%, 0, "Û"
    END IF

END SUB

SUB TeeSaveFile (Fr%)
    CLOSE : OPEN "hisc.dat" FOR OUTPUT AS #1: COLOR 15, 6: PRINT #1, CHR$(Fr%); : FOR b% = 1 TO Fr%: FOR a% = 1 TO LEN(hi$(b%)): MID$(hi$(b%), a%, 1) = CHR$(255 - ASC(MID$(hi$(b%), a%, 1))): NEXT: PRINT #1, hi$(b%): PRINT #1, 900 - Tas%(b%): PRINT # _
1, Pis(b%): NEXT: CLOSE
END SUB

SUB TeeTausta (Players)
    COLOR 6: LOCATE 1, 1: PRINT STRING$(2000 - 160, 219)
    COLOR 14, 6: FOR a% = 1 TO 22: LOCATE a%, 3: PRINT "°°°±±±±²²²²ÛÛÛÛÛÛ²²²²±±±±°°°"; : NEXT
    IF Players = 2 THEN COLOR 14, 6: FOR a% = 1 TO 22: LOCATE a%, 50: PRINT "°°°±±±±²²²²ÛÛÛÛÛÛ²²²²±±±±°°°"; : NEXT
    FOR c% = 1 TO Players
        FOR a% = 1 TO 12
            Set a%, 1, 14, c%
            Set a%, 20, 14, c%
        NEXT
        FOR a% = 1 TO 20
            Set 1, a%, 14, c%
            Set 12, a%, 14, c%
        NEXT
        FOR a% = 2 TO 19
            FOR b% = 2 TO 11
                Set b%, a%, 0, c%
        NEXT: NEXT
    NEXT
END SUB

SUB TutkiRivit (d%, Players)
    COLOR , 6: LOCATE 23, 53: PRINT "                   "
    Riveja% = Pmra%
    FOR a% = 2 TO 19
        FOR b% = 2 TO 11
            IF Lapi(b%, a%, d%) THEN EXIT FOR
        NEXT
        IF b% = 12 THEN
            Pmra% = Pmra% + 1: Poista a%, d%
        END IF
    NEXT
    COLOR 12, 6
    gr% = INT(RND * 20) + 1
    SELECT CASE d%
        CASE 1:
            SELECT CASE Pmra% - Riveja%
                CASE 1: LOCATE 23, 6: PRINT "Yksi rivi = + 50 p  ": Pisteet(d%) = Pisteet(d%) + 50
                CASE 2: LOCATE 23, 6: PRINT "Kaksi rivi„ = + 150 p  ": Pisteet(d%) = Pisteet(d%) + 150
                CASE 3: LOCATE 23, 6: PRINT "Kolme rivi„ = + 300 p  ": Pisteet(d%) = Pisteet(d%) + 300
                CASE 4: LOCATE 23, 6: PRINT "Nelj„ rivi„ = + 600 p  ": Pisteet(d%) = Pisteet(d%) + 600
                CASE IS > 4: Pisteet(d%) = Pisteet(d%) + 19999
                CASE ELSE: LOCATE 23, 6: PRINT "Nolla rivi„ = +"; gr%; "p   ": Pisteet(d%) = Pisteet(d%) + gr%
            END SELECT
        CASE 2:
            SELECT CASE Pmra% - Riveja%
                CASE 1: LOCATE 23, 53: PRINT "Yksi rivi = + 50 p  ": Pisteet(d%) = Pisteet(d%) + 50
                CASE 2: LOCATE 23, 53: PRINT "Kaksi rivi„ = + 150 p  ": Pisteet(d%) = Pisteet(d%) + 150
                CASE 3: LOCATE 23, 53: PRINT "Kolme rivi„ = + 300 p  ": Pisteet(d%) = Pisteet(d%) + 300
                CASE 4: LOCATE 23, 53: PRINT "Nelj„ rivi„ = + 600 p  ": Pisteet(d%) = Pisteet(d%) + 600
                CASE IS > 4: Pisteet(d%) = Pisteet(d%) + 19999
                CASE ELSE: LOCATE 23, 53: PRINT "Nolla rivi„ = +"; gr%; "p   ": Pisteet(d%) = Pisteet(d%) + gr%
            END SELECT
    END SELECT
    IF Pmra% > 1 AND Players = 2 AND Pena = 1 THEN
        FOR h% = 1 TO Pmra% - 1
            FOR a% = 3 TO 18
                FOR b% = 2 TO 11
                    IF d% = 1 THEN Set b%, a%, Alue%(b%, a% + 1, 2), 2
                    IF d% = 2 THEN Set b%, a%, Alue%(b%, a% + 1, 1), 1
            NEXT: NEXT
            FOR a% = 2 TO 7
                IF d% = 1 THEN Set INT(RND * 9) + 2, 19, INT(RND * 8), 2
                IF d% = 2 THEN Set INT(RND * 9) + 2, 19, INT(RND * 8), 1
        NEXT: NEXT
    END IF
    IF Riveja% = Pmra% THEN Riveja% = 0 ELSE Riveja% = 1
END SUB

