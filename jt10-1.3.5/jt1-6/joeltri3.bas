DECLARE SUB Pelaa ()
DECLARE SUB TeeTausta ()
DECLARE SUB SetPaletti ()
DECLARE FUNCTION Inke! ()
DECLARE SUB PoistaRivi (a%)
DECLARE SUB ClearPalette ()
DECLARE SUB Pal (c AS INTEGER)
DECLARE FUNCTION CheckLines% ()
DECLARE FUNCTION Pyorita! (z!, x!, y!)
DECLARE FUNCTION PaaseekoLapi% (x!, y!)
DECLARE SUB StrPrint (x%, y%, jono$, Koko%, Colour%)
DECLARE SUB Pet (x AS INTEGER, y AS INTEGER, What AS INTEGER, c AS INTEGER)
DECLARE SUB Set (x AS INTEGER, y AS INTEGER, What AS INTEGER, c AS INTEGER)
DECLARE SUB TeePala (x AS INTEGER, y AS INTEGER, What AS INTEGER, c AS INTEGER)

TYPE Pregs
	r AS INTEGER
	g AS INTEGER
	b AS INTEGER
END TYPE
TYPE Alue
	c AS INTEGER
	What AS INTEGER
END TYPE
TYPE PalaCoord
	x AS INTEGER
	y AS INTEGER
END TYPE

DIM SHARED Pr(15) AS Pregs, Prg AS Pregs, AlueKorkeus

OPEN "FieldDat.jt3" FOR BINARY AS #1
IF LOF(1) = 0 THEN
	'IF UCASE$(LEFT$(COMMAND$, 2)) = "/S" THEN
	'    AlueKorkeus = VAL(RIGHT$(COMMAND$, LEN(COMMAND$) - 2))
	'ELSE
		AlueKorkeus = 25
	'END IF
	l = AlueKorkeus - 5: PUT #1, , l
ELSE
	'IF UCASE$(LEFT$(COMMAND$, 2)) = "/S" THEN
	'    AlueKorkeus = VAL(RIGHT$(COMMAND$, LEN(COMMAND$) - 2))
	'ELSE
		GET #1, , AlueKorkeus: AlueKorkeus = AlueKorkeus + 5
	'END IF
END IF
CLOSE
DIM SHARED Alue(18, 10 + AlueKorkeus) AS Alue, Uusi, Mika

CONST True = 1
CONST False = NOT True
CONST None = 0
DIM SHARED Vari(1 TO 6)

RANDOMIZE TIMER * VAL(DATE$)

DIM SHARED Note(43)
f = 415.4
FOR a = 0 TO 73
	f = f * 2 ^ (1 / 12)
	l = a MOD 12
	IF l = 1 OR l = 3 OR l = 6 OR l = 8 OR l = 10 THEN  ELSE t = t + 1: Note(t) = f
NEXT

'FOR a = 1 TO 6
'    PLAY "mlmbt254l4o1 a>cea< a>cea< a>cea< a>cea <egb>e <egb>e <egb>e <egb>e <dfa>d <dfa>d <dfa>d <dfa>d <eg+b>e <eg+b>e <eg+b>e <eg+b>e"
'    PRINT a
'NEXT
'
'END

DIM SHARED Paloja
READ Paloja
DIM SHARED Pala(5, 4, Paloja) AS PalaCoord
DIM SHARED NPala(5) AS PalaCoord

FOR a% = 1 TO Paloja
	FOR b% = 1 TO 4
		FOR c% = 1 TO 5
			READ Pala(c%, b%, a%).x, Pala(c%, b%, a%).y
NEXT c%, b%, a%
FOR a = 1 TO 6: READ Vari(a): NEXT
DEF fnr (x) = INT(RND * x) + 1
SCREEN 12
LOCATE , , 0
SetPaletti
TeeTausta
KEY 16, CHR$(4) + CHR$(&H46)
ON KEY(16) GOSUB Poisssss
KEY(16) ON
KEY 15, CHR$(0) + CHR$(157)
ON KEY(15) GOSUB Paused
KEY(15) ON

Pelaa
END


DATA 14

DATA 2,1, 3,1, 1,2, 2,2, 1,3
DATA 1,1, 2,1, 2,2, 3,2, 3,3
DATA 3,1, 3,2, 2,2, 1,3, 2,3
DATA 1,1, 2,2, 3,3, 1,2, 2,3

DATA 1,2, 2,2, 2,1, 3,2, 2,3
DATA 1,2, 2,2, 2,1, 3,2, 2,3
DATA 1,2, 2,2, 2,1, 3,2, 2,3
DATA 1,2, 2,2, 2,1, 3,2, 2,3

DATA 2,1, 3,1, 2,2, 2,3, 1,3
DATA 1,1, 1,2, 2,2, 3,2, 3,3
DATA 2,1, 3,1, 2,2, 2,3, 1,3
DATA 1,1, 1,2, 2,2, 3,2, 3,3

DATA 1,1, 1,2, 1,3, 1,4, 1,5
DATA 1,1, 2,1, 3,1, 4,1, 5,1
DATA 1,1, 1,2, 1,3, 1,4, 1,5
DATA 1,1, 2,1, 3,1, 4,1, 5,1

DATA 1,2, 2,1, 2,2, 3,2, 3,3
DATA 2,1, 2,2, 3,2, 1,3, 2,3
DATA 1,1, 2,2, 1,2, 3,2, 2,3
DATA 2,1, 3,1, 1,2, 2,2, 2,3

DATA 1,1, 2,1, 3,1, 1,2, 3,2
DATA 1,1, 2,1, 1,2, 1,3, 2,3
DATA 1,1, 2,2, 3,1, 1,2, 3,2
DATA 1,1, 2,2, 2,1, 1,3, 2,3

DATA 1,1, 2,2, 2,1, 3,1, 2,3
DATA 1,2, 2,2, 3,2, 3,1, 3,3
DATA 2,1, 2,2, 2,3, 1,3, 3,3
DATA 1,1, 2,2, 1,3, 1,2, 3,2

DATA 3,1, 1,2, 2,2, 3,2, 2,3
DATA 1,1, 2,1, 2,2, 3,2, 2,3
DATA 2,1, 2,2, 1,2, 3,2, 1,3
DATA 2,1, 2,2, 1,2, 2,3, 3,3

DATA 1,1, 2,1, 3,1, 1,2, 2,2
DATA 1,1, 2,1, 1,2, 2,2, 2,3
DATA 2,1, 3,1, 1,2, 2,2, 3,2
DATA 1,1, 2,2, 1,2, 1,3, 2,3

DATA 1,1, 2,1, 1,2, 2,2, 3,2
DATA 1,1, 2,1, 1,2, 2,2, 1,3
DATA 1,1, 2,1, 3,1, 2,2, 3,2
DATA 2,1, 1,2, 2,2, 2,3, 1,3

DATA 1,1, 2,1, 3,1, 1,2, 1,3
DATA 1,1, 1,2, 1,3, 2,3, 3,3
DATA 3,1, 3,2, 3,3, 2,3, 1,3
DATA 1,1, 2,1, 3,1, 3,2, 3,3

DATA 1,1, 2,1, 2,2, 2,3, 3,3
DATA 3,1, 3,2, 2,2, 1,2, 1,3
DATA 1,1, 2,1, 2,2, 2,3, 3,3
DATA 3,1, 3,2, 2,2, 1,2, 1,3

DATA 1,1, 2,1, 3,1, 4,1, 1,2
DATA 1,1, 1,2, 1,3, 1,4, 2,4
DATA 1,2, 2,2, 3,2, 4,2, 4,1
DATA 1,1, 2,1, 2,2, 2,3, 2,4

DATA 1,1, 1,2, 2,2, 3,2, 4,2
DATA 2,1, 2,2, 2,3, 2,4, 1,4
DATA 1,1, 2,1, 3,1, 4,1, 4,2
DATA 1,1, 2,1, 1,2, 1,3, 1,4




DATA 1,2,3,7,8,9

Poisssss:
	ClearPalette
	CLS
	FOR x% = 0 TO 624 STEP 16
		TeePala x%, 0, 1, 7
		TeePala x%, 400, 1, 7
	NEXT
	SetPaletti
	StrPrint 60, 60, "DO YOU REALLY WANT TO QUIT THE GAME ?", 3, 4
	y$ = INPUT$(1)
	IF UCASE$(y$) = "Y" THEN
		SCREEN 0: END
	ELSE
		TeeTausta
		ClearPalette
		FOR y% = 6 TO AlueKorkeus
			FOR x% = 2 TO 17
				Set x%, y%, Alue(x%, y%).What, Alue(x%, y%).c
		NEXT: NEXT
	END IF
	SetPaletti
RETURN

Paused:
	ClearPalette
	WHILE INKEY$ = "": WEND
	SetPaletti
RETURN

FUNCTION CheckLines%
	CheckLines% = 0
	FOR a% = 6 TO AlueKorkeus
		y$ = INKEY$
		FOR b = 2 TO 17
			IF PaaseekoLapi%(b, CSNG(a%)) THEN EXIT FOR
		NEXT
		IF b = 18 THEN PoistaRivi a%: CheckLines% = CheckLines% + 1
	NEXT
END FUNCTION

SUB ClearPalette
	Prg.r = 0: Prg.g = 0: Prg.b = 0
	FOR a% = 15 TO 2 STEP -1: Pal a%: NEXT
END SUB

FUNCTION PaaseekoLapi% (x, y)
	PaaseekoLapi% = Alue(x, y).c = 0
END FUNCTION

SUB Pal (c AS INTEGER)
	PALETTE c, Prg.r + 256 * Prg.g + 65536 * Prg.b
	Pr(c).r = Prg.r
	Pr(c).g = Prg.g
	Pr(c).b = Prg.b
END SUB

SUB Pelaa
	DIM y$(0), OldCoord(5) AS PalaCoord
	Uusi = fnr(Paloja)
	Nopeus = 1000
	WHILE PeliOhi = 0
		Mika = Uusi
		Nopeus = Nopeus - 10
		Uusi = fnr(Paloja)
		x = 8: y = 5: z = 1
		FOR a = 1 TO 5
			NPala(a).x = Pala(a, z, Mika).x
			NPala(a).y = Pala(a, z, Mika).y
		NEXT
		Colour = Vari(fnr(6))
		FOR a = 1 TO 5
			IF PaaseekoLapi(x + NPala(a).x, y + 1 + NPala(a).y) = 0 THEN EXIT FOR
		NEXT
		IF a = 6 THEN y = y + 1: s = 1 ELSE PeliOhi = 1
		
		StrPrint 400, 140, "NEXT BLOCK : ", 2, 4
		UudenPalikanValeVari = Vari(fnr(6))
		LINE (447, 160)-(528, 240), 10, BF
		FOR a = 1 TO 5
			Pet 400 / 16 + Pala(a, 1, Uusi).x, 160 / 16 + Pala(a, 1, Uusi).y, 5, CINT(UudenPalikanValeVari)
		NEXT
		PalaMaassa = 0
		WHILE PalaMaassa = 0
			FOR b = 1 TO Nopeus
				y$ = INKEY$
				SELECT CASE y$
					CASE CHR$(0) + "H":
						IF Pyorita(z, x, y) = 1 THEN s = 1
					CASE CHR$(0) + "K":
						FOR a = 1 TO 5
							IF PaaseekoLapi(x - 1 + NPala(a).x, y + NPala(a).y) = 0 THEN EXIT FOR
						NEXT
						IF a = 6 THEN x = x - 1: s = 1
					CASE CHR$(0) + "M":
						FOR a = 1 TO 5
							IF PaaseekoLapi(x + 1 + NPala(a).x, y + NPala(a).y) = 0 THEN EXIT FOR
						NEXT
						IF a = 6 THEN x = x + 1: s = 1
					CASE CHR$(0) + "P":
						FOR a = 1 TO 5
							IF PaaseekoLapi(x + NPala(a).x, y + 1 + NPala(a).y) = 0 THEN EXIT FOR
						NEXT
						IF a = 6 THEN y = y + 1: s = 1 ELSE PalaMaassa = 1
				END SELECT
				IF s = 1 AND PalaMaassa = 0 THEN
					FOR a = 1 TO 5
						Pet OldCoord(a).x, OldCoord(a).y, 2, 0
					NEXT
					FOR a = 1 TO 5
						OldCoord(a).x = x + NPala(a).x
						OldCoord(a).y = y + NPala(a).y
						Pet OldCoord(a).x, OldCoord(a).y, 2, CINT(Colour)
					NEXT
					s = 0
				END IF
			NEXT
			FOR a = 1 TO 5
				IF PaaseekoLapi(x + NPala(a).x, y + 1 + NPala(a).y) = 0 THEN EXIT FOR
			NEXT
			IF a = 6 THEN y = y + 1: s = 1 ELSE PalaMaassa = 1
		WEND
		FOR a = 1 TO 5
			Pet OldCoord(a).x, OldCoord(a).y, 2, 0
		NEXT
		FOR a = 1 TO 5
			OldCoord(a).x = 8
			OldCoord(a).y = 0
			Set x + NPala(a).x, y + NPala(a).y, 2, CINT(Colour)
		NEXT
		Rivit = Rivit + CheckLines%
		IF OldRivit - Rivit = 0 THEN Score = Score + fnr(50) ELSE Score = Score + (OldRivit - Rivit) * 100
		StrPrint 400, 100, "LINES : " + STR$(OldRivit), 2, 10
		StrPrint 400, 100, "LINES : " + STR$(Rivit), 2, 4
		StrPrint 400, 120, "SCORE : " + STR$(OldScore), 2, 10
		StrPrint 400, 120, "SCORE : " + STR$(Score), 2, 4

		OldScore = Score
		OldRivit = Rivit
	WEND
	LINE (18 * 16 + 31, 16 * 5)-(63, AlueKorkeus * 16 - 1), 0, BF
	StrPrint 80, 200, "GAME OVER", 5, 4
	StrPrint 79, 199, "GAME OVER", 5, 1
	StrPrint 78, 198, "GAME OVER", 5, 9
	StrPrint 77, 197, "GAME OVER", 5, 12
	FOR a = 1 TO LEN(COMMAND$) - 2
		IF MID$(COMMAND$, a, 2) = "/„" OR MID$(COMMAND$, a, 2) = "/Ž" THEN PLAY "mnmbt254o1l4ffef>cp4<fep4fef>cp4<feffef>cp4<fe>l6cp4<b-p6ap6gp6fp6fep6dp6c2"
	NEXT
END SUB

SUB Pet (x AS INTEGER, y AS INTEGER, What AS INTEGER, c AS INTEGER)
	TeePala x * 16 + 31, ((y - 1) * 16), What, c
END SUB

SUB Plei (Ch1, Cnt1, Ch2, Cnt2)
	d1 = 0: d2 = 0
	DO
		d1 = d1 + .07
		d2 = d2 + .07
		IF d1 <= Cnt1 THEN IF d2 >= Cnt2 THEN SOUND Ch1, Cnt1 - d1: EXIT SUB ELSE SOUND Ch1, .2
		IF d2 <= Cnt2 THEN IF d1 >= Cnt1 THEN SOUND Ch2, Cnt2 - d2: EXIT SUB ELSE SOUND Ch2, .2
	LOOP UNTIL d1 >= Cnt1 AND d2 >= Cnt2
END SUB

SUB PoistaRivi (a%)
	FOR b% = 2 TO 17
		Set b%, a%, 0, 0
	NEXT
	FOR c% = a% TO 7 STEP -1
		SOUND 100, .03
		FOR b% = 2 TO 17
			Set b%, c%, Alue(b%, c% - 1).What, Alue(b%, c% - 1).c
		NEXT
	NEXT
END SUB

FUNCTION Pyorita (z, x, y)
	DIM e AS INTEGER
	e = CINT(z)
	e = e + 1
	IF e > 4 THEN e = e - 4
	IF e < 1 THEN e = e + 4
	FOR a = 1 TO 5
		IF PaaseekoLapi(x + Pala(a, e, Mika).x, y + Pala(a, e, Mika).y) = 0 THEN EXIT FOR
	NEXT: Pyorita = 0
	IF a = 6 THEN
		FOR a = 1 TO 5
			NPala(a).x = Pala(a, e, Mika).x
			NPala(a).y = Pala(a, e, Mika).y
		NEXT
		z = e: Pyorita = 1
	END IF
END FUNCTION

SUB Set (x AS INTEGER, y AS INTEGER, What AS INTEGER, c AS INTEGER)
	TeePala x * 16 + 31, ((y - 1) * 16), What, c
	Alue(x, y).c = c
	Alue(x, y).What = What
END SUB

SUB SetPaletti
	Prg.r = 63: Prg.g = 63: Prg.b = 0: Pal 4
	Prg.r = 63: Prg.g = 0: Prg.b = 63: Pal 5
	Prg.r = 0: Prg.g = 63: Pal 6
	
	Prg.r = 39: Prg.g = 39: Prg.b = 0: Pal 1
	Prg.r = 39: Prg.g = 0: Prg.b = 39: Pal 2
	Prg.r = 0: Prg.g = 39: Pal 3
		
	Prg.g = 0: Pal 7
	Prg.b = 0: Prg.g = 39: Pal 8
	Prg.r = 39: Prg.g = 0: Pal 9

	Prg.b = 63: Prg.r = 0: Pal 10
	Prg.g = 63: Prg.b = 0: Pal 11
	Prg.r = 63: Prg.g = 0: Pal 12

	Prg.r = 21: Prg.g = 21: Prg.b = 21: Pal 13
	Prg.r = 42: Prg.g = 42: Prg.b = 42: Pal 14
	Prg.r = 63: Prg.g = 63: Prg.b = 63: Pal 15
END SUB

SUB Star (x, y, Colour)
	IF Colour = 0 THEN LINE (x - 2, y - 2)-(x + 2, y + 2), POINT(x - 2, y - 2), BF: EXIT SUB
	LINE (x - 2, y)-(x + 2, y), Colour
	LINE (x, y - 2)-(x, y + 2), Colour
	LINE (x - 1, y - 1)-(x + 1, y + 1), Colour, B
	PSET (x, y), Colour + 3
END SUB

DEFINT A-Z
SUB StrPrint (x, y, jono$, Koko, Colour)
	v = Koko * 4
	DRAW "BM=" + VARPTR$(x) + ",=" + VARPTR$(y) + "S=" + VARPTR$(v) + "C=" + VARPTR$(Colour)
	p = 0
	FOR i = 1 TO LEN(jono$)
		a$ = MID$(jono$, i, 1)
		SELECT CASE a$
'  H U E
'  L * R
'  G D F
			CASE " "
				DRAW "BR4"
			CASE "_"
				DRAW "BR"
			CASE "-"
				DRAW "BU3R3BD3BR2"
			CASE ":"
				DRAW "R0bu3l0BR2BD3"
			CASE "."
				DRAW "R0BR2"
			CASE "/"
				DRAW "M+3,-6BD6BR2"
			CASE "@"
				DRAW "BR4L3HU4ER3FD4GBUL2HU2ER2BD5BR3"
			CASE "?"
				DRAW "R0bu2uneeuhlgdBR2"
			CASE "0", "O"
				DRAW "BRHU4ERFD4GLBR4"
			CASE "1"
				DRAW "BRU6GBD5BR3"
			CASE "2"
				DRAW "NR3M+3,-4UHLGBD5BR5"
			CASE "3"
				DRAW "BUFREUHEUHLGBD5BR5"
			CASE "4"
				DRAW "BU6D3R3BU3D6BR2"
			CASE "5"
				DRAW "BUFREU2HL2U2R3BD6BR2"
			CASE "6"
				DRAW "BU3D2FREU2HLGU2ERFBD5BR2"
			CASE "7"
				DRAW "BU6R3M-2,6BU3R2BD3BR2"
			CASE "8"
				DRAW "BRHUEHUERFDGNLFDGLBR4"
			CASE "9"
				DRAW "BUFREU3GLHUERFDBD4BR2"
'  H U E
'  L * R
'  G D F
			CASE "A"
				DRAW "U5ERFD2NL3D3BR2"
			CASE "B"
				DRAW "U6R2FDGNL2FDGL2BR5"
			CASE "C"
				DRAW "BR3BUGLHU4ERFBD5BR2"
			CASE "D"
				DRAW "NR2U6R2FD4GBR3"
			CASE "E"
				DRAW "NR3U3NR2U3R3BD6BR2"
			CASE "F"
				DRAW "U3NR2U3R3BD6BR2"
			CASE "G"
				DRAW "BR2BU3RD2GLHU4ERFBD5BR2"
			CASE "H"
				DRAW "U6BD3R3NU3D3BR2"
			CASE "I"
				DRAW "NU6BR2"
			CASE "K"
				DRAW "U6BD3RNM+2,-3M+2,3BR2"
			CASE "L"
				DRAW "NU6R3BR2"
			CASE "M"
				DRAW "U6F2E2D6BR2"
			CASE "N"
				DRAW "U6M+3,6NU6BR2"
			CASE "P"
				DRAW "U6R2FDGL2BR5BD3"
			CASE "Q"
				DRAW "BRHU4ERFD4GLBEFBR2"
			CASE "R"
				DRAW "U6R2FDGLNLM+2,3BR2"
			CASE "S"
				DRAW "BUFREUHLHUERFBD5BR2"
			CASE "T"
				DRAW "BR2U6NL2R2BD6BR2"
			CASE "U"
				DRAW "BUNU5FREU5BD6BR2"
			CASE "V"
				DRAW "BR2NM-2,-6NM+2,-6BR4"
			CASE "W"
				DRAW "BRNM-1,-6M+1,-6M+1,6M+1,-6BD6BR2"
			CASE "X"
				DRAW "M+3,-6BL3M+3,6BR2"
			CASE "Y"
				IF p = 76 THEN DRAW "BL"    '"L"
				DRAW "BR2U4NH2E2BD6BR2"
			CASE "Z"
				DRAW "BU6R3M-3,6R3BR2"
			CASE ELSE
				DRAW "R3BR2"
		END SELECT
		p = ASC(a$)
	NEXT
END SUB

DEFSNG A-Z
SUB TeeAlustaMegaManille (x, y)
	LINE (x, y + 4)-(x + 31, y + 11), 13, B
	LINE (x + 1, y + 2)-(x + 30, y + 13), 14, B
	LINE (x + 4, y)-(x + 27, y + 15), 13, B
	LINE (x + 2, y + 1)-(x + 29, y + 14), 14, BF
	LINE (x + 3, y + 11)-(x + 5, y + 12), 15, B
	LINE (x + 6, y + 13)-(x + 8, y + 14), 15, B
	LINE (x + 5, y + 13)-(x + 6, y + 12), 15
	LINE (x + 26, y + 3)-(x + 28, y + 7), 15
	LINE (x + 26, y + 2)-(x + 29, y + 7), 15
	LINE (x + 27, y + 2)-(x + 29, y + 6), 15
	LINE (x, y + 4)-(x + 2, y + 8), 13, B
	LINE (x + 3, y + 7)-(x + 4, y + 4), 13
	LINE (x + 1, y + 6)-(x + 1, y + 2), 13
	LINE (x + 2, y + 1)-(x + 3, y + 5), 13, B
	LINE (x + 4, y)-(x + 7, y + 2), 13, B
	LINE (x + 5, y + 1)-(x + 5, y + 3), 13
	LINE (x + 6, y + 4)-(x + 9, y + 1), 13
	PSET (x + 5, y + 7), 13: PSET (x + 8, y + 5), 13: PSET (x + 10, y + 3), 13
END SUB

SUB TeeMegaMan (x, y, AsentoNumero)
	SELECT CASE AsentoNumero
		CASE 1
			LINE (x, y + 23)-(x + 8, y + 23), 0: LINE (x + 20, y + 23)-(x + 12, y + 23), 0
			LINE -(x + 12, y + 21), 0: LINE -(x + 10, y + 19), 0
			LINE -(x + 8, y + 21), 0: LINE -(x + 8, y + 23), 0
			LINE (x, y + 22)-(x + 1, y + 21), 0: LINE (x + 2, y + 21)-(x + 3, y + 20), 0
			LINE (x + 20, y + 22)-(x + 19, y + 21), 0: LINE (x + 18, y + 21)-(x + 17, y + 20), 0
			LINE (x + 4, y + 20)-(x + 4, y + 19), 0: LINE -(x + 6, y + 17), 0
			LINE -(x + 6, y + 13), 0: LINE (x + 16, y + 20)-(x + 16, y + 19), 0
			LINE -(x + 14, y + 17), 0: LINE -(x + 14, y + 13), 0
			LINE (x + 7, y + 20)-(x + 6, y + 19), 0: PAINT (x + 6, y + 21), 13, 0
			LINE (x + 7, y + 20)-(x + 6, y + 19), 13: LINE (x + 13, y + 20)-(x + 14, y + 19), 0
			PAINT (x + 19, y + 22), 13, 0: LINE (x + 13, y + 20)-(x + 14, y + 19), c
			LINE (x + 5, y + 16)-(x + 5, y + 14), 0: PSET (x + 4, y + 14), 0
			LINE (x + 15, y + 16)-(x + 15, y + 14), 0: PSET (x + 16, y + 14), 0
			LINE (x + 2, y + 17)-(x + 4, y + 17), 0: LINE (x + 18, y + 17)-(x + 16, y + 17), 0
			LINE (x + 1, y + 16)-(x + 1, y + 13), 0: LINE (x + 19, y + 16)-(x + 19, y + 13), 0

		CASE 100
			LINE (x, y + 23)-(x + 8, y + 23), 0
			LINE (x + 12, y + 23)-(x + 20, y + 23), 0
			LINE (x + 12, y + 22)-(x + 10, y + 19), 0
			LINE (x + 10, y + 19)-(x + 8, y + 21), 0
			PSET (x + 8, y + 22), 0: PSET (x + 20, y + 22), 0
			PSET (x, y + 22), 0
			LINE (x + 1, y + 21)-(x + 2, y + 21), 0
			LINE (x + 3, y + 20)-(x + 4, y + 20), 0
			LINE (x + 19, y + 21)-(x + 18, y + 21), 0
			LINE (x + 17, y + 20)-(x + 16, y + 20), 0
			LINE (x + 3, y + 20)-(x + 6, y + 17), 0
			LINE (x + 18, y + 21)-(x + 14, y + 17), 0
			LINE (x + 6, y + 17)-(x + 6, y + 13), 0
			LINE (x + 5, y + 16)-(x + 5, y + 14), 0
			PSET (x + 4, y + 14), 0: LINE (x + 4, y + 17)-(x + 2, y + 17), 0
			LINE (x + 1, y + 16)-(x + 1, y + 13), 0
			LINE (x + 14, y + 17)-(x + 14, y + 13), 0
			LINE (x + 15, y + 14)-(x + 15, y + 16), 0
			PSET (x + 16, y + 14), 0: LINE (x + 16, y + 17)-(x + 18, y + 17), 0

	END SELECT
END SUB

SUB TeePala (x AS INTEGER, y AS INTEGER, What AS INTEGER, c AS INTEGER)
	IF c = 0 THEN LINE (x, y)-(x + 15, y + 15), 0, BF: EXIT SUB
	SELECT CASE What
		CASE 1
			LINE (x, y)-(x + 15, y + 15), c, BF
			LINE (x + 10, y + 14)-(x + 10, y + 15), 15
			LINE (x + 11, y + 12)-(x + 12, y + 15), 15, BF
			LINE (x + 13, y + 10)-(x + 14, y + 12), 15, BF
			LINE (x + 15, y + 9)-(x + 14, y + 13), 15
			LINE (x + 12, y + 11)-(x + 15, y + 8), 15
			LINE (x, y + 8)-(x + 3, y + 5), 15
			LINE (x, y + 9)-(x + 3, y + 6), 15
			LINE (x + 1, y + 9)-(x + 10, y), 15
			LINE (x + 4, y + 8)-(x + 11, y + 1), 15
			LINE (x + 4, y + 7)-(x + 11, y), 15
			LINE (x + 9, y + 4)-(x + 5, y + 4), 15
			PSET (x + 6, y + 3), 15
		CASE 2
			LINE (x, y + 2)-(x + 15, y + 13), c, BF
			LINE (x + 1, y + 1)-(x + 14, y + 14), c, B
			LINE (x + 2, y)-(x + 13, y + 15), c, B
			LINE (x, y + 2)-(x, y + 7), c + 3
			LINE (x + 1, y + 1)-(x + 2, y + 2), c + 3, B
			LINE (x + 2, y)-(x + 5, y), c + 3
			LINE (x + 2, y + 2)-(x + 2, y + 3), 13
			LINE (x + 3, y + 1)-(x + 4, y + 1), 13
			LINE (x + 13, y + 13)-(x + 13, y + 12), 13
			LINE (x + 12, y + 14)-(x + 11, y + 14), 13
			LINE (x + 13, y + 2)-(x + 13, y + 3), 13
			LINE (x + 12, y + 1)-(x + 11, y + 1), 13
			LINE (x + 2, y + 13)-(x + 2, y + 12), 13
			LINE (x + 3, y + 14)-(x + 4, y + 14), 13
		CASE 3
			LINE (x, y)-(x + 15, y + 15), POINT(x, y), BF
			LINE (x + 11, y + 15)-(x + 11, y + 10), 0
			LINE (x + 10, y + 15)-(x + 6, y + 11), 0
			LINE (x + 6, y + 10)-(x, y + 10), 0
			LINE (x, y + 9)-(x + 4, y + 5), 0
			LINE (x + 5, y + 5)-(x + 5, y), 0
			LINE (x + 6, y)-(x + 10, y + 4), 0
			LINE (x + 10, y + 5)-(x + 15, y + 5), 0
			LINE (x + 15, y + 6)-(x + 12, y + 9), 0
			PAINT (x + 7, y + 7), c, 0
			LINE (x + 10, y + 14)-(x + 7, y + 11), c + 3
			LINE (x + 10, y + 14)-(x + 9, y + 11), c + 3
			LINE (x + 7, y + 1)-(x + 7, y + 3), c + 3
			LINE (x + 7, y + 7)-(x + 10, y + 8), 0, B
			LINE (x + 8, y + 6)-(x + 9, y + 9), 0, BF
		CASE 4
			LINE (x, y)-(x + 15, y + 15), POINT(x, y), BF
			LINE (x + 3, y + 15)-(x + 7, y + 11), 0
			LINE (x + 2, y + 14)-(x + 2, y + 10), 0
			LINE (x + 3, y + 9)-(x + 3, y + 8), 0
			LINE (x + 8, y + 12)-(x + 9, y + 12), 0
			LINE (x + 10, y + 13)-(x + 14, y + 13), 0
			LINE (x + 15, y + 12)-(x + 11, y + 8), 0
			LINE (x + 12, y + 7)-(x + 12, y + 6), 0
			LINE (x + 13, y + 5)-(x + 13, y + 1), 0
			LINE (x + 4, y + 7)-(x, y + 3), 0
			LINE (x + 1, y + 2)-(x + 5, y + 2), 0
			LINE (x + 6, y + 3)-(x + 7, y + 3), 0
			LINE (x + 8, y + 4)-(x + 12, y), 0
			PAINT (x + 1, y + 3), c, 0
			LINE (x + 1, y + 3)-(x + 5, y + 3), c + 3
			LINE (x + 12, y + 1)-(x + 12, y + 5), c + 3
			LINE (x + 11, y + 6)-(x + 11, y + 7), c + 3
			LINE (x + 5, y + 12)-(x + 5, y + 10), c + 3
			LINE (x + 6, y + 11)-(x + 6, y + 9), c + 3
			LINE (x + 6, y + 7)-(x + 9, y + 8), 0, B
			LINE (x + 7, y + 6)-(x + 8, y + 9), 0, BF
		CASE 5
			LINE (x, y)-(x + 15, y + 15), c + 3, BF
			LINE (x + 10, y + 14)-(x + 10, y + 15), 15
			LINE (x + 11, y + 12)-(x + 12, y + 15), 15, BF
			LINE (x + 13, y + 10)-(x + 14, y + 12), 15, BF
			LINE (x + 15, y + 9)-(x + 14, y + 13), 15
			LINE (x + 12, y + 11)-(x + 15, y + 8), 15
			LINE (x, y + 8)-(x + 3, y + 5), 15
			LINE (x, y + 9)-(x + 3, y + 6), 15
			LINE (x + 1, y + 9)-(x + 10, y), 15
			LINE (x + 4, y + 8)-(x + 11, y + 1), 15
			LINE (x + 4, y + 7)-(x + 11, y), 15
			LINE (x + 9, y + 4)-(x + 5, y + 4), 15
			PSET (x + 6, y + 3), 15
			LINE (x, y + 1)-(x, y + 14), c
			LINE (x + 15, y + 1)-(x + 15, y + 14), c
			LINE (x + 1, y)-(x + 14, y), c
			LINE (x + 1, y + 15)-(x + 14, y + 15), c

	END SELECT
END SUB

SUB TeeTausta
	ClearPalette
	DIM a AS INTEGER, b AS INTEGER
	LINE (0, 0)-(640, 480), 10, BF
	StrPrint 400, 100, "WAIT A LITTLE TIME ...", 2, 1
	FOR a = 1 TO 18
		FOR b = 1 TO 5
			Set a, b, 1, 7
			Set a, b + AlueKorkeus, 1, 7
			Pet a, b + AlueKorkeus + 5, 1, 7
			Pet a, b + AlueKorkeus + 10, 1, 7
			Pet a, b + AlueKorkeus + 15, 1, 7
			Pet a, b + AlueKorkeus + 20, 1, 7
	NEXT b, a
	FOR a = 6 TO AlueKorkeus
		Set 1, a, 1, 7
		Set 18, a, 1, 7
	NEXT
	LINE (18 * 16 + 31, AlueKorkeus * 16)-(63, AlueKorkeus * 16), 15
	
	LINE (18 * 16 + 31, 16 * 5)-(63, AlueKorkeus * 16 - 1), 0, BF
	
	LINE (46, 0)-(46, 480), 6: LINE (47, 0)-(47, 480), 3
	
	LINE (19 * 16 + 30, 0)-(19 * 16 + 30, 480), 6: LINE (19 * 16 + 31, 0)-(19 * 16 + 31, 480), 3
	StrPrint 400, 100, "WAIT A LITTLE TIME ...", 2, 10
	SetPaletti
END SUB

