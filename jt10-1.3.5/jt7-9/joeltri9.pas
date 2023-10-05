{$R-,Q-,S-,I-}
Uses Objects,Windos,Strings,Crt,Timer,X00Fossi,JT9Fract, AnsiEMU;

Const
  KB_NOKEY = $0000;
  KB_UP    = $4800;
  KB_DOWN  = $5000;
  KB_LEFT  = $4B00;
  KB_RIGHT = $4D00;
  KB_DROP  = $3920;
  KB_ESC   = $011B;

Const
  {These are default settings and have effect only when
   configuration file does not exist.}
  Port:             Word    = 1;
  Blank:            Word    =$04FA;
  OopsShield:       Boolean =False;
  DisableFractal:   Boolean =False;
  CoolWipeLines:    Boolean =True;
  InitialBlockSize: Byte    = 4;
  InitialSpeed:     Word    =50;
  Field1X:          Word    = 0;
  Field1Y:          Word    = 0;
	Field1XSize:      Word    =10;
	Field1YSize:      Word    =23;
	EvilBlocks1:      Integer = 0;
	Field2X:          Word    =55;
	Field2Y:          Word    = 0;
	Field2XSize:      Word    =10;
	Field2YSize:      Word    =23;
	EvilBlocks2:      Integer = 0;
	BlockDetail:      Byte    = 1;
	BlockColour:      Word    = 0;
														{0     = Random of 1,2,3,4,6,7,9,10,11,12,14}
														{1..15 = Specified}
														{16    = Weird}
	BlockRemoval:     Array[0..255]Of Char = 'SINGLE,DOUBLE,TRIPLE,TETRIS,PENTA,MIRACLE';
	KeyProc: Array[0..4095]Of Char =
	 '  RETVAL KB_NOKEY'^J+
	 '  IFNHIT'^J+
	 '    EXIT'^J+
	 '  GET 3'^J+
	 '  IFE 3 '' '' 13 10'^J+
	 '    RETVAL KB_DROP'^J+
	 '  IFE 3 ^P ^E ''8'''^J+
	 '    RETVAL KB_UP'^J+
   '  IFE 3 ^N ^X ''2'''^J+
	 '    RETVAL KB_DOWN'^J+
   '  IFE 3 ^F ^D ''6'''^J+
	 '    RETVAL KB_RIGHT'^J+
   '  IFE 3 ^B ^S ''4'''^J+
	 '    RETVAL KB_LEFT'^J;

  ScoreProc: Array[0..4095]Of Char =
   '  IF 0 0'^J+
   '    Rand 4 1 50'^J+
   '  IF 0 1'^J+
	 '    I4 = 100'^J+
	 '  IF 0 2'^J+
	 '    I4 = 300'^J+
	 '  IF 0 3'^J+
	 '    I4 = 500'^J+
	 '  IF 0 4'^J+
	 '    I4 = 700'^J+
	 '  IF 0 5'^J+
	 '    I4 = 900'^J+
	 '  IF 0 6'^J+
	 '    I4 = 10000'^J+
	 '  RetVal I4'^J+
	 '  Exit'^J;


Var
	AnsiPict: Array[0..49, 0..79]Of Word;

Procedure ReadConfig;
Var
	f: Text;
	s, t: String;
	b, i, Code: Integer;
	f2: File;
	Buf: String[128];
	BRead: Word;

	Procedure LoadProcedure(Var i: Integer; Dest: PChar);
		Function SpaceCount: Byte;
		Var c: Byte;
		Begin
			c := 0;
			While s[c+1]=' ' Do Inc(c);
			SpaceCount := c
		End;
		Procedure GetLine;
		Begin
			ReadLn(f, s);
			Inc(i);
			While s[Length(s)] = ' ' Do Dec(s[0]);
			s[Length(s)+1] := #10;
			s[Length(s)+2] := #0
		End;
	Var c: Byte;
	Begin
		Repeat
			GetLine;
			c := SpaceCount;
    Until(s <> '')And(s[c+1]<>';');

    c := SpaceCount;
    If Dest <> Nil Then strcpy(Dest, PChar(@s)+1);

    Repeat
      Repeat
        GetLine;
        b := SpaceCount;
      Until(s <> '')And(s[b+1]<>';');
      If b < c Then Exit;
      If Dest <> Nil Then strcat(Dest, PChar(@s)+1)
    Until False;
  End;

Begin
  FillWord(AnsiPict, SizeOf(AnsiPict)Shr 1, $0720);

  FileMode := stOpenRead+stDENYNONE;
  Assign(f, 'joeltri9.cfg');
  Reset(f);

  If IOResult <> 0 Then
  Begin
    ReWrite(f);
    Write(f, PChar(
      '#'^J+
      '# Configuration file for JoelTris IX'^J+
      '#'^J+
      '# Copyright (C) 1992,97 Joel Yliluoma - Bisqwit!ircnet'^J+
      '# You can mail me to bisqwit@samoilu.net'^J+
      '# This program is freeware.'+
      #10^J+
      #10'# Specify COM port setting in range of 1..3 for external player.'+
      #10'Port='),Port,PChar(
      #10^J+
      #10'# Initial settings for player 1'+
      #10'Field1X='),Field1X,PChar(#9'# Value range is 0 to 79-((Field1XSize+2)*2)'+
      #10'Field1Y='),Field1Y,PChar(#9'# Value range is 0 to 25'+
      #10'Field1XSize='),Field1XSize,PChar(#9'# Value range is 6 to 38'+
      #10'Field1YSize='),Field1YSize,PChar(#9'# Value range is 6 to 24'+
      #10),PChar(
      #10'# EvilBlocks setting varies in range -255..255.'+
      #10'# Setting it to 255 makes your game as easy as possible.'+
      #10'# Setting it to -255 gives you always the block you don''t want.'+
      #10'# For fair game, set it to zero, for both players.'+
      #10'EvilBlocks1='),EvilBlocks2,PChar(
      #10^J+
      #10'# Block removal names'+
			#10'BlockRemoval='),BlockRemoval,PChar(
      #10^J+
      #10'# Initial settings for player 2'+
      #10'Field2X='),Field2X,PChar(
      #10'Field2Y='),Field2Y,PChar(
      #10'Field2XSize='),Field2XSize,PChar(
      #10'Field2YSize='),Field2YSize,PChar(
      #10'EvilBlocks2='),EvilBlocks2,PChar(
      #10^J+
      #10'# Initial settings for the background fractal'+
      #10'DisableFractal='),DisableFractal,PChar(
      #10'FractX1='),FractX1,PChar(
      #10'FractY1='),FractY1,PChar(
      #10'FractX2='),FractX2,PChar(
      #10'FractY2='),FractY2,PChar(
      #10^J+
      #10'# Set this to TRUE if you want to prevent accidental'+
      #10'# block drops at top line'+
      #10'OopsShield='),OopsShield,PChar(
      #10^J+
      #10'# Set CoolWipeLines to '),TrueStr,PChar(' for TETRIS 2 compatibility,'+
      #10'#                      '),FalseStr,PChar(' for faster game.'+
      #10'# Do not add comments to the end of CoolWipeLines setting line.'+
      #10'CoolWipeLines='),CoolWipeLines,PChar(
      #10^J+
      #10'# Specifies the background color...'+
      #10'Blank='),Blank,PChar(
      #10^J+
      #10'# InitialBlockSize is 4 for normally.'+
      #10'# Samples of blocks for different sizes:'+
      #10'#   4  ‹€ﬂ €‹‹ ‹€‹'+
      #10'#            ‹  ‹'+
      #10'#   5 €€‹  ‹‹€ ﬂ€ﬂ'+
      #10'#     ‹‹   ‹‹'+
      #10'#   6 ‹€ﬂ €€'),PChar(
      #10'# For comformtable game, don''t set values outside ranges 4..5.'+
      #10'# The biggest value accepted by game is 36.'+
      #10'InitialBlockSize='),InitialBlockSize,PChar(
      #10^J+
      #10'# InitialSpeed value specifies, as you can''t guess, the delay'+
      #10'# of the game. This means, bigger value causes slower game.'+
      #10'# Setting value 0 here is not a good idea.'+
      #10'# Good value for Pentium 90MHz is 50 to 100.'+
      #10'InitialSpeed='),InitialSpeed,PChar(
      #10^J+
      #10'# BlockColour specifies colours of blocks.'+
      #10'# 0 = Normal. Colour is random of 1,2,3,4,6,7,9,10,11,12 and 14.'+
      #10'# 8 = Causes cash bug. Don''t use! (Known bug, I''m not going to fix.)'+
      #10'# 16= Weird. Every piece of block is random of above.'+
      #10'# 1,2,3,4,5,6,7,9,10,11,12,13,14,15: Use it.'),PChar(
      #10'# It is not recommended to use value 16, because it is'+
      #10'# ugly for eyes and slows down modem play.'+
      #10'BlockColour='),BlockColour,PChar(
      #10^J+
      #10'# BlockDetail specifies detail level of blocks.'+
      #10'# 0 = Normal. Just simple blocks.'+
      #10'# 1 = Horizontal detail, looks quite nice.'+
      #10'# 2 = Vertical detail, doesn''t look so nice.'+
      #10'# 3 = Both details, ugly.'),PChar(
      #10'BlockDetail='),BlockDetail,PChar(
      #10^J+
      #10'# The rest settings are flow code.'+
      #10'# Don''t modify if you don''t know what are you doing.'+
      #10'# All flow code procedures begin with colon ('':'')'^J+
      #10':KeyProc'^J),KeyProc,PChar(
      #10':Score'^J),ScoreProc,PChar(
      #10^J'### END OF CONFIGURATION FILE ###'^J));
    Close(f);
    Exit;
  End;

  i := 0;
  Repeat
    ReadLn(f, s);
    If(IOResult<>0)Or EOF(f)Then Break;
    Inc(i);
    SpFix(s);
    If(Length(s)=0)Or(s[1]='#')Then Continue;

    SpFix(s);
    b := Pos('=', s);

		t := s;
    If t[1]=':' Then
    Begin
      Delete(t,1,1);
			If UCase(t)='KEYPROC' Then LoadProcedure(i, KeyProc)
			Else If UCase(t)='SCORE' Then LoadProcedure(i, ScoreProc)
      Else
      Begin
        Write('Unknown procedure name',PChar(' setting at line '),i,PChar(' of configuration file.'^M^J^G));
				LoadProcedure(i, Nil);
      End;
      Continue;
    End;
    If b=0 Then
    Begin
      Write('Error in configuration file at line ',i,': ''='' missing.'^M^J^G);
      Continue
    End;

    t[0] := Chr(b-1);

    Delete(s, 1, b);
    SpFix(s);
    Val(s, b, Code);
    s[Length(s)+1] := #0;

    If t='InitialBlockSize'Then
      If(b<0)Or(b>36)
        Then Write('InitialBlockSize',PChar(' setting at line '),i,PChar(' is out of ranges.'^M^J^G))
        Else InitialBlockSize := b
    Else If t='InitialSpeed'Then
      If(b<0)
        Then Write('InitialSpeed',PChar(' setting at line '),i,' is less than zero.'^M^J^G)
        Else InitialSpeed := b
    Else If t='BlockColour'Then
      If(b<0)Or(b>16)
        Then Write('BlockColour',PChar(' setting at line '),i,PChar(' is out of ranges.'^M^J^G))
        Else BlockColour := b
    Else If t='BlockDetail'Then
      If(b<0)Or(b>3)
        Then Write('BlockDetail',PChar(' setting at line '),i,PChar(' is out of ranges.'^M^J^G))
        Else BlockDetail := b
    Else If t='CoolWipeLines'Then
      If stricmp(PChar(@s)+1, TrueStr)=0 Then CoolWipeLines := True
	  Else If stricmp(PChar(@s)+1, FalseStr)=0 Then CoolWipeLines := False
      Else Write('CoolWipeLines',PChar(' setting at line '),i,' is not correct.'^M^J^G)
	Else If t='BlockRemoval'Then
	  If strlen(PChar(@s)+1) < SizeOf(BlockRemoval)
		 Then strcpy(BlockRemoval, PChar(@s)+1)
	  Else Write('BlockRemoval',PChar(' setting at line '),i,' is too long.'^M^J^G)
    Else If t='DisableFractal'Then
    Begin
      DisableFractal := True;
      If stricmp(PChar(@s)+1, TrueStr)=0 Then
      Else If stricmp(PChar(@s)+1, FalseStr)=0 Then DisableFractal := False
      Else
      Begin
        Assign(f2, s);
        Reset(f2, 1);
        WindMin := FractX1+FractY1 Shl 8;
        WindMax := FractX2+FractY2 Shl 8;
        Repeat
          BlockRead(f2, Buf[1], 128, BRead);
          Buf[0] := Chr(BRead);
					WriteANSI(Buf)
				Until BRead=0;
        Close(f2);
        Move(Mem[SegB800:0], AnsiPict, SizeOf(AnsiPict))
      End
    End
    Else If t='OopsShield'Then
      If stricmp(PChar(@s)+1, TrueStr)=0 Then OopsShield := True
      Else If stricmp(PChar(@s)+1, FalseStr)=0 Then OopsShield := False
      Else Write('OopsShield',PChar(' setting at line '),i,' is not correct.'^M^J^G)
    Else If t='Port'Then
      If(b>=0)And(b<=4)Then Port:=b Else Write('Port',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='Blank'Then Blank:=b
    Else If t='FractX1'Then
      If(b>=0)And(b<=79)Then FractX1:=b Else Write('FractX1',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='FractY1'Then
      If(b>=0)And(b<=49)Then FractY1:=b Else Write('FractY1',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='FractX2'Then
      If(b>=0)And(b<=79)Then FractX2:=b Else Write('FractX2',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='FractY2'Then
      If(b>=0)And(b<=49)Then FractY2:=b Else Write('FractY2',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='Field1X'Then
      If(b>=0)Then Field1X:=b Else Write('Field1X',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='Field1Y'Then
      If(b>=0)Then Field1Y:=b Else Write('Field1Y',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='Field2X'Then
      If(b>=0)Then Field2X:=b Else Write('Field2X',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
		Else If t='Field2Y'Then
      If(b>=0)Then Field2Y:=b Else Write('Field2Y',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='Field1XSize'Then
      If(b>=0)Then Field1XSize:=b Else Write('Field1XSize',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='Field1YSize'Then
      If(b>=0)Then Field1YSize:=b Else Write('Field1YSize',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='Field2XSize'Then
      If(b>=0)Then Field2XSize:=b Else Write('Field2XSize',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='Field2YSize'Then
      If(b>=0)Then Field2YSize:=b Else Write('Field2YSize',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='EvilBlocks1'Then
      If(b>=-255)And(b<=255)
        Then EvilBlocks1 := b
        Else Write('EvilBlocks1',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else If t='EvilBlocks2'Then
      If(b>=-255)And(b<=255)
        Then EvilBlocks2 := b
        Else Write('EvilBlocks2',PChar(' at line '),i,PChar(' is out of ranges.'^M^J^G))
    Else Write('Unknown ',t,PChar(' setting at line '),i,' of configuration file.'^M^J^G)
  Until False;

  Close(f)
End;

{
  while(*Code)i++,Code++;
  While(Code^<>#0)Do Begin Inc(i);Inc(Code)End;
}

Function GetLine(Var Indent: Integer; Var s: PChar): String;
Var t: String;
Begin
  t := '';
  Indent := 0;
  While s^ = ' ' Do Begin Inc(Indent); Inc(s)End;
  While(s^ <> #10)And(s^ <> #0)Do Begin t := t + s^; Inc(s)End;
  If s^=#10 Then Inc(s);
  GetLine := t;
End;

Function Count(Const s: String; Chr: Char): Integer;
Var a: Byte; i: Integer;
Begin
  i := 0;
  For a := 1 To Length(s)Do
    if s[a]='''' Then Inc(i);
  Count := i
End;

Function GetItem(Var s: String): String;
Var t: String;
Begin
  t := '';
  While(s[1]=' ')And(Length(s)>0)Do Delete(s,1,1);
  While(s[1] <> ' ')And(Length(s)>0)Or Odd(Count(t, ''''))Do
	Begin
    t := t + s[1];
    Delete(s,1,1);
  End;

  If t[1]='^' Then t := ''''+Chr(Ord(t[2])-64)+'''';

  GetItem := t;
End;

Type
  TetrisStates = (Constructed,Initialized,Running,Waiting,
                  Waiting2,GameOver,Scores,Error,Destructed);

  PTetris = ^TTetris;
  TTetris = Object
  Public
    PField,
    VField: Array[-5..105, -5..105]Of Word;
    TempBlock, Block: Array[-1..6, -1..6]Of Word;

    IDX: Byte;

    Idle, Speed: Word;
    BlockSize: Word;
    XLev, YLev: Word;

    x, y: Word;

    State: TetrisStates;
    LineCount: Word;

    Score: LongInt;

    EvilLevel: Integer;

    Constructor Init(AIDX: Byte);

    Function NextKey: Word;

    Procedure KeyLeft;
    Procedure KeyRight;
    Procedure KeyDown;
    Procedure KeyDrop;
    Procedure KeyUp;
		Procedure KeyESC;

    Procedure Crash;

    Procedure CheckField;
    Procedure OptimizeBlock;

    Procedure Clear(AXLev,AYLev, ABlockSize, ASpeed: Word);
    Procedure RunStep;
    Procedure NewBlock;

    Function RunCode(Code: PChar): LongInt;

    Destructor Done;
  Private
    Timers:   Array[0..15]Of TimerBuf;
    IntVars: Array[0..127]Of LongInt;
  End;

  PWorld = ^TWorld;
  TWorld = Object
    TheVideo: Array[0..49, 0..79]Of Word;

    Tetrises: Array[0..7]Of Record Itself: PTetris; x, y: Word End;
    TetrisCount: Word;
    Constructor Init;
    Function Insert(It: PTetris; OriginX, OriginY: Word): PTetris;
    Procedure RunStep;
    Destructor Done;
  End;

Function KbHit(Source: Byte): Boolean;
Begin
  KbHit := False;
	Case Source Of
    0: KbHit := KeyPressed;
    1: KbHit := CharAvail(Port);
  End;
End;

Function GetCh(Source: Byte): Char;
Begin
  While Not KbHit(Source)Do;

	Case Source Of
		0: GetCh := ReadKey;
    1: GetCh := LueNap(Port);
  End;
End;

Function TTetris.RunCode(Code: PChar): LongInt;
Var
  i,Err,Mini: Integer;
  s,t,u: String;
  n,v,v2: LongInt;
Label BSkip, P1;
Begin
  If Code = Nil Then Exit;

  s := GetLine(Mini, Code);

  i := Mini;
  Repeat
		t := GetItem(s);
		u := UCase(t);
		If u='EXIT' Then Exit;
		If u='RETVAL' Then
		Begin
			t := GetItem(s);
			u := UCase(t);
					 If u='KB_NOKEY' Then RunCode := KB_NOKEY
			Else If u='KB_LEFT'  Then RunCode := KB_LEFT
			Else If u='KB_RIGHT' Then RunCode := KB_RIGHT
			Else If u='KB_UP'    Then RunCode := KB_UP
			Else If u='KB_DOWN'  Then RunCode := KB_DOWN
			Else If u='KB_DROP'  Then RunCode := KB_DROP
			Else If u='KB_ESC'   Then RunCode := KB_ESC
			Else If u[1]='I' Then
			Begin
				Val(PChar(@u)+2, n, Err);
				RunCode := IntVars[n]
			End
			Else
			Begin
				Val(u, n, Err);
				RunCode := n
			End
		End
		Else If(u[1]='I')And(u[2]In['0'..'9'])Then
		Begin
			Val(PChar(@u)+2, n, Err);
			GetItem(s); {=}
			u := UCase(GetItem(s));
			If u<>'RAND' Then
				Val(u, v, Err)
			Else
			Begin
				Val(GetItem(s), v, Err);
				Val(GetItem(s), v2, Err);
				v := Random(v2-v+1)+v;
			End;
			IntVars[n] := v
		End
		Else If u='GET' Then
		Begin
			Val(GetItem(s), n, Err);
			IntVars[n] := Ord(GetCh(IDX));
		End
		Else If u='TRAP' Then
		Begin
			Val(GetItem(s), n, Err);
			StartTimer(Timers[n]);
		End
		Else If u='LET' Then
		Begin
			Val(GetItem(s), n, Err);
			Val(GetItem(s), v, Err);
			IntVars[n] := v
		End
		Else If u='IFTRAP' Then
		Begin
			Val(GetItem(s), n, Err);
			Val(GetItem(s), v, Err);
			If Not TrapTimer(Timers[n], v)Then Goto BSkip
		End
		Else If u='IFNTRAP' Then
		Begin
			Val(GetItem(s), n, Err);
			Val(GetItem(s), v, Err);
			If TrapTimer(Timers[n], v)Then Goto BSkip
		End
		Else If u='IFNHIT' Then
		Begin
			If KbHit(IDX)Then
			Begin
BSkip:  v := i;
				Repeat
          s := GetLine(i, Code);
          If i <= v Then Break
        Until False;
        Continue
      End
    End
    Else If u='IFHIT' Then
    Begin
			If Not KbHit(IDX)Then Goto BSkip
		End
    Else If u='IF' Then
    Begin
			u := GetItem(s);
			If s[1]In['0'..'9']Then
			Begin
				Val(s, n, Err);
				If IntVars[n] = 0 Then Goto BSkip
			End
    End
    Else If u='IFN' Then
    Begin
      Val(GetItem(s), n, Err);
      If IntVars[n] <> 0 Then Goto BSkip
    End
    Else If u='IFA' Then
    Begin
      Val(GetItem(s), n, Err);
      Val(GetItem(s), v, Err);
      If IntVars[n] <= v Then Goto BSkip
    End
    Else If u='IFNA' Then
    Begin
			Val(GetItem(s), n, Err);
      Val(GetItem(s), v, Err);
      If IntVars[n] > v Then Goto BSkip
    End
    Else If u='IFB' Then
    Begin
      Val(GetItem(s), n, Err);
      Val(GetItem(s), v, Err);
      If IntVars[n] >= v Then Goto BSkip
    End
		Else If u='IFNB' Then
		Begin
			Val(GetItem(s), n, Err);
			Val(GetItem(s), v, Err);
			If IntVars[n] < v Then Goto BSkip
		End
		Else If u='IFE' Then
		Begin
			Val(GetItem(s), n, Err);
			Repeat
				t := GetItem(s);
				If t[0]=#0 Then Break;
				If t[1]='''' Then
				Begin
					If IntVars[n] = Ord(t[2])Then Goto P1
				End
				Else
        Begin
          Val(t, v, Err);
          If IntVars[n] = v Then Goto P1
        End
      Until False;
      Goto BSkip;
P1: End;

    s := GetLine(i, Code);
  Until i<Mini;
End;

Function TTetris.NextKey: Word;
Var Ch: Char;
Begin
  NextKey := RunCode(KeyProc)
End;

Constructor TWorld.Init;
Begin
  TetrisCount := 0;
  FillWord(TheVideo, SizeOf(TheVideo)Shr 1, $0020);
End;

Procedure TWorld.RunStep;
Var
  a: Word;
  C, ax, ay: Word;
Begin
	If DisableFractal Then
    Move(AnsiPict, TheVideo, SizeOf(TheVideo))
  Else
    DrawFract(TheVideo);

  If TetrisCount<>0 Then
    For a := 0 To TetrisCount-1 Do
      With Tetrises[a].Itself^ Do
      Begin
        RunStep;

        For ax := 0 To XLev Shl 1+3 Do
          For ay := 0 To YLev Do
          Begin
            C := PField[ay, ax];
            If C <> $7FFF Then
              TheVideo[ay+Tetrises[a].y, ax+Tetrises[a].x] := C;

            C := VField[ay, ax];
            If C <> 0 Then
              TheVideo[ay+Tetrises[a].y, ax+Tetrises[a].x] := C
          End;

        Case NextKey Of
          KB_NOKEY: ;
          KB_LEFT:  KeyLeft;
          KB_DROP:  KeyDrop;
          KB_RIGHT: KeyRight;
          KB_UP:    KeyUp;
          KB_DOWN:  KeyDown;
          KB_ESC:   KeyESC;
        End
      End;

  Move(TheVideo, Mem[SegB800:0], SizeOf(TheVideo)); {This will be changed.}
End;

Function TWorld.Insert(It: PTetris; OriginX, OriginY: Word): PTetris;
Begin
  Insert := Nil;

  If TetrisCount >= 8 Then
  Begin
    Dispose(It, Done);
    Exit
  End;

  Insert := It;

  Tetrises[TetrisCount].Itself := It;
  Tetrises[TetrisCount].x := OriginX;
  Tetrises[TetrisCount].y := OriginY;
  Inc(TetrisCount)
End;

Destructor TWorld.Done;
Begin
  While TetrisCount >0 Do
  Begin
    Dec(TetrisCount);
    Dispose(Tetrises[TetrisCount].Itself, Done)
  End
End;

Constructor TTetris.Init(AIDX: Byte);
Begin
  State := Constructed;
  IDX := AIDX;

  Score := 0;
  FillChar(Timers,  SizeOf(Timers),  0);
  FillChar(IntVars, SizeOf(IntVars), 0);
End;

Function RandPalikka: Word;
Begin
  Case Random(3)Of
    0: RandPalikka := ($0D00+Ord('€'));
    1: RandPalikka := ($0500+Ord('€'));
    2: RandPalikka := ($0F00+Ord('€'))
  End;
End;

Procedure TTetris.Clear(AXLev,AYLev, ABlockSize, ASpeed: Word);
Var C, ax,ay: Word;
Begin
  Speed := ASpeed; Idle := 0;

  BlockSize := ABlockSize;
  XLev := AXlev;
  YLev := AYLev;

  FillWord(PField, SizeOf(PField)Shr 1, Blank); {Clear the block field}
  FillWord(VField, SizeOf(VField)Shr 1, $0000); {Clear the work  field}

  For ax := 0 To AXLev + 1 Do
  Begin
    C := RandPalikka;

    PField[0, ax Shl 1  ] := C;
    PField[0, ax Shl 1+1] := C;

    PField[AYLev, ax Shl 1  ] := C;
    PField[AYLev, ax Shl 1+1] := C
  End;

  For ay := 0 To AYLev Do
  Begin
    C := RandPalikka;
    PField[ay, 0] := C; PField[ay, (AXLev+1)Shl 1  ] := C;
    PField[ay, 1] := C; PField[ay, (AXLev+1)Shl 1+1] := C
  End;

  NewBlock;

  State := Running;
End;

Procedure TTetris.OptimizeBlock;
Var C, ax, ay: Word;
Label P1, P2;
Begin
  C := 0;
  For ay := 0 To 5 Do
  Begin
    For ax := 0 To 5 Do
      If Block[ax, ay] <> $0000 Then Goto P1;
    Inc(C)
  End;
P1:
  For ax := 0 To 5 Do
    For ay := 0 To 5 Do
      If ay+C > 5
        Then Block[ax, ay] := $0000
        Else Block[ax, ay] := Block[ax, ay+C];

  C := 0;
  For ax := 0 To 5 Do
  Begin
    For ay := 0 To 5 Do
      If Block[ax, ay] <> $0000 Then Goto P2;
    Inc(C)
  End;
P2:
  For ax := 0 To 5 Do
    For ay := 0 To 5 Do
      If ax+C > 5
        Then Block[ax, ay] := $0000
        Else Block[ax, ay] := Block[ax+C, ay];
End;

Procedure TTetris.KeyLeft;
Var ax, ay: Word;
Begin
  If State <> Running Then Exit;
  For ax := 0 To 5 Do
    For ay := 0 To 5 Do
      If(Block[ax,ay] <> 0)And(PField[y+ay, (x+ax-1)Shl 1] <> Blank)Then
        Exit;
  Dec(x)
End;

Procedure TTetris.KeyRight;
Var ax, ay: Word;
Begin
  If State <> Running Then Exit;
  For ax := 0 To 5 Do
    For ay := 0 To 5 Do
      If(Block[ax,ay] <> 0)And(PField[y+ay, (x+ax+1)Shl 1] <> Blank)Then
        Exit;
  Inc(x)
End;

Procedure TTetris.KeyUp;
Var
  i, ix: Word;
  ax, ay: Word;
Label P1;
Begin
  If State <> Running Then Exit;
  TempBlock := Block;

	For ax := 0 To 5 Do
		For ay := 0 To 5 Do
			Block[ax, ay] := TempBlock[ay, (5-ax)];

  OptimizeBlock;

  i := 0;
  ix := x;
P1:
  If i>4 Then
  Begin
    x := ix;
    Crash;
    Exit
  End;

  For ax := 0 To 5 Do
    For ay := 0 To 5 Do
      If(Block[ax,ay] <> 0)And(PField[y+ay+1, (x+ax)Shl 1] <> Blank)Then
      Begin
        Inc(i);
        Dec(x);
        Goto P1
      End
End;

Procedure TTetris.KeyDown;
Var ax, ay: Word;
Begin
  If State <> Running Then Exit;

  For ax := 0 To 5 Do
    For ay := 0 To 5 Do
      If(Block[ax,ay] <> 0)And(PField[y+ay+1,(x+ax)Shl 1] <> Blank)Then
      Begin
        Crash;
        Exit
      End;

  Inc(y);
End;

Procedure TTetris.KeyDrop;
Var
  Min: Word;
  ax, ay: Word;
Begin
  Min := Byte(OopsShield);
  If y >= Min Then Repeat KeyDown Until y<=1
End;

Procedure TTetris.KeyESC;
Var ax: Word;
Begin
  Case State Of
    Running:
    Begin
      Idle := (YLev+1)Shl 2;
      State := GameOver
    End;
    GameOver:
    Begin
      For ax := 0 To XLev*2+3 Do PField[Idle Shr 2, ax] := $7FFF;
      If Idle = 0
        Then State := Scores
        Else Dec(Idle)
    End;
    Scores: ;
  End
End;

Procedure TTetris.Crash;
Var ax, ay, C: Word;
Begin
  For ax := 0 To 5 Do
    For ay := 0 To 5 Do
      If Block[ax,ay] <> 0 Then
      Begin
        C := Block[ax][ay];
        If(BlockDetail And 1)<>0 Then
          If(Block[ax][ay+1] = 0)And(c <> 0)Then
            If(Hi(c) < 8)Then
              c := Ord('_')Or
                (Hi(c)Shl 12)Or
                ((c And $700)Or $800);
        PField[y+ay, (x+ax)Shl 1  ] := C;

        If(BlockDetail And 2)<>0 Then
          If(Block[ax+1][ay] = 0)And(c <> 0)Then
            If(Hi(c) < 8)Then
              c := Ord('|')Or(Hi(c)Shl 12)Or((c And $700)Or $800)
            Else If(Lo(c)=Ord('_'))Then
              c := Ord('|')Or(Hi(c)Shl 8);
        PField[y+ay, (x+ax)Shl 1+1] := C
      End;

  CheckField;

  NewBlock;
End;

Procedure BufWrite(Dest: PWord; Source: PChar); Assembler; {Used by CheckField()}
Asm
  les di, Dest
  lds si, Source
  mov ah, 8
  cld
@2:
  mov al, ds:[si]
  or al, al
  jz @1
  stosw
  inc si
  jmp @2
@1:
End;

Procedure TTetris.CheckField;
Var
	ax, by, ay: Word;
	p, q: PChar;
	a: Word;
Label P1, P2;
Begin
	If State = Running Then LineCount := 0;

	For ay := 1 To YLev-1 Do
	Begin
		For ax := 1 To XLev Do
			If PField[ay, ax Shl 1] = Blank Then Goto P1;

		If State = Running Then Inc(LineCount);

		If State = Waiting Then
			PField[ay, Idle+2] := $08F8;

		If Not CoolWipeLines Then
			For ax := 1 To XLev Shl 1 Do
				PField[ay, ax+1] := $08F8;

		If State = Waiting2 Then
			If Idle = 0 Then
			Begin
				a := LineCount;
				p := BlockRemoval;
				While a > 1 Do
				Begin
					q := StrScan(p, ',');
					If q=Nil Then Break;
					p := q+1;
					Dec(a)
				End;
				q := StrScan(p, ',');
				If q<>Nil Then q^ := #0;
				BufWrite(@PField[ay, 4 Shl 1], p)
			End;
P1:
  End;

  If State = Running Then
    Inc(Score, RunCode(ScoreProc));

  If Not CoolWipeLines Then Goto P2;

  If State <> Running Then Inc(Idle);

  If(State = Waiting)And(Idle >= XLev Shl 1)Then
  Begin
    Idle := 0;
    State := Waiting2
  End;
  If(State = Waiting2)And(Idle > 32)Then {Drop lines...}
  Begin
P2: For ay := YLev DownTo 1 Do
      For ax := 1 To XLev Do
        If Hi(PField[ay, ax Shl 1])=8 Then {This line will be destroyed}
        Begin
          For by := ay DownTo 2 Do
          Begin
            PField[by, ax Shl 1  ] := PField[by-1, ax Shl 1  ];
            PField[by, ax Shl 1+1] := PField[by-1, ax Shl 1+1]
          End;

          PField[1, ax Shl 1  ] := Blank;
          PField[1, ax Shl 1+1] := Blank;

          Goto P2;
        End;

    Idle := 0;
    State := Running;

    LineCount := 0
  End;

  If(LineCount > 0)And(State=Running)Then
  Begin
    State := Waiting;
    Idle := 0
  End
End;

Procedure TTetris.RunStep;
Var
  C: Word;
  ax, ay: Word;
Begin
  FillChar(VField, SizeOf(VField), 0);

  If State > Running Then
    If State < GameOver
      Then CheckField
      Else KeyESC;
  If State <> Running Then Exit;

  For ax := 0 To 5 Do
    For ay := 0 To 5 Do
    Begin
      C := Block[ax][ay];
      If(BlockDetail And 1)<>0 Then
        If(Block[ax][ay+1] = 0)And(c <> 0)Then
          If(Hi(c) < 8)Then
            c := Ord('_')Or
              (Hi(c)Shl 12)Or
              ((c And $700)Or $800);
      VField[y+ay, (x+ax)Shl 1  ] := C;

      If(BlockDetail And 2)<>0 Then
        If(Block[ax+1][ay] = 0)And(c <> 0)Then
          If(Hi(c) < 8)Then
            c := Ord('|')Or(Hi(c)Shl 12)Or((c And $700)Or $800)
          Else If(Lo(c)=Ord('_'))Then
            c := Ord('|')Or(Hi(c)Shl 8);
      VField[y+ay, (x+ax)Shl 1+1] := C
    End;

  If Idle = Speed Then
  Begin
    Idle := 0;
    KeyDown;
  End;
  Inc(Idle);
End;

Procedure TTetris.NewBlock;
Var
  C: Word;
Const
  Colours: Array[0..10]Of Byte = (1,2,3,4,6,7,9,10,11,12,14);

  Procedure GenerateBlock;
  Var
    ax,ay: Integer;
    a: Byte;
  Begin
	  FillChar(Block, SizeOf(Block), 0);
	  Block[Random(6), 0] := C;
	  a := 1;
	  While(a < BlockSize)Do
	  Begin
		  Repeat
			  ax := Random(6);
			  ay := Random(6);
		  Until(Block[ax, ay]=0)And
					  ((Block[ax-1, ay]<>0)Or(Block[ax, ay-1]<>0)Or
				     (Block[ax+1, ay]<>0)Or(Block[ax, ay+1]<>0));
		  Inc(a);

      If BlockColour=16 Then WordRec(C).Hi := Colours[Random(11)];

		  Block[ax, ay] := C
	  End;
    OptimizeBlock
  End;
Var
  ArpoCount: Integer;
  l,r, BestBlock, BestScore, TestScore: LongInt;
  nx,ny, ax,ay: Integer;
  TouchDown: Boolean;
  MyWay: LongInt;
Label P1;
Begin
  WordRec(C).Lo := Ord('€');

  Case BlockColour Of
    0, 16: WordRec(C).Hi := Colours[Random(11)];
    Else WordRec(C).Hi := BlockColour
  End;

  If IDX=1
    Then MyWay := EvilBlocks2
    Else MyWay := EvilBlocks1;

  ArpoCount := Abs(MyWay);
  If MyWay<0
    Then BestScore := 99999
    Else BestScore :=-99999;

  BestBlock := RandSeed;

  While ArpoCount > 0 Do
  Begin
    r := RandSeed;
    GenerateBlock;

    TestScore := 0;

    TouchDown := False;

    For nx := 1 To XLev Do
      For ny := 2 To YLev Do
      Begin
        For ax := 0 To 5 Do
          If(ax+nx < XLev)And Not TouchDown Then
            For ay := 0 To 5 Do
              If(Block[ax,ay] <> 0)And
                (PField[ny+ay+1,(nx+ax)Shl 1] <> Blank)Then
              Begin
                TouchDown := True;
                Inc(TestScore, 1 Shl((ny-2)Shr 2));
                Break
              End;
        If TouchDown Then
        Begin
          l := 0;
          For ax := 0 To 5 Do
            If ax+nx < XLev Then
              For ay := 0 To 5 Do
                If Block[ax,ay] <> 0 Then
                  If(PField[ny+ay+1,(nx+ax)Shl 1] <> Blank)Then Inc(l,2)
                  Else If(Block[ax,ay+1] <> 0)Then Inc(l);

          TestScore := TestScore * l;
          Goto P1;
        End;
      End;
P1:
    If((MyWay<0)And(TestScore<BestScore))
    Or((MyWay>0)And(TestScore>BestScore))Then
    Begin
      BestScore := TestScore;
      BestBlock := r
    End;

    Dec(ArpoCount)
  End;

  RandSeed := BestBlock;
  GenerateBlock;
  x := 1;
  y := 1;
End;

Destructor TTetris.Done;
Begin
  State := Destructed
End;

Var
  MyWorld: PWorld;
Begin
  If Not FosInstalled(Port)Then
  Begin
    Write('X00 Fossil driver has not been installed. Stop.'^M^J^G);
    Exit
  End;

  ReadConfig;

  Randomize;

	New(MyWorld, Init);

	MyWorld^.Insert(New(PTetris, Init(0)), Field1X, Field1Y)^.
		Clear(Field1XSize,Field1YSize, InitialBlockSize,InitialSpeed);

	MyWorld^.Insert(New(PTetris, Init(1)), Field2X, Field2Y)^.
		Clear(Field2XSize,Field2YSize, InitialBlockSize,InitialSpeed);

	Repeat
		MyWorld^.RunStep
	Until False;

	Dispose(MyWorld, Done)
End.

