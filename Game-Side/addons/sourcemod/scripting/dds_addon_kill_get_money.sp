/************************************************************************
 * Dynamic Dollar Shop - [Addon] Kill Get Money (Sourcemod)
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
#include <dds>

/*******************************************************
 E N U M S
*******************************************************/
enum CONVAR
{
	Handle:HTMONEYMIN,
	Handle:HCTMONEYMIN,
	Handle:HTMONEYMAX,
	Handle:HCTMONEYMAX
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
	name = "Dynamic Dollar Shop :: [Addon] Kill Get Money",
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
	dds_eConvar[HTMONEYMIN] = CreateConVar("dds_money_kill_t_min", "10", "테러리스트에 있는 사람을 죽였을 때 얻는 금액의 최솟값을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HCTMONEYMIN] = CreateConVar("dds_money_kill_ct_min", "10", "대테러리스트에 있는 사람을 죽였을 때 얻는 금액의 최솟값을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HTMONEYMAX] = CreateConVar("dds_money_kill_t_max", "100", "테러리스트에 있는 사람을 죽였을 때 얻는 금액의 최댓값을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HCTMONEYMAX] = CreateConVar("dds_money_kill_ct_max", "100", "대테러리스트에 있는 사람을 죽였을 때 얻는 금액의 최댓값을 적어주세요.", FCVAR_PLUGIN);
	
	HookEvent("player_death", Event_OnPlayerDeath);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Addon] Kill Get Money' has been loaded.");
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
	{
		// 작업 방지 값 로드
		dds_hLimitUser = FindConVar("dds_money_limit_people");
	}
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
		new finalmoney, String:deadname[64];
		
		if (GetClientTeam(client) == 2)
			finalmoney = GetRandomInt(GetConVarInt(dds_eConvar[HTMONEYMIN]), GetConVarInt(dds_eConvar[HTMONEYMAX]));
		else if (GetClientTeam(client) == 3)
			finalmoney = GetRandomInt(GetConVarInt(dds_eConvar[HCTMONEYMIN]), GetConVarInt(dds_eConvar[HCTMONEYMAX]));
		
		GetClientName(client, deadname, sizeof(deadname));
		
		// 유저 금액 설정
		DDS_SetUserMoney(attacker, 2, finalmoney);
		
		DDS_PrintToChat(attacker, "%s 님을 죽여서 %d %s을(를) 얻었습니다.", deadname, finalmoney, DDS_MONEY_NAME_KO);
	}
	
	return Plugin_Continue;
}