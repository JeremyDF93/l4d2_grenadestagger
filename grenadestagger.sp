#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define NYXTOOLS_VERSION "1.0.0"
#define NYXTOOLS_AUTHOR "Kiwi, JeremyDF93"
#define NYXTOOLS_WEBSITE "https://praisethemoon.com/"

public Plugin myinfo = {
  name = "Grenade Stagger",
  author = NYXTOOLS_AUTHOR,
  description = "Stagger like you're drunk",
  version = NYXTOOLS_VERSION,
  url = NYXTOOLS_WEBSITE
};

/***
 *        ______                          
 *       / ____/___  __  ______ ___  _____
 *      / __/ / __ \/ / / / __ `__ \/ ___/
 *     / /___/ / / / /_/ / / / / / (__  ) 
 *    /_____/_/ /_/\__,_/_/ /_/ /_/____/  
 *                                        
 */

enum NyxSDK {
  Handle:SDK_ScriptStaggerPlayer,
}

enum NyxConVar {
  ConVar:ConVar_GrenadeLauncherDamage,
}

/***
 *       ______          _    __               
 *      / ____/___  ____| |  / /___ ___________
 *     / /   / __ \/ __ \ | / / __ `/ ___/ ___/
 *    / /___/ /_/ / / / / |/ / /_/ / /  (__  ) 
 *    \____/\____/_/ /_/|___/\__,_/_/  /____/  
 *                                             
 */

ConVar g_hConVars[NyxConVar];

/***
 *       ________      __          __    
 *      / ____/ /___  / /_  ____ _/ /____
 *     / / __/ / __ \/ __ \/ __ `/ / ___/
 *    / /_/ / / /_/ / /_/ / /_/ / (__  ) 
 *    \____/_/\____/_.___/\__,_/_/____/  
 *                                       
 */

Handle g_hSDKCall[NyxSDK];

/***
 *        ____  __            _          ____      __            ____              
 *       / __ \/ /_  ______ _(_)___     /  _/___  / /____  _____/ __/___ _________ 
 *      / /_/ / / / / / __ `/ / __ \    / // __ \/ __/ _ \/ ___/ /_/ __ `/ ___/ _ \
 *     / ____/ / /_/ / /_/ / / / / /  _/ // / / / /_/  __/ /  / __/ /_/ / /__/  __/
 *    /_/   /_/\__,_/\__, /_/_/ /_/  /___/_/ /_/\__/\___/_/  /_/  \__,_/\___/\___/ 
 *                  /____/                                                         
 */

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  EngineVersion engine = GetEngineVersion();
  if (engine != Engine_Left4Dead2) {
    strcopy(error, err_max, "Incompatible with this game");
    return APLRes_SilentFailure;
  }

  return APLRes_Success;
}

public void OnPluginStart() {
  g_hConVars[ConVar_GrenadeLauncherDamage] = CreateConVar("nyx_grenade_launcher_damage", "400.0", "Amount of damage the grenade gauncher does.");

  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN13CTerrorPlayer19ScriptStaggerPlayerE6Vector", 0);
  PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
  g_hSDKCall[SDK_ScriptStaggerPlayer] = EndPrepSDKCall();
  if (g_hSDKCall[SDK_ScriptStaggerPlayer] == INVALID_HANDLE)
      SetFailState("Failed to create SDKCall for CTerrorPlayer::ScriptStaggerPlayer");
}

public void OnEntityCreated(int entity, const char[] classname) {
  if (strcmp(classname, "grenade_launcher_projectile", false) == 0) {
		SDKHook(entity, SDKHook_StartTouch, OnProjectileStartTouch);
	}
}

public Action OnProjectileStartTouch(int entity, int other) {
  if (IsValidClient(other)) {
    float origin[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", origin);
    SDKCall(g_hSDKCall[SDK_ScriptStaggerPlayer], other, origin);
  }

  float flDamage = g_hConVars[ConVar_GrenadeLauncherDamage].FloatValue;
  SetEntPropFloat(entity, Prop_Data, "m_flDamage", flDamage);

  return Plugin_Continue;
}

/***
 *        ______                 __  _                 
 *       / ____/_  ______  _____/ /_(_)___  ____  _____
 *      / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
 *     / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  ) 
 *    /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/  
 *                                                     
 */

stock bool IsValidClient(int client) {
  if (client <= 0 || client > MaxClients) return false;
  if (!IsClientInGame(client)) return false;

  return true;
}
