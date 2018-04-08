unit ticker;

interface
uses term, queue;
type
TPosition = (TICKER_TOP, TICKER_BOTTOM);
PTTicker = ^TTicker;
TTicker = Object
private
    state: Tstatus;
    message: string[110];
    messageLength: byte;
    startX, startY: integer;
    tickDelay: integer;
    counter: word;
    screenPosition: TPosition;
    oldVideoRow: PTVideoRow;
    procedure videoRestore;
public
    procedure iteration;
    procedure setTickDelay(newTickDelay: integer);
    function getTickDelay: integer;
    procedure enable;
    procedure disable;
    function getState: TStatus;
    constructor construct(newMessage: string; newScreenPosition: TPosition; newStartX: integer);
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
    cfrom := startX;
    if (cfrom < 1) then cfrom := 1;

    cto := startX + messageLength;
    if (cto > 80) then cto := 80;

    for i := cfrom to cto do memory[startY, i] := oldVideoRow^[i];
end;

procedure TTicker.iteration;
begin
    if (state = INACTIVE) then exit;
    inc(counter);
    if (counter mod tickDelay <> 0) then exit;

    videoRestore;
    copyRow(startY, oldVideoRow);
    writeLine(message, startX, startY, White);
    dec(startX);
    if ((startX + messageLength) <= 0) then startX := 80;
      counter := 0;
end;

procedure TTicker.setTickDelay(newTickDelay: integer);
begin
    counter := 0;
    tickDelay := 9;
end;

function TTicker.getTickDelay: integer;
begin
    getTickDelay := tickDelay;
end;

procedure TTicker.enable;
begin
    state := ACTIVE;
end;

procedure TTicker.disable;
begin
    state := INACTIVE;
end;

function TTicker.getState: TStatus;
begin
    getState := state;
end;

constructor TTicker.construct(newMessage: string; newScreenPosition: TPosition; newStartX: integer);
begin
    new(oldVideoRow);
    screenPosition := newScreenPosition;
    if (screenPosition = TICKER_TOP) then startY := 18 else startY := 25;
    startX := newStartX;
    tickDelay := 4;
    counter := 0;
    message := newMessage;
    messageLength := length(newMessage);
    copyRow(startY, oldVideoRow);
    state := INACTIVE;
end;

end.
