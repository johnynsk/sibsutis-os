unit consumer;


interface
uses stream, queue;
type
PTConsumer = ^TConsumer;
TConsumer = Object(TStream)
private
    queue: PTQueue;
    writed: word;
public
    procedure runIterations(const availableOps: word);
    procedure iteration; virtual;
    procedure enable; virtual;
    procedure disable; virtual;
    constructor construct(newQueue: PTQueue);
end;


implementation
uses crt, dos;

procedure TConsumer.runIterations(const availableOps: word);
var
    remainingOps: word;
begin
    remainingOps := availableOps;

    while (remainingOps > 0) do
    begin
        dec(remainingOps);
        iteration;
    end;
end;

procedure TConsumer.iteration;
var
    readedNumber: longint;
begin
    if (state = INACTIVE) then exit;

    if (queue^.isEmpty) then
    begin
        state := WAITING;
        exit;
    end;

    state := ACTIVE;
    readedNumber := queue^.pop;
    if (writed > 0) then write(', ');
    write(readedNumber);
    inc(writed);
end;

procedure TConsumer.enable;
begin
    if (state = INACTIVE) then state := oldState;
end;

procedure TConsumer.disable;
begin
    if (state <> INACTIVE) then
    begin
        state := INACTIVE;
        oldState := state;
    end;
end;

constructor TConsumer.construct(newQueue: PTQueue);
begin
    state := INACTIVE;
    writed := 0;
    oldState := ACTIVE;
    queue := newQueue;
end;

end.
