/************************************************************************
 * Dynamic Dollar Shop - [Module] Flash (Sourcemod)
 * 
 * Copyright (C) 2012-2013 Eakgnarok
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 * 
************************************************************************/
#include <sourcemod>
#include <sdktools>
#include <dds>

/*******************************************************
 D E F I N E S
*******************************************************/
#define FLASHID							9

/*******************************************************
 V A R I A B L E S
*******************************************************/
// 게임 감지
//new dds_iGameID;
new bool:dds_bOKGo;

// 훅 이벤트 관련
new bool:dds_bFirstLoadCm;

// Entity 설정
new dds_iItemEnt[MAXPLAYERS+1];

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Flash",
	author = "Eakgnarok",
	description = "Many clients can allow to use several items in the game.",
	version = DDS_PLUGIN_VERSION,
	url = "http://eakgnarok.pe.kr"
};

/*******************************************************
 F O R W A R D   F U N C T I O N S
*******************************************************/
public OnPluginStart()
{
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Flash' has been loaded.");
}

public OnConfigsExecuted()
{
	new String:getname[64];
	
	GetGameFolderName(getname, sizeof(getname));
	
	// 게임에 따른 모델 스킨 관련 프리캐시
	if (StrEqual(getname, "cstrike", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("round_freeze_end", Event_OnRoundStart);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 1;
	}
	else if (StrEqual(getname, "tf", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("arena_round_start", Event_OnRoundStart);
			HookEvent("teamplay_round_start", Event_OnRoundStart);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 2;
	}
	else if (StrEqual(getname, "csgo", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("round_freeze_end", Event_OnRoundStart);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 3;
	}
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(FLASHID, "플래시", "flash");
}

/* 클라이언트 접속 시 처리해야할 작업 */
public OnClientPutInServer(client)
{
	if (DDS_IsPluginOn())
	{
		if (!IsFakeClient(client))
		{
			// 엔티티 초기화
			dds_iItemEnt[client] = -1;
		}
	}
}

/* 클라이언트 접속 해제 시 처리해야할 작업 */
public OnClientDisconnect(client)
{
	if (DDS_IsPluginOn())
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			// 엔티티 초기화
			dds_iItemEnt[client] = -1;
		}
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 플래시 처리 함수 */
public SetFlash(client, String:color[], bool:create)
{
	if (create)
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "FLASH: %d (Set: Create-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		dds_iItemEnt[client] = CreateEntityByName("light_dynamic");
		
		new Float:vec[3], String:origin[100];
		
		GetClientAbsOrigin(client, vec);
		Format(origin, sizeof(origin), "%f %f %f", vec[0], vec[1], vec[2]);
		
		DispatchKeyValue(dds_iItemEnt[client], "_light", color);
		DispatchKeyValue(dds_iItemEnt[client], "distance", "256");
		DispatchKeyValue(dds_iItemEnt[client], "spotlight_radius", "100");
		DispatchKeyValue(dds_iItemEnt[client], "origin", origin);
		DispatchKeyValue(dds_iItemEnt[client], "brightness", "2");
		DispatchKeyValue(dds_iItemEnt[client], "style", "6");
		DispatchSpawn(dds_iItemEnt[client]);
		
		new String:targetname[128];
		
		Format(targetname, sizeof(targetname), "target%i", client);
		
		DispatchKeyValue(client, "targetname", targetname);
		SetVariantString(targetname);
		AcceptEntityInput(dds_iItemEnt[client], "SetParent");
		AcceptEntityInput(dds_iItemEnt[client], "TurnOn");
		
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "FLASH: %d (Set: Create-AFTER, client: %d)", dds_iItemEnt[client], client);
		
		new String:trname[64];
		
		DDS_GetItemInfo(DDS_GetUserItemID(client, FLASHID), 1, trname);
		//PrintToChat(client, "\x04%s\x01 -DEBUG- (FLASH) 코드: %d, 이름: %s, 색상: %s", CHAT_PREFIX_KO, DDS_GetUserItemID(client, FLASHID), trname, color);
		#endif
	}
	else
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "FLASH: %d (Set: NoCreate-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		if (IsValidEntity(dds_iItemEnt[client]) && (dds_iItemEnt[client] != -1))
		{
			AcceptEntityInput(dds_iItemEnt[client], "Kill");
			
			#if defined _DEBUG_
			DDS_PrintDebugMsg(0, false, "FLASH: %d (Set: NoCreate-AFTER, client: %d)", dds_iItemEnt[client], client);
			#endif
		}
		dds_iItemEnt[client] = -1;
	}
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* round_freeze_end 이벤트 처리 함수 */
public Action:Event_OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
		{
			new String:trcolor[32];
			
			DDS_GetItemInfo(DDS_GetUserItemID(i, FLASHID), 4, trcolor);
			if (DDS_GetUserItemStatus(i, FLASHID) && (DDS_GetUserItemID(i, FLASHID) > 0) && DDS_GetItemUse(FLASHID))
				SetFlash(i, trcolor, true);
		}
	}
	
	return Plugin_Continue;
}

/* player_spawn 이벤트 처리 함수 */
public Action:Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
	{
		new String:trcolor[32];
		
		DDS_GetItemInfo(DDS_GetUserItemID(client, FLASHID), 4, trcolor);
		if (DDS_GetUserItemStatus(client, FLASHID) && (DDS_GetUserItemID(client, FLASHID) > 0) && DDS_GetItemUse(FLASHID))
			SetFlash(client, trcolor, true);
	}
	
	return Plugin_Continue;
}

/* player_death 이벤트 처리 함수 */
public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (DDS_GetUserItemStatus(client, FLASHID) && (DDS_GetUserItemID(client, FLASHID) > 0))
		SetFlash(client, "", false);
	
	return Plugin_Continue;
}