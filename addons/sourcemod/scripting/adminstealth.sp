#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#define VERSION "1.02"

int g_PlayerManager = -1;
bool g_IsStealthed[MAXPLAYERS+1] = {false, ...};

public Plugin myinfo =
{
  name = "Admin Stealth",
  author = "Invex | Byte",
  description = "Stealth's admins in various ways.",
  version = VERSION,
  url = "http://www.invexgaming.com.au"
};

public void OnPluginStart()
{
  //Commands
  RegAdminCmd("sm_stealth", Command_ToggleStealth, ADMFLAG_GENERIC, "Toggle scoreboard stealth status");
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
  for (int i = 1; i <= MaxClients; ++i) {
    if (IsClientInGame(i)) {
      if (GetClientTeam(i) == CS_TEAM_SPECTATOR && g_IsStealthed[i]) {
        SetEntProp(entity, Prop_Send, "m_bConnected", false, _, i);
      }
    }
  }
}

public Action Command_ToggleStealth(int client, int args)
{
  g_IsStealthed[client] = !g_IsStealthed[client];
  
  ReplyToCommand(client, "Your stealth is now: %s", g_IsStealthed[client] ? "ON" : "OFF");
  
  return Plugin_Handled;
}