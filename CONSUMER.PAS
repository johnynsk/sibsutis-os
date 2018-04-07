unit consumer;


interface
uses term, queue;
type
PTConsumer = ^TConsumer;
TConsumer = Object
private
    state, oldState: Tstatus;
    queue: PTQueue;
    writed: integer;
public
    procedure iteration(const availableOps: word);
    procedure enable;
    procedure disable;
    function getState: TStatus;
    constructor construct(newQueue: PTQueue);
end;


implementation
uses crt, dos;

procedure TConsumer.iteration(const availableOps: word);
var
    remainingOps: word;
    readedNumber: integer;
begin
    if (state = INACTIVE) then exit;

    remainingOps := availableOps;
    while (remainingOps > 0) do
    begin
        dec(remainingOps);

        if (queue^.isEmpty) then
        begin
            state := WAITING;
            continue;
        end;

        state := ACTIVE;
        readedNumber := queue^.pop;
        if (writed > 0) then write(', ');
        write(readedNumber);
        inc(writed);
    end;
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

function TConsumer.getState: TStatus;
begin
    getState := state;
end;

constructor TConsumer.construct(newQueue: PTQueue);
begin
    state := INACTIVE;
    writed := 0;
    oldState := ACTIVE;
    queue := newQueue;
end;

end.
