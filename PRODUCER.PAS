unit producer;

interface
uses stream, queue;
type

PTProducer = ^TProducer;
TProducer = object(TStream)
private
    currentNumber: longint;
    currentDividor: longint;
    maxDividor: longint;
    queue: PTQueue;
    procedure increaseNumber(isCurrentPrime: boolean);
public
    procedure runIterations(const availableOps: word);
    procedure iteration; virtual;
    procedure enable; virtual;
    procedure disable; virtual;
    constructor construct(newQueue: PTQueue);
end;


implementation
uses crt, dos;

procedure TProducer.runIterations(const availableOps: word);
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

procedure TProducer.iteration;
begin
    if (state = INACTIVE) then exit;

    if ((state = WAITING) and (queue^.isFull)) then exit;
    if ((state = WAITING) and (not queue^.isFull)) then state := ACTIVE;

    if (queue^.isFull) then
    begin
        state := WAITING;
        exit;
    end;

    if (currentNumber <= 2) then
    begin
        increaseNumber(true);
        exit;
    end;

    if (currentDividor > maxDividor) then
    begin
        increaseNumber(true);
        exit;
    end;

    if (currentNumber mod currentDividor = 0) then
    begin
        increaseNumber(false);
        exit;
    end;

    inc(currentDividor);
end;

procedure TProducer.increaseNumber(isCurrentPrime: boolean);
begin
    if (isCurrentPrime) then queue^.push(currentNumber);

    inc(currentNumber);
    currentDividor := 2;
    maxDividor := round(sqrt(currentNumber));
end;

procedure TProducer.enable;
begin
    if (state = INACTIVE) then state := oldState;
end;

procedure TProducer.disable;
begin
  if (state <> INACTIVE) then
  begin
      state := INACTIVE;
      oldState := state;
  end;
end;

constructor TProducer.construct(newQueue: PTQueue);
begin
    state := INACTIVE;
    currentNumber := 1;
    increaseNumber(false);
    queue := newQueue;
end;

end.
