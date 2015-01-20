/************************************************************************
 * Dynamic Dollar Shop - [Module] Laser Point (Sourcemod)
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
#include <sdkhooks>
#include <dds>

/*******************************************************
 D E F I N E S
*******************************************************/
#define LASERPOINTID					10

/*******************************************************
 V A R I A B L E S
*******************************************************/
// Entity 설정
new dds_iItemEnt[MAXPLAYERS+1];

// 예외 처리
new bool:dds_bIsExcept[MAXPLAYERS+1] = false;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Laser Point",
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
	HookEvent("player_death", Event_OnPlayerDeath);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Laser Point' has been loaded.");
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(LASERPOINTID, "레이저 포인트", "laser point");
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
			
			// SDKHooks 로드
			SDKHook(client, SDKHook_PostThink, PostThinkHook);
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
			
			// SDKHooks 언로드
			SDKUnhook(client, SDKHook_PostThink, PostThinkHook);
		}
	}
}

/* SDKHooks - PostThinkHook */
public PostThinkHook(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (DDS_GetUserItemStatus(client, LASERPOINTID) && (DDS_GetUserItemID(client, LASERPOINTID) > 0) && DDS_GetItemUse(LASERPOINTID))
		{
			new String:clweapon[64];
			
			GetClientWeapon(client, clweapon, sizeof(clweapon));
			
			if (!StrEqual(clweapon, "weapon_knife", false) && !StrEqual(clweapon, "weapon_flashbang", false) && !StrEqual(clweapon, "weapon_hegrenade", false) && !StrEqual(clweapon, "weapon_smokegrenade", false) && !StrEqual(clweapon, "weapon_c4", false))
			{
				new String:lpards[128];
				
				DDS_GetItemInfo(DDS_GetUserItemID(client, LASERPOINTID), 3, lpards);
				SetLaserPoint(client, lpards, true);

				dds_bIsExcept[client] = true;

				return;
			}
			
			// 이전에 만들어진 것이 있다면 삭제
			if (dds_bIsExcept[client])
			{
				SetLaserPoint(client, "", false);
				dds_bIsExcept[client] = false;
			}
		}
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 레이저 포인트 처리 함수 */
public SetLaserPoint(client, const String:model[], bool:create)
{
	if (create)
	{
		#if defined _DEBUG_
		//DDS_PrintDebugMsg(0, false, "LASERPOINT: %d (Set: Create-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		if (!((dds_iItemEnt[client] != -1) && (EntRefToEntIndex(dds_iItemEnt[client]) != -1)))
		{
			new envsprite = CreateEntityByName("env_sprite");
			
			DispatchKeyValue(envsprite, "model", model);
			DispatchKeyValue(envsprite, "rendermode", "5");
			DispatchKeyValue(envsprite, "renderfx", "15");
			DispatchSpawn(envsprite);
			
			AcceptEntityInput(envsprite, "ShowSprite");
			dds_iItemEnt[client] = EntIndexToEntRef(envsprite);
		}
		
		new Float:eyepos[3], Float:eyeang[3];
		
		GetClientEyePosition(client, eyepos);
		GetClientEyeAngles(client, eyeang);
		
		new Handle:htrace = INVALID_HANDLE;
		
		htrace = TR_TraceRayFilterEx(eyepos, eyeang, MASK_SOLID, RayType_Infinite, TraceFilter, client);
		if (TR_DidHit(htrace))
		{
			decl Float:resultpos[3], Float:normalvec[3];
			
			TR_GetEndPosition(resultpos, htrace);
			TR_GetPlaneNormal(htrace, normalvec);
			
			NormalizeVector(normalvec, normalvec);
			ScaleVector(normalvec, 5.0);
			AddVectors(resultpos, normalvec, resultpos);
			TeleportEntity(dds_iItemEnt[client], resultpos, NULL_VECTOR, NULL_VECTOR);
		}
		CloseHandle(htrace);
		
		#if defined _DEBUG_
		//DDS_PrintDebugMsg(0, false, "LASERPOINT: %d (Set: Create-AFTER, client: %d)", dds_iItemEnt[client], client);
		#endif
	}
	else
	{
		#if defined _DEBUG_
		//DDS_PrintDebugMsg(0, false, "LASERPOINT: %d (Set: NoCreate-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		if ((dds_iItemEnt[client] != 0) && (dds_iItemEnt[client] != -1) && (EntRefToEntIndex(dds_iItemEnt[client]) != -1))
		{
			AcceptEntityInput(dds_iItemEnt[client], "Kill");
			
			#if defined _DEBUG_
			//DDS_PrintDebugMsg(0, false, "LASERPOINT: %d (Set: NoCreate-AFTER, client: %d)", dds_iItemEnt[client], client);
			#endif
		}
		dds_iItemEnt[client] = -1;
	}
}

/* 레이저 포인트 - 트레이스 필터 처리 함수 */
public bool:TraceFilter(entity, mask, any:data)
{	
	new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	if((entity != data) && (owner != data))
		return true;
	else
		return false;
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* player_death 이벤트 처리 함수 */
public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (DDS_GetUserItemStatus(client, LASERPOINTID) && (DDS_GetUserItemID(client, LASERPOINTID) > 0))
		SetLaserPoint(client, "", false);
	
	return Plugin_Continue;
}