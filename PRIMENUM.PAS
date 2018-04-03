unit primenum;

interface
procedure enableGenPrimeNum;
procedure disableGenPrimeNum;
procedure enableOutPrimeNum;
procedure disableOutPrimeNum;

implementation

var
    gen_enabled: boolean;
    out_enabled: boolean;

procedure enableGenPrimeNum;
begin
    gen_enabled := true;
end;

procedure disableGenPrimeNum;
begin
    gen_enabled := false;
end;

procedure enableOutPrimeNum;
begin
    out_enabled := true;
end;

procedure disableOutPrimeNum;
begin
    out_enabled := false;
end;

begin
    gen_enabled := false;
    out_enabled := false;
end.
