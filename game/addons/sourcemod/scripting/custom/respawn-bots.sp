#include <sourcemod>
#include <sdktools>
#include <adt_array>
#include <timers>

public Plugin:myinfo = {
  name            = "Respawn Bots",
  author          = "kriansa, rrrfffrrr",
  description     = "Handling bot respawn system",
  version         = "1.0.0",
  url             = "https://github.com/kriansa/insurgency-server"
};

/** 
 * Global variables
 */
Handle cvarEnable = INVALID_HANDLE;
Handle cvarRTime = INVALID_HANDLE;
Handle cvarDefaultPoint = INVALID_HANDLE;
Handle cvarAddPoint = INVALID_HANDLE;
Handle cvarDisplay = INVALID_HANDLE;
Handle cvarDisplayDelay = INVALID_HANDLE;

Handle SDK_RespawnFunctionAddress = INVALID_HANDLE;

int i_maxRespawn = 0;
int i_remainPoint = 0;

public void OnPluginStart()
{
  cvarEnable = CreateConVar("sm_botrespawn_enabled", "1", "Allow bot respawn during the match", FCVAR_NOTIFY);
  cvarRTime = CreateConVar("sm_botrespawn_delay", "1", "Time in seconds that the bots will respawn after being killed", FCVAR_NOTIFY);
  cvarDefaultPoint = CreateConVar("sm_botrespawn_start_amount", "5", "Fixed amount of bot respawns per objective", FCVAR_NOTIFY);
  cvarAddPoint = CreateConVar("sm_botrespawn_bots_per_player", "10", "The amount of bots respawns per new player per objective", FCVAR_NOTIFY);
  cvarDisplay = CreateConVar("sm_botrespawn_display", "1", "Display respawn point (0 = disable, 1 = enable)", FCVAR_NOTIFY);
  cvarDisplayDelay = CreateConVar("sm_botrespawn_display_delay", "1", "Delay in seconds on which the amount of bots will appear on the screen", FCVAR_NOTIFY);

  // Update the respawn amount when these CVARs change
  HookConVarChange(cvarDefaultPoint, CvarUpdate);
  HookConVarChange(cvarAddPoint, CvarUpdate);

  // Set the address of ForceRespawn from SDK to this variable so we can
  // use it later
  HookForceRespawnFunction(SDK_RespawnFunctionAddress);

  HookEvent("round_start", Event_Reset);
  HookEvent("round_begin", Event_Reset);
  HookEvent("player_death", Event_Death);
  HookEvent("controlpoint_captured", Event_Reset);
  HookEvent("object_destroyed", Event_Reset);

  ResetMaxRespawnPoints();
  ResetRespawnPoints();

  CreateTimer(GetConVarFloat(cvarDisplayDelay), DisplayPoint, _, TIMER_REPEAT);
}

/**
 * Hook the `ForceRespawn` function from SDK.
 *
 * Needs a customized `insurgency.games.txt` on the folder `gamedata`
 */
void HookForceRespawnFunction(Handle &respawn_callback) {
  Handle c_gameconfig = LoadGameConfigFile("insurgency.games");

  if (c_gameconfig == INVALID_HANDLE) {
    delete c_gameconfig;
    SetFailState("Fatal Error: Missing File \"insurgency.games\"!");
    return;
  }

  StartPrepSDKCall(SDKCall_Player);

  char game[40];
  GetGameFolderName(game, sizeof(game));

  if (StrEqual(game, "insurgency")) {
    PrepSDKCall_SetFromConf(c_gameconfig, SDKConf_Signature, "ForceRespawn");
  } else if (StrEqual(game, "doi")) {
    PrepSDKCall_SetFromConf(c_gameconfig, SDKConf_Virtual, "ForceRespawn");
  } else {
    SetFailState("Respawn: Game not supported!");
  }

  respawn_callback = EndPrepSDKCall();
  delete c_gameconfig;

  if (respawn_callback == INVALID_HANDLE) {
    SetFailState("Fatal Error: Unable to find ForceRespawn");
  }
}

/**
 * CVAR update callback
 */
void CvarUpdate(Handle cvar, const char[] oldvalue, const char[] newvalue) {
  ResetMaxRespawnPoints();
}


/**
 * Reset the counters.
 *
 * This is likely to be done at every round start or when the objective is
 * complete
 */
Action Event_Reset(Event event, const char[] name, bool dontBroadcast)
{
  if (!GetConVarBool(cvarEnable)) {
    return Plugin_Continue;
  }

  ResetMaxRespawnPoints();
  ResetRespawnPoints();

  return Plugin_Continue;
}

/**
 * Callback when a player dies
 */
Action Event_Death(Event event, const char[] name, bool dontBroadcast)
{
  if (!GetConVarBool(cvarEnable)) {
    return Plugin_Continue;
  }

  int client = GetClientOfUserId(GetEventInt(event, "userid"));

  if (!IsValidPlayer(client) || !IsFakeClient(client)) {
    return Plugin_Continue;
  }

  CreateTimer(GetConVarFloat(cvarRTime), Spawn, client);

  return Plugin_Continue;
}

/**
 * Callback when the configured time has passed and we need to respawn a dead 
 * bot
 */
Action Spawn(Handle timer, int client)
{
  RespawnBot(client);
}

/**
 * Display the message of total enemies alive to the user
 */
Action DisplayPoint(Handle timer) {
  if (GetConVarInt(cvarDisplay) == 0) {
    return;
  }

  char hint[20];

  Format(hint, sizeof(hint), "Insurgent : %i", GetTotalAliveEnemyCount());

  for (int i = 1; i < MaxClients + 1; i++) {
    if (IsValidPlayer(i) && !IsFakeClient(i)) {
      PrintHintText(i, hint);
    }
  }
}

/**
 * Reset the max amount of respawn points, to be used in the next round
 */
void ResetMaxRespawnPoints() {
  i_maxRespawn = GetConVarInt(cvarDefaultPoint) + 
    (GetTotalPlayerCount() * GetConVarInt(cvarAddPoint));

  if (i_remainPoint > i_maxRespawn) {
    ResetRespawnPoints();
  }
}

/**
 * Reset the amount of respawn bots. This is likely to be done at every new
 * round
 */
void ResetRespawnPoints(){
  i_remainPoint = i_maxRespawn;
}

/**
 * Checks if we can respawn a bot and then do it, subtracting from the amount
 * of respawn points left
 */
void RespawnBot(int clientId) {
  if (i_remainPoint > 0) {
    SDKCall(SDK_RespawnFunctionAddress, clientId);
    i_remainPoint--;
  }
}

/**
 * Get the total amount of alive bots + the amount of respawn points
 * This is the number that gets displayed to the players
 */
int GetTotalAliveEnemyCount() {
  int enemies = i_remainPoint + GetAliveBotsCount();
  return enemies < 0 ? 0 : enemies;
}

/**
 * Check whether the clientId is a valid player and is playing
 */
int IsValidPlayer(clientId)
{
  return clientId != 0 && IsClientConnected(clientId) && IsClientInGame(clientId);
}

/**
 * This will return the amount of real players
 */
int GetTotalPlayerCount()
{
  int clients = 0;
  for (int i = 1; i < MaxClients + 1; i++) {
    if (IsClientInGame(i) && !IsFakeClient(i)) {
      clients++;
    }
  }
  return clients;
}

/**
 * This will return the amount of alive bots in the game
 */
int GetAliveBotsCount()
{
  int clients = 0;
  for (int i = 1; i < MaxClients + 1; i++) {
    if (IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i)) {
      clients++;
    }
  }
  return clients;
}
