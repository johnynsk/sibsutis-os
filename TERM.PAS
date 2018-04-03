unit term;

interface
type
    parallelStatus = (ACTIVE, INACTIVE);

procedure writeLine(const str: string; const x, y: integer);
function leadZero(value: integer): string;


implementation

uses crt, dos;

procedure writeLine(const str: string; const x, y: integer);
var
    position: integer;
    screen: array[1..25, 1..80] of
    record
        symbol: char;
        attr: byte;
    end absolute $b800:$0000;
begin
    position := x;
    while (position <= 80) and (position - x + 1 <= length(str)) do
    begin
        screen[y, position].attr := white;
        screen[y, position].symbol := str[position - x + 1];
        inc(position);
    end;
end;


function leadZero(value: integer): string;
var
    strValue: string;
begin
    str(value, strValue);
    leadZero := strValue;
    if (value < 10) then
    begin
        leadZero := '0' + strValue;
    end;
end;

end.
