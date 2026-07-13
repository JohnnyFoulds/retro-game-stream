{ This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
  Source: https://github.com/JohnnyFoulds/retro-game-stream }

unit Screen;

interface

uses Crt, World;

const
  OFS_X = 20;
  OFS_Y = 1;

procedure InitScreen;
procedure EraseTile(WX, WY: Integer);
procedure DrawWorld;
procedure DrawEntities;
procedure DrawStatus;
procedure ShowTitle;
procedure ShowOverlay(Line1, Line2: String);

implementation

function IntToStr(N: Integer): String;
var S: String;
begin
  Str(N, S);
  IntToStr := S;
end;

procedure PutAt(WX, WY: Integer; Ch: Char; Col: Byte);
begin
  GotoXY(OFS_X + WX, OFS_Y + WY);
  TextColor(Col);
  Write(Ch);
end;

procedure InitScreen;
begin
  ClrScr;
  TextBackground(Black);
end;

procedure EraseTile(WX, WY: Integer);
var Ch: Char; Col: Byte;
begin
  Ch := World.TileAt(WX, WY);
  case Ch of
    CH_PLATFORM : Col := LightGray;
    CH_LADDER   : Col := Yellow;
    CH_DOLLAR   : Col := LightGreen;
    CH_EXIT     : Col := LightCyan;
  else              Col := Black;
  end;
  PutAt(WX, WY, Ch, Col);
end;

procedure DrawWorld;
var R, C: Integer;
begin
  for R := 1 to WORLD_H do
    for C := 1 to WORLD_W do
      EraseTile(C, R);
end;

procedure DrawEntities;
var I: Integer;
begin
  TextBackground(Black);
  for I := 1 to MAX_ENEMIES do
    PutAt(Enemies[I].X, Enemies[I].Y, 'M', LightRed);
  PutAt(Player.X, Player.Y, '@', White);
end;

procedure DrawStatus;
begin
  GotoXY(1, OFS_Y + WORLD_H + 1);
  TextColor(LightGray);
  TextBackground(Black);
  ClrEol;
  Write(' Score:', Player.Score:4,
        '   $:', Dollars:2, ' left',
        '   Lives:', Player.Lives,
        '   Arrows/WASD=move  Q=quit');
end;

procedure ShowTitle;
begin
  ClrScr;
  TextBackground(Black);
  TextColor(LightCyan);
  GotoXY(20, 5);  Write('THE CORPORATE LADDER');
  GotoXY(15, 6);  Write('Avoid Middle Management!');
  TextColor(LightGray);
  GotoXY(12,  9); Write('@ = You      H = Ladder   = = Platform');
  GotoXY(12, 10); Write('$ = Dollar   M = Manager  E = Exit');
  GotoXY(10, 12); Write('GOAL: Collect all $ then reach E at the top');
  GotoXY(10, 13); Write('CONTROLS: Arrow keys or WASD   Q = quit');
  TextColor(Yellow);
  GotoXY(21, 16); Write('Press any key to start');
  ReadKey;
end;

procedure ShowOverlay(Line1, Line2: String);
var CX: Integer;
begin
  TextBackground(Blue);
  TextColor(Yellow);
  CX := (80 - Length(Line1) - 2) div 2 + 1;
  GotoXY(CX, 11); Write(' ', Line1, ' ');
  CX := (80 - Length(Line2) - 2) div 2 + 1;
  GotoXY(CX, 12); Write(' ', Line2, ' ');
  TextBackground(Black);
end;

end.
