#include <sourcemod>
#include <colors>
#include <sdktools>

#define PLUGIN_VERSION "1.1fix"
#pragma newdecls required

ArrayList props;

Handle g_AutoReload;
Handle g_Message;

public Plugin myinfo =
{
	name 			= "FactioneR's Map Restrictions",
	author		    = "FactioneR",
	description 	= "Area restrictions in maps.",
	version 		= PLUGIN_VERSION,
	url 			= ""
}

public void OnPluginStart()
{
	AutoExecConfig(true, "factioner_maprestrictions");
	
	g_AutoReload  	 = CreateConVar("factioner_maprestrictions_autorefresh", "1", "Refresh props when player joins a team our disconnect.");
	g_Message		 = CreateConVar("factioner_maprestrictions_msgs", "1", "Show message when round starts");
		
	props = new ArrayList();
	HookEvent("round_start", EventRoundStart);
	//HookEvent("player_team", PlayerJoinTeam);
	//HookEvent("player_disconnect", PlayerJoinTeam);
	RegAdminCmd("refreshprops", CmdReloadProps, ADMFLAG_ROOT);
	CreateConVar("factioner_maprestrictions_version", PLUGIN_VERSION, "Plugin version", FCVAR_NOTIFY|FCVAR_REPLICATED);
}

public Action PlayerJoinTeam(Handle ev, char[] name, bool dbroad){
	if(GetConVarInt(g_AutoReload) == 1)
		CreateTimer(0.1, ReloadPropsTime);
}

public Action CmdReloadProps(int client, int args){
	ReloadProps();
}

public Action ReloadPropsTime(Handle time){
	ReloadProps();
}



public Action EventRoundStart(Handle ev, char[] name, bool db){
	ReloadProps();
	
	if(GetConVarInt(g_Message) != 1)
		return Plugin_Continue;
	PrintMessage();
	return Plugin_Continue;
}

void ReloadProps(){
	DeleteAllProps();
	CreateProps();
}


void DeleteAllProps(){

	for(int i = 0;i < props.Length;i++){
		int Ent = props.Get(i);
		if(IsValidEntity(Ent))
			AcceptEntityInput(props.Get(i), "kill");
	}
	props.Clear();
}

int GetAlivePlayersCount( int iTeam )
{
  int iCount, i; iCount = 0;

  for( i = 1; i <= MaxClients; i++ )
    if( IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) == iTeam )
      iCount++;

  return iCount;
}  


void PrintMessage(){
	char mapname[100];
	GetCurrentMap(mapname, sizeof(mapname));
	int PlayerCount = GetAlivePlayersCount(3);
	KeyValues kv = new KeyValues("Messages");
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "data/factioner_maprestrictions/%s.ini", mapname);
	if(!FileToKeyValues(kv, path)) return;
	if(kv.JumpToKey("Messages") && kv.GotoFirstSubKey()){
		do
		{
			char Message[500];
			int MoreThan = kv.GetNum("morethan", 0);
			int LessThan = kv.GetNum("lessthan", 0);
			kv.GetString("message", Message, sizeof(Message));
			if(!StrEqual(Message, "") && PlayerCount > MoreThan && (LessThan == 0 || PlayerCount < LessThan))
			{
				CPrintToChatAll("{green}[Map Restrictions]{default} {lightgreen}%d{default}x{lightgreen}%d {default}- {green}%s", GetTeamClientCount(2), GetTeamClientCount(3), Message);
			}
		}while(kv.GotoNextKey());	
	}
	else
	{
		SetFailState("[MapRestrictions] - Corrupted %s.ini file", mapname);
	}
	delete kv;
}

void CreateProps(){
	char mapname[100];
	GetCurrentMap(mapname, sizeof(mapname));
	props.Clear();
	int PlayerCount = GetAlivePlayersCount(3);
	KeyValues kv = new KeyValues("Positions");
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "data/factioner_maprestrictions/%s.ini", mapname);
	if(!FileToKeyValues(kv, path)) return;
		
	if(kv.JumpToKey("Positions") && kv.GotoFirstSubKey())
	{
		do
		{
			char model[PLATFORM_MAX_PATH];
			kv.GetString("model", model, sizeof(model));
			int MoreThan = kv.GetNum("morethan", 0);
			int LessThan = kv.GetNum("lessthan", 0);

			
			if(kv.GotoFirstSubKey())
			{
				do
				{
					float origin[3];
					float angles[3];
					kv.GetVector("origin", origin);
					kv.GetVector("angles", angles);
					
					if(PlayerCount > MoreThan && (LessThan == 0 || PlayerCount < LessThan))
					{
						if(PrecacheModel(model,true) == 0)
							SetFailState("[MapRestrictions] - Error precaching model '%s'", model);
						
						int Ent = CreateEntityByName("prop_physics_override"); 
					
						DispatchKeyValue(Ent, "physdamagescale", "0.0");
						DispatchKeyValue(Ent, "model", model);
						DispatchKeyValue(Ent, "Solid", "6");

						DispatchSpawn(Ent);
						SetEntityMoveType(Ent, MOVETYPE_PUSH);
						
						TeleportEntity(Ent, origin, angles, NULL_VECTOR);
						props.Push(Ent);
					}
				}while(kv.GotoNextKey());
				kv.GoBack();
			}
			else
			{
				SetFailState("[MapRestrictions] - Corrupted %s.ini file", mapname);
			}
		}while(kv.GotoNextKey());
	}
	else
	{
		SetFailState("[MapRestrictions] - Corrupted %s.ini file", mapname);
	}
	delete kv;
}