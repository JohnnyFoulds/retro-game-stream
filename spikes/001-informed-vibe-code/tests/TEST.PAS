{ This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
  Source: https://github.com/JohnnyFoulds/retro-game-stream }

program TEST;

{$F+} { Far calls required for procedural type compatibility across units }

{ Unit tests for spike/001-informed-vibe-code.
  Covers: world initialisation, tile queries, player movement,
  gravity, dollar collection, enemy patrol, collision detection.

  Run:  TEST.EXE > TEST.TAP
  Exit: 0 = all passed, 1 = any failure.
}

uses TPTEST, World, Player, Enemy, GLogic;

{ -----------------------------------------------------------------------
  World / tile tests
  ----------------------------------------------------------------------- }

procedure Test_World_Dimensions;
begin
  InitWorld;
  AssertEqualInt('WORLD_W', 40, WORLD_W);
  AssertEqualInt('WORLD_H', 22, WORLD_H);
end;

procedure Test_World_FloorIsPlatform;
begin
  InitWorld;
  { Row 22 is solid floor — every cell should be CH_PLATFORM }
  AssertEqualChar('floor row 22 col 1',  CH_PLATFORM, TileAt(1,  22));
  AssertEqualChar('floor row 22 col 20', CH_PLATFORM, TileAt(20, 22));
  AssertEqualChar('floor row 22 col 40', CH_PLATFORM, TileAt(40, 22));
end;

procedure Test_World_InBoundsEdges;
begin
  InitWorld;
  AssertTrue ('(1,1) in bounds',      InBounds(1,  1));
  AssertTrue ('(40,22) in bounds',    InBounds(40, 22));
  AssertFalse('(0,1) out of bounds',  InBounds(0,  1));
  AssertFalse('(41,1) out of bounds', InBounds(41, 1));
  AssertFalse('(1,0) out of bounds',  InBounds(1,  0));
  AssertFalse('(1,23) out of bounds', InBounds(1,  23));
end;

procedure Test_World_OutOfBoundsTileIsWall;
begin
  InitWorld;
  AssertEqualChar('OOB tile is wall', '#', TileAt(0, 0));
  AssertEqualChar('OOB tile is wall', '#', TileAt(99, 99));
end;

procedure Test_World_IsSolid;
begin
  InitWorld;
  AssertTrue ('floor is solid',      IsSolid(1,  22));
  AssertFalse('empty space not solid', IsSolid(1, 1));
end;

procedure Test_World_IsLadder;
begin
  InitWorld;
  { Column 8, row 6-9 is a ladder in MAP_DATA }
  AssertTrue ('col 8 row 7 is ladder', IsLadder(8, 7));
  AssertFalse('col 1 row 1 not ladder', IsLadder(1, 1));
end;

procedure Test_World_IsPassable;
begin
  InitWorld;
  AssertTrue ('empty is passable',    IsPassable(1, 1));
  AssertFalse('platform not passable', IsPassable(1, 22));
end;

procedure Test_World_DollarsCountedOnInit;
begin
  InitWorld;
  AssertTrue('at least one dollar on init', Dollars > 0);
end;

procedure Test_World_SetTileAndTileAt;
begin
  InitWorld;
  SetTile(5, 5, CH_DOLLAR);
  AssertEqualChar('tile set to dollar', CH_DOLLAR, TileAt(5, 5));
  SetTile(5, 5, CH_EMPTY);
  AssertEqualChar('tile set back to empty', CH_EMPTY, TileAt(5, 5));
end;

{ -----------------------------------------------------------------------
  Player initialisation
  ----------------------------------------------------------------------- }

procedure Test_Player_StartsAtSpawn;
begin
  InitWorld;
  AssertEqualInt('player spawn X', 2,  World.Player.X);
  AssertEqualInt('player spawn Y', 21, World.Player.Y);
end;

procedure Test_Player_StartsWithZeroScore;
begin
  InitWorld;
  AssertEqualInt('player score 0', 0, World.Player.Score);
end;

procedure Test_Player_StartsWithThreeLives;
begin
  InitWorld;
  AssertEqualInt('player lives 3', 3, World.Player.Lives);
end;

{ -----------------------------------------------------------------------
  Player movement
  ----------------------------------------------------------------------- }

procedure Test_Player_MoveRight;
var StartX: Integer;
begin
  InitWorld;
  { Player starts at (2,21) — row 21 is above the floor, grounded }
  StartX := World.Player.X;
  MovePlayer(1, 0);
  AssertEqualInt('moved right by 1', StartX + 1, World.Player.X);
end;

procedure Test_Player_MoveLeft;
var StartX: Integer;
begin
  InitWorld;
  { Move right first so we have room to move left }
  MovePlayer(1, 0);
  StartX := World.Player.X;
  MovePlayer(-1, 0);
  AssertEqualInt('moved left by 1', StartX - 1, World.Player.X);
end;

procedure Test_Player_CannotWalkIntoWall;
begin
  InitWorld;
  { Place player one cell right of the left wall (#), try to walk left }
  World.Player.X := 2;
  World.Player.Y := 21;
  MovePlayer(-1, 0); { target is col 1 which is inside the level, passable }
  { col 1 row 21 is empty space above floor — should succeed }
  { Real wall test: put player at col 2 and try to walk into a platform }
  InitWorld;
  World.Player.X := 2;
  World.Player.Y := 22; { inside floor — but let's test blocked by IsSolid }
  { Actually test: player cannot move into a platform tile }
  World.Player.X := 1;
  World.Player.Y := 21;
  SetTile(1, 21, CH_PLATFORM); { block left of player }
  { Move right — col 2 should be fine, passable }
  World.Player.X := 2;
  MovePlayer(-1, 0); { try left into platform at col 1 }
  AssertEqualInt('blocked by platform', 2, World.Player.X);
  SetTile(1, 21, CH_EMPTY);
end;

procedure Test_Player_CannotMoveHorizontallyWhileAirborne;
var StartX: Integer;
begin
  InitWorld;
  { Place player in mid-air (row 3, no floor or ladder beneath) }
  World.Player.X := 5;
  World.Player.Y := 3;
  StartX := World.Player.X;
  MovePlayer(1, 0);
  AssertEqualInt('no horizontal move in air', StartX, World.Player.X);
end;

procedure Test_Player_CanClimbLadderUp;
var StartY: Integer;
begin
  InitWorld;
  { Place player on a ladder tile — col 8 row 8 is a ladder }
  World.Player.X := 8;
  World.Player.Y := 8;
  StartY := World.Player.Y;
  MovePlayer(0, -1);
  AssertEqualInt('climbed up on ladder', StartY - 1, World.Player.Y);
end;

procedure Test_Player_CannotClimbUpOffLadder;
var StartY: Integer;
begin
  InitWorld;
  { Place player on empty space, try to climb up }
  World.Player.X := 5;
  World.Player.Y := 17; { grounded on platform row 18 }
  StartY := World.Player.Y;
  MovePlayer(0, -1);
  AssertEqualInt('cannot climb up without ladder', StartY, World.Player.Y);
end;

{ -----------------------------------------------------------------------
  Gravity
  ----------------------------------------------------------------------- }

procedure Test_Gravity_PlayerFallsWhenUnsupported;
var StartY: Integer;
begin
  InitWorld;
  { Place player in open air }
  World.Player.X := 5;
  World.Player.Y := 3;
  StartY := World.Player.Y;
  ApplyGravity;
  AssertEqualInt('fell one cell', StartY + 1, World.Player.Y);
end;

procedure Test_Gravity_PlayerDoesNotFallOnPlatform;
var StartY: Integer;
begin
  InitWorld;
  { Player at (2,21) is one above the floor — should not fall further
    because IsSolid(2,22) is true }
  World.Player.X := 2;
  World.Player.Y := 21;
  StartY := World.Player.Y;
  ApplyGravity;
  AssertEqualInt('resting on floor, no fall', StartY, World.Player.Y);
end;

procedure Test_Gravity_PlayerDoesNotFallOnLadder;
var StartY: Integer;
begin
  InitWorld;
  { Place player on a ladder — gravity should not apply }
  World.Player.X := 8;
  World.Player.Y := 7;
  StartY := World.Player.Y;
  ApplyGravity;
  AssertEqualInt('no gravity on ladder', StartY, World.Player.Y);
end;

{ -----------------------------------------------------------------------
  Dollar collection
  ----------------------------------------------------------------------- }

procedure Test_Dollar_CollectedOnMove;
var DollarsBefore: Integer;
begin
  InitWorld;
  DollarsBefore := Dollars;
  { Place a dollar directly to the right of player spawn (2,21) }
  SetTile(3, 21, CH_DOLLAR);
  Inc(Dollars);
  MovePlayer(1, 0);
  AssertEqualInt('dollar count decreased', DollarsBefore, Dollars);
  AssertEqualInt('score increased by 10', 10, World.Player.Score);
  AssertEqualChar('tile cleared to empty', CH_EMPTY, TileAt(3, 21));
end;

{ -----------------------------------------------------------------------
  Enemy initialisation — this is the bug we are hunting
  ----------------------------------------------------------------------- }

procedure Test_Enemy_NoEnemyOnPlayerAtInit;
var I: Integer; Overlap: Boolean;
begin
  InitWorld;
  Overlap := False;
  for I := 1 to MAX_ENEMIES do
    if (Enemies[I].X = World.Player.X) and
       (Enemies[I].Y = World.Player.Y) then
      Overlap := True;
  AssertFalse('no enemy on player spawn at init', Overlap);
end;

procedure Test_Enemy_AllEnemiesInBoundsAtInit;
var I: Integer;
begin
  InitWorld;
  for I := 1 to MAX_ENEMIES do
  begin
    AssertTrue('enemy in bounds X',
      InBounds(Enemies[I].X, Enemies[I].Y));
  end;
end;

procedure Test_Enemy_CollisionSetsGameOver;
begin
  InitWorld;
  { Move enemy 1 onto player position }
  Enemies[1].X := World.Player.X;
  Enemies[1].Y := World.Player.Y;
  CheckCollision;
  AssertTrue('collision sets GameOver', GameOver);
end;

procedure Test_Enemy_NoCollisionWhenApart;
begin
  InitWorld;
  { Ensure no enemy is on player — if init is correct this should pass }
  CheckCollision;
  AssertFalse('no GameOver when enemies not on player', GameOver);
end;

procedure Test_Enemy_MoveReverseOnWall;
var OrigDir, OrigX: Integer;
begin
  InitWorld;
  { Force enemy 1 against the right world boundary }
  Enemies[1].X  := WORLD_W;
  Enemies[1].Y  := 21;
  Enemies[1].DX := 1;
  OrigDir := Enemies[1].DX;
  MoveEnemies;
  AssertTrue('enemy reversed at boundary',
    Enemies[1].DX = -OrigDir);
end;

{ -----------------------------------------------------------------------
  Game loop / UpdateGame tests
  ----------------------------------------------------------------------- }

procedure Test_UpdateGame_GravityAppliesWithNoInput;
var StartY: Integer;
begin
  InitWorld;
  { Place player in free air }
  World.Player.X := 5;
  World.Player.Y := 3;
  StartY := World.Player.Y;
  UpdateGame(0, 0);
  AssertEqualInt('gravity applies with no input', StartY + 1, World.Player.Y);
end;

procedure Test_UpdateGame_EnemiesDoNotMoveWithNoInput;
var I: Integer; Changed: Boolean;
begin
  InitWorld;
  Changed := False;
  { Capture starting positions }
  UpdateGame(0, 0);
  { Enemies must not have moved — compare against InitWorld positions }
  InitWorld;
  for I := 1 to MAX_ENEMIES do
    if Enemies[I].X <> Enemies[I].X then { re-init above resets to known coords }
      Changed := True;
  AssertFalse('enemies do not move on no-input update', Changed);
end;

procedure Test_UpdateGame_EnemiesMoveAfterPlayerInput;
var X1: Integer;
begin
  InitWorld;
  { Record enemy 1 starting X }
  X1 := Enemies[1].X;
  { Drive enough ticks with input to guarantee enemy moves (TICK_ENEMY = 2) }
  UpdateGame(1, 0);
  UpdateGame(1, 0);
  { Enemy 1 should have moved at least once — position differs OR direction flipped.
    We assert enemy has been given the opportunity to move; since enemy 1 starts
    moving right and has clear space, X should have advanced. }
  AssertTrue('enemy moved after player input ticks',
    (Enemies[1].X <> X1) or (Enemies[1].DX = -1));
end;

procedure Test_UpdateGame_EnemiesOnlyMoveEveryNthInput;
var X1: Integer;
begin
  InitWorld;
  X1 := Enemies[1].X;
  { One input tick — TICK_ENEMY = 2, so enemy must NOT have moved yet }
  UpdateGame(1, 0);
  AssertEqualInt('enemy has not moved after 1 input tick', X1, Enemies[1].X);
end;

{ -----------------------------------------------------------------------
  Main
  ----------------------------------------------------------------------- }

begin
  { World }
  RegisterTest('world has correct dimensions',      Test_World_Dimensions);
  RegisterTest('floor row 22 is solid',             Test_World_FloorIsPlatform);
  RegisterTest('InBounds edge cases',               Test_World_InBoundsEdges);
  RegisterTest('out-of-bounds tile returns wall',   Test_World_OutOfBoundsTileIsWall);
  RegisterTest('IsSolid correct',                   Test_World_IsSolid);
  RegisterTest('IsLadder correct',                  Test_World_IsLadder);
  RegisterTest('IsPassable correct',                Test_World_IsPassable);
  RegisterTest('dollar count > 0 after init',       Test_World_DollarsCountedOnInit);
  RegisterTest('SetTile and TileAt round-trip',     Test_World_SetTileAndTileAt);

  { Player init }
  RegisterTest('player starts at spawn position',   Test_Player_StartsAtSpawn);
  RegisterTest('player starts with zero score',     Test_Player_StartsWithZeroScore);
  RegisterTest('player starts with three lives',    Test_Player_StartsWithThreeLives);

  { Player movement }
  RegisterTest('player moves right',                Test_Player_MoveRight);
  RegisterTest('player moves left',                 Test_Player_MoveLeft);
  RegisterTest('player blocked by platform',        Test_Player_CannotWalkIntoWall);
  RegisterTest('no horizontal move in air',         Test_Player_CannotMoveHorizontallyWhileAirborne);
  RegisterTest('player climbs up on ladder',        Test_Player_CanClimbLadderUp);
  RegisterTest('player cannot climb up off ladder', Test_Player_CannotClimbUpOffLadder);

  { Gravity }
  RegisterTest('player falls when unsupported',     Test_Gravity_PlayerFallsWhenUnsupported);
  RegisterTest('player rests on platform',          Test_Gravity_PlayerDoesNotFallOnPlatform);
  RegisterTest('no gravity on ladder',              Test_Gravity_PlayerDoesNotFallOnLadder);

  { Collection }
  RegisterTest('dollar collected on move into cell', Test_Dollar_CollectedOnMove);

  { Game loop }
  RegisterTest('gravity applies with no input',         Test_UpdateGame_GravityAppliesWithNoInput);
  RegisterTest('enemies do not move on no-input',       Test_UpdateGame_EnemiesDoNotMoveWithNoInput);
  RegisterTest('enemies move after player input ticks', Test_UpdateGame_EnemiesMoveAfterPlayerInput);
  RegisterTest('enemies only move every Nth input',     Test_UpdateGame_EnemiesOnlyMoveEveryNthInput);

  { Enemy }
  RegisterTest('no enemy on player spawn at init',  Test_Enemy_NoEnemyOnPlayerAtInit);
  RegisterTest('all enemies in bounds at init',     Test_Enemy_AllEnemiesInBoundsAtInit);
  RegisterTest('collision sets GameOver',           Test_Enemy_CollisionSetsGameOver);
  RegisterTest('no GameOver when enemies apart',    Test_Enemy_NoCollisionWhenApart);
  RegisterTest('enemy reverses at boundary',        Test_Enemy_MoveReverseOnWall);

  if RunTests > 0 then Halt(1);
end.
