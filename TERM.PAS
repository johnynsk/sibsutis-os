unit term;

interface
type
    Tstatus = (ACTIVE, WAITING, INACTIVE);
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

procedure printUsage;
var
    memory: TVideoMemory absolute $b800:$0000;
begin

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

procedure render;
begin
    textBackGround(Black);
    clrScr;

    printGrid;


    {
    window(2, 2, 38, 17);
    textBackGround(Red);
    clrScr;
    textColor(White);
    gotoXY(3, 1);
    write('left pane');
    window(3, 3, 37, 16);
    textBackGround(Black);
    clrScr;
    writeLine('stream  1:', 3, 3);
    writeLine('stream 2:', 3, 4);

    window(40, 2, 79, 17);
    textBackGround(Yellow);
    clrScr;
    textColor(White);
    gotoXY(4, 1);
    write('right pane');
    window(41, 3, 78, 16);
    textBackGround(Black);
    clrScr;
    writeLine('stream 1:', 41, 3);
    writeLine('stream 4 :', 41, 4);

    {usage}

    window(2, 18, 79, 24);
    textBackGround(LightGray);
    textColor(Black);
    clrScr;
end;

end.
