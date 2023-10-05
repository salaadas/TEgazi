{$A+,B-,D+,E-,F+,G+,I-,L-,N-,O-,P-,Q+,R+,S-,T-,V+,X+,Y-}
{$M 1024,0,0}
Uses Crt, Dos, UseMotu;

Const
	AlueKorkeus = 25;
Procedure Screen13; InLine($B8/$13/0/$CD/16);

Procedure Screen12; InLine($B8/$12/0/$CD/16);

Procedure Screen0; InLine($B8/$3/0/$CD/16);

Procedure Pset12(x, y : Integer; PColor : Byte); Far; Assembler;
Asm
	mov ax, x; or ax, ax; js @G2; cmp x, 639; jg @G2
	mov ax, y; or ax, ax; js @G2; cmp y, 479; jg @G2
	mov ax,y; mov dx,80; mul dx; mov bx,x; mov cl,bl; shr bx,3; add bx,ax
	and cl,7; xor cl,7; mov ah,1; shl ah,cl
	mov dx,3CEh; mov al,8; out dx,ax
	mov ax,205h; out dx,ax
	mov ax,0A000h; mov es,ax
	mov al,es:[bx]; mov al,byte ptr PColor; mov es:[bx],al
	mov ax,0FF08h; out dx,ax
	mov ax,5; out dx,ax
@G2:End;

Function Point12(x, y : Integer) : Byte; Far; Assembler;
Asm
	mov ax, x; or ax, ax; js @G2; cmp x, 639; jg @G2
	mov ax, y; or ax, ax; js @G2; cmp y, 479; jg @G2
	mov ax,y; mov dx,80; mul dx; mov si,x; mov cx,si
	shr si,3; add si,ax
	and cl,7; xor cl,7; mov ch,1; shl ch,cl
	mov ax,0A000h; mov es,ax
	mov dx,3CEh; mov ax,00304h; xor bl,bl
@G1:out dx,ax; mov bh,es:[si]; and bh,ch; neg bh; rol bx,1
	dec ah; jge @G1; mov al,bl
@G2:End;

Procedure Pset13(x,y:Word;c:Byte); Far; Assembler;
Asm mov ax, SegA000;mov es, ax;mov ax,320;mul y
add ax,x;mov bx,ax;mov al,c;mov es:[bx],al End;

Procedure Line12(x1,y1,x2,y2:Integer;c:Byte);
Var i, len : Integer;
Begin
	If(x1<0)Then x1 := 0; If(x2<0)Then x2 := 0;
	If(y1<0)Then y1 := 0; If(y2<0)Then y2 := 0;
	If(x1>639)Then x1 := 639; If(x2>639)Then x2 := 639;
	If(y1>479)Then y1 := 479; If(y2>479)Then y2 := 479;
  If Abs(x2-x1)>Abs(y2-y1)Then Len:=Abs(x2-x1)Else Len:=Abs(y2-y1);
  If Len=0 Then Begin PSet12(x1,y1,c); Exit End;
  For i := 0 To Len Do
  	Pset12(LongInt(x2-x1)*i Div Len,LongInt(y2-y1)*i Div Len,c)
  (*
	Asm
		mov ax,x2;sub ax,x1;mov bx,y2;sub bx,y1
		or ax,ax;jns @NO1;neg ax;@NO1:; or bx,bx;jns @NO2;neg bx;@NO2:
		cmp ax, bx;jg @NO3;mov si, bx;jmp @NO4;@NO3:mov si, ax;@NO4:
		mov cx, si; @NO5: mov ax,x2;sub ax,x1;imul cx
    {or si, si; jnz @NO98; mov si, 1; @No98:}idiv si; add ax, x1
		mov di, ax; mov ax,y2;sub ax,y1; imul cx
    {or si, si; jnz @NO99; mov si, 1; @No99:}idiv si; add ax, y1
		mov bx, ax; pusha; push di; push bx; mov al, c; push ax
		{$IFOPT F-}push cs{$ENDIF}; call Pset12; popa; loop @NO5
	End;
  *)
End;

Procedure RectAngle12(x1,y1,x2,y2 : Integer; c : Byte);
Begin
	Line12(x1,y1,x2,y1,c); Line12(x1,y2,x2,y2,c);
	Line12(x1,y1,x1,y2,c); Line12(x2,y1,x2,y2,c)
End;

Procedure HorLine12(x, y1, y2 : Word; c : Byte); Far; Assembler;
Asm
	mov ax, y1; mov bx, y2; cmp ax, bx; jb @P2; xchg ax, bx;
@P2:mov y1, ax; mov y2, bx; mov ax, y1
@P1:pusha; push x; push ax; mov al, c; push ax
	{$IFOPT F-}push cs{$ENDIF}; call Pset12; popa
	inc ax; cmp ax, y2; jb @P1
End;

Procedure HorLine13(x, y1, y2 : Word; c : Byte); Far; Assembler;
Asm
	mov ax, y1; mov bx, y2; cmp ax, bx
	jb @P2; xchg ax, bx; @P2: mov y1, ax; mov y2, bx
	mov ax, 0A000h; mov es, ax; mov di, y1
@P1:mov ax, 320; mul di; add ax, x; mov bx, ax
	mov al, c; mov es:[bx], al; inc di; cmp di, y2; jb @P1

End;

Procedure Bar12(x1,y1,x2,y2:Integer;c:Byte); Far; Assembler;
Asm
	mov ax,x2;mov bx,x1;cmp ax,bx;jg @OK;xchg ax,bx;@OK:mov x2,ax;mov x1,bx
	mov ax,y2;mov bx,y1;cmp ax,bx;jg @OL;xchg ax,bx;@OL:mov y2,ax;mov y1,bx
	mov cx,x2;sub cx,x1;@P1:push cx;mov ax,x1;add ax,cx;mov cx,y2;sub cx,y1
@P2:mov bx,y1;add bx,cx;pusha;push ax;push bx;mov al,c;push ax
	{$IFOPT F-}push cs{$ENDIF}; call Pset12;popa;loop @P2;pop cx;loop @P1
End;

Procedure Line13(x1,y1,x2,y2:Word;c:Byte); Far; Assembler;
Asm
	mov ax,x2;sub ax,x1;mov bx,y2;sub bx,y1
	or ax,ax;jns @NO1;neg ax;@NO1:
	or bx,bx;jns @NO2;neg bx;@NO2:
	cmp ax, bx;jg @NO3;mov si, bx;jmp @NO4;@NO3:mov si, ax;@NO4:
	mov cx, si; @NO5:mov ax,SegA000;mov es,ax
	mov ax,x2;sub ax,x1;imul cx; idiv si; add ax, x1
	mov di, ax; mov ax,y2;sub ax,y1; imul cx; idiv si; add ax, y1
	mov bx, ax; mov ax, 320; mul bx; add ax, di
	mov bx, ax; mov al, c; mov es:[bx], al; loop @NO5
End;

Procedure RectAngle13(x1,y1,x2,y2 : Integer; c : Byte);
Begin
	Line13(x1,y1,x2,y1,c); Line13(x1,y2,x2,y2,c);
	Line13(x1,y1,x1,y2,c); Line13(x2,y1,x2,y2,c)
End;

Procedure Cls12; Far; Assembler;
Asm
	mov dx,03C4h; mov al,2; out dx,al; inc dx
	mov al,15; out dx,al; mov es,SegA000; xor di,di
	xor ax,ax; mov cx,80*480/2; rep stosw
End;

Procedure Cls13; Far; Assembler;
Asm
	mov ax, SegA000; mov es, ax; mov cx, 32000
	xor di, di; mov ax, 0; rep stosw
End;

Procedure Circle13(x,y,r:Integer;c:Byte); Far;
Var id, ix, iy : Integer;
Begin
	For iy := -r To r Do
	Begin
		ix := Round(Sqrt(r*r-iy*iy));
		Asm
			mov ax,y;sub ax,iy;mov bx, ax; mov ax,320;mul bx; add ax,ix;sub ax,x;
			mov bx,ax;mov ax,SegA000;mov es,ax;mov al,c;mov es:[bx],al
			mov ax,y;sub ax,iy;mov bx, ax; mov ax,320;mul bx; add ax,x;sub ax,ix
			mov bx,ax;mov ax,SegA000;mov es,ax;mov al,c;mov es:[bx],al
			mov ax, ix; mov bx, iy; mov ix, bx; mov iy, ax
			mov ax,y;sub ax,iy;mov bx, ax; mov ax,320;mul bx; add ax,ix;sub ax,x
			mov bx,ax;mov ax,SegA000;mov es,ax;mov al,c;mov es:[bx],al
			mov ax,y;add ax,iy;mov bx, ax; mov ax,320;mul bx; add ax,ix;sub ax,x
			mov bx,ax;mov ax,SegA000;mov es,ax;mov al,c;mov es:[bx],al
			mov ax, ix; mov bx, iy; mov ix, bx; mov iy, ax
		End
	End
End;

Procedure FillDisk13(x,y,r:Integer;c:Byte); Far;
Var id, ix, iy : Integer;
Begin
	For iy := -r To r Do
	Begin
		ix := Round(Sqrt(r*r-iy*iy));
		Asm
			mov ax, iy; add ax, y; mov bx, ax
			mov ax, 320; mul bx; sub ax, ix; add ax, x
			mov cx, ix; or cx, cx; jns @P2; neg cx; @P2:
			mov di, ax; shl cx, 1; mov ax, SegA000; mov es, ax
			mov al, c; rep stosb
		End
	End
End;

Type
	String2 = String[2];
	String4 = String[4];
	String8 = String[8];
	String16 = String[16];
	String32 = String[32];
	String64 = String[64];

Procedure Pelaa; ForWard;
Procedure TeeTausta; ForWard;
Procedure SetPaletti; ForWard;
Procedure PoistaRivi(a : Integer); ForWard;
Procedure ClearPalette; ForWard;
{ÉÍÍÍÍÍÍÍÍÍÍÍ»
 º PUUPŽŽ!!! º
 ÈÍÍÍÍÍÍÍÍÍÍÍ¼}
Procedure Pal(c : Integer); ForWard;
Function Inkey : String2; ForWard;
Function CheckLines : Integer; ForWard;
Function Pyorita(z, x, y : Integer) : Boolean; ForWard;
Function PaaseekoLapi(x, y : Integer) : Boolean; ForWard;
Procedure StrPrint(x, y : Integer; Jono : String; Koko, Colour : Integer); ForWard;
Procedure Pet(x, y, What, c : Integer); ForWard;
Procedure PSet(x, y, What, c : Integer); ForWard;
Procedure TeePala(x, y, What, c : Integer); ForWard;

Type Pregs = Record
	r, g, b : Integer
End;

Type AlueType = Record
	c, What : Integer
End;

Type PalaCoord = Record
	x, y : Integer
End;

Const
	Paloja = 14;
Var
	Time:Longint Absolute $40:$6C;
	Alue:Array[0..18, 0..35] Of AlueType;
	Uusi, Mika : Integer;
	Pala : Array[1..5, 1..4, 1..Paloja] Of PalaCoord;
Const
	None = 0; Vari : Array[1..6]Of Integer = (1,2,3,7,8,9);
	YPala : Array[1..Paloja, 1..4, 1..5] Of PalaCoord =
(
 (((x:2; y:1),(x:3; y:1),(x:1; y:2),(x:2; y:2),(x:1; y:3)),
	((x:1; y:1),(x:2; y:1),(x:2; y:2),(x:3; y:2),(x:3; y:3)),
	((x:3; y:1),(x:3; y:2),(x:2; y:2),(x:1; y:3),(x:2; y:3)),
	((x:1; y:1),(x:2; y:2),(x:3; y:3),(x:1; y:2),(x:2; y:3))),

 (((x:1; y:2),(x:2; y:2),(x:2; y:1),(x:3; y:2),(x:2; y:3)),
	((x:1; y:2),(x:2; y:2),(x:2; y:1),(x:3; y:2),(x:2; y:3)),
	((x:1; y:2),(x:2; y:2),(x:2; y:1),(x:3; y:2),(x:2; y:3)),
	((x:1; y:2),(x:2; y:2),(x:2; y:1),(x:3; y:2),(x:2; y:3))),

 (((x:2; y:1),(x:3; y:1),(x:2; y:2),(x:2; y:3),(x:1; y:3)),
	((x:1; y:1),(x:1; y:2),(x:2; y:2),(x:3; y:2),(x:3; y:3)),
	((x:2; y:1),(x:3; y:1),(x:2; y:2),(x:2; y:3),(x:1; y:3)),
	((x:1; y:1),(x:1; y:2),(x:2; y:2),(x:3; y:2),(x:3; y:3))),

 (((x:1; y:1),(x:1; y:2),(x:1; y:3),(x:1; y:4),(x:1; y:5)),
	((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:4; y:1),(x:5; y:1)),
	((x:1; y:1),(x:1; y:2),(x:1; y:3),(x:1; y:4),(x:1; y:5)),
	((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:4; y:1),(x:5; y:1))),

 (((x:1; y:2),(x:2; y:1),(x:2; y:2),(x:3; y:2),(x:3; y:3)),
	((x:2; y:1),(x:2; y:2),(x:3; y:2),(x:1; y:3),(x:2; y:3)),
	((x:1; y:1),(x:2; y:2),(x:1; y:2),(x:3; y:2),(x:2; y:3)),
	((x:2; y:1),(x:3; y:1),(x:1; y:2),(x:2; y:2),(x:2; y:3))),

 (((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:1; y:2),(x:3; y:2)),
	((x:1; y:1),(x:2; y:1),(x:1; y:2),(x:1; y:3),(x:2; y:3)),
	((x:1; y:1),(x:2; y:2),(x:3; y:1),(x:1; y:2),(x:3; y:2)),
	((x:1; y:1),(x:2; y:2),(x:2; y:1),(x:1; y:3),(x:2; y:3))),

 (((x:1; y:1),(x:2; y:2),(x:2; y:1),(x:3; y:1),(x:2; y:3)),
	((x:1; y:2),(x:2; y:2),(x:3; y:2),(x:3; y:1),(x:3; y:3)),
	((x:2; y:1),(x:2; y:2),(x:2; y:3),(x:1; y:3),(x:3; y:3)),
	((x:1; y:1),(x:2; y:2),(x:1; y:3),(x:1; y:2),(x:3; y:2))),

 (((x:3; y:1),(x:1; y:2),(x:2; y:2),(x:3; y:2),(x:2; y:3)),
	((x:1; y:1),(x:2; y:1),(x:2; y:2),(x:3; y:2),(x:2; y:3)),
	((x:2; y:1),(x:2; y:2),(x:1; y:2),(x:3; y:2),(x:1; y:3)),
	((x:2; y:1),(x:2; y:2),(x:1; y:2),(x:2; y:3),(x:3; y:3))),

 (((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:1; y:2),(x:2; y:2)),
	((x:1; y:1),(x:2; y:1),(x:1; y:2),(x:2; y:2),(x:2; y:3)),
	((x:2; y:1),(x:3; y:1),(x:1; y:2),(x:2; y:2),(x:3; y:2)),
	((x:1; y:1),(x:2; y:2),(x:1; y:2),(x:1; y:3),(x:2; y:3))),

 (((x:1; y:1),(x:2; y:1),(x:1; y:2),(x:2; y:2),(x:3; y:2)),
	((x:1; y:1),(x:2; y:1),(x:1; y:2),(x:2; y:2),(x:1; y:3)),
	((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:2; y:2),(x:3; y:2)),
	((x:2; y:1),(x:1; y:2),(x:2; y:2),(x:2; y:3),(x:1; y:3))),

 (((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:1; y:2),(x:1; y:3)),
	((x:1; y:1),(x:1; y:2),(x:1; y:3),(x:2; y:3),(x:3; y:3)),
	((x:3; y:1),(x:3; y:2),(x:3; y:3),(x:2; y:3),(x:1; y:3)),
	((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:3; y:2),(x:3; y:3))),

 (((x:1; y:1),(x:2; y:1),(x:2; y:2),(x:2; y:3),(x:3; y:3)),
	((x:3; y:1),(x:3; y:2),(x:2; y:2),(x:1; y:2),(x:1; y:3)),
	((x:1; y:1),(x:2; y:1),(x:2; y:2),(x:2; y:3),(x:3; y:3)),
	((x:3; y:1),(x:3; y:2),(x:2; y:2),(x:1; y:2),(x:1; y:3))),

 (((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:4; y:1),(x:1; y:2)),
	((x:1; y:1),(x:1; y:2),(x:1; y:3),(x:1; y:4),(x:2; y:4)),
	((x:1; y:2),(x:2; y:2),(x:3; y:2),(x:4; y:2),(x:4; y:1)),
	((x:1; y:1),(x:2; y:1),(x:2; y:2),(x:2; y:3),(x:2; y:4))),

 (((x:1; y:1),(x:1; y:2),(x:2; y:2),(x:3; y:2),(x:4; y:2)),
	((x:2; y:1),(x:2; y:2),(x:2; y:3),(x:2; y:4),(x:1; y:4)),
	((x:1; y:1),(x:2; y:1),(x:3; y:1),(x:4; y:1),(x:4; y:2)),
	((x:1; y:1),(x:2; y:1),(x:1; y:2),(x:1; y:3),(x:1; y:4))));

Var
	NPala : Array[0..5] Of PalaCoord;
	Pr : Array[0..15]Of Pregs; Prg : PRegs;
	Rivit : Integer;

Procedure Pelaa;
Var
	y : String2; Colour, x, yc, z, s, a, b : Integer;
  OldCoord : Array[0..5]Of PalaCoord;
  OldRivit, PalaMaassa, UudenPalikanValeVari,
	OldScore, Score, PeliOhi, Nopeus : Integer;
Begin
	Uusi := Random(Paloja)+1;
  PeliOhi := 0; Nopeus := 1000;
	While(PeliOhi = 0) Do
  Begin
		Mika := Uusi;
		Nopeus := Nopeus - 1;
		Uusi := Random(Paloja)+1;
		x := 8; yc := 5; z := 1;
    For a := 1 To 5 Do
    Begin
			NPala[a].x := Pala[a, z, Mika].x;
			NPala[a].y := Pala[a, z, Mika].y
    End;
		Colour := Vari[Random(6)+1];
    b := 0;
    For a := 1 To 5 Do
    Begin
			If PaaseekoLapi(x + NPala[a].x, yc + 1 + NPala[a].y) Then
	      Begin a := 5; b := 1 End
    End;
		If(b=0)Then Begin Inc(yc); s := 1 End Else PeliOhi := 1;
		StrPrint(400, 140, 'NEXT BLOCK : ', 2, 4);
		UudenPalikanValeVari := Vari[Random(6)+1];
		Bar12(447, 160, 528, 240, 10);
		For a := 1 To 5 Do Pet(400 Div 16 + Pala[a, 1, Uusi].x, 160 Div 16 + Pala[a, 1, Uusi].y, 5, UudenPalikanValeVari);
		PalaMaassa := 0;
		While(PalaMaassa = 0)Do
    Begin
			For b := 1 To Nopeus Do
      Begin
				y := Inkey;
        If(y='þH')Then If Pyorita(z, x, yc) Then s := 1;
        If(y='þK')Then
				Begin
        	b := 0;
					For a := 1 To 5 Do
						If PaaseekoLapi(x - 1 + NPala[a].x, yc + NPala[a].y)=False Then Begin a := 5; b := 1 End;
          If b = 0 Then Begin Dec(x); s := 1 End
        End;
        If(y='þM')Then
				Begin
        	b := 0;
					For a := 1 To 5 Do
						If PaaseekoLapi(x + 1 + NPala[a].x, yc + NPala[a].y)=False Then Begin a := 5; b := 1 End;
          If b = 0 Then Begin Inc(x); s := 1 End
        End;
        If(y='þP')Then
				Begin
        	b := 0;
					For a := 1 To 5 Do
						If PaaseekoLapi(x + NPala[a].x, yc + 1 + NPala[a].y)=False Then Begin a := 5; b := 1 End;
          If b = 0 Then Begin Inc(yc); s := 1 End Else PalaMaassa := 1
        End;
				If(s = 1)And(PalaMaassa = 0)Then
        Begin
					For a := 1 To 5 Do Pet(OldCoord[a].x, OldCoord[a].y, 2, 0);
					For a := 1 To 5 Do
          Begin
						OldCoord[a].x := x + NPala[a].x;
						OldCoord[a].y := yc + NPala[a].y;
						Pet(OldCoord[a].x, OldCoord[a].y, 2, Colour)
          End;
					s := 0
        End
      End;
     	b := 0;
			For a := 1 To 5 Do
				If PaaseekoLapi(x + NPala[a].x, yc + 1 + NPala[a].y)=False Then Begin a := 5; b := 1 End;
      If b = 0 Then Begin Inc(yc); s := 1 End Else PalaMaassa := 1
    End;
    For a := 1 To 5 Do Pet(OldCoord[a].x, OldCoord[a].y, 2, 0);
		For a := 1 To 5 Do
    Begin
			OldCoord[a].x := 8;
			OldCoord[a].y := 0;
			PSet(x + NPala[a].x, yc + NPala[a].y, 2, Colour)
    End;
    Inc(Rivit, CheckLines);
		If(OldRivit - Rivit = 0)Then Inc(Score, Random(50)+1)Else Inc(Score, (OldRivit - Rivit) * 100);
		StrPrint(400, 100, 'LINES : " '+ Strin(OldRivit), 2, 10);
		StrPrint(400, 100, 'LINES : " '+ Strin(Rivit), 2, 4);
		StrPrint(400, 120, 'SCORE : " '+ Strin(OldScore), 2, 10);
		StrPrint(400, 120, 'SCORE : " '+ Strin(Score), 2, 4);
		OldScore := Score; OldRivit := Rivit
  End;
	Bar12(18 * 16 + 31, 16 * 5, 63, AlueKorkeus * 16 - 1, 0);
	StrPrint(80, 200, 'GAME OVER', 5, 4);
	StrPrint(79, 199, 'GAME OVER', 5, 1);
	StrPrint(78, 198, 'GAME OVER', 5, 9);
	StrPrint(77, 197, 'GAME OVER', 5, 12);
	{PLAY "mnmbt254o1l4ffef>cp4<fep4fef>cp4<feffef>cp4<fe>l6cp4<b-p6ap6gp6fp6fep6dp6c2"}
End;

Procedure TeeTausta;
Var a, b : Integer;
Begin
	ClearPalette;
	Bar12(0, 0, 640, 480, 10);
	For a := 1 To 18 Do
		For b := 1 To 5 Do
    Begin
			PSet(a, b, 1, 7);
			PSet(a, b + AlueKorkeus, 1, 7);
			Pet(a, b + AlueKorkeus + 5, 1, 7);
			Pet(a, b + AlueKorkeus + 10, 1, 7);
			Pet(a, b + AlueKorkeus + 15, 1, 7);
			Pet(a, b + AlueKorkeus + 20, 1, 7)
    End;
	For a := 6 To AlueKorkeus Do
  Begin
		PSet(1, a, 1, 7);
		PSet(18, a, 1, 7)
  End;
	Line12(63, AlueKorkeus * 16, 18 * 16 + 31, AlueKorkeus * 16, 15);
	Bar12(63, AlueKorkeus * 16 - 1, 18 * 16 + 31, 16 * 5, 0);
	Line12(46, 0, 46, 480, 6);
	Line12(47, 0, 47, 480, 3);
	Line12(19 * 16 + 30, 0, 19 * 16 + 30, 480, 6);
	Line12(19 * 16 + 31, 0, 19 * 16 + 31, 480, 3);
	StrPrint(400, 100, 'WAIT A LITTLE TIME ...', 2, 10);
	SetPaletti
End;

Procedure SetPaletti;
Begin
	Prg.r := 63; Prg.g := 63; Prg.b := 0; Pal(4);
	Prg.r := 63; Prg.g := 0; Prg.b := 63; Pal(5);
	Prg.r := 0; Prg.g := 63; Pal(6);

	Prg.r := 39; Prg.g := 39; Prg.b := 0; Pal(1);
	Prg.r := 39; Prg.g := 0; Prg.b := 39; Pal(2);
	Prg.r := 0; Prg.g := 39; Pal(3);

	Prg.g := 0; Pal(7);
	Prg.b := 0; Prg.g := 39; Pal(8);
	Prg.r := 39; Prg.g := 0; Pal(9);
	Prg.b := 63; Prg.r := 0; Pal(10);
	Prg.g := 63; Prg.b := 0; Pal(11);
	Prg.r := 63; Prg.g := 0; Pal(12);

	Prg.r := 21; Prg.g := 21; Prg.b := 21; Pal(13);
	Prg.r := 42; Prg.g := 42; Prg.b := 42; Pal(14);
	Prg.r := 63; Prg.g := 63; Prg.b := 63; Pal(15)
End;

Procedure PoistaRivi(a : Integer);
Var b, c : Integer;
Begin
	For b := 2 To 17 Do PSet(b, a, 0, 0);
	For c := a DownTo 7 Do
  Begin
		Sound(100); Delay(10); NoSound;
    For b := 2 To 17 Do PSet(b, c, Alue[b, c - 1].What, Alue[b, c - 1].c)
End End;

Procedure ClearPalette;
Var a : Integer;
Begin
	Prg.r := 0; Prg.g := 0; Prg.b := 0;
	For a := 15 DownTo 2 Do Pal(a)
End;

Function PaaseekoLapi(x, y : Integer) : Boolean;
Begin PaaseekoLapi := (Alue[x, y].c = 0) End;

Procedure Pal(c : Integer);
Begin
	InLine($FA);
  Port[$3C8]:=c; Port[$3C9]:=Prg.r; Port[$3C9]:=Prg.g; Port[$3C9]:=Prg.b;
	Pr[c].r := Prg.r; Pr[c].g := Prg.g; Pr[c].b := Prg.b; InLine($FB)
End;

Function Inkey : String2;
Var Ch : Char;
Begin
	If KeyPressed Then
	Begin
		Ch := ReadKey; If Ch=#0 Then Inkey := 'þ'+ReadKey Else Inkey := Ch
  End Else Inkey := ''
End;

Function CheckLines : Integer;
Var a, b, c : Integer; y : String2;
Begin
	CheckLines := 0;
	For a := 6 To AlueKorkeus Do
  Begin
		y := Inkey; c := 0;
		For b := 2 To 17 Do
			If(PaaseekoLapi(b, a))Then Begin b := 17; c := 1 End;
		If c = 0 Then
		Begin
			PoistaRivi(a); CheckLines := CheckLines + 1
    End
  End
End;

Function Pyorita(z, x, y : Integer) : Boolean;
Var a, b, e : Integer;
Begin
	e := z + 1;
	If e > 4 Then e := e - 4;
	If e < 1 Then e := e + 4;
  b := 0;
	For a := 1 To 5 Do
		If PaaseekoLapi(x + Pala[a, e, Mika].x, y + Pala[a, e, Mika].y)Then
    	Begin b := 1; a := 5 End;
	Pyorita := False;
	If b=0 Then
  Begin
		For a := 1 To 5 Do
    Begin
			NPala[a].x := Pala[a, e, Mika].x;
			NPala[a].y := Pala[a, e, Mika].y
		End;
		z := e; Pyorita := True
End End;


Procedure StrPrint(x, y : Integer; Jono : String; Koko, Colour : Integer);
Begin
	{
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
	NEXT}
End;

Procedure Pet(x, y, What, c : Integer);
Begin
	TeePala(x * 16 + 31, ((y - 1) * 16), What, c)
End;

{Procedure Plei (Ch1, Cnt1, Ch2, Cnt2)
	d1 = 0: d2 = 0
	DO
		d1 = d1 + .07
		d2 = d2 + .07
		IF d1 <= Cnt1 THEN IF d2 >= Cnt2 THEN SOUND Ch1, Cnt1 - d1: EXIT SUB ELSE SOUND Ch1, .2
		IF d2 <= Cnt2 THEN IF d1 >= Cnt1 THEN SOUND Ch2, Cnt2 - d2: EXIT SUB ELSE SOUND Ch2, .2
	LOOP UNTIL d1 >= Cnt1 AND d2 >= Cnt2
END SUB}

Procedure PSet(x, y, What, c : Integer);
Begin
	TeePala(x * 16 + 31, ((y - 1) * 16), What, c);
	Alue[x, y].c := c;
	Alue[x, y].What := What
End;

Procedure TeePala(x, y, What, c : Integer);
Begin
	If(c = 0)Then
		Begin Bar12(x, y, x + 15, y + 15, 0); Exit End;
	Case What Of
		1:
    Begin
			Bar12 (x, y, x + 15, y + 15, c);
			Line12 (x + 10, y + 14, x + 10, y + 15, 15);
			Bar12 (x + 11, y + 12, x + 12, y + 15, 15);
			Bar12 (x + 13, y + 10, x + 14, y + 12, 15);
			Line12 (x + 15, y + 9, x + 14, y + 13, 15);
			Line12 (x + 12, y + 11, x + 15, y + 8, 15);
			Line12 (x, y + 8, x + 3, y + 5, 15);
			Line12 (x, y + 9, x + 3, y + 6, 15);
			Line12 (x + 1, y + 9, x + 10, y, 15);
			Line12 (x + 4, y + 8, x + 11, y + 1, 15);
			Line12 (x + 4, y + 7, x + 11, y, 15);
			Line12 (x + 5, y + 4, x + 9, y + 4, 15);
			Pset12 (x + 6, y + 3, 15)
    End;
    {
		CASE 2
			Line12 (x, y + 2, x + 15, y + 13), c, BF
			Line12 (x + 1, y + 1, x + 14, y + 14), c, B
			Line12 (x + 2, y, x + 13, y + 15), c, B
			Line12 (x, y + 2, x, y + 7), c + 3
			Line12 (x + 1, y + 1, x + 2, y + 2), c + 3, B
			Line12 (x + 2, y, x + 5, y), c + 3
			Line12 (x + 2, y + 2, x + 2, y + 3), 13
			Line12 (x + 3, y + 1, x + 4, y + 1), 13
			Line12 (x + 13, y + 13, x + 13, y + 12), 13
			Line12 (x + 12, y + 14, x + 11, y + 14), 13
			Line12 (x + 13, y + 2, x + 13, y + 3), 13
			Line12 (x + 12, y + 1, x + 11, y + 1), 13
			Line12 (x + 2, y + 13, x + 2, y + 12), 13
			Line12 (x + 3, y + 14, x + 4, y + 14), 13
		CASE 3
			Line12 (x, y, x + 15, y + 15), POINT(x, y), BF
			Line12 (x + 11, y + 15, x + 11, y + 10), 0
			Line12 (x + 10, y + 15, x + 6, y + 11), 0
			Line12 (x + 6, y + 10, x, y + 10), 0
			Line12 (x, y + 9, x + 4, y + 5), 0
			Line12 (x + 5, y + 5, x + 5, y), 0
			Line12 (x + 6, y, x + 10, y + 4), 0
			Line12 (x + 10, y + 5, x + 15, y + 5), 0
			Line12 (x + 15, y + 6, x + 12, y + 9), 0
			PAINT (x + 7, y + 7), c, 0
			Line12 (x + 10, y + 14, x + 7, y + 11), c + 3
			Line12 (x + 10, y + 14, x + 9, y + 11), c + 3
			Line12 (x + 7, y + 1, x + 7, y + 3), c + 3
			Line12 (x + 7, y + 7, x + 10, y + 8), 0, B
			Line12 (x + 8, y + 6, x + 9, y + 9), 0, BF
		CASE 4
			Line12 (x, y, x + 15, y + 15), POINT(x, y), BF
			Line12 (x + 3, y + 15, x + 7, y + 11), 0
			Line12 (x + 2, y + 14, x + 2, y + 10), 0
			Line12 (x + 3, y + 9, x + 3, y + 8), 0
			Line12 (x + 8, y + 12, x + 9, y + 12), 0
			Line12 (x + 10, y + 13, x + 14, y + 13), 0
			Line12 (x + 15, y + 12, x + 11, y + 8), 0
			Line12 (x + 12, y + 7, x + 12, y + 6), 0
			Line12 (x + 13, y + 5, x + 13, y + 1), 0
			Line12 (x + 4, y + 7, x, y + 3), 0
			Line12 (x + 1, y + 2, x + 5, y + 2), 0
			Line12 (x + 6, y + 3, x + 7, y + 3), 0
			Line12 (x + 8, y + 4, x + 12, y), 0
			PAINT (x + 1, y + 3), c, 0
			Line12 (x + 1, y + 3, x + 5, y + 3), c + 3
			Line12 (x + 12, y + 1, x + 12, y + 5), c + 3
			Line12 (x + 11, y + 6, x + 11, y + 7), c + 3
			Line12 (x + 5, y + 12, x + 5, y + 10), c + 3
			Line12 (x + 6, y + 11, x + 6, y + 9), c + 3
			Line12 (x + 6, y + 7, x + 9, y + 8), 0, B
			Line12 (x + 7, y + 6, x + 8, y + 9), 0, BF
		CASE 5
			Line12 (x, y, x + 15, y + 15), c + 3, BF
			Line12 (x + 10, y + 14, x + 10, y + 15), 15
			Line12 (x + 11, y + 12, x + 12, y + 15), 15, BF
			Line12 (x + 13, y + 10, x + 14, y + 12), 15, BF
			Line12 (x + 15, y + 9, x + 14, y + 13), 15
			Line12 (x + 12, y + 11, x + 15, y + 8), 15
			Line12 (x, y + 8, x + 3, y + 5), 15
			Line12 (x, y + 9, x + 3, y + 6), 15
			Line12 (x + 1, y + 9, x + 10, y), 15
			Line12 (x + 4, y + 8, x + 11, y + 1), 15
			Line12 (x + 4, y + 7, x + 11, y), 15
			Line12 (x + 9, y + 4, x + 5, y + 4), 15
			PSET (x + 6, y + 3), 15
			Line12 (x, y + 1, x, y + 14), c
			Line12 (x + 15, y + 1, x + 15, y + 14), c
			Line12 (x + 1, y, x + 14, y), c
			Line12 (x + 1, y + 15, x + 14, y + 15), c
    }
  End
End;

Var a, b, c : Integer;
Begin
	For a := 1 To 5 Do
  	For b := 1 To 4 Do
    	For c := 1 To Paloja Do
      	Pala[a,b,c] := YPala[c,b,a];

	Randomize;
	{FOR a = 1 TO 6
	    PLAY "mlmbt254l4o1 a>cea< a>cea< a>cea< a>cea <egb>e <egb>e"
			PLAY "<egb>e <egb>e <dfa>d <dfa>d <dfa>d <dfa>d <eg+b>e <eg+b>e"
			PLAY "<eg+b>e <eg+b>e"
	    PRINT a
	NEXT

	END
  }
	Screen12;
	SetPaletti;
	TeeTausta;
	Pelaa;
	Halt
End.



{
SUB Star (x, y, Colour)
	IF Colour = 0 THEN LINE (x - 2, y - 2)-(x + 2, y + 2), POINT(x - 2, y - 2), BF: EXIT SUB
	LINE (x - 2, y)-(x + 2, y), Colour
	LINE (x, y - 2)-(x, y + 2), Colour
	LINE (x - 1, y - 1)-(x + 1, y + 1), Colour, B
	PSET (x, y), Colour + 3
END SUB
}

{
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
}

{SUB TeeMegaMan (x, y, AsentoNumero)
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
}