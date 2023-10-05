{$R+,Q+,I+}
Uses Objects, Crt, SVGA;

Var
	f: TBufStream;

Const
	Palette: Array[0..1, 0..3]Of Byte =
 ((0,15,4,12),
	(0,5,15,12));

Const
	Asennot: Array[0..8, 0..16]Of ShortInt =
 (( 8,  0, 1, 2, 3, 3, 2, 1, 0,           0,0,0,0,0,0,0,0),
	( 8,  0, 1, 2, 3, 3, 2, 1, 0,           0,0,0,0,0,0,0,0),
	(11,  0, 0, 1, 1, 2, 2, 3, 3, 3, 3, 3,  0,0,0,0,0),
	( 8,  0, 1, 2, 3, 3, 2, 1, 0,           0,0,0,0,0,0,0,0),
	(10,  0, 0, 1, 1, 1, 0, 0, 2, 2, 2,     0,0,0,0,0,0),
	(10,  0, 1, 2, 3, 9, 8, 9, 3, 2, 1,     0,0,0,0,0,0),
	( 9,  0, 0, 1, 1, 2, 2, 3, 3, 3,        0,0,0,0,0,0,0),
	( 8,  0, 0, 1, 1, 2, 2, 9, 9,           0,0,0,0,0,0,0,0),
	( 1,  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15));

Procedure Pala(x,y, Kuka,Pos: Word; Timer: LongInt; PalIndex: Integer);
Var
	dx, Asento: ShortInt;
	a, b, nx, ny, c: Byte;
Begin
	Asento := Asennot[Kuka, 1+(Timer Mod Asennot[Kuka, 0])];

	For ny := 0 To 15 Do
	Begin
		f.Seek(Kuka*4096 + Pos*4 + 64*ny + (Asento And 7)*1024);

		If Asento >= 8
			Then Begin dx := -1; nx := 15 End
			Else Begin dx :=  1; nx := 0 End;

		For b := 3 DownTo 0 Do
		Begin
			f.Read(c, 1);
			For a := 3 DownTo 0 Do
			Begin
				PSet(x+nx, y+ny, Palette[PalIndex, (c Shr(a*2))And 3]);
				Inc(nx, dx)
			End
		End
	End
End;

Procedure Toad(x,y: Word; Yla,Ala: Integer);
Var
	a, b, nx, ny, c: Byte;
	i: Integer;
Begin
	For ny := 0 To 15 Do
	Begin
		If ny<8 Then i := Yla Else i := Ala;
		f.Seek(8*4096 + i*4 + 64*ny);

		nx := 0;

		For b := 3 DownTo 0 Do
		Begin
			f.Read(c, 1);
			For a := 3 DownTo 0 Do
			Begin
				PSet(x+nx, y+ny, Palette[0, (c Shr(a*2))And 3]);
				Inc(nx)
			End
		End
	End
End;

Var
	x: Integer;
	y: Integer;
Begin
	Set256Mode(320, 200);

	f.Init('d:\pelit\nes\warioswo.dat', stOpenRead, 2048);

	For x := 0 To 15 Do
		Toad((x And 7)*17,(x Shr 3)*17 + 100,  x,x);

	Toad( 0*17, 50, 0,   0);
	Toad( 1*17, 50, 0,   1);
	Toad( 2*17, 50, 0,   2);
	Toad( 3*17, 50, 0,-127);
	Toad( 4*17, 50, 0,-126);
	Toad( 5*17, 50, 0,-125);
	Toad( 6*17, 50, 4, 4);
	Toad( 7*17, 50, 8, 8);
	Toad( 8*17, 50, 9, 9);
	Toad( 9*17, 50, 6+128, 10);
	Toad(10*17, 50, 0,-123);
	Toad(11*17, 50, 7, 5);

	Repeat
		For x := 0 To 7 Do
			Pala(x*32,0, x,0, MemL[Seg0040:$6C], 1)
	Until KeyPressed;

	f.Done
End.
