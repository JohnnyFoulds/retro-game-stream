program CorporateLadder;

uses Crt;

{ -----------------------------------------------------------------------
  THE CORPORATE LADDER: Avoid Middle Management
  Turbo Pascal 7 / DOS text-mode  80x25

  Level structure (Y increases downward):
    Row 22: floor (full platform)
    Row 21: walking level 1 (above floor)      <- player spawns here
    Row 18: upper platform with gap at col 28
    Row 17: walking level 2
    Row 14: platform with gap at col 12
    Row 13: walking level 3
    Row 10: platform with gap at col 32
    Row  9: walking level 4
    Row  6: platform with gap at col 8
    Row  5: walking level 5 (top)              <- exit here
    Rows 1-4: open sky

  Ladder spans: for each adjacent level pair, a ladder at one column
  spans from the lower walking row UP THROUGH the platform row to the
  upper walking row.  The platform has a tile gap at the ladder column.
  The ladder tile at the upper walking row lets the player exit sideways.
  ----------------------------------------------------------------------- }

const
  WORLD_W = 40;
  WORLD_H = 22;

  TILE_EMPTY    = ' ';
  TILE_PLATFORM = '=';
  TILE_LADDER   = 'H';
  TILE_DOLLAR   = '$';
  TILE_EXIT     = 'E';
  TILE_PLAYER   = '@';
  TILE_ENEMY    = 'M';

  COL_PLATFORM  = LightGray;
  COL_LADDER    = Yellow;
  COL_DOLLAR    = LightGreen;
  COL_EXIT      = LightCyan;
  COL_PLAYER    = White;
  COL_ENEMY     = LightRed;
  COL_STATUS    = LightGray;

  MAX_ENEMIES   = 4;
  TICK_ENEMY    = 6;    { enemy moves every N player-action ticks }

  { Screen offset: 40-wide map centred on 80-col screen }
  OFS_X = 20;   { screen col = OFS_X + world_x }
  OFS_Y = 0;    { screen row = OFS_Y + world_y }

  { -------------------------------------------------------------------
    MAP  (40 cols x 22 rows, 1-indexed)
    Ladder at col 28, rows 17-21  connects walking rows 21 and 17
    Ladder at col 12, rows 13-17  connects walking rows 17 and 13
    Ladder at col 32, rows  9-13  connects walking rows 13 and  9
    Ladder at col  8, rows  5- 9  connects walking rows  9 and  5
    ------------------------------------------------------------------- }
  MAP : array[1..WORLD_H, 1..WORLD_W] of Char = (
  { row 1  sky }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 2  sky }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 3  sky }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 4  sky }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 5  walking level 5  (top)   H@8  $@25  E@38 }
  (' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','$',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','E',' ',' '),
  { row 6  platform  gap@8          =1-7  H@8  =9-40 }
  ('=','=','=','=','=','=','=','H','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','='),
  { row 7  ladder col 8 }
  (' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 8  ladder col 8 }
  (' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 9  walking level 4          H@8  $@10  H@32 }
  (' ',' ',' ',' ',' ',' ',' ','H',' ','$',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 10 platform  gap@32         =1-31  H@32  =33-40 }
  ('=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','H','=','=','=','=','=','=','=','='),
  { row 11 ladder col 32 }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 12 ladder col 32 }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 13 walking level 3          H@12  H@32  $@35 }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ','$',' ',' ',' ',' ',' '),
  { row 14 platform  gap@12         =1-11  H@12  =13-40 }
  ('=','=','=','=','=','=','=','=','=','=','=','H','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','='),
  { row 15 ladder col 12 }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 16 ladder col 12 }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 17 walking level 2          $@5  H@12  H@28 }
  (' ',' ',' ',' ','$',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 18 platform  gap@28         =1-27  H@28  =29-40 }
  ('=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','H','=','=','=','=','=','=','=','=','=','=','=','='),
  { row 19 ladder col 28 }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 20 ladder col 28 }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 21 walking level 1  (ground)  $@20  H@28 }
  (' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','$',' ',' ',' ',' ',' ',' ',' ','H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
  { row 22 floor (full) }
  ('=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=','=')
  );

type
  TEntity = record
    X, Y : Integer;
  end;

var
  World    : array[1..WORLD_H, 1..WORLD_W] of Char;
  Player   : TEntity;
  Enemies  : array[1..MAX_ENEMIES] of TEntity;
  Score    : Integer;
  Dollars  : Integer;
  GameOver : Boolean;
  Won      : Boolean;
  Tick     : Integer;
  Key      : Char;
  dx, dy   : Integer;
  i        : Integer;

{ -----------------------------------------------------------------------
  Helpers
  ----------------------------------------------------------------------- }

function IntToStr(n : Integer) : String;
var s : String;
begin
  Str(n, s);
  IntToStr := s;
end;

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
  World init & rendering
  ----------------------------------------------------------------------- }

procedure InitWorld;
var r, c : Integer;
begin
  Dollars := 0;
  for r := 1 to WORLD_H do
    for c := 1 to WORLD_W do
    begin
      World[r][c] := MAP[r][c];
      if MAP[r][c] = TILE_DOLLAR then Inc(Dollars);
    end;

  Player.X := 2;  Player.Y := 21;

  Enemies[1].X := 15; Enemies[1].Y := 21;
  Enemies[2].X := 30; Enemies[2].Y := 17;
  Enemies[3].X :=  5; Enemies[3].Y := 13;
  Enemies[4].X := 20; Enemies[4].Y :=  9;

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

procedure RestoreTile(e : TEntity);
begin
  DrawTile(e.X, e.Y);
end;

procedure DrawPlayer;
begin
  TextBackground(Black);
  PutAt(Player.X, Player.Y, TILE_PLAYER, COL_PLAYER);
end;

procedure DrawEnemies;
var i : Integer;
begin
  TextBackground(Black);
  for i := 1 to MAX_ENEMIES do
    PutAt(Enemies[i].X, Enemies[i].Y, TILE_ENEMY, COL_ENEMY);
end;

procedure DrawStatus;
begin
  GotoXY(1, 24);
  TextColor(COL_STATUS);
  TextBackground(Black);
  ClrEol;
  Write(' Score:', Score:4,
        '   $:', Dollars:2, ' left',
        '   Arrows/WASD=move  Q=quit');
end;

{ -----------------------------------------------------------------------
  Player movement + gravity
  ----------------------------------------------------------------------- }

procedure MovePlayer(ddx, ddy : Integer);
var nx, ny : Integer;
begin
  nx := Player.X + ddx;
  ny := Player.Y + ddy;

  if not InBounds(nx, ny) then Exit;
  if IsSolid(nx, ny)      then Exit;

  { Up: only when standing on a ladder }
  if (ddy < 0) and not IsLadder(Player.X, Player.Y) then Exit;

  { Horizontal: only when grounded or on a ladder }
  if (ddx <> 0) and not IsGrounded(Player.X, Player.Y) then Exit;

  RestoreTile(Player);
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
  if IsLadder(Player.X, Player.Y)     then Exit;
  if IsSolid(Player.X, Player.Y + 1)  then Exit;
  if not InBounds(Player.X, Player.Y + 1) then Exit;
  RestoreTile(Player);
  Player.Y := Player.Y + 1;
end;

{ -----------------------------------------------------------------------
  Enemy AI: simple left-right patrol; stays on its platform
  ----------------------------------------------------------------------- }

const
  EDir : array[1..MAX_ENEMIES] of Integer = (1, -1, 1, -1);

procedure MoveEnemies;
var
  i, nx : Integer;
begin
  for i := 1 to MAX_ENEMIES do
  begin
    nx := Enemies[i].X + EDir[i];
    if not InBounds(nx, Enemies[i].Y)
       or IsSolid(nx, Enemies[i].Y)
       or (not IsSolid(nx, Enemies[i].Y + 1)
           and not IsLadder(nx, Enemies[i].Y)) then
      EDir[i] := -EDir[i]
    else
    begin
      RestoreTile(Enemies[i]);
      Enemies[i].X := nx;
    end;
  end;
end;

procedure CheckCollisions;
var i : Integer;
begin
  for i := 1 to MAX_ENEMIES do
    if (Enemies[i].X = Player.X) and (Enemies[i].Y = Player.Y) then
      GameOver := True;
end;

{ -----------------------------------------------------------------------
  Overlays
  ----------------------------------------------------------------------- }

procedure ShowOverlay(line1, line2 : String);
var cx : Integer;
begin
  cx := (80 - Length(line1)) div 2 + 1;
  GotoXY(cx, 11); TextColor(Yellow); TextBackground(Blue);
  Write(' ', line1, ' ');
  cx := (80 - Length(line2)) div 2 + 1;
  GotoXY(cx, 12);
  Write(' ', line2, ' ');
  TextBackground(Black);
end;

procedure ShowTitle;
begin
  ClrScr;
  TextColor(LightCyan); TextBackground(Black);
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

{ -----------------------------------------------------------------------
  Main
  ----------------------------------------------------------------------- }

begin
  ShowTitle;
  ClrScr;
  TextBackground(Black);

  InitWorld;
  DrawWorld;
  DrawEnemies;
  DrawPlayer;
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
        if Tick mod TICK_ENEMY = 0 then
          MoveEnemies;

        CheckCollisions;
        DrawEnemies;
        DrawPlayer;
        DrawStatus;
      end;
    end
    else
    begin
      ApplyGravity;
      DrawEnemies;
      DrawPlayer;
      Delay(50);
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
