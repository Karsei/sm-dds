/************************************************************************
 * Dynamic Dollar Shop - [Module] Pet (Sourcemod)
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
#define PETID							16

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

// 애완동물 관련
new dds_iUserPetTemp[MAXPLAYERS+1];

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Pet",
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
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Pet' has been loaded.");
}

public OnConfigsExecuted()
{
	// 애완동물 관련 프리캐시
	PrecacheModel("models/Characters/Hostage_01.mdl", true);
	PrecacheModel("models/Characters/Hostage_02.mdl", true);
	PrecacheModel("models/Characters/Hostage_03.mdl", true);
	PrecacheModel("models/Characters/Hostage_04.mdl", true);
	PrecacheModel("models/blackout.mdl", true);
	
	new String:getname[64];
	
	GetGameFolderName(getname, sizeof(getname));
	
	// 게임에 따른 모델 스킨 관련 프리캐시
	if (StrEqual(getname, "cstrike", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("round_freeze_end", Event_OnRoundStart);
			HookEvent("hostage_hurt", Event_OnHostage, EventHookMode_Pre);
			HookEvent("hostage_follows", Event_OnHostage, EventHookMode_Pre);
			HookEvent("hostage_stops_following", Event_OnHostage, EventHookMode_Pre);
			HookEvent("hostage_killed", Event_OnHostage, EventHookMode_Pre);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 1;
	}
	else if (StrEqual(getname, "tf", false)) // hostage 관련 이벤트 훅 없음
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("arena_round_start", Event_OnRoundStart);
			HookEvent("teamplay_round_start", Event_OnRoundStart);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = false;
		//dds_iGameID = 2;
	}
	else if (StrEqual(getname, "csgo", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("round_freeze_end", Event_OnRoundStart);
			HookEvent("hostage_hurt", Event_OnHostage, EventHookMode_Pre);
			HookEvent("hostage_follows", Event_OnHostage, EventHookMode_Pre);
			HookEvent("hostage_stops_following", Event_OnHostage, EventHookMode_Pre);
			HookEvent("hostage_killed", Event_OnHostage, EventHookMode_Pre);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 3;
	}
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(PETID, "애완동물", "pet");
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
			dds_iUserPetTemp[client] = -1;
			
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
			dds_iUserPetTemp[client] = -1;
			
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
		if (dds_bOKGo)
		{
			if (DDS_GetUserItemStatus(client, PETID) && (DDS_GetUserItemID(client, PETID) > 0) && DDS_GetItemUse(PETID))
				SetRealTimePet(client, dds_iItemEnt[client]);
		}
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 애완동물 처리 함수 */
/* Thanks to 'DJ당구' */
public SetPet(client, const String:model[], String:ani[], bool:create)
{
	if (create)
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "PET: %d (Set: Create-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		new String:entindex[6], String:setani[64];
		
		if (strlen(ani) <= 0)
			Format(setani, sizeof(setani), "idle");
		else if (strlen(ani) > 0)
			Format(setani, sizeof(setani), ani);
		
		new mainpet = CreateEntityByName("hostage_entity");
		new temppet = CreateEntityByName("prop_dynamic_ornament");
		
		IntToString(temppet, entindex, sizeof(entindex)-1);
		
		DispatchKeyValue(mainpet, "classname", "prop_physics");
		DispatchKeyValue(mainpet, "targetname", entindex);
		DispatchKeyValue(mainpet, "disableshadows", "1");
		DispatchKeyValueFloat(mainpet, "friction", 1.0);
		SetEntPropEnt(mainpet, Prop_Send, "m_hOwnerEntity", client);
		DispatchSpawn(mainpet);
		
		SetEntityMoveType(mainpet, MOVETYPE_FLY);
		
		SetEntProp(mainpet, Prop_Data, "m_takedamage", 0, 1);
		SetEntProp(mainpet, Prop_Data, "m_CollisionGroup", 2);
		SetEntPropEnt(mainpet, Prop_Send, "m_hOwnerEntity", client);
		SetEntityModel(mainpet, "models/blackout.mdl");
		
		DispatchKeyValue(temppet, "model", model);
		DispatchKeyValue(temppet, "DefaultAnim", setani);
		DispatchSpawn(temppet);
		
		new Float:eyepos[3], Float:eyeang[3], Float:angup[3], Float:resultpos[3];
		
		GetClientEyePosition(client, eyepos);
		GetClientEyeAngles(client, eyeang);
		
		eyeang[0] = 0.0;
		
		GetAngleVectors(eyeang, angup, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(angup, angup);
		ScaleVector(angup, -50.0);
		AddVectors(eyepos, angup, resultpos);
		
		TeleportEntity(mainpet, resultpos, NULL_VECTOR, NULL_VECTOR);
		
		SetVariantString(entindex);
		AcceptEntityInput(temppet, "SetParent");
		SetVariantString(entindex);
		AcceptEntityInput(temppet, "SetAttached");
		
		TeleportEntity(mainpet, resultpos, NULL_VECTOR, NULL_VECTOR);
		
		dds_iItemEnt[client] = mainpet;
		dds_iUserPetTemp[client] = temppet;
	}
	else
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "PET: %d (Set: NoCreate-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		if (IsValidEntity(dds_iItemEnt[client]) && (dds_iItemEnt[client] != -1))
		{
			AcceptEntityInput(dds_iItemEnt[client], "Kill");
			
			#if defined _DEBUG_
			DDS_PrintDebugMsg(0, false, "PET: %d (Set: NoCreate-AFTER, client: %d)", dds_iItemEnt[client], client);
			#endif
		}
		dds_iItemEnt[client] = -1;
		dds_iUserPetTemp[client] = -1;
	}
}

/* 애완동물 실시간 처리 함수 */
public SetRealTimePet(client, entity)
{
	if (IsValidEntity(entity))
	{
		decl Float:eyeang[3], Float:eyepos[3], Float:petpos[3], Float:repos[3], Float:reang[3];
		
		GetClientEyePosition(client, eyepos);
		GetClientEyeAngles(client, eyeang);
		
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", petpos);
		MakeVectorFromPoints(eyepos, petpos, repos);
		GetVectorAngles(repos, reang);
		
		new Handle:htrace = INVALID_HANDLE;
		
		htrace = TR_TraceRayFilterEx(eyepos, reang, MASK_SOLID, RayType_Infinite, TraceFilter, client);
		
		new Float:angup[3], Float:reconvpos[3], Float:dist, Float:tempang[3], Float:tempvec[3];
		
		if (TR_DidHit(htrace))
		{
			if (TR_GetEntityIndex(htrace) == entity)
			{
				eyeang[0] = 0.0;
				
				GetAngleVectors(eyeang, angup, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(angup, angup);
				ScaleVector(angup, -50.0);
				AddVectors(eyepos, angup, reconvpos);
				
				dist = GetVectorDistance(eyepos, petpos);
				
				if (dist >= 100.0)
				{
					if (dist >= 800.0)
					{
						TeleportEntity(entity, reconvpos, NULL_VECTOR, NULL_VECTOR);
					}
					else
					{
						MakeVectorFromPoints(petpos, reconvpos, tempvec);
						NormalizeVector(tempvec, tempvec);
						GetVectorAngles(tempvec, tempang);
						ScaleVector(tempvec, 1600.0);
						
						TeleportEntity(entity, NULL_VECTOR, tempang, tempvec);
					}
				}
				else
				{
					MakeVectorFromPoints(petpos, reconvpos, tempvec);
					NormalizeVector(tempvec, tempvec);
					GetVectorAngles(tempvec, tempang);
					ScaleVector(tempvec, 10.0);
					
					TeleportEntity(entity, NULL_VECTOR, tempang, tempvec);
				}
			}
			else
			{
				eyeang[0] = 0.0;
				
				GetAngleVectors(eyeang, angup, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(angup, angup);
				ScaleVector(angup, -50.0);
				AddVectors(eyepos, angup, reconvpos);
				
				TeleportEntity(entity, reconvpos, NULL_VECTOR, NULL_VECTOR);
			}
		}
		else
		{
			eyeang[0] = 0.0;
			
			GetAngleVectors(eyeang, angup, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(angup, angup);
			ScaleVector(angup, -50.0);
			AddVectors(eyepos, angup, reconvpos);
			
			TeleportEntity(entity, reconvpos, NULL_VECTOR, NULL_VECTOR);
		}
		CloseHandle(htrace);
	}
}

/* 애완동물 - 트레이스 필터 처리 함수 */
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
/* round_freeze_end 이벤트 처리 함수 */
public Action:Event_OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
		{
			new String:petadrs[128], String:petopt[128];
			
			DDS_GetItemInfo(DDS_GetUserItemID(i, PETID), 3, petadrs);
			DDS_GetItemInfo(DDS_GetUserItemID(i, PETID), 10, petopt);
			if (DDS_GetUserItemStatus(i, PETID) && (DDS_GetUserItemID(i, PETID) > 0) && DDS_GetItemUse(PETID))
				SetPet(i, petadrs, petopt, true);
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
		new String:petadrs[128], String:petopt[128];
		
		DDS_GetItemInfo(DDS_GetUserItemID(client, PETID), 3, petadrs);
		DDS_GetItemInfo(DDS_GetUserItemID(client, PETID), 10, petopt);
		if (DDS_GetUserItemStatus(client, PETID) && (DDS_GetUserItemID(client, PETID) > 0) && DDS_GetItemUse(PETID))
			SetPet(client, petadrs, petopt, true);
	}
	
	return Plugin_Continue;
}

/* player_death 이벤트 처리 함수 */
public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (DDS_GetUserItemStatus(client, PETID) && (DDS_GetUserItemID(client, PETID) > 0))
		SetPet(client, "", "", false);
	
	return Plugin_Continue;
}

/* hostage 관련 이벤트 처리 함수 */
public Action:Event_OnHostage(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	if (DDS_GetItemUse(PETID))
		return Plugin_Handled;
	else
		return Plugin_Continue;
}