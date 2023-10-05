{$DEFINE SetVects}
{$UNDEF HangupAfterQuit}
{$A+,B-,E-,F+,N-,O+,V-}
{$I+,R+,S+}
{$D+,L+}
{ $C FIXED DISCARDABLE}
{ $K-,W-,C-}
{$M $4000,0,0}
{$UNDEF Ovr}
{$IFNDEF DPMI}
	{$IFNDEF WINDOWS}
	  { $DEFINE Ovr}
	{$ENDIF}
{$ENDIF}

{$IFDEF Ovr}
	Uses Crt, Dos{, Modemi}, Useful, UseMotu, Overlay;
	{$O USEFUL}
{$ELSE}
	Uses Crt, Dos{, Modemi}, UseMotu, Useful;
{$ENDIF}

{SETUP OPTIONS}
Const
	SegB800 = $B800;
	BlockSize : Byte = 5;
	CPU2 : Boolean = False;
	Local : Boolean = True;
	DrNfo : Boolean = True;
	Level : Word = 2000;
	KentLev : Byte = 10;
	BType : Array[Boolean]Of String3 = ('NO','YES');
{GAME VARIABLES}
Var
	Block : Array[1..2,1..2]Of Array[0..7,0..7,1..4]Of ShortInt;
	GO, Asento, Px, Py : Array[1..2]Of Byte;
	Score, Stat : Array[1..2]Of Word; Portti1, Portti2 : Byte;
	Yritys : Array[1..4]Of Array[1..20]Of Word;

{Procedure MiniTerm;
Var c : Integer;
Begin
	Repeat
		If(CharAvail(Portti1))Then SendByte(Portti2, ReadByte(Portti1));
		If(CharAvail(Portti2))Then SendByte(Portti1, ReadByte(Portti2));
	Until(Mem[$40:$17]And $10=$10);
	Repeat Until(Mem[$40:$17]And $10=0)
End;}

Procedure Game;
Var
	Kentat : Array[1..2]Of Array[0..41,0..35]Of ShortInt;
	Visual : Array[0..79,0..49]Of ShortInt;
	Procedure AbsSet(x, y, c : ShortInt);
	Var n : Byte; Ch : Char; v1,v2 : ShortInt; s2 : String16;
	Begin
		Visual[x, y] := c;
		If(y And 1=0)Then
		Begin
			v1 := Visual[x, y];
			v2 := Visual[x, y+1]
		End
		Else
		Begin
			v2 := Visual[x, y];
			v1 := Visual[x, y-1]
		End;
		Begin
			WriteANSI(#27'['+Strin(y Div 2)+';'+Strin(x)+'H');
			n := v1*16+v2; s2[0] := #0;
			If(n And 8<>0)Then s2 := ';1'; If(n And 128<>0)Then s2 := ';5';
			If(n And 7=0)Then s2 := s2+';30'; If(n And 7=1)Then s2 := s2+';34';
			If(n And 7=2)Then s2 := s2+';32'; If(n And 7=3)Then s2 := s2+';36';
			If(n And 7=4)Then s2 := s2+';31'; If(n And 7=5)Then s2 := s2+';35';
			If(n And 7=6)Then s2 := s2+';33'; n := n Shr 4;
			If(n And 7=1)Then s2 := s2 + ';44';
			If(n And 7=2)Then s2 := s2 + ';42'; If(n And 7=3)Then s2 := s2 + ';46';
			If(n And 7=4)Then s2 := s2 + ';41'; If(n And 7=5)Then s2 := s2 + ';45';
			If(n And 7=6)Then s2 := s2 + ';43'; If(n And 7=7)Then s2 := s2 + ';47';
			s2 := s2;
{			If(Linjalla(Portti1))Then OutTextToPort(Portti1,#27'[0'+s2+'mÜ');}
{			If(Linjalla(Portti2))Then }WriteANSI(#27'[0'+s2+'mÜ')
		End
	End;
	Procedure PSet(Who, x, y, c : ShortInt; Stay : Boolean);
	Begin
		If(Stay)Then Kentat[Who, y, x] := c;
		If(c=0)And((x+y And 1)And 1=0)Then c := 1;
		AbsSet(10+Who*20+x, 4+y, c);
	End;
	Procedure UusiTeePala(Who : Byte);
	Var n, a, x, y : Byte;
	Begin
		{Scrll Next to Current}
		Block[Who, 2] := Block[Who, 1];
		{Clear Next block}
		For x := 0 To 7 Do For y := 0 To 7 Do For a := 1 To 4 Do Block[Who, 1, x, y, a] := 0;
		{Let's edit Next block}
		x := Random(BlockSize); y := Random(BlockSize); Block[Who, 1, x, y, 1] := 5;
		For a := 1 To BlockSize-1 Do
		Begin
			n := 0;
			Repeat
				If(Random>0.5)Then If(Random>0.5)Then If(x>0)Then Dec(x)Else Else If(x<BlockSize-1)Then Inc(x)Else
				Else If(Random>0.5)Then If(y>0)Then Dec(y)Else Else If(y<BlockSize-1)Then Inc(y); Inc(n)
			Until(Block[Who, 1, x, y, 1] = 0)Or(n=0); Block[Who, 1, x, y, 1] := 5
		End;
		{It's now done. Let's rotate it.}
		For a := 2 To 4 Do For x := 0 To 7 Do For y := 0 To 7 Do Block[Who, 1, x, y, a] := Block[Who, 1, y, 7-x, a-1];
		{..And finally, clear the empty spaces in the left-up-corner.}
		For a := 1 To 4 Do
		Begin
			Repeat
				n := 0; For x := 0 To 7 Do If(Block[Who, 1, 0, x, a]>0)Then n := 1;
				If(n=0)Then
				Begin
					For x := 0 To 7 Do For y := 1 To 7 Do Block[Who, 1, y-1, x, a] := Block[Who, 1, y, x, a];
					For x := 0 To 7 Do Block[Who, 1, 7, x, a] := 0
				End
			Until(n<>0);
			Repeat
				n := 0; For y := 0 To 7 Do If(Block[Who, 1, y, 0, a]>0)Then n := 1;
				If(n=0)Then
				Begin
					For x := 1 To 7 Do For y := 0 To 7 Do Block[Who, 1, y, x-1, a] := Block[Who, 1, y, x, a];
					For y := 0 To 7 Do Block[Who, 1, y, 7, a] := 0
				End
			Until(n<>0)
		End
	End;
Var
	b, n, a, c, x, y : Integer; Chi, Ch : String3;
	Pois : Boolean; Cx, Cy : Byte; s2 : String16;
	Na, Nx, ux, ua : Byte; KP1, KP2 : Boolean;
Label NCheck, Poiis;
Begin
	WriteANSI(#27'[0m'#27'[2J'#27'[1;1H'#27'[1;44m'#27'[K'#27'[10CGame made by Proguru of JohemiWare, 27.02.1995');
	FillChar(Kentat, SizeOf(Kentat), 0); Randomize;
	FillChar(Visual, SizeOf(Visual), 0);
	For a:=1 To 2 Do For x:=1 To KentLev Do For y:=1 To 30 Do PSet(a,x,y,0,True);
	For y := 0 To 31 Do
	Begin
		a := y+Random(6)-Random(6);
		If(a<10)Then c := 7 Else If(a<20)Then c := 6 Else c := 4;
		For a := 1 To 2 Do
		Begin
			PSet(a, 0, y, c, True);
			PSet(a, KentLev+1, 31-y, c, True);
			PSet(a, y*(KentLev+1) Div 31, 0, c, True);
			PSet(a, KentLev+1-y*(KentLev+1) Div 31, 31, c, True)
		End
	End; UusiTeePala(1); UusiTeePala(2);
	Pois := False;
	Stat[1]  := 0; Stat[2]  := 0;
	GO[1]    := 0; GO[2]    := 0;
	Score[1] := 0; Score[2] := 0;
	a := 1; Cx := 1; Cy := 19;
	Begin
		{If(Linjalla(Portti1))Then }WriteANSI(#27'[2;1H'#27'[0;1mP1.NEXT   P2.NEXT');
		{If(Linjalla(Portti1))Then }WriteANSI(#27'[18;1H'#27'[0;1;44m'#27'[KChat window');
	End;
	WriteANSI(#27'[16;1H'#27'[0;1mP1.SCORE: ');
	WriteANSI(#27'[17;1H'#27'[0;1mP2.SCORE: ');
	Repeat
		KP1 := False; KP2 := False;
		Chi[0] := #0;
		If(Local)Then
		Begin
			If(KeyPressed)Then
			Begin
				Chi := ReadKey; If(Chi=#0)Then Chi := 'þ'+ReadKey;
				If(CPU2=False)Then
				Begin
					If(Chi='w')Or(Chi='W')Then Begin KP2 := True; Chi := 'þH' End;
					If(Chi='s')Or(Chi='S')Then Begin KP2 := True; Chi := 'þP' End;
					If(Chi='a')Or(Chi='A')Then Begin KP2 := True; Chi := 'þK' End;
					If(Chi='d')Or(Chi='D')Then Begin KP2 := True; Chi := 'þM' End
				End;
				If(KP2=False)Then KP1 := True
			End
		End
		Else
		Begin
			If(KeyPressed)Then
			Begin
				Chi := ReadKey; If(Chi=#0)Then Chi := 'þ'+ReadKey;
				KP1 := True
			End;
			If(CPU2=False)Then
			Begin
				If(CharAvail(2))Then
				Begin
					Chi := LueNap(2);
					If(Chi=#0)Then
						Chi := 'þ' + LueNap(2)
					Else If(Chi=#27)Then
						Chi := Chi + LueNap(2) + LueNap(2);
					KP2 := True
				End
			End
		End;
	 For a := 1 To 2 Do
	 Begin
		If(GO[a]>0)Then Goto Poiis;
		If(Stat[a]=0)And(GO[a]=0)Then
		Begin
			b := 0;
NCheck:
			For y := 1 To 30 Do
			Begin
				c := 0;
				For x := 1 To KentLev Do If(Kentat[a,y,x]=0)Then c := 1;
				If(c=0)Then
				Begin
					n := y;
					For y := y DownTo 2 Do
						For x := 1 To KentLev Do Kentat[a,y,x]:=Kentat[a,y-1,x];
					Inc(b); Goto NCheck
				End
			End;
			If(b<>0)Then
				For y := 1 To 30 Do For x := 1 To KentLev Do PSet(a, x, y, Kentat[a,y,x], True);
			Case b Of
				0: Inc(Score[a], Random(10));
				1: Inc(Score[a], 10);
				2: Inc(Score[a], 30);
				3: Inc(Score[a], 60);
				4: Inc(Score[a], 100);
			End;
			UusiTeePala(a); c := 1;
			{If(Linjalla(Portti1))Then }WriteANSI(#27'[16;10H'#27'[0;1m'+Strin(Score[1]));
			{If(Linjalla(Portti1))Then }WriteANSI(#27'[17;10H'#27'[0;1m'+Strin(Score[2]));
			For x := 0 To BlockSize-1 Do
				For y := 0 To BlockSize-1 Do
					If(Block[a,2,x,y,1]>0)And(Kentat[a,y+1,x+1]>0)Then c := 0;
			If(c=0)Then
			Begin
				GO[a] := 1;
				For c := 2 To 17 Do
				Begin
					{If(Linjalla(Portti1))Then }WriteANSI(#27'['+Strin(c)+';'+Strin(10+a*20)+'H'#27'[0;1;34m    GAME OVER    ');
				End;
				Goto Poiis
			End;
			For x := 0 To BlockSize-1 Do
				For y := 0 To BlockSize-1 Do
				Begin
					n := Block[a,1,x,y,1]+1;
					If(Visual[1+(a-1)*10+x, 6+(c-1)*(BlockSize+1)+y]<>n)Then
						AbsSet(1+(a-1)*10+x,6+(c-1)*(BlockSize+1)+y,n)
				End;
			If(a=2)And(CPU2=True)Then
			Begin
				Na := 1; Nx := 1; Yritys[1, 1] := 0;
				ua := 1; ux := 1;
			End;
			Stat[a] := 1; Asento[a] := 1;
			Px[a] := 1; Py[a] := 1
		End;
		If(a=2)And(CPU2=True)And((ua<4)Or(ux<KentLev))Then
		Begin
			n := 1; c := 0;
			Repeat
				Inc(n);
				For x := 0 To BlockSize-1 Do
					For y := 0 To BlockSize-1 Do
						If(Block[2,2,x,y,ua]>0)And(Kentat[2,y+n+1,x+ux]>0)Then Inc(c)
			Until(c>0); c := c*2+n; Yritys[ua, ux] := c;
			If(c>Yritys[Na, Nx])Then Begin Na:=ua;Nx:=ux End;
			If(ua<4)Then Inc(ua)Else Begin ua:=1; Inc(ux) End
		End;
		If(Stat[a]=1)And(GO[a]=0)Then
		Begin
			c := 0;
			For x := 0 To BlockSize-1 Do
				For y := 0 To BlockSize-1 Do
					If(Block[a,2,x,y,Asento[a]]>0)And(Kentat[a,y+Py[a]+1,x+Px[a]]>0)Then c := 1;
			If(c=0)Then
			Begin
				For x := 0 To BlockSize-1 Do
					For y := 0 To BlockSize-1 Do
						If(Block[a,2,x,y,Asento[a]]>0)Then
							PSet(a,Px[a]+x,Py[a]+y,0,False);
				Inc(Py[a]);
				For x := 0 To BlockSize-1 Do
					For y := 0 To BlockSize-1 Do
						If(Block[a,2,x,y,Asento[a]]>0)Then
							PSet(a,Px[a]+x,Py[a]+y,Block[a,2,x,y,Asento[a]],False);
				Stat[a] := Level;
			End
			Else
			Begin
				For x := 0 To BlockSize-1 Do
					For y := 0 To BlockSize-1 Do
						If(Block[a,2,x,y,Asento[a]]>0)Then
							PSet(a,Px[a]+x,Py[a]+y,Block[a,2,x,y,Asento[a]],True);
				Stat[a] := 1
			End;
		End;
		If(a=1)Then
			If(KP1)Then Ch := Chi Else Ch[0] := #0
		Else
			If(KP2)Then Ch := Chi Else Ch[0] := #0;
		If(a=2)And(CPU2=True)And(Mem[$40:$40]And 1=0)Then
		Begin
			Mem[$40:$40] := $FF;
			If(Asento[2]<>na)Then Ch := 'þH'
			Else If(Px[2]<nx)Then Ch := 'þM'
			Else If(Px[2]>nx)Then Ch := 'þK'
			Else If(Random(2)=0)Then Ch := 'þP';
			If(Ch[0]<>#0)Then KP2 := True
		End;
		If(Ch[0]=#0)Then Dec(Stat[a])
		Else
		Begin
			If(Ch='þT'){Or((Linjalla(Portti2)=False)And(Local=False))}Then Pois := True
			Else If((Ch=#27'[B')Or(Ch='þP'))Then
				If(Stat[a]>Level Div 10)Then Stat[a] := 1 Else Dec(Stat[a])
			Else If(Ch=#27'[C')Or(Ch='þM')Then
			Begin
				c := 0;
				For x := 0 To BlockSize-1 Do
					For y := 0 To BlockSize-1 Do
						If(Block[a,2,x,y,Asento[a]]>0)And(Kentat[a,y+Py[a],x+Px[a]+1]>0)Then c := 1;
				If(c=0)Then
				Begin
					For x := 0 To BlockSize-1 Do
						For y := 0 To BlockSize-1 Do
							If(Block[a,2,x,y,Asento[a]]>0)Then
								PSet(a,Px[a]+x,Py[a]+y,0,False);
					Inc(Px[a]);
					For x := 0 To BlockSize-1 Do
						For y := 0 To BlockSize-1 Do
							If(Block[a,2,x,y,Asento[a]]>0)Then
								PSet(a,Px[a]+x,Py[a]+y,Block[a,2,x,y,Asento[a]],False)
				End
			End
			Else If(Ch=#27'[D')Or(Ch='þK')Then
			Begin
				c := 0;
				For x := 0 To BlockSize-1 Do
					For y := 0 To BlockSize-1 Do
						If(Block[a,2,x,y,Asento[a]]>0)And(Kentat[a,y+Py[a],x+Px[a]-1]>0)Then c := 1;
				If(c=0)Then
				Begin
					For x := 0 To BlockSize-1 Do
						For y := 0 To BlockSize-1 Do
							If(Block[a,2,x,y,Asento[a]]>0)Then
								PSet(a,Px[a]+x,Py[a]+y,0,False);
					Dec(Px[a]);
					For x := 0 To BlockSize-1 Do
						For y := 0 To BlockSize-1 Do
							If(Block[a,2,x,y,Asento[a]]>0)Then
								PSet(a,Px[a]+x,Py[a]+y,Block[a,2,x,y,Asento[a]],False)
				End
			End
			Else If(Ch=#27'[A')Or(Ch='þH')Then
			Begin
				c := 0; n := Asento[a]-1; If(n=0)Then n := 4;
				For x := 0 To BlockSize-1 Do
					For y := 0 To BlockSize-1 Do
						If(Block[a,2,x,y,n]>0)And(Kentat[a,y+Py[a],x+Px[a]]>0)Then c := 1;
				If(c=0)Then
				Begin
					For x := 0 To BlockSize-1 Do
						For y := 0 To BlockSize-1 Do
							If(Block[a,2,x,y,Asento[a]]>0)Then
								PSet(a,Px[a]+x,Py[a]+y,0,False);
					Asento[a] := n;
					For x := 0 To BlockSize-1 Do
						For y := 0 To BlockSize-1 Do
							If(Block[a,2,x,y,Asento[a]]>0)Then
								PSet(a,Px[a]+x,Py[a]+y,Block[a,2,x,y,Asento[a]],False)
				End
			End
			Else
			Begin
				If(a=1)Then s2 := #27'[0;1;31m' Else s2 := #27'[0;1;34m';
				If(Ch=#13)Then Ch := #13+#10;
				While(Pos(#27, Ch)>0)Do Ch[Pos(#27, Ch)]:='<';
				{If(Linjalla(Portti1))Then }WriteANSI(s2+#27'['+Strin(cy)+';'+Strin(cx)+'H'#27'[K'+Ch);
				Cx := WhereX; Cy := WhereY;
				If Cy=25 Then
				Begin
					{If(Linjalla(Portti1))Then }WriteANSI(#27'[19;1H');
					n := 255;
					For y := 19 To 23 Do
						For x := 1 To 80 Do
						Begin
							b := Mem[SegB800:(y+1)*160+(x-1)*2];
							c := Mem[SegB800:(y+1)*160+(x-1)*2+1];
							If(c<>n)Then
							Begin
								n := c;
								s2[0] := #0;
								If(n And 8<>0)Then s2 := ';1'; If(n And 128<>0)Then s2 := ';5';
								If(n And 7=0)Then s2 := s2+';30'; If(n And 7=1)Then s2 := s2+';34';
								If(n And 7=2)Then s2 := s2+';32'; If(n And 7=3)Then s2 := s2+';36';
								If(n And 7=4)Then s2 := s2+';31'; If(n And 7=5)Then s2 := s2+';35';
								If(n And 7=6)Then s2 := s2+';33'; n := n Shr 4;
								If(n And 7=1)Then s2 := s2 + ';44';
								If(n And 7=2)Then s2 := s2 + ';42'; If(n And 7=3)Then s2 := s2 + ';46';
								If(n And 7=4)Then s2 := s2 + ';41'; If(n And 7=5)Then s2 := s2 + ';45';
								If(n And 7=6)Then s2 := s2 + ';43'; If(n And 7=7)Then s2 := s2 + ';47';
								s2 := s2;
								{If(Linjalla(Portti1))Then }WriteANSI(#27'[0'+s2+'m');
							End;
							{If(Linjalla(Portti1))Then }WriteANSIChar(Char(b));
						End;
					Cy := 23;
					{If(Linjalla(Portti1))Then OutTextToPort(Portti1, }WriteANSI(#27'[24;1H'#27'[K');
					{If(Linjalla(Portti1))Then OutTextToPort(Portti1, }WriteANSI(#27'[23;1H'#27'[K');
				End
			End
		End;
		If(GO[1]>0)And(GO[2]>0)Then Pois := True
	 End;
Poiis:
	Until(Pois)
End;

Procedure Setup;
	Procedure Update;
	Var s : String;
	Begin
		s := Strin(BlockSize);
		GotoXY(21, 1); ClrEOL; FastWrite(21,1, $17, s);
		GotoXY(21, 2); ClrEOL; FastWrite(21,2, $17, BType[CPU2]);
		GotoXY(21, 3); ClrEOL; FastWrite(21,3, $17, BType[Local]);
		GotoXY(21, 4); ClrEOL; FastWrite(21,4, $17, BType[DrNfo]);
		s := Strin(Level);
		GotoXY(21, 5); ClrEOL; FastWrite(21,5, $17, s)
	End;
Const s1 : String[25] = '1)Block size is   :';
Const s2 : String[25] = '2)Player 2 is CPU :';
Const s3 : String[25] = '3)Game is local   :';
Const s4 : String[25] = '4)Use DORINFOx.DEF:';
Const s5 : String[25] = '5)Gamespeed is now:';
Const s6 : String[25] = 'Game is currently :';
Const s7 : String[25] = '6)Exit and save changes';
Const s8 : String[25] = '7)Exit the whole game';
Const s9 : String[25] = 'Select your option: ';

Var Ch : Char;
Begin
	Window(1,1,80,25);
	TextAttr := $1F;
	WriteANSI(#27'[20;1H'#27'[0;1;44m'#27'[K'#27'[10CGame made by Proguru of JohemiWare, 27.02.1995');
	WriteANSI(#27'[21;1H'#27'[0;1;44m'#27'[K'#27'[5CProceeding setup...');
	FastWrite(1, 1, $07, s1);
	FastWrite(1, 2, $07, s2);
	FastWrite(1, 3, $07, s3);
	FastWrite(1, 4, $07, s4);
	FastWrite(1, 5, $07, s5);
	FastWrite(1, 6, $07, s6);
	GotoXY(21, 6); ClrEOL; Write('UNREGISTERED!!!!!');
	FastWrite(1, 7, $07, s7);
	FastWrite(1, 8, $07, s8);
	FastWrite(1, 9, $09, s9);
	Delay(1000); Update;
	Repeat
		GotoXY(22,9); TextAttr := $17;
		Repeat Ch := ReadKey Until(Ch>'/')And(Ch<'8'); Write(Ch);
		If(Ch='1')Then Begin GotoXY(21,1); ClrEOL; ReadLn(BlockSize) End;
		If(Ch='2')Then CPU2 := Boolean(1-Byte(CPU2));
		If(Ch='3')Then Local := Boolean(1-Byte(Local));
		If(Ch='4')Then DrNfo := Boolean(1-Byte(DrNfo));
		If(Ch='5')Then Begin GotoXY(21,5); ClrEOL; ReadLn(Level) End;
		If(Level>30000)Then Level := 30000;
		If(BlockSize<1)Then BlockSize:=1 Else If(BlockSize>8)Then BlockSize:=8;
		Update
	Until(Ch='6')Or(Ch='7'); If(Ch='7')Then Begin InLine($B8/3/0/$CD/16); Halt End
End;

Begin
	{$IFDEF DPMI}
		WriteLn('The game is compiled for Protected mode. Halting...');
		Halt;
	{$ENDIF}
	{$IFDEF WINDOWS}
		WriteLn('The game is compiled for Windows mode (Y„„kk). Halting...');
		Halt;
	{$ENDIF}
	DirectVideo := True; CheckBreak := True;
	CheckEOF := False; CheckSnow := False; TextAttr := 7;
	InLine($B8/3/0/$CD/16); Portti1 := 1; Portti2 := 0;
	{$IFDEF Ovr}
	WriteLn('þ Modemsystem initialized...');
	WriteLn('þ Clearing overlay buffer...'); OvrClearBuf;
	WriteLn('þ Initializing overlay system...'); OvrInit('JOELTRI7.OVR');
	WriteLn('þ Overlay buffer size: ',OvrGetBuf,' bytes.');
	If(OvrResult <> OvrOk)then
	Begin
		Case(OvrResult)Of
			OvrError: Writeln('Program has no overlays.');
			OvrIOError: Writeln('Overlay file I/O error.');
			OvrNotFound: Writeln('Overlay file not found.');
		End;
		Halt(1)
	End;
	OvrInitEMS;
	Case OvrResult Of
		OvrNoEMSDriver: Writeln('EMS driver is not installed, using conventional memory for swapping.');
		OvrNoEMSMemory: Writeln('Not enough EMS memory, using conventional memory for swapping.');
		Else Writeln('Using EMS for faster overlay swapping.');
	End;
	Delay(1000);
	{$ENDIF}
	InLine($B8/3/0/$CD/16); Setup;
	InLine($B8/3/0/$CD/16); Game;
	InLine($B8/3/0/$CD/16); WriteLn('Carrier lost, exiting...')
End.