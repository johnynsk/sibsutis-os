PROGRAM COLORS;

uses crt, dos;
var i:integer;
begin
  for i:= 0 to 255 do begin
    {if (i >= 128) then TextAttr := i - 128 else TextAttr := i;}
    write(chr(i): 4);
    if ((i+1) mod 16 = 0 ) then writeln(' ', i);
  end;
end   .
