unit term;

interface
type

TVideoCell = record
    symbol: char;
    attr: byte;
end;
PTVideoRow = ^TVideoRow;
TVideoRow = array[1 .. 80] of TVideoCell;
TVideoMemory = array[1 .. 25] of TVideoRow;

const
    KEY_CTRL = 4;
    KEY_NONE = 0;
    KEY_T = 148;
    KEY_ESC = 129;
    KEY_Q = 144;
    KEY_W = 145;

procedure writeLine(const str: string; const x, y: integer; color: byte);
procedure printGrid;
procedure render;
procedure copyRow(rowNumber: word; result: PTVideoRow);
procedure showBox(x1, y1, x2, y2: integer);
function getKeyChar(keyCode: word; special: byte): String;

implementation

uses crt, dos;

procedure writeLine(const str: string; const x, y: integer; color: byte);
var
    position: integer;
    screen: TVideoMemory absolute $b800:$0000;
begin
    position := x;
    while (position <= 80) and (position - x + 1 <= length(str)) do
    begin
        screen[y, position].attr := color;
        screen[y, position].symbol := str[position - x + 1];
        inc(position);
    end;
end;

procedure copyRow(rowNumber: word; result: PTVideoRow);
var
    i: integer;
    screen: TVideoMemory absolute $b800:$0000;
    row: TVideoRow;
begin
    for i := 1 to 80 do
    begin
        row[i] := screen[rowNumber][i];
    end;
    result^ := row;
end;

procedure printGrid;
var
    x, y: word;
    memory: TVideoMemory absolute $b800:$0000;
begin
    writeln('code=', memory[14, 2].attr, 'symbol', memory[14, 2].symbol, '|');
    writeln('code=', memory[1, 1].attr, 'symbol', memory[1, 1].symbol, '|');

    for x := 1 to 80 do
    begin
        for y := 1 to 25 do
        begin
            if ((x div 2) mod 2 = 0 ) then
            begin
                if (y mod 2 <> 0) then
                  memory[y, x].attr := (LightRed shl 4 + Green) else memory[y, x].attr := LightBlue;
                if (x mod 2 <> 0) then memory[y, x].symbol := ' ' else memory[y, x].symbol := chr(219);
            end
            else
            begin
                if (y mod 2 <> 0) then memory[y, x].attr := LightGreen else memory[y, x].attr := Green;
                if (x mod 2 <> 0) then memory[y, x].symbol := ' ' else memory[y, x].symbol := '.';
            end;
        end;
    end;
end;

function getKeyChar(keyCode: word; special: byte): String;
var
    keyChar: string[2];
begin
    keyChar := '';

    case keyCode of
        KEY_ESC: keyChar := '~E';
        144: keyChar := 'Q';

        173: keyChar := 'X';
        174: if (special and KEY_CTRL = KEY_CTRL) then keyChar := '^C' else keyChar := 'C';

        178: keyChar := 'M';
        179: keyChar := '<';
        180: keyChar := '>';

        164: keyChar := 'J';
        165: keyChar := 'K';
        166: keyChar := 'L';

        148: keyChar := 'T';
        149: keyChar := 'Y';

        150: keyChar := 'U';
        151: keyChar := 'I';
        152: keyChar := 'O';
    end;

    getKeyChar := keyChar;
end;

procedure showBox(x1, y1, x2, y2: integer);
var
    i: word;
    screen: TVideoMemory absolute $b800:$0000;
begin
    for i := (x1 + 1) to (x2 - 1) do
    begin
        if ((i <= 0) or (i > 80)) then continue;
        screen[y1, i].symbol := chr(196);
        screen[y2, i].symbol := chr(196);
    end;

    for i := (y1 + 1) to (y2 - 1) do
    begin
        if ((i <= 0) or (i > 25)) then continue;
        screen[i, x1].symbol := chr(179);
        screen[i, x2].symbol := chr(179);
    end;

    if ((x1 > 0) and (x1 <= 80)) then
    begin
        if ((y1 > 0) and (y1 <= 25)) then screen[y1, x1].symbol := chr(218);
        if ((y2 > 0) and (y2 <= 25)) then screen[y2, x1].symbol := chr(192);
    end;

    if ((x2 > 0) and (x2 <= 80)) then
    begin
        if ((y1 > 0) and (y1 <= 25)) then screen[y1, x2].symbol := chr(191);
        if ((y2 > 0) and (y2 <= 25)) then screen[y2, x2].symbol := chr(217);
    end;
end;

procedure render;
begin
    textBackGround(Black);
    clrScr;

    printGrid;

    window(3, 15, 78, 23);
    textBackGround(LightGray);
    textColor(Black);
    clrScr;
    showBox(2, 14, 79, 24);
    writeLine(' Consumer output ', 5, 14, blue shl 4 + yellow);
end;

begin

end.
