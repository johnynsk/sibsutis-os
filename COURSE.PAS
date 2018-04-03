{$M $1000,0,0,0}
{Music, clocks, prime numbers, textbanner}
program course;
uses dos, crt, sounds, clocks, term;
var
    oldTimerHandler: procedure;
    oldKeyHandler: procedure;
    counter: word;


procedure render;
begin
    textBackGround(Black);
    clrScr;

    window(2, 2, 38, 17);
    textBackGround(Red);
    clrScr;
    textColor(White);
    gotoXY(3, 1);
    write('process one');
    window(3, 3, 37, 16);
    textBackGround(Black);
    clrScr;

    window(40, 2, 79, 17);
    textBackGround(Yellow);
    clrScr;
    textColor(White);
    gotoXY(4, 1);
    write('states 2');
    window(41, 3, 78, 16);
    textBackGround(Black);
    clrScr;

    writeLine('stream  1:', 3, 3);
    writeLine('stream 2:', 3, 4);
    writeLine('stream 1:', 41, 3);
    writeLine('stream 4 :', 41, 4);

    {usage}

    window(1, 18, 80, 24);
    textBackGround(LightGray);
    clrScr;
end;

{$F+}
procedure timerHandler; interrupt;
begin
    inc(counter);
    clocksTimer;
    soundTimer;
    printClock;
    inline($9C);
    oldTimerHandler;
end;

procedure keyHandler; interrupt;
begin
    inline($9C);
    oldKeyHandler;
end;
{$F-}

procedure construct;
begin
    getIntVec($8, @oldTimerHandler);
    getIntVec($9, @oldKeyHandler);
    setIntVec($8, addr(timerHandler));
    setIntVec($9, addr(keyHandler));
    enableSound;
end;


procedure destruct;
begin
    disableSound;
    setIntVec($8, addr(oldTimerHandler));
    setIntVec($9, addr(oldKeyHandler));
    window(1, 1, 80, 25);
    textBackGround(Black);
    clrScr;
    halt;
end;

begin
    construct;
    render;
    setXYClock(5, 5);
    readkey;
    destruct;
    {keep(0);}
end.
