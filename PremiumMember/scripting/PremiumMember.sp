#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors>
#include <scp>

#define PLUGIN_VERSION "2.5"
//#pragma newdecls required
#pragma semicolon 1

#define TEAM_T	2
#define TEAM_CT	3

new cli[MAXPLAYERS+2];

public Plugin myinfo =
{
	name 			= "PremiumMember",
	author		    = "FactioneR",
	description 	= "Add bonuses to members",
	version 		= PLUGIN_VERSION,
	url 			= ""
}

public void OnPluginStart()
{
	RegAdminCmd("sm_refresh_premium", RefreshMembers, ADMFLAG_ROOT);
	RegConsoleCmd("sm_premium", ShowInfo);
	for(int i = 1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
			cli[i] = IsMember(i);
	}
	HookEvent("player_spawn", EventPlayerSpawn);
}

public Action RefreshMembers(int client, int args)
{
	for(int i = 1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
			cli[i] = IsMember(i);
	}
	return Plugin_Handled;
}

public Action ShowInfo(int client, int args)
{
	if(cli[client] == 0){
		Menu menu = CreateMenu(ShowInfoHandler);
		menu.SetTitle("Premium Member");
		//menu.AddItem("option1", "MyPremium");
		menu.AddItem("z1", "Nu beneficiezi de Premium Membership", ITEMDRAW_DISABLED);
		menu.AddItem("z2", "Pentru preturi scrie in chat !preturi", ITEMDRAW_DISABLED);
		menu.ExitButton = true;
		menu.Display(client,MENU_TIME_FOREVER);
	}
	else if(cli[client] > 0){
		Menu menu = CreateMenu(ShowInfoHandler);
		menu.SetTitle("Premium Member");
		if(cli[client] == 1){
			menu.AddItem("b1", "Beneficiezi de Bronze Member", ITEMDRAW_DISABLED);
		}
		else if(cli[client] == 1){
			menu.AddItem("s1", "Beneficiezi de Silver Member", ITEMDRAW_DISABLED);
		}
		else if(cli[client] == 1){
			menu.AddItem("g1", "Beneficiezi de Gold Member", ITEMDRAW_DISABLED);
		}
		menu.AddItem("settings", "Settings");
		menu.ExitButton = true;
		menu.Display(client,MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

public int ShowInfoHandler(Menu menu, MenuAction action, int client, int itemNum) 
{
	if( action == MenuAction_Select ) 
	{
		char info[32];
		Menu menu2 = CreateMenu(ShowInfoHandlerHandler);
		GetMenuItem(menu, itemNum, info, sizeof(info));
		/*
		if(strcmp(info, "option1") == 0){
			if(cli[client] == 0){ // None
				menu2.SetTitle("===== MyPremium =====");
				menu2.AddItem("110", "Din pacate nu ai nici un nivel de Premium", ITEMDRAW_DISABLED);
				menu2.ExitButton = true;
				menu2.ExitBackButton = true;
				menu2.Display(client,MENU_TIME_FOREVER);
			}
			else if(cli[client] == 1){ // Bronze
				menu2.SetTitle("===== MyPremium - Bronze =====");
				menu2.AddItem("211", "", ITEMDRAW_DISABLED);
				menu2.ExitButton = true;
				menu2.ExitBackButton = true;
				menu2.Display(client,MENU_TIME_FOREVER);
			} 
			else if(cli[client] == 2){ // Silver

			}
			else if(cli[client] == 3){ // Gold

			}
		}
		else*/ 
		if( strcmp(info,"settings") == 0 )
		{
			menu2.SetTitle("===== Bronze Member =====");
			
			menu2.AddItem("21", "GRATUIT! Adauga europa.1tap.ro la nume", ITEMDRAW_DISABLED);
			menu2.AddItem("22", "Beneficii: P250, Armura, flash, +5 dmg", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
			//DOMenu(client, 0);
			//DID(client);
		}
		else if( strcmp(info,"option2") == 0 ) 
		{
			menu2.SetTitle("===== Silver Member =====");
			
			menu2.AddItem("31", "5 eur -> Contact: !owner", ITEMDRAW_DISABLED);
			menu2.AddItem("32", "Beneficii: Five-SeveN, armura, flash, +10 dmg", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
		else if( strcmp(info,"option3") == 0 ) 
		{
			menu2.SetTitle("===== Gold Member =====");
			
			menu2.AddItem("41", "10 eur -> Contact: !owner", ITEMDRAW_DISABLED);
			menu2.AddItem("42", "Beneficii: Deagle, armura, flash, smoke, +15 dmg", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
	}
	if(action == MenuAction_Cancel)
	{
		if(itemNum==MenuCancel_ExitBack)
		{
			ShowInfo(client,0);
		}
		//PrintToServer("Client %d's menu was cancelled.Reason: %d", client, itemNum); 
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int ShowInfoHandlerHandler(Menu menu, MenuAction action, int client, int itemNum) 
{
	if(action == MenuAction_Cancel) 
	{
		if(itemNum==MenuCancel_ExitBack)
		{
			ShowInfo(client,0);
		}
		//PrintToServer("Client %d's menu was cancelled.Reason: %d", client, itemNum); 
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public Action EventPlayerSpawn(Handle ev, char[] name, bool db)
{
	new id=GetClientOfUserId(GetEventInt(ev,"userid"));
	AddBonus(id);
	return Plugin_Continue;
}

int IsMember(client) // has string in name
{
	char Name[MAX_NAME_LENGTH+1];
	int ret = 0;

	char stid[32];
	GetClientAuthId(client, AuthId_Steam2,stid, sizeof(stid));

	if(GetClientName(client, Name, sizeof(Name)))
	{
		TrimString(Name);
	}

	if(StrContains(Name, "europa.1tap.ro", false) != -1)
	{
		ret = 1;
	}

	KeyValues kv = new KeyValues("playerNames");
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/PremiumMembers/premium_members.ini");
	if(!FileToKeyValues(kv, path)) return ret;
	if(kv.JumpToKey("playerNames") && kv.GotoFirstSubKey()){
		do
		{
			char Nm[100];
			char SteamID[50];

			kv.GetString("name", Nm, sizeof(Nm));
			kv.GetString("steamid", SteamID, sizeof(SteamID));
			int level = kv.GetNum("level", 0);
			
			if(strcmp(SteamID, stid, false) == 0)
			{
				return level;
			}

		}while(kv.GotoNextKey());	
	}
	else
	{
		SetFailState("[PremiumMember] - Corrupted .ini file");
	}
	delete kv;

	return ret;
}

public Action OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if ((damage <= 0.0 || victim < 1 || victim > MaxClients || attacker < 1 || attacker > MaxClients) && (cli[attacker] < 1) && (cli[attacker] > 3))
		return Plugin_Continue;
	
	if(cli[attacker] == 1 && IsPlayerAlive(victim))
	{
		damage += 5;
		//PrintToChat(attacker, "Damage is %d", damage/1000000);
		return Plugin_Changed;	
	}
	if(cli[attacker] == 2 && IsPlayerAlive(victim))
	{
		damage += 10;
		//PrintToChat(attacker, "Damage is %d", damage/1000000);
		return Plugin_Changed;	
	}
	if(cli[attacker] == 3 && IsPlayerAlive(victim))
	{
		damage += 15;
		return Plugin_Changed;	
	}
	return Plugin_Continue;
}


public void OnClientPutInServer(int client)
{
	for(int i = 1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
			cli[i] = IsMember(i);
	}
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}


public void PrintMessage(int client)
{
	PrintToChat(client," ");
	PrintToChat(client," ");
	if(cli[client] == 1)
	{
		PrintToChat(client," \n\n\x01 Beneficiezi de \x09 Bronze\x01 Member pentru ca esti special pentru noi \x02<3\x01");
		PrintToChat(client," \x0E Avantaje:\x05 P250, Kevlar, Flash, +5 damage\x01\n\n");
	}
	else if(cli[client] == 2)
	{
		PrintToChat(client," \n\n\x01 Beneficiezi de \x08 Silver\x01 Member\x01 pentru ca esti special pentru noi \x02<3\x01");
		PrintToChat(client," \x0E Avantaje:\x05 Five-SeveN, Kevlar, Flash, +10 damage\x01\n\n");
	} 
	else if(cli[client] == 3)
	{
		PrintToChat(client," \n\n\x01 Beneficiezi de \x02 Gold\x01 Member pentru ca esti special pentru noi \x02<3\x01");
		PrintToChat(client," \x0E Avantaje:\x05 Deagle, Kevlar, Flash, Smoke, +15 damage\x01\n\n");
	}
	PrintToChat(client," ");
	PrintToChat(client," ");
}

/*
public Action OnChatMessage(&author, Handle:recipients, String:name[], String:message[])
{
	if(IsGoldMember(author))
	{
		Format(name, MAXLENGTH_NAME, "\x02[GoldMember]\x01 %s", name);
		Format(message, (MAXLENGTH_MESSAGE - strlen(name) - 5), "%s", message);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void CP_OnChatMessagePost(int author, ArrayList recipients, const char[] flagstring, const char[] formatstring, const char[] name, const char[] message, bool processcolors, bool removecolors)
{
	PrintToServer("%s: %s [%b/%b]", name, message, processcolors, removecolors);
}
*/
void AddBonus(client)
{
	new String:sWeaponName[64];
	GetClientWeapon(client, sWeaponName, sizeof(sWeaponName));
	if(cli[client] == 3)
	{
		if((strcmp("weapon_glock", sWeaponName) == 0) || (strcmp("weapon_usp_silencer", sWeaponName) == 0) || (strcmp("weapon_hkp2000", sWeaponName) == 0))
		{
			new glock = GetPlayerWeaponSlot(client, 1);
			RemovePlayerItem(client, glock);
			AcceptEntityInput(glock, "kill");

			GivePlayerItem(client, "weapon_deagle");
		}
		GivePlayerItem(client, "weapon_flashbang");
		GivePlayerItem(client, "weapon_smokegrenade");
		switch( GetClientTeam( client ) )
		{
			case TEAM_T:
			{
				GivePlayerItem( client, "item_kevlar"); // Give Kevlar Suit and a Helmet
				SetEntProp( client, Prop_Send, "m_ArmorValue", 100, 1 ); // Set kevlar armour
			}
			case TEAM_CT:
			{
				GivePlayerItem( client, "item_kevlar"); // Give Kevlar Suit and a Helmet
				SetEntProp( client, Prop_Send, "m_ArmorValue", 100, 1 ); // Set kevlar armour
			}
		}
		PrintMessage(client);
	}
	else if(cli[client] == 2)
	{
		if((strcmp("weapon_glock", sWeaponName) == 0) || (strcmp("weapon_usp_silencer", sWeaponName) == 0) || (strcmp("weapon_hkp2000", sWeaponName) == 0))
		{
			new glock = GetPlayerWeaponSlot(client, 1);
			RemovePlayerItem(client, glock);
			AcceptEntityInput(glock, "kill");

			GivePlayerItem(client, "weapon_fiveseven");
		}
		GivePlayerItem(client, "weapon_flashbang");
		switch( GetClientTeam( client ) )
		{
			case TEAM_T:
			{
				GivePlayerItem( client, "item_kevlar"); // Give Kevlar Suit and a Helmet
				SetEntProp( client, Prop_Send, "m_ArmorValue", 100, 1 ); // Set kevlar armour
			}
			case TEAM_CT:
			{
				GivePlayerItem( client, "item_kevlar"); // Give Kevlar Suit and a Helmet
				SetEntProp( client, Prop_Send, "m_ArmorValue", 100, 1 ); // Set kevlar armour
			}
		}
		PrintMessage(client);
	}
	else if(cli[client] == 1)
	{
		if((strcmp("weapon_glock", sWeaponName) == 0) || (strcmp("weapon_usp_silencer", sWeaponName) == 0) || (strcmp("weapon_hkp2000", sWeaponName) == 0))
		{
			new glock = GetPlayerWeaponSlot(client, 1);
			RemovePlayerItem(client, glock);
			AcceptEntityInput(glock, "kill");

			GivePlayerItem(client, "weapon_p250");
		}
		
		GivePlayerItem(client, "weapon_flashbang");
		switch( GetClientTeam( client ) )
		{
			case TEAM_T:
			{
				GivePlayerItem( client, "item_kevlar"); // Give Kevlar Suit and a Helmet
				SetEntProp( client, Prop_Send, "m_ArmorValue", 100, 1 ); // Set kevlar armour
			}
			case TEAM_CT:
			{
				GivePlayerItem( client, "item_kevlar"); // Give Kevlar Suit and a Helmet
				SetEntProp( client, Prop_Send, "m_ArmorValue", 100, 1 ); // Set kevlar armour
			}
		}
		PrintMessage(client);
	}
}