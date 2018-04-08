{$M 16384,0,655360}
{Music, clocks, prime numbers, textbanner}
program course;
uses dos, crt, sounds, clocks, term, queue, producer, consumer, ticker;

var
    oldTimerHandler: procedure;
    oldKeyHandler: procedure;
    counter: word;
    flagExit, flagKeyboard, flagTimer: boolean;
    producerInstance: TProducer;
    consumerInstance: TConsumer;
    tickerInstance: TTicker;
    clocksInstance: TClocks;
    soundInstance: TSound;
    numbersQueue: PTQueue;

{$F+}
procedure destruct;
begin
    soundInstance.disable;
    setIntVec($8, addr(oldTimerHandler));
    setIntVec($9, addr(oldKeyHandler));
    window(1, 1, 80, 25);
    textBackGround(Black);
    textColor(White);
    clrScr;
    halt;
end;

procedure timerHandler; interrupt;
var clockTime:string;
begin
    inc(counter);

    if (flagTimer) then
    begin
        inline($9C);
        oldTimerHandler;
    end;

    flagTimer := true;

    clocksInstance.iteration;
    soundInstance.iteration;
    tickerInstance.iteration;
    flagTimer := false;
    inline($9C);
    oldTimerHandler;
end;

procedure keyHandler; interrupt;
var
    keyCode: word;
    special: byte absolute $40:$17;
begin
    if (flagKeyboard) then
    begin
        inline($9C);
        oldKeyHandler;
        exit;
    end;

    flagKeyboard := true;
    keyCode := Port[$60];

    if ((keyCode = KEY_T) and (special = KEY_CTRL)) then
        if (clocksInstance.getState = ACTIVE) then clocksInstance.disable else clocksInstance.enable;

    if ((keyCode = KEY_W) and (special = KEY_CTRL)) then
        if (soundInstance.getState = ACTIVE) then soundInstance.disable else soundInstance.enable;


    if ((keyCode = KEY_ESC) or (keyCode = KEY_Q)) then
    begin
        flagExit := false;
    end;

    flagKeyboard := false;

    inline($9C);
    oldKeyHandler;
end;
{$F-}

procedure construct;
begin
    flagKeyboard := false;
    flagTimer := false;
    getIntVec($8, @oldTimerHandler);
    getIntVec($9, @oldKeyHandler);
    setIntVec($8, addr(timerHandler));
    setIntVec($9, addr(keyHandler));
end;

var
    readed_clock_x, readed_clock_y: word;
    error_code_clock_x: integer;
    message: string;
begin
    val(ParamStr(1), readed_clock_x, error_code_clock_x);
    flagExit := true;
    render;

    clocksInstance.construct(readed_clock_x * 3, readed_clock_x);
    clocksInstance.enable;

    new(numbersQueue);
    numbersQueue^.construct;
    numbersQueue^.setMaxLength(5);

    producerInstance.construct(numbersQueue);
    producerInstance.enable;

    consumerInstance.construct(numbersQueue);
    consumerInstance.enable;

    message := 'Evgeniy Vasilev. Student of SIBSUTIs, member of group ZP-51';
    tickerInstance.construct(message, TICKER_TOP, 80);
    tickerInstance.setTickDelay(4);
    tickerInstance.enable;

    soundInstance.construct;

    construct;
    while (flagExit) do
    begin
        producerInstance.iteration(3);
        consumerInstance.iteration(2);
        {tickerInstance2.iteration;}
        delay(100);
    end;

    destruct;
end.
