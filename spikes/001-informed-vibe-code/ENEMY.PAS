{ This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
  Source: https://github.com/JohnnyFoulds/retro-game-stream }

unit Enemy;

interface

uses World;

procedure MoveEnemies;
procedure CheckCollision;

implementation

procedure MoveEnemies;
var I, NX: Integer;
begin
  for I := 1 to MAX_ENEMIES do
  begin
    NX := Enemies[I].X + Enemies[I].DX;
    if not InBounds(NX, Enemies[I].Y)
       or IsSolid(NX, Enemies[I].Y)
       or (not IsSolid(NX, Enemies[I].Y + 1)
           and not IsLadder(NX, Enemies[I].Y)) then
      Enemies[I].DX := -Enemies[I].DX
    else
      Enemies[I].X := NX;
  end;
end;

procedure CheckCollision;
var I: Integer;
begin
  for I := 1 to MAX_ENEMIES do
    if (Enemies[I].X = Player.X) and (Enemies[I].Y = Player.Y) then
      GameOver := True;
end;

end.
