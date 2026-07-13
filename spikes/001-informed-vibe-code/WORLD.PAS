{ This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
  Source: https://github.com/JohnnyFoulds/retro-game-stream }

unit World;

interface

const
  WORLD_W     = 40;
  WORLD_H     = 22;
  MAX_ENEMIES = 4;

  CH_EMPTY    = ' ';
  CH_PLATFORM = '=';
  CH_LADDER   = 'H';
  CH_DOLLAR   = '$';
  CH_EXIT     = 'E';

type
  TTile = (ttEmpty, ttWall, ttPlatform, ttLadder, ttExit);

  TPlayer = record
    X, Y  : Integer;
    Score : Integer;
    Lives : Integer;
  end;

  TEnemy = record
    X, Y : Integer;
    DX   : Integer;
  end;

  TTheme = record
    EmptyChar    : Char;
    WallChar     : Char;
    PlatformChar : Char;
    LadderChar   : Char;
    ExitChar     : Char;
    PlayerChar   : Char;
    EnemyChar    : Char;
    MoneyChar    : Char;
  end;

var
  WorldMap : array[1..WORLD_H, 1..WORLD_W] of Char;
  Player   : TPlayer;
  Enemies  : array[1..MAX_ENEMIES] of TEnemy;
  Dollars  : Integer;
  GameOver : Boolean;
  Won      : Boolean;

procedure InitWorld;
function  InBounds(X, Y: Integer): Boolean;
function  TileAt(X, Y: Integer): Char;
procedure SetTile(X, Y: Integer; Ch: Char);
function  IsSolid(X, Y: Integer): Boolean;
function  IsLadder(X, Y: Integer): Boolean;
function  IsPassable(X, Y: Integer): Boolean;
function  IsSupported(X, Y: Integer): Boolean;

implementation

const
  MAP_DATA: array[1..WORLD_H] of String[40] = (
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
    '========================================'  { 22 floor    }
  );

procedure InitWorld;
var R, C: Integer;
begin
  Dollars := 0;
  for R := 1 to WORLD_H do
    for C := 1 to WORLD_W do
    begin
      WorldMap[R][C] := MAP_DATA[R][C];
      if MAP_DATA[R][C] = CH_DOLLAR then Inc(Dollars);
    end;

  Player.X     := 2;
  Player.Y     := 21;
  Player.Score := 0;
  Player.Lives := 3;

  Enemies[1].X :=  15; Enemies[1].Y := 21; Enemies[1].DX :=  1;
  Enemies[2].X :=  20; Enemies[2].Y := 17; Enemies[2].DX := -1;
  Enemies[3].X :=   5; Enemies[3].Y := 13; Enemies[3].DX :=  1;
  Enemies[4].X :=  20; Enemies[4].Y :=  9; Enemies[4].DX := -1;

  GameOver := False;
  Won      := False;
end;

function InBounds(X, Y: Integer): Boolean;
begin
  InBounds := (X >= 1) and (X <= WORLD_W) and (Y >= 1) and (Y <= WORLD_H);
end;

function TileAt(X, Y: Integer): Char;
begin
  if InBounds(X, Y) then TileAt := WorldMap[Y][X]
  else TileAt := '#';
end;

procedure SetTile(X, Y: Integer; Ch: Char);
begin
  if InBounds(X, Y) then WorldMap[Y][X] := Ch;
end;

function IsSolid(X, Y: Integer): Boolean;
begin
  IsSolid := TileAt(X, Y) = CH_PLATFORM;
end;

function IsLadder(X, Y: Integer): Boolean;
begin
  IsLadder := TileAt(X, Y) = CH_LADDER;
end;

function IsPassable(X, Y: Integer): Boolean;
var Ch: Char;
begin
  Ch := TileAt(X, Y);
  IsPassable := (Ch = CH_EMPTY)    or (Ch = CH_LADDER) or
                (Ch = CH_DOLLAR)   or (Ch = CH_EXIT);
end;

function IsSupported(X, Y: Integer): Boolean;
begin
  IsSupported := IsSolid(X, Y + 1) or IsLadder(X, Y);
end;

end.
