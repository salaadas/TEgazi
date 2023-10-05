DECLARE SUB PlayGame ()
DECLARE SUB DoBlock (x%, y%, c%, Flag%)
DECLARE FUNCTION ScreenCardFound% (Flag%)
DECLARE SUB Setup ()
DECLARE FUNCTION NoUsingTandy% ()
DECLARE SUB WaitSecs (Tim#)
DECLARE SUB WaitForKey ()

REM DefaultBlocks 1
REM END

DEFINT A-Z '$DYNAMIC
RANDOMIZE TIMER
CONST FALSE = 0
CONST TRUE = NOT FALSE
DIM SHARED Errf, ISVGA, CurCard  AS STRING * 1, Sounds, BlType, Taso, Tandy
DIM SHARED DUMMY, Alue(0 TO 39, 0 TO 24)
Tandy = NoUsingTandy
IF ScreenCardFound(TRUE) = TRUE THEN GOTO NoScreenCard
Sounds = Tandy
IF ISVGA THEN CurCard = "V" ELSE CurCard = "C"
CALL Setup
DUMMY = ScreenCardFound(FALSE)

IF CurCard = "C" THEN
	LINE (191, 0)-(191, 199), 1
	PAINT (300, 10), CHR$(&H49) + CHR$(&H92) + CHR$(&H25), 1
	LINE (191, 0)-(191, 199), 0
ELSE
	LINE (191, 0)-(191, 437), 1
	PAINT (400, 10), CHR$(&H33) + CHR$(&HCC), 1
	LINE (191, 0)-(191, 437), 0
END IF
FOR y = 0 TO 23: DoBlock 0, y, 6, 1: DoBlock 11, y, 6, 1: NEXT
FOR x = 0 TO 11: DoBlock x, 24, 6, 1: NEXT

TYPE XyCoord
	x AS INTEGER
	y AS INTEGER
END TYPE
TYPE PalaPeli
	Ds AS INTEGER
	Bs AS INTEGER
END TYPE

PlayGame


END
Virhe: Errf = ERR: RESUME NEXT

NoScreenCard:
	PRINT "Needed (C/E/V/MC)GA adapter !"
	PLAY "o3": FOR x = 1 TO 2: PLAY "mbt255l8aefdecd<b>c<abg+": NEXT
	PLAY "mbt255l4ag+fg+a2p2>ap2<ap2>ap2<a>a<a>a<ap4>ap4<a>a2"
	WaitForKey
	END

REM $STATIC
SUB DefaultBlocks (TasoNum)
	OPEN "BlockSet." + LTRIM$(STR$(TasoNum)) FOR OUTPUT AS #1
	PRINT #1, "";                  'Palikoiden mÑÑrÑ'
		PRINT #1, "";             'Asentojen, osien mÑÑrÑ'
			PRINT #1, "";   'Koordinaatit'
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
		PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
			PRINT #1, "";
	PRINT #1, MKD$(1);
	CLOSE
END SUB

REM $DYNAMIC
'
'ON VGA c IS 0,1,4 or 5, ON CGA c IS 1 OR 0.
'DoBlock - Sets block.
SUB DoBlock (x, y, c, Flag)
	DIM z1, z2, z3, z4
	IF CurCard = "C" THEN
		IF c = 6 THEN
			LINE (x * 16, y * 8)-(x * 16 + 15, y * 8 + 7), 1, B
			PAINT (x * 16 + 1, y * 8 + 1), CHR$(&H55) + CHR$(&HAA), 1
		ELSE
			LINE (x * 16, y * 8)-(x * 16 + 15, y * 8 + 7), c, BF
		END IF
	ELSE
		IF c = 0 THEN
			LINE (x * 16, y * 16)-(x * 16 + 15, y * 16 + 15), 0, BF
		ELSEIF c = 6 THEN
			x2 = x * 16: y2 = y * 16
			LINE (x2, y2)-(x2 + 15, y2 + 15), 8, BF
			LINE (x2, y2 + 13)-(x2, y2 + 13), 10: LINE (x2 + 1, y2 + 14)-(x2 + 1, y2 + 11), 10
			LINE (x2 + 2, y2 + 12)-(x2 + 2, y2 + 10), 10: LINE (x2 + 3, y2 + 10)-(x2 + 3, y2 + 8), 10
			LINE (x2 + 4, y2 + 11)-(x2 + 4, y2 + 7), 10: LINE (x2 + 5, y2 + 10)-(x2 + 5, y2 + 7), 10
			LINE (x2 + 6, y2 + 9)-(x2 + 6, y2 + 6), 10: LINE (x2 + 7, y2 + 5)-(x2 + 7, y2 + 7), 10
			LINE (x2 + 8, y2 + 4)-(x2 + 8, y2 + 5), 10: LINE (x2 + 9, y2 + 3)-(x2 + 9, y2 + 4), 10
			LINE (x2 + 10, y2 + 4)-(x2 + 10, y2 + 6), 10: LINE (x2 + 11, y2 + 2)-(x2 + 11, y2 + 5), 10
			LINE (x2 + 12, y2 + 1)-(x2 + 12, y2 + 3), 10: LINE (x2 + 13, y2 + 2)-(x2 + 15, y2), 10
			LINE (x2 + 14, y2 + 15)-(x2 + 15, y2 + 14), 10
		ELSE
			LINE (x * 16, y * 16)-(x * 16 + 15, y * 16 + 15), c, B
			LINE (x * 16 + 1, y * 16 + 2)-(x * 16 + 14, y * 16 + 14), c + 2, B
			LINE (x * 16 + 2, y * 16 + 2)-(x * 16 + 13, y * 16 + 13), c + 8, B
			LINE (x * 16 + 3, y * 16 + 3)-(x * 16 + 12, y * 16 + 12), c + 10, B
			IF BlockType > 0 THEN
				IF POINT((x - 1) * 16 + 8, y * 16 + 8) = c + 10 THEN
					LINE ((x - 1) * 16 + 3, y * 16 + 3)-(x * 16 + 12, y * 16 + 12), c + 10, BF
					LINE ((x - 1) * 16 + 13, y * 16 + 2)-(x * 16 + 2, y * 16 + 2), c + 8
					LINE ((x - 1) * 16 + 13, y * 16 + 13)-(x * 16 + 2, y * 16 + 13), c + 8
					LINE ((x - 1) * 16 + 12, y * 16 + 1)-(x * 16 + 1, y * 16 + 1), c + 8
					LINE ((x - 1) * 16 + 12, y * 16 + 14)-(x * 16 + 1, y * 16 + 14), c + 8: z1 = TRUE
				END IF
				IF POINT((x + 1) * 16 + 8, y * 16 + 8) = c + 10 THEN
					LINE (x * 16 + 3, y * 16 + 3)-(x * 16 + 12, y * 16 + 12), c + 10, BF
					LINE (x * 16 + 13, y * 16 + 2)-((x + 1) * 16 + 2, y * 16 + 2), c + 8
					LINE (x * 16 + 13, y * 16 + 13)-((x + 1) * 16 + 2, y * 16 + 13), c + 8
					LINE (x * 16 + 12, y * 16 + 1)-((x + 1) * 16 + 1, y * 16 + 1), c + 8
					LINE (x * 16 + 12, y * 16 + 14)-((x + 1) * 16 + 1, y * 16 + 14), c + 8: z2 = TRUE
				END IF
				
				IF POINT(x * 16 + 8, (y - 1) * 16 + 8) = c + 10 THEN
					LINE (x * 16 + 3, (y - 1) * 16 + 3)-(x * 16 + 12, y * 16 + 3), c + 10, BF
					LINE (x * 16 + 2, (y - 1) * 16 + 13)-(x * 16 + 2, y * 16 + 2), c + 8
					LINE (x * 16 + 13, (y - 1) * 16 + 13)-(x * 16 + 13, y * 16 + 2), c + 8
					LINE (x * 16 + 1, (y - 1) * 16 + 14)-(x * 16 + 1, y * 16 + 1), c + 8
					LINE (x * 16 + 14, (y - 1) * 16 + 14)-(x * 16 + 14, y * 16 + 1), c + 8: z3 = TRUE
				END IF
				IF POINT(x * 16 + 8, (y + 1) * 16 + 8) = c + 10 THEN
					LINE (x * 16 + 3, (y + 1) * 16 + 3)-(x * 16 + 12, y * 16 + 3), c + 10, BF
					LINE (x * 16 + 2, (y + 1) * 16 + 2)-(x * 16 + 2, y * 16 + 13), c + 8
					LINE (x * 16 + 3, (y + 1) * 16 + 2)-(x * 16 + 3, y * 16 + 13), c + 8
					LINE (x * 16 + 1, (y + 1) * 16 + 1)-(x * 16 + 1, y * 16 + 14), c + 8
					LINE (x * 16 + 14, (y + 1) * 16 + 1)-(x * 16 + 14, y * 16 + 14), c + 8: z4 = TRUE
				END IF
				IF BlType = 2 THEN
					IF POINT((x - 1) * 16 + 8, (y - 1) * 16 + 8) = c + 10 AND z1 = TRUE AND z3 = TRUE THEN
						LINE (x * 16 - 6, y * 16 - 6)-(x * 16 + 6, y * 16 + 6), c + 10, BF
					END IF
					IF POINT((x - 1) * 16 + 8, (y - 1) * 16 + 8) = c + 10 AND z1 = TRUE AND z3 = TRUE THEN
						LINE (x * 16 + 22, y * 16 - 6)-(x * 16 + 10, y * 16 + 6), c + 10, BF
					END IF
					IF POINT((x - 1) * 16 + 8, (y - 1) * 16 + 8) = c + 10 AND z1 = TRUE AND z3 = TRUE THEN
						LINE (x * 16 - 6, y * 16 + 22)-(x * 16 + 6, y * 16 + 10), c + 10, BF
					END IF
					IF POINT((x - 1) * 16 + 8, (y - 1) * 16 + 8) = c + 10 AND z1 = TRUE AND z3 = TRUE THEN
						LINE (x * 16 + 10, y * 16 + 10)-(x * 16 + 22, y * 16 + 22), c + 10, BF
					END IF
				END IF
			END IF
		END IF
	END IF
	IF Flag = TRUE THEN Alue(x, y) = c
END SUB

FUNCTION NoUsingTandy
	NoUsingTandy = TRUE
	Errf = FALSE: ON ERROR GOTO Virhe
	PALETTE 0, 0: IF Errf > 0 THEN NoUsingTandy = FALSE
	ON ERROR GOTO 0
END FUNCTION

REM $STATIC
SUB PlayGame
	DIM x, y, z, Uusi, Mika, Paloja, Num#, Ti#, PalaMaassa, Ase(2)
	DIM t$, y$, Nyt AS XyCoord, Ennen AS XyCoord, Ptte AS SINGLE
	OPEN "BLOCKSET." + LTRIM$(STR$(Taso)) FOR BINARY AS #1
	Paloja = ASC(INPUT$(1, #1))
	REDIM Pala(Paloja, 10, 10) AS XyCoord
	REDIM Pali(1 TO Paloja) AS PalaPeli
	FOR x = 1 TO Paloja
		Pali(x).Ds = ASC(INPUT$(1, #1))
		Pali(x).Bs = ASC(INPUT$(1, #1))
		FOR y = 1 TO Pali(x).Ds
			FOR z = 1 TO Pali(x).Bs
				Pala(x, y, z).x = ASC(INPUT$(1, #1))
				Pala(x, y, z).y = ASC(INPUT$(1, #1))
	NEXT z, y, x
	Num# = CVD(INPUT$(8, #1))
	CLOSE
	Uusi = INT(RND * Paloja) + 1
	IF CurCard = "V" THEN
		FOR x = 600 TO 639: FOR y = 0 TO 479
			PSET (x, y), 5 + CINT(RND) * 2 + CINT(RND) * 8
		NEXT y, x
	END IF
	DO
		Mika = Uusi
		Ase(1) = INT(RND * Pali(Mika).Ds) + 1
		Uusi = INT(RND * Paloja) + 1
		Ase(2) = INT(RND * Pali(Uusi).Ds) + 1
		IF CurCard = "C" THEN
			LINE (200, 10)-(300, 100), 0, BF
			LOCATE 10, 31: PRINT "NEXT"; : LOCATE 11, 30: PRINT "BLOCK";
		ELSE
			LINE (200, 10)-(300, 24), 0, BF
			t$ = "NEXT BLOCK"
			FOR x = 1 TO LEN(t$)
				COLOR x: LOCATE 20, 28 + x: PRINT MID$(t$, x, 1);
			NEXT
		END IF
		FOR x = 1 TO Pali(Uusi).Bs
			DoBlock 13 + Pala(Uusi, Ase(2), x).x, 2 + Pala(Uusi, Ase(2), x).y, 1, 1
		NEXT
		Ennen.x = 3: Ennen.y = 1
		Ptte = 0
		DO
			Ti# = TIMER
			IF CurCard = "V" THEN
				PALETTE 8, 65536 * 63 + 256 * 20 + 20
				PALETTE 10, 63 + 256 * 63 + 65536 * 63
			END IF
			DO
				IF CurCard = "V" THEN
					PALETTE 5, (x * ((32 + 31 * SIN(TIMER)) / 63)) + 256 * (x * ((32 + 31 * COS(TIMER)) / 63))
					PALETTE 7, (x * ((32 + 31 * SIN(TIMER)) / 63)) + 256 * (x * ((32 + 31 * COS(TIMER)) / 63))
					PALETTE 13, (x * ((32 + 31 * SIN(TIMER)) / 63)) + 256 * (x * ((32 + 31 * COS(TIMER)) / 63))
					PALETTE 15, (x * ((32 + 31 * SIN(TIMER)) / 63)) + 256 * (x * ((32 + 31 * COS(TIMER)) / 63))
				END IF
				IF Ptte < 63 THEN Ptte = Ptte + .1
				y$ = INKEY$
				PALETTE
				SELECT CASE y$
					CASE CHR$(0) + "H":
					CASE CHR$(0) + "P":
					CASE CHR$(0) + "K":
						FOR x = 1 TO Pali(Mika).Bs
							IF Alue(Nyt.x - 1 + Pala(Mika, Ase(1), x).x, Nyt.y + Pala(Mika, Ase(1), x).y) THEN EXIT FOR
						NEXT
						IF x = Pali(Mika).Bs + 1 THEN
							FOR x = 1 TO Pali(Mika).Bs
									
							NEXT
						END IF
					CASE CHR$(0) + "M":
				END SELECT
			LOOP WHILE Ti# + Num# > TIMER
		LOOP WHILE PalaMaassa
	LOOP
END SUB

REM $DYNAMIC
FUNCTION ScreenCardFound (Flag%)
	ScreenCardFound = TRUE
	Errf = FALSE: ON ERROR GOTO Virhe
	IF Flag% = TRUE THEN
		ISVGA = TRUE: SCREEN 12: BlType = 2
		IF Errf = 5 THEN
			Errf = FALSE: SCREEN 2
			ISVGA = FALSE: BlType = 0
			IF Errf = 5 THEN EXIT FUNCTION
		END IF
		SCREEN 0, 1, 0, 0: WIDTH 80, 25
		ScreenCardFound = FALSE
	ELSE
		SCREEN 12: WIDTH 80, 60: IF Errf > 0 THEN SCREEN 2: WIDTH 80, 25
	END IF
	ON ERROR GOTO 0
END FUNCTION

REM $STATIC
SUB Setup
	COLOR 5, 0
	LOCATE 2, 18: PRINT " ∞±≤€€€€±≤€€€€€±≤€€€€€±≤€∞±≤€±≤€€€€"
	LOCATE 3, 18: PRINT "∞±≤€€   ∞±≤€±≤€±≤€≤€≤€±≤€∞±≤€∞±≤€≤€€"
	LOCATE 4, 18: PRINT " ∞±≤€€  ∞±≤€€   ∞±≤€ ∞±≤€∞±≤€∞±≤€€€"
	LOCATE 5, 18: PRINT "  ∞±≤€€€∞±≤€±≤€ ∞±≤€ ∞±≤€€≤€€∞±≤€  "
	LOCATE 6, 18: PRINT "∞±≤€€€€∞±≤€€€€€∞±≤€€€ ∞±≤€€€∞±≤€€€ "
	COLOR 13, 0
	LOCATE 7, 15: PRINT "∞±≤€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€"

	COLOR 6, 0
	LOCATE 10, 10: PRINT "SCREEN CARD TO USE : [   ]";
	LOCATE 11, 10: PRINT "BLOCKS' REGULARY   : [   ]";
	LOCATE 12, 10: PRINT "SOUNDS             : [   ]";
	LOCATE 13, 10: PRINT "STARTING LEVEL     : [   ]";
	COLOR 9, 7: LOCATE 20, 30: PRINT " < DONE > "
	COLOR 8, 0: LOCATE 19, 31: PRINT "‹‹‹‹‹‹‹‹": LOCATE 21, 31: PRINT "ﬂﬂﬂﬂﬂﬂﬂﬂ"
	Taso = 1
	GOSUB StoreDatas
	Choose = 10
	DO
		y$ = INKEY$
		LOCATE Choose, 8, 0: PRINT "  "; : LOCATE Choose, 36, 0: PRINT "  ";
		IF y$ = CHR$(0) + "H" THEN Choose = Choose - 1: IF Choose = 9 THEN Choose = 13
		IF y$ = CHR$(0) + "P" THEN Choose = Choose + 1: IF Choose = 14 THEN Choose = 10
		LOCATE Choose, 8, 0: PRINT "-"; : LOCATE Choose, 36, 0: PRINT "-";

		IF y$ = CHR$(0) + "K" THEN GOSUB Cho: IF Choose = 13 THEN Taso = Taso - 1: IF Taso = 0 THEN Taso = 1
		IF y$ = CHR$(0) + "M" THEN GOSUB Cho: IF Choose = 13 THEN Taso = Taso + 1: IF Taso = 20 THEN Taso = 19

		GOSUB StoreDatas

		IF Tandy THEN PALETTE 6, 4 + CINT(RND) * 2 + CINT(RND) * 8
	LOOP UNTIL y$ = CHR$(13)
	LOCATE Choose, 8, 0: PRINT "  "; : LOCATE Choose, 36, 0: PRINT "  ";
	COLOR 15, 7: LOCATE 20, 30: PRINT " < DONE > "
	WaitSecs .5
	COLOR 9, 7: LOCATE 20, 30: PRINT " < DONE > "
EXIT SUB






















StoreDatas:                                                 
	IF ISVGA = FALSE AND CurCard = "V" THEN CurCard = "C"
	COLOR 9, 0: LOCATE 10, 32: PRINT CurCard; "GA";
	COLOR 9, 0: LOCATE 11, 32: PRINT RTRIM$(LTRIM$(STR$(BlType)));
	IF BlType = 1 THEN PRINT "st";  ELSE IF BlType = 2 THEN PRINT "nd";  ELSE PRINT "th";
	COLOR 9, 0: LOCATE 12, 32: PRINT "O";
	IF Sounds THEN PRINT "N ";  ELSE PRINT "FF";
	COLOR 9, 0: LOCATE 13, 32: PRINT RTRIM$(LTRIM$(STR$(Taso))); " ";
RETURN
Cho:
	IF Choose = 10 THEN IF CurCard = "V" THEN CurCard = "C" ELSE CurCard = "V"
	IF Choose = 11 THEN IF CurCard = "V" THEN BlType = (BlType + 1) MOD 3 ELSE BlType = 0
	IF Choose = 12 THEN Sounds = NOT Sounds
RETURN
END SUB

REM $DYNAMIC
SUB WaitForKey
	DO UNTIL INKEY$ = "": LOOP: DO WHILE INKEY$ = "": LOOP
END SUB

REM $STATIC
SUB WaitSecs (Tim#)
	Ti# = TIMER: WHILE Ti# + Tim# > TIMER: WEND
END SUB

