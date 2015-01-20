/************************************************************************
 * Dynamic Dollar Shop - [Addon] Time Bonus Money (Sourcemod)
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
	Handle:HBONUSTIMESET,
	Handle:HBONUSTIMEMONEY
}

/*******************************************************
 V A R I A B L E S
*******************************************************/
// Cvar 핸들
new dds_eConvar[CONVAR];

// 분 당 금액 지급 관련
new Handle:dds_hUserBonusTimer[MAXPLAYERS+1] = {INVALID_HANDLE,...};

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Addon] Time Bonus Money",
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
	dds_eConvar[HBONUSTIMESET] = CreateConVar("dds_money_bonus_time_timeset", "15.0", "분 당 금액 지급이 설정되어 있을 때 몇 분 간격으로 지급할 것인지 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HBONUSTIMEMONEY] = CreateConVar("dds_money_bonus_time_moneyset", "50", "분 당 금액 지급이 설정되어 있을 때 얼마의 금액을 지급할 것인지 적어주세요.", FCVAR_PLUGIN);
	
	HookEvent("player_disconnect", Event_OnPlayerDisconnect);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Addon] Time Bonus Money' has been loaded.");
}

/* 클라이언트 접속 시 처리해야할 작업 */
public OnClientPutInServer(client)
{
	if (DDS_IsPluginOn())
	{
		if (!IsFakeClient(client))
		{
			if (dds_hUserBonusTimer[client] == INVALID_HANDLE)
				dds_hUserBonusTimer[client] = CreateTimer(GetConVarFloat(dds_eConvar[HBONUSTIMESET]) * 60.0, Timer_SQLUserBonusTime, client, TIMER_REPEAT);
		}
	}
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* player_disconnect 이벤트 처리 함수 */
// (맵 체인지 중에 일어나지 않고, 진심으로 클라이언트가 나갈 때에 발생)
public Action:Event_OnPlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (client > 0)
	{
		// 분 당 금액 지급 타이머 핸들 초기화
		if (dds_hUserBonusTimer[client] != INVALID_HANDLE)
			KillTimer(dds_hUserBonusTimer[client]);
		
		dds_hUserBonusTimer[client] = INVALID_HANDLE;
	}
	
	return Plugin_Continue;
}

/* 타이머 - 분 당 금액 지급 처리 함수 */
public Action:Timer_SQLUserBonusTime(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		DDS_SetUserMoney(client, 2, GetConVarInt(dds_eConvar[HBONUSTIMEMONEY]));
		
		DDS_PrintToChat(client, "%d 분이 지나 시간 보너스 지급으로 %d %s을(를) 받았습니다.", RoundFloat(GetConVarFloat(dds_eConvar[HBONUSTIMESET])), GetConVarInt(dds_eConvar[HBONUSTIMEMONEY]), DDS_MONEY_NAME_KO);
	}
	
	return Plugin_Continue;
}