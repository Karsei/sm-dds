/************************************************************************
 * Dynamic Dollar Shop - [Module] Knife Skin (Sourcemod)
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
#define KNIFESKINID						13

#define EF_NODRAW						32

/*******************************************************
 V A R I A B L E S
*******************************************************/
// 칼 스킨 관련
new dds_iUserViewModel[MAXPLAYERS+1][2];
new bool:dds_bUserSpawnViewModel[MAXPLAYERS+1];
new bool:dds_bUserCustomViewModel[MAXPLAYERS+1];

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Knife Skin",
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
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Knife Skin' has been loaded.");
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(KNIFESKINID, "칼 스킨", "knife skin");
}

/* 클라이언트 접속 시 처리해야할 작업 */
public OnClientPutInServer(client)
{
	if (DDS_IsPluginOn())
	{
		if (!IsFakeClient(client))
		{
			// 칼 스킨 관련 초기화
			dds_iUserViewModel[client][0] = -1;
			dds_iUserViewModel[client][1] = -1;
			
			// 뷰모델 Entity 숫자 부여
			dds_iUserViewModel[client][0] = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
			
			new tempent = -1;
			
			while ((tempent = FindEntityByClassname(tempent, "predicted_viewmodel")) != -1)
			{
				if (GetEntPropEnt(tempent, Prop_Send, "m_hOwner") == client)
				{
					if (GetEntProp(tempent, Prop_Send, "m_nViewModelIndex") == 1)
					{
						dds_iUserViewModel[client][1] = tempent;
						break;
					}
				}
			}
			
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
			// 칼 스킨 관련 초기화
			dds_iUserViewModel[client][0] = -1;
			dds_iUserViewModel[client][1] = -1;
			
			// SDKHooks 언로드
			SDKUnhook(client, SDKHook_PostThink, PostThinkHook);
		}
	}
}

/* SDKHooks - OnEntityCreated */
public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "predicted_viewmodel", false))
		SDKHook(entity, SDKHook_Spawn, OnEntitySpawned);
}

/* SDKHooks - PostThinkHook */
public PostThinkHook(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (DDS_GetUserItemStatus(client, KNIFESKINID) && (DDS_GetUserItemID(client, KNIFESKINID) > 0) && DDS_GetItemUse(KNIFESKINID))
		{
			SetKnifeSkin(client, DDS_GetItemPrecache(KNIFESKINID, DDS_GetUserItemID(client, KNIFESKINID), 0), DDS_GetItemPrecache(KNIFESKINID, DDS_GetUserItemID(client, KNIFESKINID), 1));
		}
	}
}

/* SDKHooks - Spawn */
public OnEntitySpawned(entity)
{
	new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwner");
	
	if ((owner > 0) && (owner <= MaxClients))
	{
		if (GetEntProp(entity, Prop_Send, "m_nViewModelIndex") == 0)
			dds_iUserViewModel[owner][0] = entity;
		else if (GetEntProp(entity, Prop_Send, "m_nViewModelIndex") == 1)
			dds_iUserViewModel[owner][1] = entity;
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 칼 스킨 처리 함수 */
/* Snippet : https://forums.alliedmods.net/showthread.php?t=181558 */
public SetKnifeSkin(client, vmodelcode, wmodelcode)
{
	static oldweapon[MAXPLAYERS+1];
	static oldseq[MAXPLAYERS+1];
	static Float:oldcycle[MAXPLAYERS+1];
	
	decl String:classname[30];
	new weaponindex;
	
	if (!IsPlayerAlive(client))
	{
		new spec = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		
		if (spec != -1)
		{
			weaponindex = GetEntPropEnt(spec, Prop_Send, "m_hActiveWeapon");
			
			GetEdictClassname(weaponindex, classname, sizeof(classname));
			
			if (StrEqual("weapon_knife", classname, false))
			{
				SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_nModelIndex", vmodelcode);
				SetEntProp(weaponindex, Prop_Send, "m_iWorldModelIndex", wmodelcode);
			}
		}
		return;
	}
	
	weaponindex = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	new seqval = GetEntProp(dds_iUserViewModel[client][0], Prop_Send, "m_nSequence");
	new Float:cycleval = GetEntPropFloat(dds_iUserViewModel[client][0], Prop_Data, "m_flCycle");
	
	if (weaponindex <= 0)
	{
		new effectval = GetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_fEffects");
		
		effectval |= EF_NODRAW;
		SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_fEffects", effectval);
		
		dds_bUserCustomViewModel[client] = false;
		
		oldweapon[client] = weaponindex;
		oldseq[client] = seqval;
		oldcycle[client] = cycleval;
		
		return;
	}
	
	if (weaponindex != oldweapon[client])
	{
		GetEdictClassname(weaponindex, classname, sizeof(classname));
		if (StrEqual("weapon_knife", classname, false))
		{
			new effectval;
			
			effectval = GetEntProp(dds_iUserViewModel[client][0], Prop_Send, "m_fEffects");
			effectval |= EF_NODRAW;
			SetEntProp(dds_iUserViewModel[client][0], Prop_Send, "m_fEffects", effectval);
			
			effectval = GetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_fEffects");
			effectval &= ~EF_NODRAW;
			SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_fEffects", effectval);
			
			SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_nModelIndex", vmodelcode);
			SetEntPropEnt(dds_iUserViewModel[client][1], Prop_Send, "m_hWeapon", GetEntPropEnt(dds_iUserViewModel[client][0], Prop_Send, "m_hWeapon"));
			SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_nSequence", GetEntProp(dds_iUserViewModel[client][0], Prop_Send, "m_nSequence"));
			SetEntPropFloat(dds_iUserViewModel[client][1], Prop_Send, "m_flPlaybackRate", GetEntPropFloat(dds_iUserViewModel[client][0], Prop_Send, "m_flPlaybackRate"));
			
			SetEntProp(weaponindex, Prop_Send, "m_iWorldModelIndex", wmodelcode);
			
			dds_bUserCustomViewModel[client] = true;
		}
		else
		{
			new effectval = GetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_fEffects");
			
			effectval |= EF_NODRAW;
			SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_fEffects", effectval);
			
			dds_bUserCustomViewModel[client] = false;
		}
	}
	else
	{
		if (dds_bUserCustomViewModel[client])
		{
			SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_nSequence", GetEntProp(dds_iUserViewModel[client][0], Prop_Send, "m_nSequence"));
			SetEntPropFloat(dds_iUserViewModel[client][1], Prop_Send, "m_flPlaybackRate", GetEntPropFloat(dds_iUserViewModel[client][0], Prop_Send, "m_flPlaybackRate"));
			
			if ((cycleval < oldcycle[client]) && (seqval == oldseq[client]))
				SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_nSequence", 0);
		}
	}
	
	if (dds_bUserSpawnViewModel[client])
	{
		dds_bUserSpawnViewModel[client] = false;
		
		if (dds_bUserCustomViewModel[client])
		{
			new effectval = GetEntProp(dds_iUserViewModel[client][0], Prop_Send, "m_fEffects");
			
			effectval |= EF_NODRAW;
			SetEntProp(dds_iUserViewModel[client][0], Prop_Send, "m_fEffects", effectval);
		}
	}
	
	oldweapon[client] = weaponindex;
	oldseq[client] = seqval;
	oldcycle[client] = cycleval;
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* player_spawn 이벤트 처리 함수 */
public Action:Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	dds_bUserSpawnViewModel[client] = true;
	
	return Plugin_Continue;
}

/* player_death 이벤트 처리 함수 */
public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// 칼 스킨 관련
	if (dds_iUserViewModel[client][1] != -1)
	{
		new effectval = GetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_fEffects");
		
		effectval |= EF_NODRAW;
		SetEntProp(dds_iUserViewModel[client][1], Prop_Send, "m_fEffects", effectval);
	}
	
	return Plugin_Continue;
}