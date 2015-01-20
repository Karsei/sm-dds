/************************************************************************
 * Dynamic Dollar Shop - [Module] Player Skin (Sourcemod)
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
#define TSKINID							2
#define CTSKINID						3

/*******************************************************
 E N U M S
*******************************************************/
enum CONVAR
{
	Handle:HMODZOMBIESWITCH
}

/*******************************************************
 V A R I A B L E S
*******************************************************/
// Cvar 핸들
new dds_eConvar[CONVAR];

// 게임 감지
new dds_iGameID;
new bool:dds_bOKGo;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Player Skin",
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
	dds_eConvar[HMODZOMBIESWITCH] = CreateConVar("dds_switch_modzombie", "0", "좀비 모드를 이용하고 있을때 모든 대상의 기본 스킨을 CT 스킨으로 적용할지의 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Player Skin' has been loaded.");
}

public OnConfigsExecuted()
{
	new String:getname[64];
	
	GetGameFolderName(getname, sizeof(getname));
	
	// 게임에 따른 모델 스킨 관련 프리캐시
	if (StrEqual(getname, "cstrike", false))
	{
		dds_bOKGo = true;
		dds_iGameID = 1;
	}
	else if (StrEqual(getname, "tf", false))
	{
		dds_bOKGo = true;
		dds_iGameID = 2;
	}
	else if (StrEqual(getname, "csgo", false))
	{
		dds_bOKGo = true;
		dds_iGameID = 3;
	}
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
	{
		DDS_CreateGlobalItem(TSKINID, "T 스킨", "tskin");
		DDS_CreateGlobalItem(CTSKINID, "CT 스킨", "ctskin");
	}
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* player_spawn 이벤트 처리 함수 */
public Action:Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
	{
		if ((DDS_GetUserItemStatus(client, TSKINID) && (DDS_GetUserItemID(client, TSKINID) > 0) && DDS_GetItemUse(TSKINID)) || (DDS_GetUserItemStatus(client, CTSKINID) && (DDS_GetUserItemID(client, CTSKINID) > 0) && DDS_GetItemUse(CTSKINID)))
		{
			new String:skinadrs[128];
			
			if (!GetConVarBool(dds_eConvar[HMODZOMBIESWITCH]))
			{
				if (GetClientTeam(client) == 2)
				{
					DDS_GetItemInfo(DDS_GetUserItemID(client, TSKINID), 3, skinadrs);
					if ((DDS_GetUserItemID(client, TSKINID) > 0) && DDS_GetItemUse(TSKINID))
					{
						SetEntityModel(client, skinadrs);
					}
					else
					{
						if (dds_iGameID == 1)
							SetEntityModel(client, "models/player/t_guerilla.mdl");
					}
				}
				else if (GetClientTeam(client) == 3)
				{
					DDS_GetItemInfo(DDS_GetUserItemID(client, CTSKINID), 3, skinadrs);
					if ((DDS_GetUserItemID(client, CTSKINID) > 0) && DDS_GetItemUse(CTSKINID))
					{
						SetEntityModel(client, skinadrs);
					}
					else
					{
						if (dds_iGameID == 1)
							SetEntityModel(client, "models/player/ct_urban.mdl");
					}
				}
			}
			else
			{
				DDS_GetItemInfo(DDS_GetUserItemID(client, CTSKINID), 3, skinadrs);
				if ((DDS_GetUserItemID(client, CTSKINID) > 0) && DDS_GetItemUse(CTSKINID))
				{
					SetEntityModel(client, skinadrs);
				}
				else
				{
					if (GetClientTeam(client) == 2)
					{
						if (dds_iGameID == 1)
							SetEntityModel(client, "models/player/t_guerilla.mdl");
					}
					else if (GetClientTeam(client) == 3)
					{
						if (dds_iGameID == 1)
							SetEntityModel(client, "models/player/ct_urban.mdl");
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}