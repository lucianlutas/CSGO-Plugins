
#define PLUGIN_VERSION "2.5"

public Plugin myinfo =
{
	name 			= "Info Preturi",
	author		    = "FactioneR",
	description 	= "",
	version 		= PLUGIN_VERSION,
	url 			= ""
}

new preturiVip[5];
new preturiPremium[5];
new preturiGrade[8];

public void OnPluginStart()
{
	LoadTranslations("menu_test.phrases");
	RegAdminCmd("sm_refresh_preturi", getPrices, ADMFLAG_ROOT);
	RegConsoleCmd("preturi", Menu_Prime);

	loadPrices();
}

public Action getPrices(int client, int args) // has string in name
{
	loadPrices();

	return Plugin_Handled;
}

public void loadPrices(){
	KeyValues kv = new KeyValues("info-preturi");
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/info-preturi.ini");
	FileToKeyValues(kv, path)
	kv.JumpToKey("Preturi");
	kv.GotoFirstSubKey();
	preturiVip[0] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiVip[1] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiVip[2] = kv.GetNum("pret", 0);

	kv.GotoNextKey();
	preturiPremium[0] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiPremium[1] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiPremium[2] = kv.GetNum("pret", 0);

	kv.GotoNextKey();
	preturiGrade[0] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiGrade[1] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiGrade[2] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiGrade[3] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiGrade[4] = kv.GetNum("pret", 0);
	kv.GotoNextKey();
	preturiGrade[5] = kv.GetNum("pret", 0);


	delete kv;
}

public Action Menu_Prime(int client, int args)
{
	Menu menu = CreateMenu(ShowInfoHandler);
	menu.SetTitle("Info Preturi");
	menu.AddItem("vip", "VIP");
	menu.AddItem("premium", "Premium");
	menu.AddItem("grade", "Grade");
	menu.ExitButton = true;
	menu.Display(client,MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int ShowInfoHandler(Menu menu, MenuAction action, int client, int itemNum) 
{
	if( action == MenuAction_Select ) 
	{
		char info[32];
		
		Menu menu2 = CreateMenu(ShowInfoHandlerHandler);
		GetMenuItem(menu, itemNum, info, sizeof(info));
		if( strcmp(info,"vip") == 0 )
		{
			char prtVip1[50];
			Format(prtVip1, sizeof(prtVip1), "Level 1 - %d eur", preturiVip[0]);
			char prtVip2[50];
			Format(prtVip2, sizeof(prtVip2), "Level 2 - %d eur", preturiVip[1]);
			char prtVip3[50];
			Format(prtVip3, sizeof(prtVip3), "Level 3 - %d eur", preturiVip[2]);

			menu2.SetTitle("VIP");
			menu2.AddItem("vip1", prtVip1);
			menu2.AddItem("vip2", prtVip2);
			menu2.AddItem("vip3", prtVip3);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
		else if( strcmp(info,"premium") == 0 ) 
		{
			char prtPremium1[50];
			Format(prtPremium1, sizeof(prtPremium1), "Bronz - %d eur", preturiPremium[0]);
			char prtPremium2[50];
			Format(prtPremium2, sizeof(prtPremium2), "Silver - %d eur", preturiPremium[1]);
			char prtPremium3[50];
			Format(prtPremium3, sizeof(prtPremium3), "Gold - %d eur", preturiPremium[2]);

			menu2.SetTitle("Premium");
			menu2.AddItem("premium1", prtPremium1);
			menu2.AddItem("premium2", prtPremium2);
			menu2.AddItem("premium3", prtPremium3);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
		else if( strcmp(info,"grade") == 0 ) 
		{
			char prtGrad1[50];
			Format(prtGrad1, sizeof(prtGrad1), "Helper - %d eur", preturiGrade[0]);
			char prtGrad2[50];
			Format(prtGrad2, sizeof(prtGrad2), "Admin - %d eur", preturiGrade[1]);
			char prtGrad3[50];
			Format(prtGrad3, sizeof(prtGrad3), "Moderator - %d eur", preturiGrade[2]);
			char prtGrad4[50];
			Format(prtGrad4, sizeof(prtGrad4), "Trusted - %d eur", preturiGrade[3]);
			char prtGrad5[50];
			Format(prtGrad5, sizeof(prtGrad5), "Co-Owner - %d eur", preturiGrade[4]);
			char prtGrad6[50];
			Format(prtGrad6, sizeof(prtGrad6), "Owner - %d eur", preturiGrade[5]);

			menu2.SetTitle("Grade");
			menu2.AddItem("grade1", prtGrad1, ITEMDRAW_DISABLED);
			menu2.AddItem("grade2", prtGrad2, ITEMDRAW_DISABLED);
			menu2.AddItem("grade3", prtGrad3, ITEMDRAW_DISABLED);
			menu2.AddItem("grade4", prtGrad4, ITEMDRAW_DISABLED);
			menu2.AddItem("grade5", prtGrad5, ITEMDRAW_DISABLED);
			menu2.AddItem("grade6", prtGrad6, ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
	}
	if(action == MenuAction_Cancel)
	{
		if(itemNum==MenuCancel_ExitBack)
		{
			Menu_Prime(client,0);
		} 
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int ShowInfoHandlerHandler(Menu menu, MenuAction action, int client, int itemNum) 
{
	if( action == MenuAction_Select ) 
	{
		char info[32];
		
		Menu menu2 = CreateMenu(ShowInfoHandlerHandlerHandler);
		GetMenuItem(menu, itemNum, info, sizeof(info));
		if( strcmp(info,"vip1") == 0 )
		{
			char prtVip1[50];
			Format(prtVip1, sizeof(prtVip1), "VIP Level 1 - %d eur", preturiVip[0]);

			menu2.SetTitle(prtVip1);
			menu2.AddItem("vip11", "VIP tag", ITEMDRAW_DISABLED);
			menu2.AddItem("vip12", "Regen HP +2", ITEMDRAW_DISABLED);
			menu2.AddItem("vip13", "Armor: 105", ITEMDRAW_DISABLED);
			menu2.AddItem("vip14", "Regen Armor +2", ITEMDRAW_DISABLED);
			menu2.AddItem("vip15", "Grenade Trails", ITEMDRAW_DISABLED);
			menu2.AddItem("vip16", "Speed +0.03", ITEMDRAW_DISABLED);
			menu2.AddItem("vip17", "Money +5000", ITEMDRAW_DISABLED);
			menu2.AddItem("vip18", "Grenades: HE, Flash", ITEMDRAW_DISABLED);
			menu2.AddItem("vip19", "No Fall Damage", ITEMDRAW_DISABLED);
			menu2.AddItem("vip110", "Defuser", ITEMDRAW_DISABLED);
			menu2.AddItem("vip111", "Coin", ITEMDRAW_DISABLED);
			menu2.AddItem("vip112", "C4 Model", ITEMDRAW_DISABLED);
			menu2.AddItem("vip113", "Top Icon", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
		else if( strcmp(info,"vip2") == 0 )
		{
			char prtVip2[50];
			Format(prtVip2, sizeof(prtVip2), "VIP Level 2 - %d eur", preturiVip[1]);

			menu2.SetTitle(prtVip2);
			menu2.AddItem("vip21", "VIP tag", ITEMDRAW_DISABLED);
			menu2.AddItem("vip217", "Anti Flash", ITEMDRAW_DISABLED);
			menu2.AddItem("vip22", "Regen HP +2", ITEMDRAW_DISABLED);
			menu2.AddItem("vip23", "Armor: 110", ITEMDRAW_DISABLED);
			menu2.AddItem("vip24", "Regen Armor +3", ITEMDRAW_DISABLED);
			menu2.AddItem("vip25", "Grenade Trails", ITEMDRAW_DISABLED);
			menu2.AddItem("vip26", "Speed +0.05", ITEMDRAW_DISABLED);
			menu2.AddItem("vip27", "Money +7000", ITEMDRAW_DISABLED);
			menu2.AddItem("vip28", "Grenades: HE, Flash, Smoke", ITEMDRAW_DISABLED);
			menu2.AddItem("vip29", "No Fall Damage", ITEMDRAW_DISABLED);
			menu2.AddItem("vip210", "Defuser", ITEMDRAW_DISABLED);
			menu2.AddItem("vip211", "Coin", ITEMDRAW_DISABLED);
			menu2.AddItem("vip212", "C4 Model", ITEMDRAW_DISABLED);
			menu2.AddItem("vip213", "Top Icon", ITEMDRAW_DISABLED);
			menu2.AddItem("vip214", "Neon", ITEMDRAW_DISABLED);
			menu2.AddItem("vip215", "Water Effect", ITEMDRAW_DISABLED);
			menu2.AddItem("vip216", "Spawn Effect", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
		else if( strcmp(info,"vip3") == 0 )
		{
			char prtVip3[50];
			Format(prtVip3, sizeof(prtVip3), "VIP Level 3 - %d eur", preturiVip[2]);

			menu2.SetTitle(prtVip3);
			menu2.AddItem("vip31", "VIP tag", ITEMDRAW_DISABLED);
			menu2.AddItem("vip317", "Anti Flash", ITEMDRAW_DISABLED);
			menu2.AddItem("vip318", "BunnyHop", ITEMDRAW_DISABLED);
			menu2.AddItem("vip319", "Bullet Tracers", ITEMDRAW_DISABLED);
			menu2.AddItem("vip32", "Regen HP +5", ITEMDRAW_DISABLED);
			menu2.AddItem("vip33", "Armor: 120", ITEMDRAW_DISABLED);
			menu2.AddItem("vip34", "Regen Armor +5", ITEMDRAW_DISABLED);
			menu2.AddItem("vip35", "Grenade Trails", ITEMDRAW_DISABLED);
			menu2.AddItem("vip36", "Speed +0.10", ITEMDRAW_DISABLED);
			menu2.AddItem("vip37", "Money +12000", ITEMDRAW_DISABLED);
			menu2.AddItem("vip38", "Grenades: HE, Flash, Smoke, Molotov", ITEMDRAW_DISABLED);
			menu2.AddItem("vip39", "No Fall Damage", ITEMDRAW_DISABLED);
			menu2.AddItem("vip310", "Defuser", ITEMDRAW_DISABLED);
			menu2.AddItem("vip311", "Coin", ITEMDRAW_DISABLED);
			menu2.AddItem("vip312", "C4 Model", ITEMDRAW_DISABLED);
			menu2.AddItem("vip313", "Top Icon", ITEMDRAW_DISABLED);
			menu2.AddItem("vip314", "Neon", ITEMDRAW_DISABLED);
			menu2.AddItem("vip315", "Water Effect", ITEMDRAW_DISABLED);
			menu2.AddItem("vip316", "Spawn Effect", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
		else if( strcmp(info,"premium1") == 0 ) 
		{
			char prtPremium1[50];
			Format(prtPremium1, sizeof(prtPremium1), "Bronz Member - %d eur", preturiPremium[0]);

			menu2.SetTitle(prtPremium1);
			menu2.AddItem("premium11", "GRATUIT! Adauga europa.1tap.ro la nume", ITEMDRAW_DISABLED);
			menu2.AddItem("premium12", "P250", ITEMDRAW_DISABLED);
			menu2.AddItem("premium13", "Armor 100", ITEMDRAW_DISABLED);
			menu2.AddItem("premium14", "Flash", ITEMDRAW_DISABLED);
			menu2.AddItem("premium15", "Damage +5", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
		else if( strcmp(info,"premium2") == 0 ) 
		{
			char prtPremium2[50];
			Format(prtPremium2, sizeof(prtPremium2), "Silver Member- %d eur", preturiPremium[1]);

			menu2.SetTitle(prtPremium2);
			menu2.AddItem("premium21", "Five-SeveN", ITEMDRAW_DISABLED);
			menu2.AddItem("premium22", "Armor 100", ITEMDRAW_DISABLED);
			menu2.AddItem("premium23", "Flash", ITEMDRAW_DISABLED);
			menu2.AddItem("premium24", "Damage +10", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
		else if( strcmp(info,"premium3") == 0 ) 
		{
			char prtPremium3[50];
			Format(prtPremium3, sizeof(prtPremium3), "Gold Member- %d eur", preturiPremium[2]);

			menu2.SetTitle(prtPremium3);
			menu2.AddItem("premium31", "Desert Eagle", ITEMDRAW_DISABLED);
			menu2.AddItem("premium32", "Armor 100", ITEMDRAW_DISABLED);
			menu2.AddItem("premium33", "Flash, Smoke", ITEMDRAW_DISABLED);
			menu2.AddItem("premium34", "Damage +15", ITEMDRAW_DISABLED);
			menu2.ExitButton = true;
			menu2.ExitBackButton = true;
			menu2.Display(client,MENU_TIME_FOREVER);
		}
	}
	if(action == MenuAction_Cancel)
	{
		if(itemNum==MenuCancel_ExitBack)
		{
			Menu_Prime(client,0);
		} 
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int ShowInfoHandlerHandlerHandler(Menu menu, MenuAction action, int client, int itemNum) 
{
	if(action == MenuAction_Cancel) 
	{
		if(itemNum==MenuCancel_ExitBack)
		{
			Menu_Prime(client,0);
		}
		//PrintToServer("Client %d's menu was cancelled.Reason: %d", client, itemNum); 
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}