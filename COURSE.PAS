{$M 16384,0,655360}
{Music, clocks, prime numbers, textbanner}
program course;
uses dos, crt, sounds, clocks, term, queue, producer, consumer, ticker, stream, streamin, buffer;

type
    PTMain = ^TMain;
    TMain = Object(TStream)
  public
    constructor construct;
    end;

    PTMainInfo = ^TMainInfo;
    TMainInfo = Object(TStreamInfo)
  private
    _clocks: PTClocks;
    _sound: PTSound;
    _ticker: PTTicker;
    _consumer: PTConsumer;
    _producer: PTProducer;
  public
    procedure handleKey(keyChar: string); virtual;
    procedure setInstances(cl: PTClocks; s: PTSound; t: PTTicker; cons: PTConsumer; prod: PTProducer);
    end;

var
    oldTimerHandler: procedure;
    oldKeyHandler: procedure;
    counter: word;
    flagExit, flagKeyboard, flagTimer: boolean;

    mainInstance: PTMain;
    mainInfo: PTMainInfo;

    producerInfo, consumerInfo: PTStreamInfo;
    producerInstance: PTProducer;
    consumerInstance: PTConsumer;
    numbersQueue: PTQueue;

    bufferInstance: PTBuffer;
    bufferInfo: PTStreamInfo;

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

procedure renderQueueStatus;
var
    items: string;
    usage: string;
    number: string;
    dividor: string;
begin
    str(numbersQueue^.getLength: 3, items);
    str((numbersQueue^.getUsage * 100): 4: 1, usage);
    str(producerInstance^.getCurrentNumber: 6, number);
    str(producerInstance^.getCurrentDividor: 6, dividor);
    writeLine(' Buffer usage: ' + items + ' items (' + usage + '%) ', 44, 14, Green shl 4 + Yellow);
    writeLine(' Current number: ' + number + ', dividor = ' + dividor + ' ', 35, 24, Green shl 4 + Yellow);
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

    clocksInfo^.update;
    soundInfo^.update;
    tickerInfo^.update;
    consumerInfo^.update;
    producerInfo^.update;

    renderQueueStatus;

    flagTimer := false;
    inline($9C);
    oldTimerHandler;
end;

procedure keyHandler; interrupt;
var
    keyCode: word;
    keyChar: string[2];
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

    keyChar := getKeyChar(keyCode, special);

    clocksInfo^.handleKey(keyChar);
    soundInfo^.handleKey(keyChar);
    tickerInfo^.handleKey(keyChar);
    consumerInfo^.handleKey(keyChar);
    producerInfo^.handleKey(keyChar);
    mainInfo^.handleKey(keyChar);
    bufferInfo^.handleKey(keyChar);

    if (mainInstance^.getState = INACTIVE) then flagExit := false;

    flagKeyboard := false;

    inline($9C);
    oldKeyHandler;
end;
{$F-}

constructor TMain.construct;
begin
    enable;
end;

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
    clocksInfo^.construct(clocksInstance, 'CLOCK', 'C', 4, 4);
end;

procedure initSound;
begin
    new(soundInstance);
    soundInstance^.construct;

    new(soundInfo);
    soundInfo^.construct(soundInstance, 'SOUND', 'X', 23, 9);
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
    producerInfo^.construct(producerInstance, 'PRODUCER', '<', 23, 4);
    producerInfo^.setAdjustInfo('M', '>');

    new(consumerInstance);
    consumerInstance^.construct(numbersQueue);
    consumerInstance^.enable;

    new(consumerInfo);
    consumerInfo^.construct(consumerInstance, 'CONSUMER', 'K', 42, 4);
    consumerInfo^.setAdjustInfo('J', 'L');

    new(bufferInstance);
    bufferInstance^.construct(numbersQueue);
    bufferInstance^.enable;
    new(bufferInfo);
    bufferInfo^.construct(bufferInstance, 'BUFFER', '', 61, 9);
    bufferInfo^.setAdjustInfo('T', 'Y');
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
    tickerInstance^.construct(message, screenPosition, 80, yellow shl 2 + black);
    tickerInstance^.enable;

    new(tickerInfo);
    tickerInfo^.construct(tickerInstance, 'TICKER', 'I', 61, 4);
    tickerInfo^.setAdjustInfo('U', 'O');
end;

procedure TMainInfo.setInstances(cl: PTClocks; s: PTSound; t: PTTicker; cons: PTConsumer; prod: PTProducer);
begin
    _clocks := cl;
    _sound := s;
    _ticker := t;
    _consumer := cons;
    _producer := prod;
end;

procedure TMainInfo.handleKey(keyChar: string);
begin
    if ((keyChar = toggleKey) or (keyChar = '~E') or (keyChar = '^C')) then mainInstance^.disable;

    if (clocksInstance^.getState <> INACTIVE) then exit;
    if (soundInstance^.getState <> INACTIVE) then exit;
    if (tickerInstance^.getState <> INACTIVE) then exit;
    if (consumerInstance^.getState <> INACTIVE) then exit;
    if (producerInstance^.getState <> INACTIVE) then exit;
    mainInstance^.disable;
end;

procedure construct;
begin
    new(mainInstance);
    new(mainInfo);
    mainInstance^.construct;
    mainInstance^.enable;
    mainInfo^.construct(mainInstance, 'PROGRAM', 'Q', 42, 9);
    mainInfo^.update;

    flagExit := true;
    flagKeyboard := false;
    flagTimer := false;
    getIntVec($8, @oldTimerHandler);
    getIntVec($9, @oldKeyHandler);
    setIntVec($8, addr(timerHandler));
    setIntVec($9, addr(keyHandler));
end;

procedure loop;
var
    producerSpeed, consumerSpeed, sumSpeed:word;
begin
    while (flagExit) do
    begin
        sumSpeed := 0;
        if (producerInstance^.getState <> INACTIVE) then sumSpeed := producerInstance^.getSpeed;
        if (consumerInstance^.getState <> INACTIVE) then sumSpeed := consumerInstance^.getSpeed;
        delay(300);

        if ((random(2) = 0) and (producerInstance^.getState <> INACTIVE))
        then begin
            producerInstance^.runIterations(producerInstance^.getSpeed);
            writeLine(' Current stream: producer ', 4, 24, Red shl 4 + Blue);
            continue;
        end;

        if (consumerInstance^.getState <> INACTIVE) then
        begin
            consumerInstance^.runIterations(consumerInstance^.getSpeed);
            writeLine(' Current stream: consumer ', 4, 24, Brown shl 4 + Black);
            continue;
        end;

        producerInstance^.runIterations(producerInstance^.getSpeed);
        writeLine(' Current stream: producer ', 4, 24, Red shl 4 + Black);

    end;
end;

begin
    randomize;
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
    bufferInfo^.update;

    construct;
    loop;
    destruct;
end.
