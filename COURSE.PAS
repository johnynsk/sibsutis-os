{$M 16384,0,655360}
{Music, clocks, prime numbers, textbanner}
program course;
uses dos, crt, sounds, clocks, term, queue, producer, consumer, ticker, stream, streamin;

var
    oldTimerHandler: procedure;
    oldKeyHandler: procedure;
    counter: word;
    flagExit, flagKeyboard, flagTimer: boolean;

    mainInstance: PTStream;
    mainInfo: PTStreamInfo;

    producerInfo, consumerInfo: PTStreamInfo;
    producerInstance: PTProducer;
    consumerInstance: PTConsumer;
    numbersQueue: PTQueue;

    clocksInfo, soundInfo, tickerInfo: PTStreamInfo;
    tickerInstance: PTTicker;
    clocksInstance: PTClocks;
    soundInstance: PTSound;

{$F+}
procedure destruct;
begin
    soundInstance^.disable;
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

    clocksInstance^.iteration;
    soundInstance^.iteration;
    tickerInstance^.iteration;
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
        if (clocksInstance^.getState = ACTIVE) then clocksInstance^.disable else clocksInstance^.enable;

    if ((keyCode = KEY_W) and (special = KEY_CTRL)) then
        if (soundInstance^.getState = ACTIVE) then soundInstance^.disable else soundInstance^.enable;

    if ((keyCode = KEY_ESC) or (keyCode = KEY_Q)) then
    begin
        flagExit := false;
        {mainInstance^.disable;}
    end;

    clocksInfo^.update;
    soundInfo^.update;
{
    tickerInfo^.update;
    consumerInfo^.update;
    producerInfo^.update;
}
    flagKeyboard := false;

    inline($9C);
    oldKeyHandler;
end;
{$F-}

procedure printUsage;
begin
    writeln;
    writeln('Coursework which are demonstrates parallel launching of multiple threads.');
    writeln('This work contains few threads:');
    writeln('  * clocks working');
    writeln('  * music playing');
    writeln('  * prime number generator');
    writeln('  * buffer reader');
    writeln('  * textbanner (ticker)');
    writeln('Author: Evgeniy Vasilev <info+sibsutis@evgeniyvasilev.ru>');
    writeln;
    writeln('Required on-screen positioning parameters: [X = 71 [Y = 1 [T = TOP]]]');
    writeln('  - X, Y for clocks | T: position to show ticker (TOP|BOTTOM)');
    writeln('Launching Example: ' + paramStr(0) + ' 71 1 TOP');
    writeln;
end;

procedure printError(error: string);
begin
    writeln;
    writeln('ERROR: ' + error);
    printUsage;
    halt(1);
end;

procedure initClock;
var
    readedX, readedY: integer;
    codeX, codeY: integer;
begin
    if (paramCount < 2) then printError('Missing notation for clocks. SHOULD be X Y');
    val(paramStr(1), readedX, codeX);
    val(paramStr(2), readedY, codeY);
    if ((codeX <> 0) or (codeY <> 0)) then printError('Wrong type of value for clocks position: must be a numeric');

    if ((readedX < 1) or (readedX > 72) or (readedY < 1) or (readedY > 25)) then
        printError('Wrong values of clocks position: coordinates are out of screen');

    new(clocksInstance);
    clocksInstance^.construct(readedX, readedY);
    clocksInstance^.enable;

    new(clocksInfo);
    clocksInfo^.construct(clocksInstance, 'CLOCK', '^T', 6, 5);
end;

procedure initSound;
begin
    new(soundInstance);
    soundInstance^.construct;

    new(soundInfo);
    soundInfo^.construct(soundInstance, 'SOUND', 'Y', 6, 11);
end;

procedure initProducerAndConsumer;
begin
    new(numbersQueue);
    numbersQueue^.construct;
    numbersQueue^.setMaxLength(5);

    new(producerInstance);
    producerInstance^.construct(numbersQueue);
    producerInstance^.enable;

    new(producerInfo);
    producerInfo^.construct(producerInstance, 'PROD', '<', 25, 5);
    producerInfo^.setAdjustInfo('M', '>');

    new(consumerInstance);
    consumerInstance^.construct(numbersQueue);
    consumerInstance^.enable;

    new(consumerInfo);
    consumerInfo^.construct(consumerInstance, 'CONS', 'K', 44, 5);
    consumerInfo^.setAdjustInfo('J', 'L');
end;

procedure initTicker;
var
    strPosition: string;
    code: integer;
    message: string[120];
    screenPosition: TPosition;
begin
    if (paramCount < 3) then printError('Missing notation for ticker. SHOULD be TOP or BOTTOM');

    strPosition := paramStr(3);
    if (strPosition = 'TOP') then screenPosition := TICKER_TOP
    else if (strPosition = 'BOTTOM') then screenPosition := TICKER_BOTTOM
    else printError('Wrong value of ticker position: SHOULD be TOP or BOTTOM');

    message := 'Evgeniy Vasilev. Student of SIBSUTIs, member of group ZP-51 info+sibsutis@evgeniyvasilev.ru';

    new(tickerInstance);
    tickerInstance^.construct(message, TICKER_TOP, 80, yellow shl 2 + black);
    tickerInstance^.setTickDelay(1);
    tickerInstance^.enable;

    new(tickerInfo);
    tickerInfo^.construct(tickerInstance, 'TICKER', 'I', 63, 5);
    tickerInfo^.setAdjustInfo('U', 'P');
end;

procedure construct;
begin
  {
    new(mainInstance);
    new(mainInfo);
    mainInstance^.enable;
    mainInfo^.construct(mainInstance, 'PROGRAM', 'Q', 25, 5);
}
    flagExit := true;
    flagKeyboard := false;
    flagTimer := false;
    getIntVec($8, @oldTimerHandler);
    getIntVec($9, @oldKeyHandler);
    setIntVec($8, addr(timerHandler));
    setIntVec($9, addr(keyHandler));
end;

begin
    initClock;
    initSound;
    initProducerAndConsumer;
    initTicker;
    render;
    clocksInfo^.update;
    soundInfo^.update;

    tickerInfo^.update;
    consumerInfo^.update;
    producerInfo^.update;

    construct;
    {while (mainInstance^.getState <> INACTIVE) do}
    while (flagExit) do
    begin
        producerInstance^.runIterations(3);
        consumerInstance^.runIterations(2);
        {tickerInstance2.iteration;}
        delay(100);
    end;

    destruct;
end.
