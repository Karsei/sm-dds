/************************************************************************
 * Dynamic Dollar Shop - [Module] Trail (Sourcemod)
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
#define TRAILID							1

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
	name = "Dynamic Dollar Shop :: [Module] Trail",
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
	HookEvent("player_team", Event_OnPlayerTeam);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Trail' has been loaded.");
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
		DDS_CreateGlobalItem(TRAILID, "트레일", "trail");
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
/* 트레일 처리 함수 */
public SetTrail(client, const String:model[], bool:create)
{
	if (create)
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "TRAIL: %d (Set: Create-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		decl Float:fclientpos[3];
		
		GetClientAbsOrigin(client, fclientpos);
		fclientpos[2] = fclientpos[2] + 10.0;
		
		new String:sclientpos[128], String:strailadrs[128];
		
		Format(sclientpos, sizeof(sclientpos), "%f %f %f", fclientpos[0], fclientpos[1], fclientpos[2]);
		Format(strailadrs, sizeof(strailadrs), "materials/trails/%s.vmt", model);
		
		new String:getcolor[32];
		
		DDS_GetItemInfo(DDS_GetUserItemID(client, TRAILID), 4, getcolor);
		if (StrEqual(getcolor, "0 0 0 0", false))	Format(getcolor, sizeof(getcolor), "255 255 255 255");
		
		dds_iItemEnt[client] = CreateEntityByName("env_spritetrail");
		DispatchKeyValue(dds_iItemEnt[client],"Origin", sclientpos);
		DispatchKeyValue(dds_iItemEnt[client], "lifetime", "2.5");
		DispatchKeyValue(dds_iItemEnt[client], "startwidth", "16.0");
		DispatchKeyValue(dds_iItemEnt[client], "endwidth", "8.0");
		DispatchKeyValue(dds_iItemEnt[client], "spritename", strailadrs);
		DispatchKeyValue(dds_iItemEnt[client], "renderamt", "255");
		DispatchKeyValue(dds_iItemEnt[client], "rendercolor", getcolor);
		DispatchKeyValue(dds_iItemEnt[client], "rendermode", "5");
		DispatchSpawn(dds_iItemEnt[client]);
		
		SetEntPropFloat(dds_iItemEnt[client], Prop_Send, "m_flTextureRes", 0.05);
		SetEntPropFloat(dds_iItemEnt[client], Prop_Data, "m_flSkyboxScale", 1.0);
		
		SetVariantString("!activator");
		AcceptEntityInput(dds_iItemEnt[client], "SetParent", client);
		
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "TRAIL: %d (Set: Create-AFTER, client: %d)", dds_iItemEnt[client], client);
		//DDS_PrintDebugMsg(client, true, "(TRAIL) 코드: %d, 주소: %s", dds_eUserItemID[client][TRAIL], strailadrs);
		#endif
	}
	else if (!create)
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "TRAIL: %d (Set: NoCreate-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		if (IsValidEntity(dds_iItemEnt[client]) && (dds_iItemEnt[client] != -1))
		{
			AcceptEntityInput(dds_iItemEnt[client], "Kill");
			
			#if defined _DEBUG_
			DDS_PrintDebugMsg(0, false, "TRAIL: %d (Set: NoCreate-AFTER, client: %d)", dds_iItemEnt[client], client);
			//DDS_PrintDebugMsg(client, true, "(TRAIL) 트레일 해제");
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
			new String:trailadrs[128];
			
			DDS_GetItemInfo(DDS_GetUserItemID(i, TRAILID), 3, trailadrs);
			if (DDS_GetUserItemStatus(i, TRAILID) && (DDS_GetUserItemID(i, TRAILID) > 0) && DDS_GetItemUse(TRAILID))
				SetTrail(i, trailadrs, true);
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
		new String:trailadrs[128];
		
		DDS_GetItemInfo(DDS_GetUserItemID(client, TRAILID), 3, trailadrs);
		if (DDS_GetUserItemStatus(client, TRAILID) && (DDS_GetUserItemID(client, TRAILID) > 0) && DDS_GetItemUse(TRAILID))
			SetTrail(client, trailadrs, true);
	}
	
	return Plugin_Continue;
}

/* player_death 이벤트 처리 함수 */
public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (DDS_GetUserItemStatus(client, TRAILID) && (DDS_GetUserItemID(client, TRAILID) > 0))
		SetTrail(client, "", false);
	
	return Plugin_Continue;
}

/* player_team 이벤트 처리 함수 */
public Action:Event_OnPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new setteam = GetClientOfUserId(GetEventInt(event, "team"));
	
	if (setteam == 1)
	{
		if (DDS_GetUserItemStatus(client, TRAILID) && (DDS_GetUserItemID(client, TRAILID) > 0))
			SetTrail(client, "", false);
	}
	
	return Plugin_Continue;
}