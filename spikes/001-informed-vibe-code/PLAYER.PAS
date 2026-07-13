{ This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
  Source: https://github.com/JohnnyFoulds/retro-game-stream }

unit Player;

interface

uses World, Screen;

procedure MovePlayer(DX, DY: Integer);
procedure ApplyGravity;

implementation

procedure MovePlayer(DX, DY: Integer);
var NX, NY: Integer;
begin
  NX := World.Player.X + DX;
  NY := World.Player.Y + DY;

  if not InBounds(NX, NY)   then Exit;
  if not IsPassable(NX, NY) then Exit;

  { Vertical: must be on a ladder to climb up, or entering a ladder to go down }
  if (DY < 0) and not IsLadder(World.Player.X, World.Player.Y) then Exit;
  if (DY > 0) and not IsLadder(World.Player.X, NY)
              and not IsLadder(World.Player.X, World.Player.Y)  then Exit;

  { Horizontal: must be supported }
  if (DX <> 0) and not IsSupported(World.Player.X, World.Player.Y) then Exit;

  EraseTile(World.Player.X, World.Player.Y);
  World.Player.X := NX;
  World.Player.Y := NY;

  { Collect dollar }
  if TileAt(NX, NY) = CH_DOLLAR then
  begin
    SetTile(NX, NY, CH_EMPTY);
    Inc(World.Player.Score, 10);
    Dec(Dollars);
  end;

  { Exit condition checked in Game }
end;

procedure ApplyGravity;
begin
  if IsLadder(World.Player.X, World.Player.Y)         then Exit;
  if not InBounds(World.Player.X, World.Player.Y + 1) then Exit;
  if IsSolid(World.Player.X, World.Player.Y + 1)      then Exit;
  EraseTile(World.Player.X, World.Player.Y);
  World.Player.Y := World.Player.Y + 1;
end;

end.
