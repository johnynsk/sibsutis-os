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
    counter: word;
    screenPosition: TPosition;
    beforeRenderRow, afterRenderRow: PTVideoRow;
    procedure videoRestore;
    procedure render;
public
    procedure decreaseSpeed; virtual;
    procedure increaseSpeed; virtual;
    procedure iteration; virtual;
    constructor construct(newMessage: string; newScreenPosition: TPosition; newStartX: integer; newColor: byte);
end;


implementation
uses crt, dos;

const MAX_SPEED = 40;

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
    newRow: TVideoRow;
begin
    for i := 1 to 80 do
    begin
        newRow[i] := screen[startY, i];

        if ((afterRenderRow^[i].attr xor newRow[i].attr = 0)
            and (ord(afterRenderRow^[i].symbol) xor ord(newRow[i].symbol) = 0))
        then begin
            newRow[i] := beforeRenderRow^[i];
        end;

        beforeRenderRow^[i] := newRow[i];

        if ((i > startX) and (i <= startX + messageLength)) then
        begin
            textPosition := i - startX;

            newRow[i].symbol := message[textPosition];
            newRow[i].attr := color;
        end;

        afterRenderRow^[i] := newRow[i];
        screen[startY, i] := newRow[i];
    end;
end;

procedure TTicker.iteration;
begin
    if (state = INACTIVE) then exit;
    inc(counter);
    if (counter mod speed <> 0) then exit;

    render;

    dec(startX);
    if ((startX + messageLength) <= 0) then startX := 80;
      counter := 0;
end;

procedure TTicker.increaseSpeed;
begin
    if ((speed + speedStep) > MAX_SPEED) then
    begin
        speed := MAX_SPEED;
        exit;
    end;
    speed := speed + speedStep;
end;

procedure TTicker.decreaseSpeed;
begin
    if ((speed - speedStep) <= 0) then
    begin
        speed := 1;
        exit;
    end;
    speed := speed - speedStep;
end;

constructor TTicker.construct(newMessage: string; newScreenPosition: TPosition; newStartX: integer  ; newColor: byte);
begin
    new(beforeRenderRow);
    new(afterRenderRow);
    screenPosition := newScreenPosition;
    message := ' ' + newMessage + ' ';
    messageLength := length(message);
    color := newColor;

    if (screenPosition = TICKER_TOP) then startY := 1 else startY := 25;

    startX := newStartX;
    counter := 0;
    speed := 4;
    speedStep := 1;

    state := INACTIVE;
end;

end.
