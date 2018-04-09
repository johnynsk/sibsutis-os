unit ticker;

interface
uses stream, term, queue;
type
TPosition = (TICKER_TOP, TICKER_BOTTOM);
PTTicker = ^TTicker;
TTicker = Object(TStream)
private
    message: string[110];
    messageLength: byte;
    color: byte;
    startX, startY: integer;
    tickDelay: integer;
    counter: word;
    screenPosition: TPosition;
    beforeRenderRow, afterRenderRow: PTVideoRow;
    procedure videoRestore;
    procedure render;
public
    procedure setTickDelay(newTickDelay: integer);
    function getTickDelay: integer;
    procedure iteration; virtual;
    constructor construct(newMessage: string; newScreenPosition: TPosition; newStartX: integer; newColor: byte);
end;


implementation
uses crt, dos;

procedure TTicker.videoRestore;
var
    i: integer;
    copyLength: word;
    cfrom: word;
    cto: word;
    memory: TVideoMemory absolute $b800:$0000;
begin
    for i := 1 to 80 do
    begin
        if (afterRenderRow^[i].attr xor memory[startY, i].attr <> 0) then continue;
        if (ord(afterRenderRow^[i].symbol) xor ord(memory[startY, i].symbol) <> 0) then continue;

        memory[startY, i] := beforeRenderRow^[i];
    end;
end;

procedure TTicker.render;
var
    i: integer;
    textPosition: integer;
    screen: TVideoMemory absolute $b800:$0000;
begin
    for i := 1 to 80 do
    begin
        if (i <= startX) then continue;
        if (i > startX + messageLength) then continue;
        textPosition := i - startX;

        screen[startY, i].symbol := message[textPosition];
        screen[startY, i].attr := color;
    end;
end;

procedure TTicker.iteration;
begin
    if (state = INACTIVE) then exit;
    inc(counter);
    if (counter mod tickDelay <> 0) then exit;

    videoRestore;
    copyRow(startY, beforeRenderRow);
    render;
    copyRow(startY, afterRenderRow);

    dec(startX);
    if ((startX + messageLength) <= 0) then startX := 80;
      counter := 0;
end;

procedure TTicker.setTickDelay(newTickDelay: integer);
begin
    counter := 0;
    tickDelay := newTickDelay;
end;

function TTicker.getTickDelay: integer;
begin
    getTickDelay := tickDelay;
end;

constructor TTicker.construct(newMessage: string; newScreenPosition: TPosition; newStartX: integer  ; newColor: byte);
begin
    new(beforeRenderRow);
    new(afterRenderRow);
    screenPosition := newScreenPosition;
    message := newMessage;
    messageLength := length(message);
    color := newColor;

    if (screenPosition = TICKER_TOP) then startY := 1 else startY := 25;

    startX := newStartX;
    tickDelay := 4;
    counter := 0;

    state := INACTIVE;
end;

end.
