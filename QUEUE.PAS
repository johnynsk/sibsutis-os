unit QUEUE;

interface

type
PTQueueRecord = ^TQueueRecord;
TQueueRecord = record
    next: PTQueueRecord;
    value: longint;
end;

PTQueue = ^TQueue;
TQueue = Object
private
  length, maxLength: word;
  head, tail: PTQueueRecord;
public
  procedure push(const newValue: longint);
  function pop: longint;
  function isEmpty: boolean;
  function isFull: boolean;
  function getHead: PTQueueRecord;
  function getUsage: real;
  function getLength: word;
  procedure setMaxLength(newMaxLength: word);
  function getMaxLength: word;
  constructor construct;
end;

implementation
uses crt, dos;

const MAX_LENGTH_DEFAULT = 20;

procedure TQueue.push(const newValue: longint);
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

function TQueue.pop: longint;
var
    item: PTQueueRecord;
begin
    if (head = nil) then
    begin
        pop := MAXINT;
        exit;
    end;

    item := head;
    pop := item^.value;
    head := head^.next;
    dispose(item);
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

function TQueue.getUsage: Real;
begin
    getUsage := length / maxLength;
end;

procedure TQueue.setMaxLength(newMaxLength: word);
begin
    maxLength := newMaxLength;
end;

function TQueue.getLength: word;
begin
    getLength := length;
end;

function TQueue.getMaxLength: word;
begin
    getMaxLength := maxLength;
end;

constructor TQueue.construct;
begin
    head := nil;
    tail := nil;
    length := 0;
    maxLength := MAX_LENGTH_DEFAULT;
end;

end.
