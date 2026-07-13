{ This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
  Source: https://github.com/JohnnyFoulds/retro-game-stream }

unit TPTEST;

{$F+} { Far calls required for procedural type compatibility across units }

{ Minimal TAP-producing test runner for Turbo Pascal 7.
  No exceptions, no RTTI, no class — pure TP7 real-mode DOS.

  Writes TAP output to both screen and TEST.TAP in the current directory.

  Usage:
    RegisterTest('description', TestProcedure);
    if RunTests > 0 then Halt(1);
}

interface

const
  MAX_TESTS = 64;
  TAP_FILE  = 'TEST.TAP';

type
  TTestProc = procedure;

procedure RegisterTest(const Name: String; Proc: TTestProc);
function  RunTests: Integer;

{ Assertion helpers — call only from inside a registered test procedure }
procedure AssertTrue(const Desc: String; Condition: Boolean);
procedure AssertFalse(const Desc: String; Condition: Boolean);
procedure AssertEqualInt(const Desc: String; Expected, Actual: Integer);
procedure AssertEqualChar(const Desc: String; Expected, Actual: Char);
procedure AssertEqualStr(const Desc: String;
                         const Expected, Actual: String);
procedure Fail(const Desc: String);

implementation

type
  TTestEntry = record
    Name : String;
    Proc : TTestProc;
  end;

var
  Tests         : array[1..MAX_TESTS] of TTestEntry;
  TestCount     : Integer;
  CurrentFailed : Boolean;
  TapOut        : Text;

procedure TapWrite(const S: String);
begin
  WriteLn(TapOut, S);
  WriteLn(S);
end;

procedure RegisterTest(const Name: String; Proc: TTestProc);
begin
  if TestCount >= MAX_TESTS then Exit;
  Inc(TestCount);
  Tests[TestCount].Name := Name;
  Tests[TestCount].Proc := Proc;
end;

procedure Fail(const Desc: String);
begin
  TapWrite('# FAIL: ' + Desc);
  CurrentFailed := True;
end;

procedure AssertTrue(const Desc: String; Condition: Boolean);
begin
  if not Condition then
    Fail(Desc + ' -- expected True, got False');
end;

procedure AssertFalse(const Desc: String; Condition: Boolean);
begin
  if Condition then
    Fail(Desc + ' -- expected False, got True');
end;

procedure AssertEqualInt(const Desc: String; Expected, Actual: Integer);
var ES, AS: String;
begin
  if Expected <> Actual then
  begin
    Str(Expected, ES);
    Str(Actual,   AS);
    Fail(Desc + ' -- expected ' + ES + ', got ' + AS);
  end;
end;

procedure AssertEqualChar(const Desc: String; Expected, Actual: Char);
begin
  if Expected <> Actual then
    Fail(Desc + ' -- expected ''' + Expected + ''', got ''' + Actual + '''');
end;

procedure AssertEqualStr(const Desc: String;
                         const Expected, Actual: String);
begin
  if Expected <> Actual then
    Fail(Desc + ' -- expected "' + Expected + '", got "' + Actual + '"');
end;

function IntStr(N: Integer): String;
var S: String;
begin
  Str(N, S);
  IntStr := S;
end;

function RunTests: Integer;
var
  I         : Integer;
  FailCount : Integer;
begin
  FailCount := 0;

  Assign(TapOut, TAP_FILE);
  Rewrite(TapOut);

  TapWrite('1..' + IntStr(TestCount));

  for I := 1 to TestCount do
  begin
    CurrentFailed := False;
    Tests[I].Proc;
    if CurrentFailed then
    begin
      TapWrite('not ok ' + IntStr(I) + ' ' + Tests[I].Name);
      Inc(FailCount);
    end
    else
      TapWrite('ok ' + IntStr(I) + ' ' + Tests[I].Name);
  end;

  TapWrite('# ' + IntStr(TestCount - FailCount) + ' passed, ' +
           IntStr(FailCount) + ' failed of ' + IntStr(TestCount));

  Close(TapOut);
  RunTests := FailCount;
end;

begin
  TestCount := 0;
end.
