#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

int g_PlayerManager = -1;
bool g_IsStealthed[MAXPLAYERS+1] = {false, ...};

public Plugin myinfo =
{
  name = "Scoreboard Stealth",
  author = "Invex | Byte",
  description = "Hides a player from the CSGO scoreboard",
  version = "1.00",
  url = "http://www.invexgaming.com.au"
};

public void OnPluginStart()
{
  //Commands
  RegAdminCmd("sm_sbstealth", Command_ToggleStealth, ADMFLAG_GENERIC, "Toggle scoreboard stealth status");
}

public void OnMapStart()
{
  g_PlayerManager = FindEntityByClassname(-1, "cs_player_manager");

  if (IsValidEntity(g_PlayerManager)) {
    SDKHook(g_PlayerManager, SDKHook_ThinkPost, Hook_PlayerManagetThinkPost);
  }
}

public void OnClientPutInServer(int client)
{
  g_IsStealthed[client] = false;
}

public void Hook_PlayerManagetThinkPost(int entity)
{
  for (int i = 1; i < MaxClients; ++i) {
    if (IsClientConnected(i)) {
      if (GetClientTeam(i) == CS_TEAM_SPECTATOR && g_IsStealthed[i]) {
        SetEntProp(entity, Prop_Send, "m_bConnected", false, _, i);
      }
    }
  }
}

public Action Command_ToggleStealth(int client, int args)
{
  g_IsStealthed[client] = !g_IsStealthed[client];
  
  ReplyToCommand(client, "Your scoreboard stealth is now: %s", g_IsStealthed[client] ? "ON" : "OFF");
  
  return Plugin_Handled;
}