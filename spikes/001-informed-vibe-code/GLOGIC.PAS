{ This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
  Source: https://github.com/JohnnyFoulds/retro-game-stream }

unit GLogic;

{ Pure game-logic update step — no keyboard, no rendering, no Delay.
  Testable in isolation via TEST.PAS / TPTEST.PAS.

  UpdateGame(DX, DY) is the single entry point for one game tick:
    - Applies player movement (if DX/DY non-zero)
    - Applies gravity (always)
    - Advances enemy tick counter only when player provided input
    - Moves enemies on every TICK_ENEMY-th input tick
    - Checks collision and exit condition

  GAME.PAS calls UpdateGame from the main loop after reading keyboard input.
}

interface

uses World, Player, Enemy;

const
  TICK_ENEMY = 15;

var
  Tick: Integer;

procedure UpdateGame(DX, DY: Integer);
procedure CheckExit;

implementation

procedure CheckExit;
begin
  if (TileAt(World.Player.X, World.Player.Y) = CH_EXIT) and (Dollars = 0) then
  begin
    Inc(World.Player.Score, 100);
    Won := True;
  end;
end;

procedure UpdateGame(DX, DY: Integer);
begin
  { Move player if input given }
  if (DX <> 0) or (DY <> 0) then
    MovePlayer(DX, DY);

  { Gravity always applies }
  ApplyGravity;

  { Enemy ticker advances every loop iteration — real-time arcade cadence,
    independent of player input (Lode Runner lineage, not roguelike). }
  Inc(Tick);
  if Tick mod TICK_ENEMY = 0 then MoveEnemies;

  CheckCollision;
  CheckExit;
end;

begin
  Tick := 0;
end.
