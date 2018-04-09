PROGRAM COLORS;

uses crt, dos;
var i:integer;
begin
  for i:= 0 to 255 do begin
    TextAttr := i;
    write(i: 4);
    if ((i+1) mod 16 = 0 ) then writeln;
  end;
end   .
