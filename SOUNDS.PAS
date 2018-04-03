unit sounds;

interface

procedure enableSound;
procedure disableSound;
function frequency(semitone: integer): integer;
procedure soundTimer;


implementation

uses crt;

type parallelStatus = (ACTIVE, INACTIVE);

var
    counter: word;
    state: parallelStatus;

procedure soundTimer;
begin
    inc(counter);
end;

function frequency(semitone: integer): integer;
var
	i: integer;
	result: real;
begin
	result := 440;
    if (semitone < 0) then
    begin
        while (semitone < 0) do
        begin
            result := result / (466.16 / 440);
            semitone := semitone + 1;
        end;
        frequency := round(result);
        Exit;
    end;

    while (semitone > 0) do
	begin
	  result := result * (466.16 / 440);
      semitone := semitone - 1;
	end;

	frequency := round(result);
end;

procedure disableSound;
begin
    state := INACTIVE;
    nosound;
end;

procedure enableSound;
begin
    state := ACTIVE;
end;

begin
    enableSound;
    counter := 0;
end.
