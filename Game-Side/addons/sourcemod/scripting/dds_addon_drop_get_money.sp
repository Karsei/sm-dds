/************************************************************************
 * Dynamic Dollar Shop - [Addon] Drop Get Money (Sourcemod)
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
 E N U M S
*******************************************************/
enum CONVAR
{
	Handle:HTMONEYMIN,
	Handle:HCTMONEYMIN,
	Handle:HTMONEYMAX,
	Handle:HCTMONEYMAX,
	Handle:HPROBGOLDBARDROP,
	Handle:HMODDOLLARGETSWITCH
}

/*******************************************************
 V A R I A B L E S
*******************************************************/
// Cvar 핸들
new dds_eConvar[CONVAR];

// 작업 방지 Cvar
new Handle:dds_hLimitUser = INVALID_HANDLE;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Addon] Drop Get Money",
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
	dds_eConvar[HTMONEYMIN] = CreateConVar("dds_money_goldbar_kill_t_min", "10", "테러리스트에 있는 사람을 죽여서 떨어진 금괴의 금액 최솟값을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HCTMONEYMIN] = CreateConVar("dds_money_goldbar_kill_ct_min", "10", "대테러리스트에 있는 사람을 죽여서 떨어진 금괴의 금액 최솟값을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HTMONEYMAX] = CreateConVar("dds_money_goldbar_kill_t_max", "100", "테러리스트에 있는 사람을 죽여서 떨어진 금괴의 금액 최댓값을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HCTMONEYMAX] = CreateConVar("dds_money_goldbar_kill_ct_max", "100", "대테러리스트에 있는 사람을 죽여서 떨어진 금괴의 금액 최댓값을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HPROBGOLDBARDROP] = CreateConVar("dds_money_drop_goldbar_prob", "1.0", "금괴가 떨어지는 것을 어느 정도의 확률로 떨어뜨릴 것인지 적어주세요(비율로 적어주세요).", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HMODDOLLARGETSWITCH] = CreateConVar("dds_switch_moddollar_get", "1", "금괴에 닿았을 때 획득하는 방법을 정하는 곳입니다. 1 - 모두 획득 가능, 2 - 죽인 플레이어만 획득 가능, 3 - 죽인 플레이어의 팀만 가능", FCVAR_PLUGIN, true, 1.0, true, 3.0);
	
	HookEvent("player_death", Event_OnPlayerDeath);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Addon] Drop Get Money' has been loaded.");
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
	{
		// 작업 방지 값 로드
		dds_hLimitUser = FindConVar("dds_money_limit_people");
	}
}

/* 클라이언트 접속 시 처리해야할 작업 */
public OnClientPutInServer(client)
{
	if (DDS_IsPluginOn())
	{
		if (!IsFakeClient(client))
		{
			// SDKHooks 설정
			SDKHook(client, SDKHook_StartTouch, StartTouchHook);
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
			// SDKHooks 언로드
			SDKUnhook(client, SDKHook_StartTouch, StartTouchHook);
		}
	}
}

/* SDKHooks - StartTouch */
public Action:StartTouchHook(client, target)
{
	if (!IsClientInGame(client))	return Plugin_Continue;
	if (!IsValidEntity(target))	return Plugin_Continue;
	
	new String:model[128];
	
	GetEntPropString(target, Prop_Data, "m_ModelName", model, 128);
	
	// 금괴를 건드렸을 때의 처리
	if (StrEqual(model, "models/money/goldbar.mdl", false))
	{
		new finalmoney, bool:okset, String:cnum[32], owntarget;
		
		if (GetClientTeam(client) == 2)
			finalmoney = GetRandomInt(GetConVarInt(dds_eConvar[HTMONEYMIN]), GetConVarInt(dds_eConvar[HTMONEYMAX]));
		else if (GetClientTeam(client) == 3)
			finalmoney = GetRandomInt(GetConVarInt(dds_eConvar[HCTMONEYMIN]), GetConVarInt(dds_eConvar[HCTMONEYMAX]));
		
		GetEntPropString(target, Prop_Data, "m_iName", cnum, sizeof(cnum));
		ReplaceString(cnum, sizeof(cnum), "CP_", "", false);
		
		owntarget = StringToInt(cnum);
		
		if (GetConVarInt(dds_eConvar[HMODDOLLARGETSWITCH]) == 1) // 모두 습득
		{
			okset = true;
		}
		else if (GetConVarInt(dds_eConvar[HMODDOLLARGETSWITCH]) == 2) // 죽인 플레이어만
		{
			if (client == owntarget)
				okset = true;
		}
		else if (GetConVarInt(dds_eConvar[HMODDOLLARGETSWITCH]) == 3) // 죽인 플레이어의 팀만
		{
			if (GetClientTeam(client) == GetClientTeam(owntarget))
				okset = true;
		}
		
		if (okset)
		{
			AcceptEntityInput(target, "Kill");
			
			DDS_SetUserMoney(client, 2, finalmoney);
			
			DDS_PrintToChat(client, "%d %s을(를) 얻었습니다.", finalmoney, DDS_MONEY_NAME_KO);
		}
	}
	return Plugin_Continue;
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 프롭 생성 */
/* CreateItem 과는 목적이 전혀 다른 함수 */
public CreateProp(client, const String:model[], String:proptype[], Float:pos[3])
{
	new entity = CreateEntityByName(proptype);
	
	new String:cset[32];
	
	Format(cset, sizeof(cset), "CP_%i", client);
	
	DispatchKeyValue(entity, "physdamagescale", "0.0");
	DispatchKeyValue(entity, "model", model);
	SetEntProp(entity, Prop_Data, "m_takedamage", 2);
	DispatchSpawn(entity);
	
	DispatchKeyValue(entity, "targetname", cset);
	SetVariantString(cset);
	
	TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* player_death 이벤트 처리 함수 */
public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	// 특정 유저 또는 봇을 맞추었을 경우
	if ((client > 0) && (attacker > 0) && (client != attacker) && IsClientInGame(client) && IsClientInGame(attacker) && !IsFakeClient(attacker) && (GetClientCountEx(false, true) >= GetConVarInt(dds_hLimitUser)))
	{
		new Float:pos[3], Float:rannum;
		
		GetClientAbsOrigin(client, pos);
		
		pos[2] += 5.0;
		
		rannum = GetRandomFloat(0.0, 1.0);
		
		if (rannum <= GetConVarFloat(dds_eConvar[HPROBGOLDBARDROP]))
		{
			if (GetConVarInt(dds_eConvar[HMODDOLLARGETSWITCH]) == 1)
				CreateProp(client, "models/money/goldbar.mdl", "prop_physics_respawnable", pos);
			else
				CreateProp(attacker, "models/money/goldbar.mdl", "prop_physics_respawnable", pos);
		}
	}
	
	return Plugin_Continue;
}