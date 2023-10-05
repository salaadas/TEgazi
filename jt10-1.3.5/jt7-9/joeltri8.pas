{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R+,S+,V-}
{$M 16384,120000,120000}
Uses Dos, Crt, MTask, SVGA;

{
 ∞∞∞∞∞∞∞€   ∞∞∞∞∞≤∞∞
 ∞±∞∞∞∞€€   ∞∞∞∞±≤∞∞
 ∞∞±±±±€€   ∞∞∞∞≤∞∞∞
 ∞∞±≤≤±€€   ∞∞±≤∞∞∞∞
 ∞∞±≤≤±€€   ∞±≤∞∞∞∞∞
 ∞∞±±±±€€   ≤≤∞∞∞∞∞≤
 ∞∞€€€€∞€   ∞∞∞∞∞∞≤±
 ∞€€€€€€∞   ∞∞∞∞∞≤±∞
}

Const
	sx = 320;
	sy = 200;
	SPEED    = $7F;
	COMPUTER = $80;
	BlockSize : Word = 25;

Var
	BufH : Word; BufT : Array[1..2]Of Word;
	Buf : Array[0..4093]Of Char;
	ID, Result : Word;
	Upd : Boolean;

Procedure PlayGame(Who, Stx : Word);
	Var
		NBlock, Block: Array[0..6, 0..6]Of Integer;
		Alue : Array[1..14,1..20]Of Integer;
		PalaMaassa, GameOver : Boolean;

	Procedure Pala(x,y,t:Integer);
	Var a, b : Integer;
	Begin
		x:=x Shl 3; y:=y Shl 3;
		Case t Of
			0:Begin
					For b := 0 To 7 Do
						HorLine(x, x+7, y+b, 20);
					HorLine(x, x+7, y, 18);
					HorLine(x, x+7, y+4, 18);
					For a := 0 To 3 Do
					Begin
						PSet(x+1, y+a,18);
						PSet(x+4, y+a+4, 18)
					End;
				End;
			2:Begin
					For a := 0 To 7 Do
					Begin
						For b := (7-a)To 7 Do PSet(x+a, y+b, 12);
						For b := 0 To(7-a) Do PSet(x+a, y+b, 15)
					End;
					For b := 3 To 5 Do HorLine(x+3, x+5, y+b, 14)
				End;
			1:Begin
					For b := 0 To 7 Do
						HorLine(x, x+7, y+b, 8);
					PSet(x+5, y, 15);
					PSet(x+5, y+0, 15);
					PSet(x+5, y+1, 15);
					PSet(x+4, y+2, 15);

					PSet(x+2, y+3, 15);
					PSet(x+3, y+3, 15);

					PSet(x+2, y+4, 15);

					PSet(x, y+5, 15);
					PSet(x+1, y+5, 15);

					PSet(x+7, y+5, 15);
					PSet(x+6, y+6, 15);

					PSet(x+4, y+1, 7);
					PSet(x+2, y+3, 7);
					PSet(x+7, y+6, 7);

					PSet(x+5, y+7, 7);
					PSet(x+6, y+7, 15)
				End
		End
	End;

	Procedure ClearAlue;
	Var x, y : Integer;
	Begin
		FillChar(Alue, SizeOf(Alue), 0);
		For x := 1 To 14 Do Alue[x, 20] := 1;
		For y := 2 To 20 Do Begin Alue[1, y] := 1; Alue[14, y] := 1 End;
	End;

	Procedure UpdField;
	Var x, y : Integer;
	Begin
		For x := 1 To 14 Do
		Begin
			For y := 2 To 20 Do
				Pala(x+Lo(Stx), y, Alue[x, y]);
			Pala(x+Lo(Stx), 1, Alue[x, y])
		End
	End;

	Procedure NewPala;
	Var c, x, y : Integer;
	Begin
		FillChar(Block, SizeOf(Block), 0);
		Block[Succ(Random(5)), 1] := 2;
		c := 1;
		While(c<BlockSize)Do
		Begin
			Repeat
				x := Succ(Random(5));
				y := Succ(Random(5));
			Until(Block[x, y]=0)And
						((Block[Pred(x),y]=2)Or(Block[x,Pred(y)]=2)Or
					 (Block[Succ(x),y]=2)Or(Block[x,Succ(y)]=2));
			Inc(c);
			Block[x, y] := 2
		End
	End;

	Procedure SetBlock(xc, yc : Integer; Off, Permanent : Boolean);
	Var x, y : Integer;
	Begin
		For x := 1 To 5 Do
			For y := 1 To 5 Do
				If(Block[x, y]=2)Then
				Begin
					If(Off)
						Then Pala(xc-1+Lo(Stx)+x, yc-1+y, 0)
						Else Pala(xc-1+Lo(Stx)+x, yc-1+y, 2);
					If(Permanent)Then
						If(Off)
							Then Alue[xc-1+x, yc-1+y] := 0
							Else Alue[xc-1+x, yc-1+y] := 2
				End
	End;

	Procedure OptiBlock;
	Var c, d, x, y : Integer;
	Begin
		c := 0;
		For y := 1 To 5 Do
		Begin
			d := 0;
			For x := 1 To 5 Do If(Block[x, y]=2)Then d := 1;
				If d=0 Then Inc(c) Else y := 5
			End;
		For d := 1 To c Do
			For x := 1 To 5 Do
				For y := 1 To 5 Do
					Block[x, y] := Block[x, y+1];
		c := 0;
		For x := 1 To 5 Do
		Begin
			d := 0;
			For y := 1 To 5 Do If(Block[x, y]=2)Then d := 1;
			If d=0 Then Inc(c) Else x := 5
		End;
		For d := 1 To c Do
			For y := 1 To 5 Do
				For x := 1 To 5 Do
					Block[x, y] := Block[x+1, y];
	End;

	Function ReadKey(Who : Word): Char;
	Begin
		ReadKey := Buf[BufT[Who]];
		BufT[Who] := Succ(BufT[Who])And 4095
	End;
Var
	Score, x, y, z, BlockX, BlockY, Drx, Dry : Integer;
	CanMove, Tipu : Boolean; TestX, TestY : Byte;
	EnitX, EnitY, Eniten : Array[1..4]Of Integer;
	NytMr : Integer; TestAse, NytAse : Integer;

Label
	Tiputa, OhiLoop, TipuAgain,
	Ylos, Alas, Vasen, Oikea;
Begin
	ClearAlue; UpdField;
	GameOver := False;
	Score := 1;
	Repeat
		NewPala; OptiBlock;
		BlockX := 2; BlockY := 2; NytAse := 1;
		For x := 1 To 4 Do Begin EnitX[x] := 5; EnitY[x] := 2; Eniten[x] := 0 End;
		For x := 1 To 5 Do
			For y := 1 To 5 Do
				If(Block[x,y]=2)And(Alue[BlockX+x-1, BlockY+y-1]<>0)Then Exit;
		TestX := 2; TestY := 2; CanMove := False;
		PalaMaassa := False; Tipu := False; TestAse := 5;
		Repeat
			z := Mem[$40:$6C];
			SetBlock(BlockX, BlockY, False, False);
			Upd := Not Tipu;
			Drx := 0; Dry := 1;
			Repeat
				If(Hi(Stx)And COMPUTER <> 0)Then
				Begin {Detect best place for block}
				End;
				If BufH <> BufT[Who] Then
				Begin
					SwitchTask;
					Tipu := False;
					Case ReadKey(Who)Of
						#27: Exit;
						'W','w': If Who=2 Then Goto Ylos;
						'S','s': If Who=2 Then Goto Alas;
						'A','a': If Who=2 Then Goto Vasen;
						'D','d': If Who=2 Then Goto Oikea;
						' ': If Who=2 Then Tipu := True;
						#13: If Who=1 Then Tipu := True;
						#0: If Who = 1 Then
									Case ReadKey(Who)Of
										'H':Begin
Ylos:											SetBlock(BlockX, BlockY, True, False);
													NBlock := Block;
													For x := 1 To 5 Do
														For y := 1 To 5 Do
															Block[x, y] := NBlock[y, (6-x)];
													OptiBlock;
													For x := 1 To 5 Do
														For y := 1 To 5 Do
															If(Block[x, y]=2)And
																((BlockX+x-1>13)Or
																 (Alue[BlockX+x-1, BlockY+y-1]<>0))Then
															Begin
																Block := NBlock;
																SetBlock(BlockX, BlockY, True, False);
																Goto OhiLoop
															End;
													SetBlock(BlockX, BlockY, False, False);
													Upd := True
												End; {VÑÑnnÑ palaa}
										'P':
Alas:									Begin Drx := 0; Dry := 1; Goto Tiputa End;
										'K':
Vasen:								Begin Drx :=-1; Dry := 0; Goto Tiputa End;
										'M':
Oikea:								Begin Drx := 1; Dry := 0; Goto Tiputa End;
									End;
					End
				End;
				SwitchTask;
			Until((Mem[$40:$6C]+256-z)And 255>Hi(Stx)And SPEED)Or Tipu;
Tiputa:SetBlock(BlockX, BlockY, True, False);
			For x := 1 To 5 Do
				For y := 1 To 5 Do
					If(Block[x,y]=2)And(Alue[BlockX+x-1+Drx, BlockY+y-1+Dry]<>0)Then
					Begin
						If(Dry>0)Then PalaMaassa := True;
						Goto OhiLoop
					End;
			SwitchTask;
			Inc(BlockX, Drx); Inc(BlockY, Dry);
OhiLoop:
		Until PalaMaassa;
		SetBlock(BlockX, BlockY, False, True);
		Upd := True;
TipuAgain:
		For y := 2 To 19 Do
		Begin
			SwitchTask;
			z := 0;
			For x := 2 To 13 Do
				If(Alue[x, y]=0)Then z := 1;
			If(z=0)Then
			Begin
				For z := y DownTo 2 Do
					For x := 2 To 13 Do
					Begin
						Alue[x, z] := Alue[x, z-1];
						Pala(x+Lo(Stx), z, Alue[x, z])
					End;
				Inc(Score, 200);
				Goto TipuAgain
			End
		End;
		Inc(Score, Random(50));
		GotoXY(Lo(Stx)+2, 22);
		Write('Score: ',Score:5);
	Until GameOver
End;

Procedure HandleKbd(a, b : Word);
Label Plc1;
Begin
	While True Do
	Begin
		SwitchTask;
		If(KeyPressed)Then
		Begin
Plc1:	Buf[BufH] := ReadKey;
			If(Buf[BufH]='|')Then
			Begin
				InLine($B8/3/0/$CD/16);

				Exec(GetEnv('COMSPEC'), '');

				WriteLn('Press any key to continue game...');

				Set256Mode(sx, sy);
				Goto Plc1;
			End;
			BufH := Succ(BufH)And 4095
		End
	End
End;

Var
	Ch : Char;
	a, b, c : Integer;
Begin
	DirectVideo := False;
	Set256Mode(sx, sy);
	TextAttr := 1;
	Write('Kerropa palikoiden koko: ');
	For b := 0 To FontKork-1 Do
	Begin
		c := 35+Round(3*Sin(b));
		For a := 0 To 24*8 Do
			PSet(a, b, Point(a,b)*c);
	End;
	BlockSize := 4;
	Repeat
		GotoXY(26, 1); Write(BlockSize,' ');
		For b := 0 To FontKork-1 Do
		Begin
			c := 58+Round(3*Sin(b));
			For a := 1 To 3*8 Do
				PSet(a+25*8-1, b, Point(a + 25*8-1,b)*c)
		End;
		Ch := ReadKey;
		Case Ch Of
			'0'..'9':
				If(BlockSize<2)Or((BlockSize=2)And(Ch<'6'))Then
					BlockSize := BlockSize*10+Ord(Ch)-Ord('0');
			^H: BlockSize := BlockSize Div 10;
		End
	Until Ch In[^[,^M];
	If(Ch=^[)Then Halt;
	Cls(1);
	Upd := True;
	Randomize; TextAttr := 12;
	BufH := 0; BufT[1] := 0; BufT[2] := 0;
	FontKork := 8;
	NewTask(@PlayGame,  1, 24+(6         )Shl 8, 16384, ID, Result);
	NewTask(@PlayGame,  2,  0+(6+COMPUTER)Shl 8, 16384, ID, Result);
	NewTask(@HandleKbd, 0,  0,  4096, ID, Result);
	Repeat SwitchTask Until(NTasks = 2)
End.