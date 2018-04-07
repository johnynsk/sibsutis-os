unit QUEUE;

interface

type
PTQueueRecord = ^TQueueRecord;
TQueueRecord = record
    next: PTQueueRecord;
    value: integer;
end;

PTQueue = ^TQueue;
TQueue = Object
private
  length, maxLength: word;
  head, tail: PTQueueRecord;
public
  procedure push(const newValue: integer);
  function pop: integer;
  function isEmpty: boolean;
  function isFull: boolean;
  function getHead: PTQueueRecord;
  function getFullness: real;
  function getLength: word;
  procedure setMaxLength(newMaxLength: word);
  constructor construct;
end;

implementation
uses crt, dos;

const MAX_LENGTH_DEFAULT = 20;

procedure TQueue.push(const newValue: integer);
var
    item: PTQueueRecord;
begin
    inc(length);
    new(item);
    item^.value := newValue;
    item^.next := nil;
    tail^.next := item;
    write('');
    tail := item;

    if (head = nil) then
    begin
        head := item;
        exit;
    end;
end;

function TQueue.pop: integer;
begin
    if (head = nil) then
    begin
        pop := MAXINT;
        exit;
    end;

    pop := head^.value;
    head := head^.next;
    dec(length);
end;

function TQueue.getHead: PTQueueRecord;
begin
    getHead := head;
end;

function TQueue.isFull: Boolean;
begin
    isFull := length = maxLength;
end;

function TQueue.isEmpty: Boolean;
begin
    isEmpty := length = 0;
end;

function TQueue.getFullness: Real;
begin
    getFullness := length / maxLength * 100;
end;

procedure TQueue.setMaxLength(newMaxLength: word);
begin
    maxLength := newMaxLength;
end;

function TQueue.getLength: word;
begin
    getLength := length;
end;

constructor TQueue.construct;
begin
    head := nil;
    tail := nil;
    length := 0;
    maxLength := MAX_LENGTH_DEFAULT;
end;

end.
