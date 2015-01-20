/************************************************************************
 * Dynamic Dollar Shop - [Option] Startup Model Fix (Sourcemod)
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
 V A R I A B L E S
*******************************************************/
// 게임 감지
new dds_iGameID;
new bool:dds_bOKGo;

// 훅 이벤트 관련
new bool:dds_bFirstLoadCm;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Option] Startup Model Fix",
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
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Option] Startup Model Fix' has been loaded.");
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
			HookEvent("round_freeze_end", Event_OnRoundFreezeEnd);
			dds_bFirstLoadCm = true;
		}
		
		PrecacheModel("models/player/ct_urban.mdl", true);
		
		dds_bOKGo = true;
		dds_iGameID = 1;
	}
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* round_freeze_end 이벤트 처리 함수 */
public Action:Event_OnRoundFreezeEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
		{
			new String:chkmodel[128];
			
			GetClientModel(i, chkmodel, sizeof(chkmodel));
			
			if (dds_iGameID == 1)
			{
				if (StrEqual(chkmodel, "models/player/ct_gsg9.mdl", false) || StrEqual(chkmodel, "models/player/ct_sas.mdl", false))
					SetEntityModel(i, "models/player/ct_urban.mdl");
			}
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
		new String:chkmodel[128];
		
		GetClientModel(client, chkmodel, sizeof(chkmodel));
		
		if (dds_iGameID == 1)
		{
			if (StrEqual(chkmodel, "models/player/ct_gsg9.mdl", false) || StrEqual(chkmodel, "models/player/ct_sas.mdl", false))
				SetEntityModel(client, "models/player/ct_urban.mdl");
		}
	}
	
	return Plugin_Continue;
}