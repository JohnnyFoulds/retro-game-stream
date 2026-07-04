program CorporateLadder;

uses Crt;

{ -----------------------------------------------------------------------
  THE CORPORATE LADDER: Avoid Middle Management
  Turbo Pascal 7 / DOS text-mode  80x25

  Level (Y increases downward, col/row 1-based):
    Row 22: floor
    Row 21: level 1  $ col20   H col28
    Row 18: platform gap@28    H col28
    Row 17: level 2  $ col5    H col12  H col28
    Row 14: platform gap@12    H col12
    Row 13: level 3  H col12   H col32  $ col36
    Row 10: platform gap@32    H col32
    Row  9: level 4  H col8    $ col10  H col32
    Row  6: platform gap@8     H col8
    Row  5: level 5  H col8    $ col25  E col35
  ----------------------------------------------------------------------- }

const
  WORLD_W = 40;
  WORLD_H = 22;

  TILE_EMPTY    = ' ';
  TILE_PLATFORM = '=';
  TILE_LADDER   = 'H';
  TILE_DOLLAR   = '$';
  TILE_EXIT     = 'E';
  TILE_ENEMY    = 'M';

  COL_PLATFORM  = LightGray;
  COL_LADDER    = Yellow;
  COL_DOLLAR    = LightGreen;
  COL_EXIT      = LightCyan;
  COL_PLAYER    = White;
  COL_ENEMY     = LightRed;
  COL_STATUS    = LightGray;

  MAX_ENEMIES = 4;
  TICK_ENEMY  = 2;

  { Map centred: screen col = OFS_X + world_x, screen row = world_y }
  OFS_X = 20;
  OFS_Y = 0;

  { Each string is exactly 40 characters }
  MAP_DATA : array[1..WORLD_H] of String[40] = (
    '                                        ', {  1 }
    '                                        ', {  2 }
    '                                        ', {  3 }
    '                                        ', {  4 }
    '       H                $         E     ', {  5 level 5 }
    '=======H================================', {  6 platform }
    '       H                                ', {  7 }
    '       H                                ', {  8 }
    '       H $                     H        ', {  9 level 4 }
    '===============================H========', { 10 platform }
    '                               H        ', { 11 }
    '                               H        ', { 12 }
    '           H                   H   $    ', { 13 level 3 }
    '===========H============================', { 14 platform }
    '           H                            ', { 15 }
    '           H                            ', { 16 }
    '    $      H               H            ', { 17 level 2 }
    '===========================H============', { 18 platform }
    '                           H            ', { 19 }
    '                           H            ', { 20 }
    '                   $       H            ', { 21 level 1 }
    '========================================'  { 22 floor }
  );

type
  TEntity = record
    X, Y : Integer;
  end;

var
  World   : array[1..WORLD_H, 1..WORLD_W] of Char;
  Player  : TEntity;
  Enemies : array[1..MAX_ENEMIES] of TEntity;
  EDir    : array[1..MAX_ENEMIES] of Integer;
  Score   : Integer;
  Dollars : Integer;
  GameOver: Boolean;
  Won     : Boolean;
  Tick    : Integer;
  Key     : Char;
  dx, dy  : Integer;
  i       : Integer;

{ -----------------------------------------------------------------------
  Helpers
  ----------------------------------------------------------------------- }

function IntToStr(n : Integer) : String;
var s : String;
begin Str(n, s); IntToStr := s; end;

procedure PutAt(wx, wy : Integer; ch : Char; col : Byte);
begin
  GotoXY(OFS_X + wx, OFS_Y + wy);
  TextColor(col);
  Write(ch);
end;

function InBounds(x, y : Integer) : Boolean;
begin
  InBounds := (x >= 1) and (x <= WORLD_W) and (y >= 1) and (y <= WORLD_H);
end;

function IsSolid(x, y : Integer) : Boolean;
begin
  if not InBounds(x, y) then begin IsSolid := True; Exit end;
  IsSolid := (World[y][x] = TILE_PLATFORM);
end;

function IsLadder(x, y : Integer) : Boolean;
begin
  if not InBounds(x, y) then begin IsLadder := False; Exit end;
  IsLadder := (World[y][x] = TILE_LADDER);
end;

function IsGrounded(x, y : Integer) : Boolean;
begin
  IsGrounded := IsSolid(x, y + 1) or IsLadder(x, y);
end;

{ -----------------------------------------------------------------------
  World init & draw
  ----------------------------------------------------------------------- }

procedure InitWorld;
var r, c : Integer;
begin
  Dollars := 0;
  for r := 1 to WORLD_H do
    for c := 1 to WORLD_W do
    begin
      World[r][c] := MAP_DATA[r][c];
      if MAP_DATA[r][c] = TILE_DOLLAR then Inc(Dollars);
    end;

  Player.X := 2; Player.Y := 21;

  Enemies[1].X := 15; Enemies[1].Y := 21;
  Enemies[2].X := 20; Enemies[2].Y := 17;
  Enemies[3].X :=  5; Enemies[3].Y := 13;
  Enemies[4].X := 20; Enemies[4].Y :=  9;

  EDir[1] :=  1;
  EDir[2] := -1;
  EDir[3] :=  1;
  EDir[4] := -1;

  Score    := 0;
  GameOver := False;
  Won      := False;
  Tick     := 0;
end;

procedure DrawTile(wx, wy : Integer);
var ch  : Char;
    col : Byte;
begin
  ch := World[wy][wx];
  case ch of
    TILE_PLATFORM : col := COL_PLATFORM;
    TILE_LADDER   : col := COL_LADDER;
    TILE_DOLLAR   : col := COL_DOLLAR;
    TILE_EXIT     : col := COL_EXIT;
  else col := Black;
  end;
  PutAt(wx, wy, ch, col);
end;

procedure DrawWorld;
var r, c : Integer;
begin
  TextBackground(Black);
  for r := 1 to WORLD_H do
    for c := 1 to WORLD_W do
      DrawTile(c, r);
end;

procedure DrawEntities;
var j : Integer;
begin
  TextBackground(Black);
  for j := 1 to MAX_ENEMIES do
    PutAt(Enemies[j].X, Enemies[j].Y, TILE_ENEMY, COL_ENEMY);
  PutAt(Player.X, Player.Y, '@', COL_PLAYER);
end;

procedure DrawStatus;
begin
  GotoXY(1, 24);
  TextColor(COL_STATUS);
  TextBackground(Black);
  ClrEol;
  Write(' Score:', Score:4, '   $:', Dollars:2,
        ' left   Arrows/WASD=move  Q=quit');
end;

{ -----------------------------------------------------------------------
  Game logic
  ----------------------------------------------------------------------- }

procedure MovePlayer(ddx, ddy : Integer);
var nx, ny : Integer;
begin
  nx := Player.X + ddx;
  ny := Player.Y + ddy;
  if not InBounds(nx, ny)  then Exit;
  if IsSolid(nx, ny)       then Exit;
  { can only climb up when already on a ladder }
  if (ddy < 0) and not IsLadder(Player.X, Player.Y) then Exit;
  { can only walk sideways when grounded }
  if (ddx <> 0) and not IsGrounded(Player.X, Player.Y) then Exit;

  DrawTile(Player.X, Player.Y);
  Player.X := nx;
  Player.Y := ny;

  if World[ny][nx] = TILE_DOLLAR then
  begin
    World[ny][nx] := TILE_EMPTY;
    Inc(Score, 10);
    Dec(Dollars);
  end;
  if (World[ny][nx] = TILE_EXIT) and (Dollars = 0) then
    Won := True;
end;

procedure ApplyGravity;
begin
  if IsLadder(Player.X, Player.Y)    then Exit;
  if not InBounds(Player.X, Player.Y + 1) then Exit;
  if IsSolid(Player.X, Player.Y + 1) then Exit;
  DrawTile(Player.X, Player.Y);
  Player.Y := Player.Y + 1;
end;

procedure MoveEnemies;
var j, nx : Integer;
begin
  for j := 1 to MAX_ENEMIES do
  begin
    nx := Enemies[j].X + EDir[j];
    if not InBounds(nx, Enemies[j].Y)
       or IsSolid(nx, Enemies[j].Y)
       or (not IsSolid(nx, Enemies[j].Y + 1)
           and not IsLadder(nx, Enemies[j].Y)) then
      EDir[j] := -EDir[j]
    else
    begin
      DrawTile(Enemies[j].X, Enemies[j].Y);
      Enemies[j].X := nx;
    end;
  end;
end;

procedure CheckCollisions;
var j : Integer;
begin
  for j := 1 to MAX_ENEMIES do
    if (Enemies[j].X = Player.X) and (Enemies[j].Y = Player.Y) then
      GameOver := True;
end;

{ -----------------------------------------------------------------------
  Screens
  ----------------------------------------------------------------------- }

procedure ShowOverlay(line1, line2 : String);
var cx : Integer;
begin
  TextBackground(Blue);
  TextColor(Yellow);
  cx := (80 - Length(line1) - 2) div 2 + 1;
  GotoXY(cx, 11);
  Write(' ', line1, ' ');
  cx := (80 - Length(line2) - 2) div 2 + 1;
  GotoXY(cx, 12);
  Write(' ', line2, ' ');
  TextBackground(Black);
end;

procedure ShowTitle;
begin
  ClrScr;
  TextBackground(Black);
  TextColor(LightCyan);
  GotoXY(20, 5); Write('THE CORPORATE LADDER');
  GotoXY(15, 6); Write('Avoid Middle Management!');
  TextColor(LightGray);
  GotoXY(12,  9); Write('@ = You      H = Ladder   = = Platform');
  GotoXY(12, 10); Write('$ = Dollar   M = Manager  E = Exit');
  GotoXY(10, 12); Write('GOAL: Collect all $ then reach E at the top');
  GotoXY(10, 13); Write('CONTROLS: Arrow keys or WASD   Q = quit');
  TextColor(Yellow);
  GotoXY(21, 16); Write('Press any key to start');
  ReadKey;
end;

{ -----------------------------------------------------------------------
  Main
  ----------------------------------------------------------------------- }

begin
  ShowTitle;
  ClrScr;
  TextBackground(Black);

  InitWorld;
  DrawWorld;
  DrawEntities;
  DrawStatus;

  repeat
    dx := 0; dy := 0;

    if KeyPressed then
    begin
      Key := ReadKey;
      if Key = #0 then
      begin
        Key := ReadKey;
        case Key of
          #72 : dy := -1;
          #80 : dy :=  1;
          #75 : dx := -1;
          #77 : dx :=  1;
        end
      end
      else
        case UpCase(Key) of
          'W' : dy := -1;
          'S' : dy :=  1;
          'A' : dx := -1;
          'D' : dx :=  1;
          'Q' : GameOver := True;
        end;

      if (dx <> 0) or (dy <> 0) then
      begin
        MovePlayer(dx, dy);
        ApplyGravity;
        Inc(Tick);
        if Tick mod TICK_ENEMY = 0 then MoveEnemies;
        CheckCollisions;
        DrawEntities;
        DrawStatus;
      end;
    end
    else
    begin
      ApplyGravity;
      DrawEntities;
      Delay(20);
    end;

  until GameOver or Won;

  if Won then
  begin
    Inc(Score, 100);
    ShowOverlay('YOU MADE IT TO THE TOP!',
                'Score: ' + IntToStr(Score) + '  Press any key');
  end
  else
    ShowOverlay('MIDDLE MANAGEMENT GOT YOU.',
                'Press any key to quit');

  ReadKey;
  ClrScr;
  TextColor(LightGray);
  if Won then
    WriteLn('Congratulations! Final score: ', Score)
  else
    WriteLn('Game over. Final score: ', Score);
end.
