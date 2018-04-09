unit streamin;

interface
uses stream;

type
PTStreamInfo = ^TStreamInfo;
TStreamInfo = Object
private
    streamName: string[6];
    toggleKey: string[2];
    isAdjustable, isShowed: boolean;
    stream: PTStream;
    oldState: TStatus;
    oldSpeed: integer;

    posX: integer;
    posY: integer;

    decreaseKey: string[2];
    increaseKey: string[2];
public
    procedure update;
    procedure setAdjustInfo(newDecreaseKey, newIncreaseKey: string);
    constructor construct(newStream: PTStream; newStreamName, newToggleKey: string; newPosX, newPosY: integer);
end;

implementation
uses term, crt;

procedure TStreamInfo.setAdjustInfo(newDecreaseKey, newIncreaseKey: string);
begin
    isAdjustable := true;
    decreaseKey := newDecreaseKey;
    increaseKey := newIncreaseKey;
end;

procedure TStreamInfo.update;
var
    screen: TVideoMemory absolute $b800:$0000;
    lines: word;
    i, j: integer;
    streamStatusString: string;
    color: byte;
begin
    if ((stream^.getState = oldState) and (stream^.getSpeed = oldSpeed) and (isShowed)) then exit;
    oldState := stream^.getState;
    oldSpeed := stream^.getSpeed;

    if (oldState = ACTIVE) then
    begin
        color := (Green shl 4) + White;
        streamStatusString := 'RUN';
    end else if (oldState = INACTIVE) then
    begin
        streamStatusString := 'IDLE';
        color := (Red shl 4) + White;
    end else begin
        streamStatusString := 'WAIT';
        color := (Blue shl 4) + White;
    end;

    lines := 1;
    if (isAdjustable) then lines := 2;

    for i := -1 to lines + 1 do
    begin
        for j := -1 to 15 do
        begin
            screen[posY + i, posX + j].attr := color;
            screen[posY + i, posX + j].symbol := ' ';
        end;
    end;

    writeLine(streamStatusString, posX, posY, color);
    writeLine(streamName, posX + 5, posY, color);
    writeLine(toggleKey, posX, posY + 1, color);
end;

constructor TStreamInfo.construct(newStream: PTStream; newStreamName, newToggleKey: string; newPosX, newPosY: integer);
begin
    stream := newStream;
    oldState := stream^.getState;
    oldSpeed := stream^.getSpeed;
    streamName := newStreamName;
    toggleKey := newToggleKey;
    isShowed := false;
    posX := newPosX;
    posY := newPosY;
    isAdjustable := false;
end;

begin

end.
