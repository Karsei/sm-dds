/************************************************************************
 * Dynamic Dollar Shop - [Addon] Get Time Stack Money (Sourcemod)
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

#define DDS_ADD_NAME			"Dynamic Dollar Shop :: [Addon] Get Time Stack Money"

/*******************************************************
 * V A R I A B L E S
*******************************************************/
// Convar 변수
ConVar dds_hCV_MoneyTimeStackAmount;
ConVar dds_hCV_MoneyTimeStackInterval;

// 유저 지급 타이머
Handle dds_hUserBonusTimer[MAXPLAYERS + 1];

/*******************************************************
 * P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = DDS_ADD_NAME,
	author = DDS_ENV_CORE_AUTHOR,
	description = "This can allow clients to get money by winning round.",
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
	dds_hCV_MoneyTimeStackAmount = 			CreateConVar("dds_get_timestack_amount", 		"50", 		"설정한 간격 시간이 되었을 때 어느 정도의 금액을 지급할 것인지 적어주세요.", FCVAR_PLUGIN);
	dds_hCV_MoneyTimeStackInterval = 		CreateConVar("dds_get_timestack_interval", 		"15", 		"몇 분 간격으로 금액을 지급할 것인지 적어주세요.", FCVAR_PLUGIN);

	// Event Hook 연결
	HookEvent("player_disconnect", Event_OnPlayerDisconnect);
}

/**
 * 클라이언트가 접속하면서 스팀 고유번호를 받았을 때
 *
 * @param client			클라이언트 인덱스
 * @param auth				클라이언트 고유 번호(타입 2)
 */
public void OnClientAuthorized(int client, const char[] auth)
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!DDS_IsPluginOn())	return;

	// 봇은 제외
	if (IsFakeClient(client))	return;

	// 타이머가 생성되어있으면 제외
	if (dds_hUserBonusTimer[client] != null)	return;

	// 타이머 부여
	dds_hUserBonusTimer[client] = CreateTimer(dds_hCV_MoneyTimeStackInterval.FloatValue * 60.0, Timer_UserTimeBonus, client, TIMER_REPEAT);
}


/*******************************************************
 * C A L L B A C K   F U N C T I O N S
*******************************************************/
/**
 * 이벤트 :: 서버에서 클라이언트가 나갈 때
 *
 * @param event					이벤트 핸들
 * @param name					이벤트 이름 문자열
 * @param dontbroadcast			이벤트 브로드캐스트 차단 여부
 */
public Action Event_OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!DDS_IsPluginOn())	return Plugin_Continue;

	// 이벤트 핸들을 통해 클라이언트 식별
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	// 서버는 통과
	if (client <= 0)	return Plugin_Continue;

	// 타이머 핸들이 없으면 통과
	if (dds_hUserBonusTimer[client] == null)	return Plugin_Continue;

	// 타이머 초기화
	KillTimer(dds_hUserBonusTimer[client]);
	delete dds_hUserBonusTimer[client];
	dds_hUserBonusTimer[client] = null;

	return Plugin_Continue;
}

/**
 * 타이머 :: 시간 간격 당 금액 지급
 *
 * @param timer				타이머 핸들
 * @param client			클라이언트 인덱스
 */
public Action Timer_UserTimeBonus(Handle timer, any client)
{
	// 클라이언트가 게임 내에 없다면 통과
	if (!IsClientInGame(client))	return Plugin_Continue;

	// 금액 설정
	DDS_SetClientMoney(client, DataProc_MONEYUP, dds_hCV_MoneyTimeStackAmount.IntValue);

	// 채팅창 출력
	DDS_PrintToChat(client, "%t", "system get money timestack msg", dds_hCV_MoneyTimeStackInterval.IntValue, dds_hCV_MoneyTimeStackAmount.IntValue, "global money");

	return Plugin_Continue;
}