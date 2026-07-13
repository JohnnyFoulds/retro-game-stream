{ This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
  Source: https://github.com/JohnnyFoulds/retro-game-stream }

unit Game;

interface

procedure RunGame;

implementation

uses Crt, World, PlayerUnit, EnemyUnit, Screen;

const
  TICK_ENEMY = 2;

var
  Tick : Integer;
  Key  : Char;
  DX, DY : Integer;

procedure CheckExit;
begin
  if (World.TileAt(Player.X, Player.Y) = CH_EXIT) and (Dollars = 0) then
  begin
    Inc(Player.Score, 100);
    Won := True;
  end;
end;

procedure RunGame;
begin
  ShowTitle;
  InitScreen;
  InitWorld;
  DrawWorld;
  DrawEntities;
  DrawStatus;

  Tick := 0;

  repeat
    DX := 0; DY := 0;

    if KeyPressed then
    begin
      Key := ReadKey;
      if Key = #0 then
      begin
        Key := ReadKey;
        case Key of
          #72 : DY := -1;  { up    }
          #80 : DY :=  1;  { down  }
          #75 : DX := -1;  { left  }
          #77 : DX :=  1;  { right }
        end;
      end
      else
        case UpCase(Key) of
          'W' : DY := -1;
          'S' : DY :=  1;
          'A' : DX := -1;
          'D' : DX :=  1;
          'Q' : GameOver := True;
        end;
    end;

    { Update order: input → move → gravity → collect (in MovePlayer) →
      enemy → collision → exit check → render }
    if (DX <> 0) or (DY <> 0) then
      MovePlayer(DX, DY);

    ApplyGravity;

    Inc(Tick);
    if Tick mod TICK_ENEMY = 0 then MoveEnemies;

    CheckCollision;
    CheckExit;

    DrawEntities;
    DrawStatus;

    Delay(20);

  until GameOver or Won;

  if Won then
    ShowOverlay('YOU MADE IT TO THE TOP!',
                'Press any key')
  else
    ShowOverlay('MIDDLE MANAGEMENT GOT YOU.',
                'Press any key to quit');

  ReadKey;
end;

end.
