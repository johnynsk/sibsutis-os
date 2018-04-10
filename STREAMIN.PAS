unit streamin;

interface
uses stream;

type
PTStreamInfo = ^TStreamInfo;
TStreamInfo = Object
private
    streamName: string[9];
    isAdjustable, isShowed: boolean;
    stream: PTStream;
    oldState: TStatus;
    oldSpeed: integer;

    posX: integer;
    posY: integer;

    decreaseKey: string[2];
    increaseKey: string[2];
public
    toggleKey: string[2];
    procedure update;
    procedure handleKey(keyChar: string); virtual;
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

procedure TStreamInfo.handleKey(keyChar: string);
begin
    if (keyChar = toggleKey) then
    begin
        if (stream^.state <> INACTIVE) then stream^.disable else stream^.enable;
        exit;
    end;

    if (keyChar = decreaseKey) then
    begin
        stream^.decreaseSpeed;
        exit;
    end;

    if (keyChar = increaseKey) then
    begin
        stream^.increaseSpeed;
        exit;
    end;
end;

procedure TStreamInfo.update;
var
    screen: TVideoMemory absolute $b800:$0000;
    lines: word;
    i, j: integer;
    streamStatusString, currentSpeed: string;
    color: byte;
begin
    if ((stream^.getState = oldState) and (stream^.getSpeed = oldSpeed) and (isShowed)) then exit;
    oldState := stream^.getState;
    oldSpeed := stream^.getSpeed;
    isShowed := true;

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

    lines := 2;
    if (isAdjustable) then lines := 3;

    for i := 0 to lines do
    begin
        for j := 0 to 15 do
        begin
            screen[posY + i, posX + j].attr := color;
            screen[posY + i, posX + j].symbol := ' ';
        end;
    end;

    showBox(posX, posY, posX + 15, posY + lines);
    writeLine(' ' + streamName + ' ', posX + 2, posY, color);
    writeLine(streamStatusString, posX + 11, posY + 1, color);
    writeLine(toggleKey, posX + 2, posY + 1, color);

    if (not isAdjustable) then exit;
    str(stream^.getSpeed: 3, currentSpeed);
    writeLine(decreaseKey, posX + 2, posY + 2, color);
    writeLine(currentSpeed, posX + 5, posY + 2, color);
    writeLine(increaseKey, posX + 11, posY + 2, color);
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
