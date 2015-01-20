/************************************************************************
 * Dynamic Dollar Shop - [Addon] Win Get Money (Sourcemod)
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
	Handle:HREBONUSMONEYMIN,
	Handle:HREBONUSMONEYMAX
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
	name = "Dynamic Dollar Shop :: [Addon] Win Get Money",
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
	dds_eConvar[HREBONUSMONEYMIN] = CreateConVar("dds_money_re_bonus_min", "10", "라운드가 끝났을 때 이긴 팀의 살아있는 사람에게 줄 보너스 금액의 최솟값을 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HREBONUSMONEYMAX] = CreateConVar("dds_money_re_bonus_max", "50", "라운드가 끝났을 때 이긴 팀의 살아있는 사람에게 줄 보너스 금액의 최댓값을 적어주세요.", FCVAR_PLUGIN);
	
	HookEvent("round_end", Event_OnRoundEnd);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Addon] Win Get Money' has been loaded.");
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
/* round_end 이벤트 처리 함수 */
public Action:Event_OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	
	new winteam = GetEventInt(event, "winner");
	
	if (winteam > 1)
	{
		if (GetClientCountEx(false, true) >= GetConVarInt(dds_hLimitUser))
		{
			new tempranmoney = GetRandomInt(GetConVarInt(dds_eConvar[HREBONUSMONEYMIN]), GetConVarInt(dds_eConvar[HREBONUSMONEYMAX]));
			
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i) && (GetClientTeam(i) == winteam))
					DDS_SetUserMoney(i, 2, tempranmoney);
			}
			DDS_PrintToChatAll("이긴 팀의 살아있는 분들에게 보너스 %d %s을(를) 드립니다!", tempranmoney, DDS_MONEY_NAME_KO);
		}
	}
	
	return Plugin_Continue;
}