Unit X00Fossi;

Interface

Function FosInstalled(Port: Word): Boolean;
Procedure FosSetData(Port: Word; BaudRate: LongInt);
Function SendByte(Port: Word; Chr: Char): Boolean;
Procedure OutTextToPort(Port: Word; s: PChar);
Function CharAvail(Port: Word): Boolean;
Function LueNap(Port: Word): Char;
Procedure HangUp(Port: Word);

Implementation

Uses Timer;

Function FosInstalled(Port: Word): Boolean; Assembler;
Asm
  mov ah, 1Ch
  mov dx, Port
  int 14h

  cmp ax, 1954h
  mov al, 1
  je @@1
  xor ax, ax
@@1:
End;

Procedure FosSetData(Port: Word; BaudRate: LongInt);
Begin
       If BaudRate=  2400 Then Asm mov cl, 5 End
  Else If BaudRate=  4800 Then Asm mov cl, 6 End
  Else If BaudRate=  4800 Then Asm mov cl, 7 End
  Else If BaudRate= 19200 Then Asm mov cl, 8 End
  Else If BaudRate= 28800 Then Asm mov cl, $80 End
  Else If BaudRate= 38400 Then Asm mov cl, $81 End
  Else If BaudRate= 57600 Then Asm mov cl, $82 End
  Else If BaudRate= 76800 Then Asm mov cl, $83 End
  Else If BaudRate=115200 Then Asm mov cl, $84 End
  Else Exit;
  Asm
    mov ax, 1E00h
    xor bx, bx
    mov ch, 3
    mov dx, Port
    int 14h
  End
End;

Function SendByte(Port: Word; Chr: Char): Boolean; Assembler;
Asm
  mov ah, 0Bh
  mov al, Chr
  mov dx, Port
  int 14h
  {Returns TRUE if succesful}
End;

Procedure OutTextToPort(Port: Word; s: PChar); Assembler;
Asm
  les si, s
@@1:
  mov al, es:[si]
  or al, al
  jz @@2
  push es
   push si
    push Port
    push ax
    call SendByte
   pop si
  pop es
  inc si
  jmp @@1
@@2:
End;

Function CharAvail(Port: Word): Boolean; Assembler;
Asm
  mov ah, 0Ch
  mov dx, Port
  int 14h
  inc ax
  jz @1
  mov ax, 1
@1:
End;

Function LueNap(Port: Word): Char; Assembler;
Asm
  mov ah, 2
  mov dx, Port
  int 14h
End;

Procedure HangUp(Port: Word); Assembler;
Asm
  xor cx, cx
@@1:
  push cx
   mov ax, 0600h
   mov dx, Port
   int 14h
   mov ax, 0601h
   mov dx, Port
   int 14h
  pop cx
  dec cx
  jnz @@1
End;



End.