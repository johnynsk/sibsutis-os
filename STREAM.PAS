unit stream;
interface
type

Tstatus = (ACTIVE, WAITING, INACTIVE);
PTStream = ^TStream;
TStream = Object
public
    state, oldState :TStatus;
    speed, speedStep: integer;
public
    procedure enable; virtual;
    procedure disable; virtual;
    function getState: TStatus;
    procedure decreaseSpeed; virtual;
    procedure increaseSpeed; virtual;
    function getSpeed: integer; virtual;
    procedure iteration; virtual;
end;

implementation

uses crt, dos;

procedure TStream.enable;
begin
    state := ACTIVE;
end;

procedure TStream.disable;
begin
    state := INACTIVE;
end;

function TStream.getState: TStatus;
begin
    getState := state;
end;

procedure TStream.iteration;
begin
end;

function TStream.getSpeed: integer;
begin
    getSpeed := 5;
end;

procedure TStream.decreaseSpeed;
begin
    speed := speed - speedStep;
end;

procedure TStream.increaseSpeed;
begin
    speed := speed + speedStep;
end;

begin

end.
