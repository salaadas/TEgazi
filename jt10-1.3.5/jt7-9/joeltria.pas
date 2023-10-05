Uses SVGA;

Var
  LeftTable,
  RightTable: Array[0..199, 0..2]Of Integer;

  Back: Array[0..63,0..63]Of Byte;
  Fore: Array[0..7,0..63]Of Byte;

  Blokki: Array[0..127,0..127]Of Byte;

  i,j: Byte;

  View: PChar;

Procedure TextureMapPoly(x1,y1,x2,y2,x3,y3,x4,y4: Integer; Var Dest);
Var miny, maxy, loop1: integer;

  Procedure ScanLeftSide(x1,x2,ytop,LineHeight:integer;side:byte);
  Var x,px,py,xadd,pxadd,pyadd:integer; y:integer;
  Begin
    Inc(LineHeight);
    xadd:=(x2-x1)Shl 7 Div LineHeight;
    If side = 1 Then
    Begin
      px:=(127-1)Shl 7;
      py:=0;
      pxadd:=(-127 Shl 7)Div LineHeight;
      pyadd:=0;
    End;
    If side = 2 Then
    Begin
      px:=127 Shl 7;
      py:=127 Shl 7;
      pxadd:=0;
      pyadd:=(-127 Shl 7)Div LineHeight;
    End;
    If side = 3 Then
    Begin
      px:=0;
      py:=127 Shl 7;
      pxadd:=127 Shl 7 Div LineHeight;
      pyadd:=0;
    End;
    If side = 4 Then
    Begin
      px:=0;
      py:=0;
      pxadd:=0;
      pyadd:=127 Shl 7 Div LineHeight;
    End;
    x:=x1 Shl 7;
    For y:=0 to LineHeight do
    Begin
      LeftTable[ytop+y,0]:=x Shr 7;
      LeftTable[ytop+y,1]:=px Shr 7;
      LeftTable[ytop+y,2]:=py Shr 7;
      Inc(x, xadd);
      Inc(px, pxadd);
      Inc(py, pyadd)
    End;
  End;
  Procedure ScanRightSide(x1,x2,ytop,LineHeight:integer;side:byte);
  Var x,px,py,xadd,pxadd,pyadd:integer; y:integer;
  Begin
    Inc(LineHeight);
    xadd:=(x2-x1)Shl 7 Div LineHeight;
    If side = 1 Then
    Begin
      px:=0;
      py:=0;
      pxadd:=127 Shl 7 Div LineHeight;
      pyadd:=0;
    End;
    If side = 2 Then
    Begin
      px:=127 Shl 7;
      py:=0;
      pxadd:=0;
      pyadd:=127 Shl 7 Div LineHeight;
    End;
    If side = 3 Then
    Begin
      px:=127 Shl 7;
      py:=127 Shl 7;
      pxadd:=(-127)Shl 7 Div LineHeight;
      pyadd:=0;
    End;
    If side = 4 Then
    Begin
      px:=0;
      py:=127 Shl 7;
      pxadd:=0;
      pyadd:=(-127)Shl 7 Div LineHeight;
    End;
    x:=x1 Shl 7;
    For y:=0 to LineHeight do
    Begin
      RightTable[ytop+y,0]:=x Shr 7;
      RightTable[ytop+y,1]:=px Shr 7;
      RightTable[ytop+y,2]:=py Shr 7;
      Inc(x, xadd);
      Inc(px, pxadd);
      Inc(py, pyadd)
    End
  End;


  Procedure Texturemap;
  Var px1,py1:integer;
      px2,py2:integer;
      polyx1,polyx2,y,LineWidth:integer;
      pxadd,pyadd:integer;
  Begin
    If miny<0 Then miny:=0;
    If maxy>199 Then maxy:=199;
    If maxy-miny<2 Then exit;
    If miny>199 Then exit;
    If maxy<0 Then exit;
    For y:=miny to maxy do Begin
      polyx1:=LeftTable[y,0];      { X Starting position }
      px1:=LeftTable[y,1]Shl 7;   { Texture X at start  }
      py1:=LeftTable[y,2]Shl 7;   { Texture Y at stary  }
      polyx2:=RightTable[y,0];     { X Ending position   }
      px2:=RightTable[y,1]Shl 7;  { Texture X at End    }
      py2:=RightTable[y,2]Shl 7;  { Texture Y at End    }
      LineWidth:=polyx2-polyx1;    { Width of line }
      If LineWidth<=0 Then LineWidth:=1;
      pxadd:=(px2-px1)Div LineWidth;
      pyadd:=(py2-py1)Div LineWidth;
      asm
        les     di,Dest
        mov     bx,polyx1
        add     di,bx

        mov     dx,[Y]
        mov     bx, dx
        shl     dx, 8
        shl     bx, 6
        add     dx, bx
        add     di, dx        { es:di points to start of line }

        mov     bx, px1

        mov     cx,LineWidth

        mov     dx,py1

@Loop1: mov     ax,bx
        xor     si,si
        and     ax,1111111110000000b;   { Get rid of fixed TPoint }
        add     si,ax
        mov     ax,dx
        shr     ax,7
        add     si,ax           { get the pixel in our texture }
        add     si,offset Blokki
        mov al, [si]
        mov es:[di], al         { draw the pixel to the screen }
        inc di

        mov     ax,pxadd
        add     bx,ax
        mov     ax,pyadd
        add     dx,ax           { increment our position in the texture }
        dec     cx
        jnz     @loop1
      End;
    End;
  End;

Begin
  miny:=32767;
  maxy:=0;

  If y1<miny Then miny:=y1;
  If y2<miny Then miny:=y2;
  If y3<miny Then miny:=y3;
  If y4<miny Then miny:=y4;

  If y1>maxy Then maxy:=y1;
  If y2>maxy Then maxy:=y2;
  If y3>maxy Then maxy:=y3;
  If y4>maxy Then maxy:=y4;

  If miny>maxy-5 Then exit;     { Why paint slivers? }

  If(y2<y1)
    Then ScanLeftSide(x2,x1,y2,y1-y2,1)
    Else ScanRightSide(x1,x2,y1,y2-y1,1);

  If(y3<y2)
    Then ScanLeftSide(x3,x2,y3,y2-y3,2)
    Else ScanRightSide(x2,x3,y2,y3-y2,2);

  If(y4<y3)
    Then ScanLeftSide(x4,x3,y4,y3-y4,3)
    Else ScanRightSide(x3,x4,y3,y4-y3,3);

  If(y1<y4)
    Then ScanLeftSide(x1,x4,y1,y4-y1,4)
    Else ScanRightSide(x4,x1,y4,y1-y4,4);

  texturemap
End;

Procedure DrawField;
Var x, y: Word;
Begin
  For y := 0 To 191 Do
  Begin
    Move(Fore[y And 7,(y Shr 3 And 3)*8], Mem[SegA000:y*320], 8);

    Move(Back[y And 63], Mem[SegA000:y*320+8], 56);
    Move(Back[y And 63], Mem[SegA000:y*320+64], 64);
    Move(Back[y And 63], Mem[SegA000:y*320+128], 64);
    Move(Back[y And 63], Mem[SegA000:y*320+192], 64);
    Move(Back[y And 63], Mem[SegA000:y*320+256], 56);

    Move(Fore[y And 7,(y Shr 3 And 3)*8], Mem[SegA000:y*320+312], 8);
  End;

  For y := 192 To 199 Do
    For x := 0 To 9 Do
      Move(Fore[y And 7], Mem[SegA000:y*320+x*32], 32)
End;

Begin
  PCXFile('tetrpali.pcx', True,True,True);

  For i := 0 To 63 Do Move(Mem[SegA000:i*320], Back[i], 64);
  For i := 0 To 7 Do Move(Mem[SegA000:(i+64)*320], Fore[i], 64);

  GetMem(View, 64000);

  DrawField;
  Move(Mem[SegA000:0], View^, 64000);

	TextureMapPoly(0,170, 160,0, 319,50, 200,199, Mem[SegA000:0]);

  ReadLn;

  Asm mov ax,3; int 10h End
End.