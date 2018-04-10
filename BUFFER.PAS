unit buffer;

interface

uses stream, streamin, queue;

type

PTBuffer = ^TBuffer;
TBuffer = Object(TStream)
  private
    queue: PTQueue;
  public
    procedure increaseSpeed; virtual;
    procedure decreaseSpeed; virtual;
    function getSpeed: integer; virtual;
    constructor construct(newQueue: PTQueue);
  end;


implementation

procedure TBuffer.increaseSpeed;
begin
    queue^.setMaxLength(queue^.getMaxLength + 1);
end;

procedure TBuffer.decreaseSpeed;
var
    newLength: word;
begin
    newLength := queue^.getMaxLength - 1;
    if ((newLength <= 0) or (newLength < queue^.getLength)) then exit;
    queue^.setMaxLength(newLength);
end;

function TBuffer.getSpeed: integer;
begin
    getSpeed := queue^.getMaxLength;
end;

constructor TBuffer.construct(newQueue: PTQueue);
begin
    queue := newQueue;
end;

begin

end.
