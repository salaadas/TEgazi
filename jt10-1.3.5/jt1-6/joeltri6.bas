'SUB declarations.
DECLARE SUB CheckRows (Sc%, Hi%, La%, Pi%, Le%)
DECLARE SUB DoBlock (x%, y%, d%, z%, SaveFlag%)
DECLARE FUNCTION PlayGame% ()
DECLARE SUB Pause ()
'TYPE definitions.
DEFINT A-Z '$DYNAMIC
TYPE Colours
	z AS INTEGER
	z2 AS INTEGER
END TYPE
TYPE XyCoord
	x AS INTEGER
	y AS INTEGER
	c AS Colours
END TYPE

'CONSTants.
CONST FALSE = 0
CONST TRUE = NOT FALSE
CONST Konst = ", but it doesn't matter"

'Global SHARED variables and arrays.
DIM SHARED Errf, Area(40, 30) AS Colours, Max
DIM SHARED UsingVGAMode

'Initialize randomseed.
RANDOMIZE TIMER

'Set default screenmode.
SCREEN 2: SCREEN 0, 1, 0, 0: WIDTH 80, 25: COLOR 7, 0: CLS

IF INSTR(COMMAND$, "/S") = 0 THEN
	OPEN "STARTUP.COM" FOR BINARY AS #1
	IF LOF(1) > 0 THEN
		OPEN "LOGO.EXE" FOR OUTPUT AS #2
		PRINT : PRINT : PRINT "INITIALIZING ................"; : LOCATE , 14
		y$ = INPUT$(190, #1): FOR x = 1 TO 16: PRINT "o"; : y$ = INPUT$(1253, #1): PRINT #2, y$; : NEXT
		CLOSE : CLS : SHELL "LOGO.EXE": KILL "LOGO.EXE"
	ELSE
		PRINT "STARTUP.COM file not found"; Konst; "!!": CLOSE
	END IF
END IF

'Test "is VGA found?"
Errf = 0: ON ERROR GOTO Virhe
SCREEN 12: IF Errf = 5 THEN SCREEN 2: UsingVGAMode = FALSE ELSE UsingVGAMode = TRUE
Errf = 0: WIDTH 80, 60: IF Errf = 5 THEN Max = 30 ELSE Max = 60
Errf = 0: ON ERROR GOTO 0

'Start game.  Returns FALSE if user don't want to play (pressed ESC)
IF PlayGame = TRUE THEN
ELSE
END IF


END



Virhe: Errf = ERR: RESUME NEXT

SUB CheckRows (Sc, Hi, La, Pi, Le)
	DIM Ju, Po, x, y, x2, y2, Ri(1 TO 28)
	Ju = 0: Po = 0
	FOR y = 1 TO 28
		FOR x = 1 TO Le - 1
			IF Area(x, y).z = 0 THEN EXIT FOR
		NEXT
		IF x = Le THEN
			FOR x2 = 1 TO Le - 1: DoBlock x2, y, 0, 0, TRUE: NEXT
			Ju = Ju + 1
			Ri(y) = TRUE
		ELSE
			Ri(y) = FALSE
		END IF
	NEXT
	FOR y = 1 TO 28
		IF Ri(y) THEN
			FOR y2 = y TO 2 STEP -1
				FOR x2 = 1 TO Le - 1: DoBlock x2, y2, Area(x2, y2 - 1).z, Area(x2, y2 - 1).z2, TRUE: NEXT
			NEXT
			FOR x2 = 1 TO Le - 1: DoBlock x2, 1, 0, 0, TRUE: NEXT
			Po = Po + 1
		END IF
	NEXT
	Hi = 0
	FOR y = 1 TO 28
		FOR x = 1 TO Le - 1
			IF Area(x, y).z > 0 THEN EXIT FOR
		NEXT
		IF x < Le THEN Hi = Hi + 1
	NEXT
	IF Po = 1 THEN La = 50 ELSE IF Po = 2 THEN La = 150 ELSE IF Po = 3 THEN La = 250
	IF Po = 4 THEN La = 350 ELSE IF Po = 5 THEN La = 450 ELSE IF Po = 6 THEN La = 550
	IF Po = 7 THEN La = 650 ELSE IF Po = 8 THEN La = 750 ELSE IF Po = 9 THEN La = 850
	IF Po = 10 THEN La = 1000 ELSE IF Po = 0 THEN La = INT(RND * 20)
	Pi = Pi + Ju
	Sc = Sc + La
END SUB

SUB DoBlock (x, y, d, z, SaveFlag)
	DIM c(1 TO 4), x2, y2
	x2 = x * 16: IF UsingVGAMode THEN y2 = y * 16 ELSE y2 = y * 6
	IF d = 1 THEN c(1) = 15: c(2) = 7: c(3) = 8: c(4) = 4
	IF d = 2 THEN c(1) = 14: c(2) = 10: c(3) = 2: c(4) = 3
	IF UsingVGAMode THEN
		IF z > 0 THEN
			LINE (x2 + 15, y2)-(x2, y2), c(1): LINE -(x2, y2 + 15), c(1)
			LINE -(x2 + 15, y2 + 15), c(3): LINE -(x2 + 15, y2), c(3)
			LINE (x2 + 1, y2 + 1)-(x2 + 14, y2 + 14), c(2), BF
			PSET (x2, y2 + 15), c(4): PSET (x2 + 15, y2), c(4)
		END IF
		SELECT CASE z
			CASE 0:
				LINE (x2, y2)-(x2 + 15, y2 + 15), 0, BF
			CASE 1:
			CASE 2:
				LINE (x2 + 11, y2 + 4)-(x2 + 4, y2 + 4), c(1): LINE -(x2 + 4, y2 + 11), c(1)
				LINE -(x2 + 11, y2 + 11), c(3): LINE -(x2 + 11, y2 + 4), c(3)
				LINE (x2 + 5, y2 + 5)-(x2 + 10, y2 + 10), c(2), BF
				PSET (x2 + 4, y2 + 11), c(4): PSET (x2 + 11, y2 + 4), c(4)
			CASE 3:
				LINE (x2 + 3, y2 + 11)-(x2 + 11, y2 + 3), c(4)
				LINE (x2 + 4, y2 + 12)-(x2 + 12, y2 + 4), c(1)
		END SELECT
	ELSE
		IF z = 0 THEN
			LINE (x2, y2)-(x2 + 15, y2 + 5), 0, BF
		ELSE
			LINE (x2, y2)-(x2 + 15, y2 + 5), 1, BF
			IF SaveFlag THEN
				IF POINT(x2 - 1, y2 + 2) = 1 THEN LINE (x2 - 8, y2 + 3)-(x2 + 8, y2 + 3), 0, , &H5555
				IF POINT(x2 + 16, y2 + 2) = 1 THEN LINE (x2 + 8, y2 + 3)-(x2 + 24, y2 + 3), 0, , &H5555
				IF POINT(x2 + 7, y2 - 1) = 1 THEN LINE (x2 + 8, y2 - 3)-(x2 + 8, y2 + 3), 0', , &H3333
				IF POINT(x2 + 7, y2 + 6) = 1 THEN LINE (x2 + 8, y2 + 3)-(x2 + 8, y2 + 9), 0', , &H3333
			END IF
		END IF
	END IF
	IF SaveFlag THEN
		Area(x, y).z = d: Area(x, y).z2 = z
	END IF
END SUB

SUB Pause
	IF UsingVGAMode THEN
		DIM BkGrnd(1000) AS DOUBLE
		GET (80, 40)-(400, 300), BkGrnd
		LINE (80, 40)-(400, 300), 7, BF
		LINE (80, 300)-(80, 40), 15: LINE -(400, 40), 15
		LINE -(400, 300), 8: LINE -(80, 300), 8
		IF Max = 30 THEN LOCATE 13, 5 ELSE LOCATE 13, 10
		PRINT "P A U S E D": WHILE INKEY$ <> "": WEND: WHILE INKEY$ = "": WEND
		PUT (80, 40), BkGrnd, PSET
	ELSE
		DIM BkGrnd(500) AS DOUBLE
		GET (27, 20)-(140, 150), BkGrnd
		LINE (27, 30)-(140, 150), 1, B
		LINE (28, 31)-(139, 149), 0, BF
		PAINT (50, 50), CHR$(&H55) + CHR$(&HAA), 1
		IF Max = 30 THEN LOCATE 13, 5 ELSE LOCATE 13, 10
		PRINT "P A U S E D": WHILE INKEY$ <> "": WEND: WHILE INKEY$ = "": WEND
		PUT (27, 20), BkGrnd, PSET
	END IF
END SUB

FUNCTION PlayGame
	PlayGame = TRUE
	DIM Pcs, Snds, x, y, x2, y2, Level, Leve, Last, Highest, Pits
	DIM Px(2), Py(2), Pa(2), Pz, Pz2, Ti#, Score
	DIM BlockOver, LevelOver, GameOver, Mode
	Level = 0: GameOver = FALSE: Snds = TRUE: Score = 0
	DO
		Leve = INT(RND * 10) + 12
		FOR x = 0 TO Leve + 1
			FOR y = 0 TO 30
				Area(x, y).z = 0: Area(x, y).z2 = 0
				DoBlock x, y, 0, 0, FALSE
		NEXT y, x
		FOR x = 0 TO Leve
			DoBlock x, 0, 1, 1, TRUE: DoBlock x, 29, 1, 1, TRUE
		NEXT
		FOR y = 1 TO 28
			DoBlock 0, y, 1, 1, TRUE: DoBlock Leve, y, 1, 1, TRUE
		NEXT
		IF RND > .5 THEN
			IF UsingVGAMode THEN
				FOR x = 0 TO 15: LINE (x, x)-(16 + Leve * 16 - x, 479 - x), 3, B: NEXT
				LINE (15, 464)-(15, 15), 15: LINE -(1 + Leve * 16, 15), 15
				LINE -(1 + Leve * 16, 464), 8: LINE -(15, 464), 8
			END IF
		END IF
		IF UsingVGAMode THEN
			LINE (16, 16)-(Leve * 16, 463), 0, BF
			LINE (Leve * 16 + 16, 0)-(639, 479), 0, BF
		ELSE
			LINE (14, 6)-(Leve * 16 + 1, 174), 0, BF
			LINE (Leve * 16 + 16, 0)-(454, 199), 0, BF
		END IF
		Level = Level + 1
		LevelOver = 0
		DO
			Pcs = INT(RND * INT(RND * INT(RND * 11))) + 2
			IF RND > .7 OR Pcs > 10 THEN Pcs = 1
			REDIM Pala(1 TO 4, 1 TO 11) AS XyCoord: GOSUB NewBlock
			BlockOver = FALSE
			Pa(1) = 1: Px(1) = 2: Py(1) = 3: Pa(2) = 1: Px(2) = 2: Py(2) = 2
			Ti# = TIMER: Mode = FALSE
			Secs# = (20 - Level) / 10
			Pz = FALSE: Pz2 = TRUE: GOSUB Crbl
			DO
				y$ = INKEY$
				IF (Ti# + Secs# < TIMER) OR (Mode = TRUE AND y$ = "") THEN y$ = CHR$(0) + "P": Ti# = TIMER ELSE Mode = FALSE
				SELECT CASE y$
					CASE CHR$(0) + "H":
						Px(2) = Px(1): Py(2) = Py(1): Pa(2) = Pa(1) MOD 4 + 1: GOSUB Test
						IF Pz = TRUE THEN
							Pz = FALSE: Pz2 = FALSE: GOSUB Crbl
							Pa(1) = Pa(1) MOD 4 + 1
							Pz = FALSE: Pz2 = TRUE: GOSUB Crbl
						ELSE
							IF Snds THEN SOUND 37, .5
						END IF
					CASE CHR$(0) + "P":
						Px(2) = Px(1): Py(2) = Py(1) + 1: Pa(2) = Pa(1): GOSUB Test
						IF Pz = TRUE THEN
							Pz = FALSE: Pz2 = FALSE: GOSUB Crbl
							Py(1) = Py(1) + 1
							Pz = FALSE: Pz2 = TRUE: GOSUB Crbl
						ELSE
							BlockOver = TRUE
						END IF
					CASE CHR$(0) + "K":
						Px(2) = Px(1) - 1: Py(2) = Py(1): Pa(2) = Pa(1): GOSUB Test
						IF Pz = TRUE THEN
							Pz = FALSE: Pz2 = FALSE: GOSUB Crbl
							Px(1) = Px(1) - 1
							Pz = FALSE: Pz2 = TRUE: GOSUB Crbl
						ELSE
							IF Snds THEN SOUND 37, .5
						END IF
					CASE CHR$(0) + "M":
						Px(2) = Px(1) + 1: Py(2) = Py(1): Pa(2) = Pa(1): GOSUB Test
						IF Pz = TRUE THEN
							Pz = FALSE: Pz2 = FALSE: GOSUB Crbl
							Px(1) = Px(1) + 1
							Pz = FALSE: Pz2 = TRUE: GOSUB Crbl
						ELSE
							SOUND 37, .5
						END IF
					CASE " ": Mode = TRUE
					CASE "]", CHR$(16), "P", "p", CHR$(0) + CHR$(25): Pause
					CASE CHR$(19), "S", "s", CHR$(0) + CHR$(31): Snds = NOT Snds
					CASE CHR$(27): PlayGame = FALSE: EXIT FUNCTION
				END SELECT
			LOOP UNTIL BlockOver
			Pz = TRUE: Pz2 = TRUE: GOSUB Crbl

			CALL CheckRows(Score, Highest, Last, Pits, Leve)
			IF UsingVGAMode THEN COLOR 14
				  LOCATE 1, 58: PRINT "*** ** Player 1: ** ***": IF UsingVGAMode THEN COLOR 11
			IF Max = 60 THEN y = 3 ELSE y = 2
			LOCATE y, 58: PRINT USING "Score . . .     ##,####"; Score: IF UsingVGAMode THEN COLOR 9
			IF Max = 60 THEN y = 5 ELSE y = 3
			LOCATE y, 58: PRINT USING "Rows to destroy   : ##,"; Highest: IF UsingVGAMode THEN COLOR 3
			IF Max = 60 THEN y = 7 ELSE y = 4
			LOCATE y, 58: PRINT USING "Last score you got: ##,"; Last: IF UsingVGAMode THEN COLOR 1
			IF Max = 60 THEN y = 9 ELSE y = 5
			LOCATE y, 58: PRINT USING "Rows destroyed    : ##,"; Pits: IF UsingVGAMode THEN COLOR 3
			IF Max = 60 THEN y = 11 ELSE y = 6
			LOCATE y, 58: PRINT USING "Playing level     : ##,"; Level
			LevelOver = LevelOver + 1
		LOOP UNTIL LevelOver >= Level * 20
	LOOP UNTIL GameOver


EXIT FUNCTION

NewBlock:           '*** BLOCK GENERATOR ***'
	REDIM Pal(1 TO Pcs, 1 TO Pcs)
	x2 = INT(RND * Pcs) + 1: y2 = INT(RND * Pcs) + 1
	Pal(x2, y2) = 1: Pala(1, 1).x = x2: Pala(1, 1).y = y2
	FOR x = 2 TO Pcs
		DO
			c = 0: x2 = INT(RND * Pcs) + 1: y2 = INT(RND * Pcs) + 1
			IF x2 > 1 THEN IF Pal(x2 - 1, y2) = 1 THEN c = 1
			IF x2 < Pcs THEN IF Pal(x2 + 1, y2) = 1 THEN c = 1
			IF y2 > 1 THEN IF Pal(x2, y2 - 1) = 1 THEN c = 1
			IF y2 < Pcs THEN IF Pal(x2, y2 + 1) = 1 THEN c = 1
		LOOP WHILE (c = 0) OR (Pal(x2, y2) = 1)
		Pal(x2, y2) = 1: Pala(1, x).x = x2: Pala(1, x).y = y2
		Pala(1, x).c.z = INT(RND * 2) + 1: Pala(1, x).c.z2 = INT(RND * 3) + 1
	NEXT
	Pala(1, 1).c.z = INT(RND * 2) + 1: Pala(1, 1).c.z2 = INT(RND * 3) + 1
	ERASE Pal
	FOR x = 1 TO Pcs
		Pala(2, x).x = Pcs + 1 - Pala(1, x).y: Pala(2, x).y = Pala(1, x).x
		Pala(3, x).x = Pcs + 1 - Pala(1, x).x: Pala(3, x).y = Pcs + 1 - Pala(1, x).y
		Pala(4, x).x = Pala(1, x).y: Pala(4, x).y = Pcs + 1 - Pala(1, x).x
		FOR y = 2 TO 4: Pala(y, x).c = Pala(1, x).c: NEXT
	NEXT
	FOR x = 1 TO 4: FOR y = Pcs + 1 TO 11: Pala(x, y).x = 0: Pala(x, y).y = 0: Pala(x, y).c.z = 0: Pala(x, y).c.z2 = 0: NEXT y, x
	FOR x = 1 TO 4: FOR y = 1 TO Pcs
		Pala(x, y).x = Pala(x, y).x - 1: Pala(x, y).y = Pala(x, y).y - 1
	NEXT y, x
RETURN
Test:
	FOR x = 1 TO Pcs
		IF Px(2) + Pala(Pa(2), x).x < 0 OR Py(2) + Pala(Pa(2), x).y < 0 THEN EXIT FOR
		IF Area(Px(2) + Pala(Pa(2), x).x, Py(2) + Pala(Pa(2), x).y).z > 0 THEN EXIT FOR
	NEXT
	IF x = Pcs + 1 THEN Pz = TRUE ELSE Pz = FALSE
RETURN
Crbl:
	IF Pz2 = TRUE THEN
		FOR x = 1 TO Pcs: DoBlock Px(1) + Pala(Pa(1), x).x, Py(1) + Pala(Pa(1), x).y, Pala(Pa(1), x).c.z, Pala(Pa(1), x).c.z2, Pz: NEXT
	ELSE
		FOR x = 1 TO Pcs: DoBlock Px(1) + Pala(Pa(1), x).x, Py(1) + Pala(Pa(1), x).y, 0, 0, Pz: NEXT
	END IF
RETURN
END FUNCTION

