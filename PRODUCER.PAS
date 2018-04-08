unit producer;

interface
uses term, queue;
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
    procedure iteration(const availableOps: word);
    procedure enable;
    procedure disable;
    constructor construct(newQueue: PTQueue);
end;


implementation
uses crt, dos;

procedure TProducer.iteration(const availableOps: word);
var
    remainingOps: word;
begin
    if (state = INACTIVE) then exit;

    if ((state = WAITING) and (queue^.isFull)) then exit;
    if ((state = WAITING) and (not queue^.isFull)) then state := ACTIVE;

    if (queue^.isFull) then
    begin
        state := WAITING;
        exit;
    end;

    remainingOps := availableOps;
    while (remainingOps > 0) do
    begin
        dec(remainingOps);
        if (currentNumber <= 2) then
        begin
            increaseNumber(true);
            continue;
        end;

        if (currentDividor > maxDividor) then
        begin
            increaseNumber(true);
            continue;
        end;

        if (currentNumber mod currentDividor = 0) then
        begin
            increaseNumber(false);
            continue;
        end;

        inc(currentDividor);
    end;
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
