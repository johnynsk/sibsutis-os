unit clocks;

interface
uses stream;

type
  PTClocks = ^TClocks;
  TClocks = Object(TStream)
  private
      hour, min, sec, usec, oldSec: word;
      counter: word;
      posX, posY: word;
      function leadZero(val: word): string;
      procedure increment;
  public
      procedure iteration; virtual;
      constructor construct(newPosX, newPosY: word);
  end;

implementation

uses dos, crt, term;
function TClocks.leadZero(val: word): string;
var
    strValue: string[2];
begin
    str(val, strValue);
    leadZero := strValue;
    if (val < 10) then
    begin
        leadZero := '0' + strValue;
    end;
end;

procedure TClocks.iteration;
begin
    increment;
    if (oldSec = sec) then exit;
    if (state <> ACTIVE) then exit;
    writeLine(' ' + leadZero(hour) + ':' + leadZero(min) + ':' + leadZero(sec) + ' ', posX, posY, Black shl 4 + white);
end;

procedure TClocks.increment;
begin
    inc(counter);

    if (counter mod 91 = 0) then
    begin
        oldSec := sec;
        inc(sec);
        counter := 0;
    end else begin
        if (counter mod 18 = 0) then
        begin
            if (counter mod 90 <> 0) then inc(sec);
        end
        else exit;
    end;

    if (sec <= 59) then exit;

    inc(min);
    sec := 0;

    if (min <= 59) then exit;

    inc(hour);
    min := 0;

    if (hour > 23) then hour := 0;
end;

constructor TClocks.construct(newPosX, newPosY: word);
begin
    getTime(hour, min, sec, usec);
    state := ACTIVE;
    posX := newPosX;
    posY := newPosY;
    counter := round(usec / (36 * 65536));
end;

end.
