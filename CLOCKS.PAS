unit clocks;

interface

type
  parallelStatus = (ACTIVE, INACTIVE);

procedure clocksTimer;
procedure enableClock;
procedure disableClock;
procedure setXYClock(x, y: word);
procedure printClock;
function getClockTime: string;
function getClockState: parallelStatus;

implementation

uses term, dos;
var
    hour, min, sec, usec: word;
    counter: word;
    state: parallelStatus;
    posX, posY: word;

function getClockTime: string;
begin
    getClockTime := concat(' ', leadZero(hour), ':', leadZero(min), ':', leadZero(sec), ' ');
end;

procedure printClock;
begin
    if (counter mod 18 <> 0) then
    begin
        exit;
    end;

    if (state = ACTIVE) then
    begin
        writeLine(getClockTime, posX, posY);
    end;
end;

procedure setXYClock(x, y: word);
begin
    posX := x;
    posY := y;
end;

procedure enableClock;
begin
    state := ACTIVE;
end;

procedure disableClock;
begin
    state := INACTIVE;
end;

function getClockState: parallelStatus;
begin
    getClockState := state;
end;

procedure clocksTimer;
begin
    inc(counter);

    if (counter mod 91 = 0) then
    begin
        inc(sec);
        counter := 0;
    end
    else
    begin
        if (counter mod 18 = 0) then
        begin
            if (counter mod 90 <> 0) then
            begin
                inc(sec);
            end;
        end
        else
        begin
            exit;
        end;
    end;

    if (sec <= 59) then
    begin
        exit;
    end;
    inc(min);
    sec := 0;

    if (min <= 59) then
    begin
        exit;
    end;

    inc(hour);
    min := 0;

    if (hour > 23) then
    begin
        hour := 0;
    end;
end;

begin
    getTime(hour, min, sec, usec);
    state := ACTIVE;
    posX := 1;
    posY := 1;
    counter := round(usec / (36 * 65536));
end.
