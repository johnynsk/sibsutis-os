unit sounds;

interface
uses stream;

type
    PTSound = ^TSound;
    TSound = Object(TStream)
    private
        counter: word;
        procedure playSongSnowTree;
        function frequency(semitone: integer): integer;
    public
        procedure iteration; virtual;
        procedure disable; virtual;
        constructor construct;
    end;

implementation

uses crt;

const
    {* OCTAVE -3 *}
    C_S3 = -33; CS_S3 = -32; D_S3 = -31; DS_S3 = -30; E_S3 = -29; F_S3 = -28;
    FS_S3 = -27; G_S3 = -26; GS_S3 = -25; A_S3 = -24; AS_S3 = -23; B_S3 = -22;

    {* OCTAVE -2 *}
    C_S2 = -21; CS_S2 = -20; D_S2 = -19; DS_S2 = -18; E_S2 = -17; F_S2 = -16;
    FS_S2 = -15; G_S2 = -14; GS_S2 = -13; A_S2 = -12; AS_S2 = -11; B_S2 = -10;

    {* OCTAVE -1 *}
    C_S1 = -9; CS_S1 = -8; D_S1 = -7; DS_S1 = -6; E_S1 = -5; F_S1 = -4;
    FS_S1 = -3; G_S1 = -2; GS_S1 = -1; A_S1 = 0; AS_S1 = 1; B_S1 = 2;

    {* OCTAVE 0 *}
    C_0 = 3; CS_0 = 4; D_0 = 5; DS_0 = 6; E_0 = 7; F_0 = 8;
    FS_0 = 9; G_0 = 10; GS_0 = 11; A_0 = 12; AS_0 = 13; B_0 = 14;

    {* OCTAVE 1 *}
    C_1 = 15; CS_1 = 16; D_1 = 17; DS_1 = 18; E_1 = 19; F_1 = 20;
    FS_1 = 21; G_1 = 22; GS_1 = 23; A_1 = 24; AS_1 = 25; B_1 = 26;

    {* OCTAVE 2 *}
    C_2 = 27; CS_2 = 28; D_2 = 29; DS_2 = 30; E_2 = 31; F_2 = 32;
    FS_2 = 33; G_2 = 34; GS_2 = 35; A_2 = 36; AS_2 = 37; B_2 = 38;

    {* OCTAVE 3 *}
    C_3 = 39; CS_3 = 40; D_3 = 41; DS_3 = 42; E_3 = 43; F_3 = 44;
    FS_3 = 45; G_3 = 46; GS_3 = 47; A_3 = 48; AS_3 = 49; B_3 = 50;

    {* OCTAVE 4 *}
    C_4 = 51; CS_4 = 52; D_4 = 53; DS_4 = 54; E_4 = 55; F_4 = 56;
    FS_4 = 57; G_4 = 58; GS_4 = 59; A_4 = 60; AS_4 = 61; B_4 = 62;

    {* OCTAVE 5 *}
    C_5 = 63; CS_5 = 64; D_5 = 65; DS_5 = 66; E_5 = 67; F_5 = 68;
    FS_5 = 69; G_5 = 70; GS_5 = 71; A_5 = 72; AS_5 = 73; B_5 = 74;

    {* OCTAVE 6 *}
    C_6 = 75; CS_6 = 76; D_6 = 77; DS_6 = 78; E_6 = 79; F_6 = 80;
    FS_6 = 81; G_6 = 82; GS_6 = 83; A_6 = 84; AS_6 = 85; B_6 = 86;


procedure TSound.iteration;
begin
    if (state <> ACTIVE) then exit;
    inc(counter);
    playSongSnowTree;
end;

procedure TSound.playSongSnowTree;
begin
    case counter of
    1: sound(frequency(5));
    5: sound(frequency(14));
    9: sound(frequency(14));
    13: sound(frequency(12));
    17: sound(frequency(14));
    21: sound(frequency(10));
    25: sound(frequency(5));
    29: sound(frequency(5));
    33: nosound;
    34: sound(frequency(5));
    38: sound(frequency(14));
    42: sound(frequency(14));
    46: sound(frequency(15));
    50: sound(frequency(19));
    54: sound(frequency(17));
    58: nosound;
    66: sound(frequency(17));
    70: sound(frequency(7));
    74: sound(frequency(7));
    78: sound(frequency(15));
    82: sound(frequency(15));
    86: sound(frequency(14));
    90: sound(frequency(12));
    94: sound(frequency(10));
    98: sound(frequency(5));
    102: sound(frequency(14));
    106: sound(frequency(14));
    110: sound(frequency(12));
    114: sound(frequency(14));
    118: sound(frequency(10));
    122: nosound;
    137: counter := 0;
    end;
end;

function TSound.frequency(semitone: integer): integer;
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
procedure TSound.disable;
begin
    state := INACTIVE;
    nosound;
end;

constructor TSound.construct;
begin
    disable;
    counter := 0;
end;

end.
