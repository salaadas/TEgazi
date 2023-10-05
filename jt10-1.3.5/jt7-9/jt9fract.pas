{$G+,E-,N+,R-,Q-,S-,I-}
Unit JT9Fract;

Interface

Procedure DrawFract(Var Buffer);

Const
  FractX1: Byte = 28;
  FractY1: Byte = 15;
  FractX2: Byte = 58;
  FractY2: Byte = 35;

Implementation

Type
  Float = Extended;

Const
  cx: Float = -12.17;
  cy: Float = +13.02;

Var
  xo,yo:Float;
  i:Word;
  a : Byte;
  x, y: Word;
  xd,yd: Float;

Function Raster: Byte;
Begin
  Raster := (x+y)And 1
End;

Procedure PSet(Var Buffer; x,y, i: Integer);
Var c: Byte; Offs: Word;
Begin
  Case i And 7 Of
    0: i := 0;
    1: i := Raster;
    2: i := 1;
    3: i := 3;
    4: i := 2;
    5: i := 6;
    6: i := 4;
    7: i := 0;
  End;

  Offs := ((y Shr 1)*80+x)*2;

  If Odd(y)
    Then c := i + Mem[Seg(Buffer):Ofs(Buffer)+Offs+1]And $F0
    Else c := i Shl 4 + Mem[Seg(Buffer):Ofs(Buffer)+Offs+1]And 15;

  If c And 15 = c Shr 4
    Then MemW[Seg(Buffer):Ofs(Buffer)+Offs] := c Shl 8 + 32
    Else MemW[Seg(Buffer):Ofs(Buffer)+Offs] := c Shl 8 + 220
End;

Procedure DrawFract(Var Buffer);
Var
  a: Byte;
  xdiff, ydiff: Float;
  x3,y3: Float;
Const
  FirstTime: Boolean = True;
  Counter: Integer = 0;
Begin
  For x:=0 To (FractX2-FractX1) Do
    For y:=0 To (FractY2-FractY1) Do
    Begin
      xo:=-2+4*x/(FractX2-FractX1);
      yo:= 2-4*y/(FractY2-FractY1);

      i:=0;
      Repeat
        x3:=Sqr(xo)-Sqr(yo)+cx;
        y3:=2*xo*yo+cy;
        xo:=x3;
        yo:=y3;
        inc(i);
      Until(i=7)Or(Sqr(x3)+Sqr(y3) > 16);

      PSet(Buffer, x+FractX1,y+FractY1, i)
    End;

  If(Counter<=0)Or FirstTime Then
  Begin
    FirstTime := False;

    xdiff := Random-Random*2 - cx;
    ydiff := Random-Random*2 - cy;

    Counter := 150;

    xd := xdiff/Counter*1.4;
    yd := ydiff/Counter*1.4;
  End;
  Dec(Counter);

  cx := cx + xd;
  cy := cy + yd;
End;

End.
