Program lab3;
{$M $1000,0,0,0}

Uses
    crt, dos, sounds;
Var
    oldTimerHandler: Procedure;
    c, c1, control: Word;
    controls: Byte absolute $40:$17;
    counter: Longint;
    timer_offset: Word;
    hour, min, sec, usec: word;
    adjust_factor: word;
    coordX, coordY: word;
    delay, from_delay: real;

{$F+}
procedure callInt(ch_, cl_: Byte);
var
  regs: registers;
begin
  with regs do begin
    AH := $01;
    CH := ch_;
    CL := cl_;
  end;
  Intr($10, regs);
end;


procedure syncTime;
begin
    getTime(hour, min, sec, usec);
    counter := round(usec / (36 * 65536));
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

procedure updateTime;
begin

    if (counter mod 18 = 0) then
    begin
        if (counter mod 90 <> 0) then
        begin
            inc(sec);
        end;
    end;

    if (counter mod 91 = 0) then
    begin
        inc(sec);
        counter := 0;
    end;

    if (sec > 59) then
    begin
        inc(min);
        sec := 0;
    end;
    if (min > 59) then
    begin
        inc(hour);
        min := 0;
    end;

    if (hour > 23) then
    begin
        hour := 0;
    end;
end;

procedure timerHandler; interrupt;
var
    oldX, oldY: integer;
        needRender: boolean;
begin
    needRender := false;
    updateTime;
    from_delay := from_delay + 65536 / 3600;
    if (from_delay >= delay) then
    begin
        from_delay := 0;
        needRender := true;
    end;

    if (needRender) then
    begin
        oldX := whereX;
        oldY := whereY;

        callInt($20, $00);
        gotoxy(coordX, coordY);

        write(' ', leadZero(hour), ':', leadZero(min), ':', leadZero(sec), ' ');
        gotoxy(coordX, coordY + 1);
        write('X=', coordX, 'Y=', coordY);

        gotoxy(oldX, oldY);
        callInt($06, $07);
    end;
    inc(counter);
    inline($9C);
    oldTimerHandler;
End;
{$F-}

procedure usage;
begin
    writeln('Usage');
    writeln('LAB3.EXE X Y [delay=1]');
    writeln('where X = coord by X');
    writeln('where Y = coord by Y');
    writeln('delay in seconds for render');
    halt;
end;

var
    parseResultX, parseResultY, parseResultDelay: integer;
begin
    synctime;
    if ((ParamCount < 2) or (ParamCount > 3)) then
    begin
        usage;
    end;

    val(paramStr(1), coordX, parseResultX);
    val(paramStr(2), coordY, parseResultY);
    delay := 1;
    from_delay := 0;
    if (paramCount = 3) then
    begin
        val(paramStr(3), delay, parseResultDelay);
    end;

    delay := delay * 65536 / 3600;

    if ((parseResultX <> 0) or (parseResultY <> 0)) then
    begin
        usage;
    end;

    GetIntVec($1c, @oldTimerHandler);
    SetIntVec($1c, Addr(timerHandler));
    keep(0);
end.
