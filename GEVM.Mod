(* Визуальный эмулятор ГЭВМ - Гипотетической электронно-вычислительной машины.
ГЭВМ состоит из оперативной памяти на 256 байтов и регистра "программный счётчик".
Перемещайтесь по ячейкам памяти с помощью клавиш со стрелками, вводите значения
ячеек памяти при помощи цифр от 0 до 9 и букв от A до F.
Зелёным цветом изображаются шестнадцатеричные числа, красным - десятичные.
Клавиши:
Табуляция - переставить курсор на следующую ячейку памяти и обнулить её.
P - переключить курсор на программный счётчик (или обратно).
R - выполнить инструкцию (процессор прорабатывает один такт).
X - сменить основание системы счисления в данной ячейке с 10 на 16 (или обратно).
Y - сменить основание системы счисления для вывода адресов ячеек.
[ - привести основание системы счисления во всех ячейках к основанию адресов.
] - перезагрузить ГЭВМ.
Escape - закрыть эмулятор.

Инструкции ГЭВМ:
E4 - сложить два числа, адреса которых даны в первых двух параметрах,
     и записать результат в ячейку по адресу, данному в третьем параметре.
A1 - безусловный переход на адрес, данный в [единственном] параметре.
B4 - уменьшить значение ячейки, адрес которой дан в параметре, на единицу.
A2 - если значение по адресу, данному в первом параметре, равно нулю, перейти на
     адрес, данный во втором параметре.
00 - останов.

6 апреля 2019 г. Рига.

                        === ENGLISH ===

Visual GEVM (Hypothetical Computer) emulator.
GEVM consists of a 256 byte random access memory and a register called
"program counter". Move from cell to cell using arrow keys, input cell values
using the digits from 0 to 9 and letters from A to F. Green color represents
hexadecimal numbers, red represents decimal numbers.
Keys:
Tab - move cursor to the next cell and set it to zero.
P - move cursor to the program counter (or back).
R - run an instruction (the processor will process a single tick).
X - switch number system base in the current cell from 10 to 16 (or back).
Y - switch number system base of the cell addresses.
[ - set number system base in all cells to the base of cell addresses.
] - reset GEVM.
Escape - close the emulator.

GEVM Instructions:
E4 - add two numbers, the addresses of which are given in the first two
     parameters, and put the sum in the cell, which address lies in the
     third parameter.
A1 - unconditional transfer to the address, given in the [single] parameter.
B4 - decrease value of the cell, which address is given in the parameter.
A2 - if value which is pointed by the first parameter equals zero, go to
     the address given in the second parameter.
00 - end program.

April 6, 2019. Riga. *)

MODULE GEVM;
IMPORT Files, G := Graph, Out;
CONST 
  w = 8; (* Ячеек ОЗУ в строке *)
  h = 5; (* Ячеек ОЗУ в столбце *)
  cw = 60; (* Ширина ячейки в пикселях *)
  ch = 24; (* Высота ячейки в пикселях *)
  intX = 13; (* Интервал между ячейками по горизонтали в пикселях *)
  intY = 32; (* Интервал между ячейками по вертикали в пикселях *)

  (* Клавиши *)
  tab    = CHR(9);
  backsp = CHR(8);
  enter  = CHR(13);
  esc    = CHR(27);
  right  = CHR(79);
  left   = CHR(80);
  down   = CHR(81);
  up     = CHR(82);

VAR F: Files.File;
  r: Files.Rider;
  s: G.Bitmap;
  font: G.Font;

  mem: ARRAY 256 OF CHAR; (* ОЗУ *)
  base10: ARRAY 256 OF BOOLEAN; (* Основание системы счисления = 10 *)
  mark: ARRAY 256 OF BOOLEAN; (* Пометка изменений *)
  pc: CHAR; (* Программный счётчик *)
  off: BOOLEAN; (* Выключена ли ГЭВМ *)

  first: INTEGER; (* Номер первой видимой ячейки ОЗУ *)
  cur: INTEGER; (* Номер выделенной ячейки ОЗУ *)
  curPC: BOOLEAN; (* Находится ли курсор на программном счётчике *)
  addr10: BOOLEAN; (* Показываются ли адреса в десятичном виде *)

  cx: INTEGER; (* Отступ слева в пикселях *)
  cy: INTEGER; (* Отступ сверху в пикселях *)

  (* Цвета *)
  black: INTEGER;
  white: INTEGER;
  grey: INTEGER;
  green, dkgreen, ltgreen: INTEGER;
  red, dkred, ltred: INTEGER;
  yellow: INTEGER;

PROCEDURE ResetMem;
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(mem) - 1 DO
    mem[i] := 0X;
    base10[i] := TRUE
  END;
  pc := 0X; first := 0; cur := 0;
  curPC := FALSE; addr10 := TRUE; off := TRUE
END ResetMem;

PROCEDURE ResetBase;
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(mem) - 1 DO base10[i] := addr10 END
END ResetBase;

PROCEDURE Init(): BOOLEAN;
VAR i: INTEGER;
  ok: BOOLEAN;
BEGIN
  ok := TRUE;
  font := G.LoadFont("data/images/font.bmp", 8, 16);
  IF font = NIL THEN
    Out.String("Could not load font."); Out.Ln;
    ok := FALSE
  END;

  IF ok THEN
    cx := (s.w - (cw + intX) * w - intX) DIV 2;
    cy := (s.h - (ch + intY) * h) DIV 2;

    black   := G.MakeCol(  0,   0,   0);
    white   := G.MakeCol(255, 255, 255);
    grey    := G.MakeCol(120, 120, 120);
    red     := G.MakeCol(230,   0,   0);
    dkred   := G.MakeCol(100,   0,   0);
    ltred   := G.MakeCol(255,  90,  90);
    green   := G.MakeCol(  0, 230,   0);
    dkgreen := G.MakeCol(  0, 100,   0);
    ltgreen := G.MakeCol( 90, 255,  90);
    yellow  := G.MakeCol(255, 255,  90);

    ResetMem;
    ResetBase
  END;
  RETURN ok
END Init;

PROCEDURE NumToStr(n: INTEGER; b10: BOOLEAN; VAR str: ARRAY OF CHAR);
VAR i, b, x: INTEGER;
  L, R: INTEGER;
  c: CHAR;
BEGIN
  IF b10 THEN b := 10 ELSE b := 16 END;
  i := 0;
  REPEAT
    x := n MOD b;
    IF x < 10 THEN str[i] := CHR(ORD('0') + x)
    ELSE str[i] := CHR(ORD('A') + x - 10)
    END;
    n := n DIV b;
    INC(i)
  UNTIL n = 0;
  (* Возможно дописать 0 *)
  IF i < 2 THEN str[i] := '0'; INC(i) END;
  str[i] := 0X;
  (* Перевенуть задом наперёд *)
  L := 0; R := i - 1;
  WHILE L < R DO c := str[L]; str[L] := str[R]; str[R] := c; INC(L); DEC(R) END
END NumToStr;

(* v - значение в ячейке;
   type = 0 или 1, это тип (цвет) кнопки *)
PROCEDURE DrawReg(v: INTEGER; b10: BOOLEAN; x0, y0, x1, y1, type: INTEGER;
    shine: BOOLEAN);
VAR str: ARRAY 16 OF CHAR;
  c1, c2, c3: INTEGER;
BEGIN
  IF type = 0 THEN c1 := green; c2 := dkgreen; c3 := ltgreen
  ELSE c1 := red; c2 := dkred; c3 := ltred
  END;
  G.RectFill(s, x0, y0, x1, y1, c3);
  G.HLine(s, x0, y0, x1, c1);
  G.VLine(s, x0, y0, y1, c1);
  G.HLine(s, x0, y1, x1, c2);
  G.VLine(s, x1, y0, y1, c2);
  (* Внутри *)
  NumToStr(v, b10, str);
  G.DrawString(s, font, x0 + (cw - font.charW * 2) DIV 2,
    y0 + (ch - font.charH) DIV 2, str, black);
  (* Курсор *)
  IF shine THEN
    G.Rect(s, x0 - 1, y0 - 1, x1 + 1, y1 + 1, yellow);
    G.Rect(s, x0 - 3, y0 - 3, x1 + 3, y1 + 3, yellow)
  END
END DrawReg;

(* n - индекс ячейки;
   type = 0 или 1, это тип (цвет) кнопки *)
PROCEDURE DrawCell(n, x0, y0, x1, y1, type: INTEGER);
VAR str: ARRAY 16 OF CHAR;
  x, y, c: INTEGER;
BEGIN
  (* Подсветка изменений *)
  IF n = ORD(pc) THEN
    G.RectFill(s, x0 - 3, y0 - 3, x1 + 3, y1 + font.charH + 3, grey);
    G.Rect(s, x0 - 3, y0 - 3, x1 + 3, y1 + font.charH + 3, white);
    G.Rect(s, x0 - 4, y0 - 4, x1 + 4, y1 + font.charH + 4, ltred);
    G.Rect(s, x0 - 5, y0 - 5, x1 + 5, y1 + font.charH + 5, red)
  END;
  
  DrawReg(ORD(mem[n]), base10[n], x0, y0, x1, y1, type, (cur = n) & ~curPC);
  (* Подпись внизу *)
  NumToStr(n, addr10, str);
  IF n = ORD(pc) THEN c := yellow
  ELSIF addr10 THEN c := ltred
  ELSE c := ltgreen
  END;
  x := x0 + (cw - font.charW * 2) DIV 2; y := y1 + 3;
  G.DrawString(s, font, x, y, str, c);
  IF mark[n] THEN
    G.HLine(s, x - 1, y + font.charH - 2, x + font.charW * 2 - 1, yellow)
  END
END DrawCell;

PROCEDURE DrawMem;
VAR i, type: INTEGER;
  last: INTEGER;
  x, y: INTEGER;
BEGIN
  last := first + w * h - 1;
  IF last >= LEN(mem) THEN last := LEN(mem) - 1 END;
  x := cx; y := cy;
  FOR i := first TO last DO
    IF base10[i] THEN type := 1 ELSE type := 0 END;
    DrawCell(i, x, y, x + cw - 1, y + ch - 1, type);
    IF (i + 1) MOD w # 0 THEN INC(x, cw + intX)
    ELSE INC(y, ch + intY); x := cx
    END
  END
END DrawMem;

(* Рисует регистр "программный счётчик" *)
PROCEDURE DrawPC;
VAR x, y, type, c: INTEGER;
  str: ARRAY 8 OF CHAR;
BEGIN
  IF addr10 THEN type := 1; c := ltred ELSE type := 0; c := ltgreen END;
  x := cx + (w - 1) * (cw + intX);
  y := cy - ch - 20;
  str := "Pr. sc."; str[0] := 8FX; str[1] := 0E0X;
  str[4] := 0E1X; str[5] := 0E7X;
  G.DrawString(s, font, x - 8 * font.charW,
    y + (ch - font.charH) DIV 2, str, c);
  DrawReg(ORD(pc), addr10, x, y, x + cw - 1, y + ch - 1, type, curPC)
END DrawPC;

PROCEDURE Move(c: CHAR);
BEGIN
  IF ~curPC THEN
    IF c = up THEN DEC(cur, w)
    ELSIF c = left THEN DEC(cur)
    ELSIF c = right THEN INC(cur)
    ELSE (* c = down *) INC(cur, w)
    END;
    IF cur < 0 THEN cur := 0
    ELSIF cur >= LEN(mem) THEN cur := LEN(mem) - 1
    END;
    IF cur < first THEN DEC(first, w)
    ELSIF cur >= first + w * h THEN INC(first, w)
    END
  END
END Move;

PROCEDURE Backspace;
VAR b: INTEGER;
BEGIN
  IF curPC THEN
    IF addr10 THEN b := 10 ELSE b := 16 END;
    pc := CHR(ORD(pc) DIV b)
  ELSE
    IF base10[cur] THEN b := 10 ELSE b := 16 END;
    mem[cur] := CHR(ORD(mem[cur]) DIV b)
  END
END Backspace;

PROCEDURE Input(x: INTEGER);
VAR v, v0, b: INTEGER;
  b10: BOOLEAN;
BEGIN
  IF curPC THEN
    b10 := addr10;
    v0 := ORD(pc)
  ELSE
    b10 := base10[cur];
    v0 := ORD(mem[cur])
  END;
  IF ~b10 OR (x < 10) THEN
    IF b10 THEN b := 10 ELSE b := 16 END;
    v := v0 * b + x;
    IF v > 255 THEN v := v0 MOD b * b + x END;
    IF curPC THEN pc := CHR(v) ELSE mem[cur] := CHR(v) END
  END
END Input;

PROCEDURE Mark(n: INTEGER);
BEGIN
  mark[n] := TRUE
END Mark;

PROCEDURE ClearMarks;
VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(mark) - 1 DO mark[i] := FALSE END
END ClearMarks;

PROCEDURE GoTick;
VAR instr, p0, p1, p2, p3, p4, v1, v2, v3: INTEGER;
BEGIN
  ClearMarks;
  off := FALSE;
  p0 := ORD(pc); instr := ORD(mem[p0]);
  p1 := (p0 + 1) MOD LEN(mem); v1 := ORD(mem[p1]);
  p2 := (p0 + 2) MOD LEN(mem); v2 := ORD(mem[p2]);
  p3 := (p0 + 3) MOD LEN(mem); v3 := ORD(mem[p3]);
  p4 := (p0 + 4) MOD LEN(mem);
  IF instr = 0E4H THEN
    mem[v3] := CHR((ORD(mem[v1]) + ORD(mem[v2])) MOD 256);
    Mark(v3);
    pc := CHR(p4)
  ELSIF instr = 0A1H THEN pc := mem[p1]
  ELSIF instr = 0B4H THEN
    mem[v1] := CHR((ORD(mem[v1]) - 1) MOD 256);
    Mark(v1);
    pc := CHR(p2)
  ELSIF instr = 0A2H THEN
    IF mem[v1] = 0X THEN pc := mem[p2]
    ELSE pc := CHR(p3)
    END
  ELSIF instr = 0 THEN off := TRUE; pc := 0X
  END
END GoTick;

PROCEDURE DrawMsg;
VAR z: ARRAY 5 OF CHAR;
BEGIN
  IF off THEN
    z[0] := 82X; z[1] := 9BX; z[2] := 08AX; z[3] := 08BX; z[4] := 0X;
    G.DrawString(s, font, cx, cy - font.charH - intY, z, yellow)
  END
END DrawMsg;

PROCEDURE Run;
VAR done: BOOLEAN;
  c: CHAR;
BEGIN
  done := FALSE;
  REPEAT
    G.ClearScreen;
    DrawMem;
    DrawPC;
    DrawMsg;
    G.Flip;
    c := G.ReadKey();
    IF (right <= c) & (c <= up) THEN Move(c)
    ELSIF c = tab THEN Move(right); mem[cur] := 0X
    ELSIF c = backsp THEN Backspace
    ELSIF ("0" <= c) & (c <= "9") THEN Input(ORD(c) - ORD("0"))
    ELSIF ("a" <= c) & (c <= "f") THEN Input(ORD(c) - ORD("a") + 10)
    ELSIF c = "x" THEN base10[cur] := ~base10[cur]
    ELSIF c = "y" THEN addr10 := ~addr10
    ELSIF c = "p" THEN curPC := ~curPC
    ELSIF c = "r" THEN GoTick
    ELSIF c = "[" THEN ResetBase
    ELSIF c = "]" THEN ResetMem
    ELSIF c = esc THEN done := TRUE
    END
  UNTIL done
END Run;

BEGIN
  G.Settings(640, 400, {G.fullscreen, G.sharpPixels, G.spread});
  s := G.Init();
  IF (s # NIL) & Init() THEN
    Run
  ELSE Out.String("Init failed."); Out.Ln
  END;
  G.Close
END GEVM.
