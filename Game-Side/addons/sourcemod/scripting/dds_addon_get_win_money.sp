/************************************************************************
 * Dynamic Dollar Shop - [Addon] Get Win Money (Sourcemod)
 * 
 * Copyright (C) 2012-2015 Karsei
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
 ***********************************************************************/
#include <sourcemod>
#include <dds>

#define DDS_ADD_NAME			"Dynamic Dollar Shop :: [Addon] Get Win Money"

/*******************************************************
 * V A R I A B L E S
*******************************************************/
// Convar 변수
ConVar dds_hCV_MoneyWinMin;
ConVar dds_hCV_MoneyWinMax;

// 외부 Convar 연결
ConVar dds_hSecureUserMin;

/*******************************************************
 * P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = DDS_ADD_NAME,
	author = DDS_ENV_CORE_AUTHOR,
	description = "This can allow clients to get moneys by winning round.",
	version = DDS_ENV_CORE_VERSION,
	url = DDS_ENV_CORE_HOMEPAGE
};


/*******************************************************
 * F O R W A R D   F U N C T I O N S
*******************************************************/
/**
 * 플러그인 시작 시
 */
public void OnPluginStart()
{
	// Convar 등록
	dds_hCV_MoneyWinMin = 		CreateConVar("dds_get_win_min", 		"10", 		"라운드가 끝났을 때 이긴 팀의 살아있는 사람에게 줄 보너스 금액의 최솟값을 적어주세요.", FCVAR_PLUGIN);
	dds_hCV_MoneyWinMax = 		CreateConVar("dds_get_win_max", 		"50", 		"라운드가 끝났을 때 이긴 팀의 살아있는 사람에게 줄 보너스 금액의 최댓값을 적어주세요.", FCVAR_PLUGIN);

	// Event Hook 연결
	HookEvent("round_end", Event_OnRoundEnd);
}

/**
 * 라이브러리가 추가될 때
 *
 * @param name					로드된 라이브러리 명
 */
public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "dds_core", false))
	{
		// 작업 방지 ConVar 로드
		dds_hSecureUserMin = FindConVar("dds_get_secure_user_min");
	}
}


/*******************************************************
 * C A L L B A C K   F U N C T I O N S
*******************************************************/
/**
 * 이벤트 :: 라운드가 끝났을 때
 *
 * @param event					이벤트 핸들
 * @param name					이벤트 이름 문자열
 * @param dontbroadcast			이벤트 브로드캐스트 차단 여부
 */
public Action Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!DDS_IsPluginOn())	return Plugin_Continue;

	// 최소 인원이 들어가있지 않다면 통과
	if (GetClientCountEx() < dds_hSecureUserMin.IntValue) return Plugin_Continue;

	// 이벤트 핸들을 통해 클라이언트 식별
	int winTeam = GetEventInt(event, "winner");

	// 팀으로 들어가있는 사람들만 처리
	if (winTeam > 1)
	{
		// 랜덤으로 금액 설정
		int iRanMoney = GetRandomInt(dds_hCV_MoneyWinMin.IntValue, dds_hCV_MoneyWinMax.IntValue);

		// 클라이언트 별 처리
		for (int i = 1; i <= MaxClients; i++)
		{
			// 클라이언트가 게임 내에 없다면 통과
			if (!IsClientInGame(i))	return Plugin_Continue;

			// 클라이언트가 인증을 받지 못했다면 통과
			if (!IsClientAuthorized(i))	return Plugin_Continue;

			// 클라이언트가 봇이라면 통과
			if (IsFakeClient(i))	return Plugin_Continue;

			// 클라이언트가 죽었다면 통과
			if (!IsPlayerAlive(i))	return Plugin_Continue;

			// 이긴 팀과 다르다면 통과
			if (GetClientTeam(i) != winTeam)	return Plugin_Continue;

			// 금액 설정
			DDS_SetClientMoney(i, DataProc_MONEYUP, iRanMoney);

			// 채팅창 출력
			DDS_PrintToChat(i, "%t", "system get money win msg", iRanMoney, "global money");
		}
	}

	return Plugin_Continue;
}