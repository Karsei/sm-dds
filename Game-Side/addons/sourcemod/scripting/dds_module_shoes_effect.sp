/************************************************************************
 * Dynamic Dollar Shop - [Module] Shoes Effect (Sourcemod)
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
#define SHOESID							5

/*******************************************************
 E N U M S
*******************************************************/
enum CONVAR
{
	Handle:HSHOESRINGMIN,
	Handle:HSHOESRINGMAX,
	Handle:HSHOESRINGSPEED
}

/*******************************************************
 V A R I A B L E S
*******************************************************/
// Cvar 핸들
new dds_eConvar[CONVAR];

// 게임 감지
//new dds_iGameID;
new bool:dds_bOKGo;

// 훅 이벤트 관련
new bool:dds_bFirstLoadCm;

// 모델 프리캐시
new dds_iEffectShoesPre;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Shoes Effect",
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
	dds_eConvar[HSHOESRINGMIN] = CreateConVar("dds_shoes_ring_min", "10.0", "이펙트 슈즈를 착용 시 나타나는 원의 최소 반지름을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HSHOESRINGMAX] = CreateConVar("dds_shoes_ring_max", "150.0", "이펙트 슈즈를 착용 시 나타나는 원의 최대 반지름을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HSHOESRINGSPEED] = CreateConVar("dds_shoes_ring_speed", "5", "이펙트 슈즈를 착용 시 나타나는 원의 움직임 속도를 적어주세요.", FCVAR_PLUGIN);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Shoes Effect' has been loaded.");
}

public OnConfigsExecuted()
{
	dds_iEffectShoesPre = PrecacheModel("materials/sprites/steam1.vmt", true);
	
	new String:getname[64];
	
	GetGameFolderName(getname, sizeof(getname));
	
	// 게임에 따른 모델 스킨 관련 프리캐시
	if (StrEqual(getname, "cstrike", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("player_footstep", Event_OnPlayerFootstep);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 1;
	}
	else if (StrEqual(getname, "csgo", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("player_footstep", Event_OnPlayerFootstep);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 3;
	}
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(SHOESID, "이펙트 슈즈", "shoes");
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* player_footstep 이벤트 처리 함수 */
public Action:Event_OnPlayerFootstep(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
	{
		if (DDS_GetUserItemStatus(client, SHOESID) && (DDS_GetUserItemID(client, SHOESID) > 0) && DDS_GetItemUse(SHOESID))
		{
			new Float:clientpos[3], tempcolor[4];
			
			GetClientAbsOrigin(client, clientpos);
			clientpos[2] += 3.0;
			
			new String:tempval[128], String:exstr[4][128];
			
			DDS_GetItemInfo(DDS_GetUserItemID(client, SHOESID), 4, tempval);
			ExplodeString(tempval, " ", exstr, 4, 128);
			
			for (new k; k < 4; k++)
			{
				tempcolor[k] = StringToInt(exstr[k]);
			}
			
			TE_SetupBeamRingPoint(clientpos, GetConVarFloat(dds_eConvar[HSHOESRINGMAX]), GetConVarFloat(dds_eConvar[HSHOESRINGMIN]), DDS_GetItemPrecache(SHOESID, DDS_GetUserItemID(client, SHOESID)), dds_iEffectShoesPre, 0, 15, 0.5, 5.0, 0.0, tempcolor, GetConVarInt(dds_eConvar[HSHOESRINGSPEED]), 0);
			TE_SendToAll();
			TE_SetupBeamRingPoint(clientpos, GetConVarFloat(dds_eConvar[HSHOESRINGMIN]), GetConVarFloat(dds_eConvar[HSHOESRINGMAX]), DDS_GetItemPrecache(SHOESID, DDS_GetUserItemID(client, SHOESID)), dds_iEffectShoesPre, 0, 10, 0.5, 10.0, 1.5, tempcolor, GetConVarInt(dds_eConvar[HSHOESRINGSPEED]), 0);
			TE_SendToAll();
			TE_SetupBeamRingPoint(clientpos, GetConVarFloat(dds_eConvar[HSHOESRINGMAX]), GetConVarFloat(dds_eConvar[HSHOESRINGMIN]), DDS_GetItemPrecache(SHOESID, DDS_GetUserItemID(client, SHOESID)), dds_iEffectShoesPre, 0, 10, 0.5, 10.0, 1.5, tempcolor, GetConVarInt(dds_eConvar[HSHOESRINGSPEED]), 0);
			TE_SendToAll();
			
			#if defined _DEBUG_
			//DDS_PrintDebugMsg(client, true, "(SHOES) 코드1: %d, 코드2: %d, 색상: (R)%d (G)%d (B)%d (A)%d", DDS_GetItemPrecache(SHOESID, DDS_GetUserItemID(client, SHOESID)), dds_iEffectShoesPre, tempcolor[0], tempcolor[1], tempcolor[2], tempcolor[3]);
			#endif
		}
	}
	
	return Plugin_Continue;
}