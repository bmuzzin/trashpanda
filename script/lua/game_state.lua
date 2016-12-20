-- config parameters
LobbyWaitTime = 4      -- seconds before creating your own lobby
GameRequiredMembers = 2 -- number of players you need to make a game
--LANClientPort = 8056
LANLobbyPort = 8156

GameModes =
{
    lobby =0,           -- collecting players (GameState.game_mode)
    active = 1,         -- actively playingthe game
}


GameState = 
{
    game_mode = 0,          -- mode the game is currently in
}
