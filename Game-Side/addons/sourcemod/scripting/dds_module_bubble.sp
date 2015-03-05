/************************************************************************
 * Dynamic Dollar Shop - [Module] Bubble (Sourcemod)
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
#include <sdktools>
#include <sdkhooks>
#include <dds>

#define DDS_ADD_NAME			"Dynamic Dollar Shop :: [Module] Bubble"
#define DDS_ITEMCG_BB_ID		7

/*******************************************************
 * V A R I A B L E S
*******************************************************/
// Convar 변수
ConVar dds_hCV_BUBBLE_COUNT;
ConVar dds_hCV_BUBBLE_SPEED;

// 게임 식별
char dds_sGameIdentity[32];
bool dds_bGameCheck;

/*******************************************************
 * P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = DDS_ADD_NAME,
	author = DDS_ENV_CORE_AUTHOR,
	description = "This can allow clients to use Bubble function.",
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
	dds_hCV_BUBBLE_COUNT = 		CreateConVar("dds_bb_count", 	"12", 				"버블을 장착했을 때 나타나는 개체의 갯수를 적어주세요.", FCVAR_PLUGIN);
	dds_hCV_BUBBLE_SPEED = 		CreateConVar("dds_bb_speed", 	"25.0", 			"버블을 장착했을 때 나타나는 개체의 움직임 속도를 적어주세요.", FCVAR_PLUGIN);
}

/**
 * 설정이 로드되고 난 후
 */
public void OnConfigsExecuted()
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!DDS_IsPluginOn())	return;

	// 게임 식별
	GetGameFolderName(dds_sGameIdentity, sizeof(dds_sGameIdentity));

	// 게임 별 이벤트 후킹
	System_SetHookEvent(dds_sGameIdentity);
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
		// '버블' 아이템 종류 생성
		DDS_CreateItemCategory(DDS_ITEMCG_BB_ID);
	}
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

	// SDKHooks 로드
	SDKHook(client, SDKHook_PostThink, PostThinkHook);
}

/**
 * 클라이언트가 서버로부터 나가고 있을 때
 *
 * @param client			클라이언트 인덱스
 */
public void OnClientDisconnect(int client)
{
	// 게임에 없으면 통과
	if (!IsClientInGame(client))	return;

	// 봇은 제외
	if (IsFakeClient(client))	return;

	// SDKHooks 언로드
	SDKUnhook(client, SDKHook_PostThink, PostThinkHook);
}


/*******************************************************
 * G E N E R A L   F U N C T I O N S
*******************************************************/
/**
 * System :: 게임 별 이벤트 연결
 *
 * @param gamename					게임 이름
 */
public void System_SetHookEvent(const char[] gamename)
{
	if (StrEqual(gamename, "cstrike", false))
	{
		/********************************************
		 * '카운터 스트라이크: 소스'
		*********************************************/
		// 게임 식별 완료
		dds_bGameCheck = true;
	}
	else if (StrEqual(gamename, "csgo", false))
	{
		/********************************************
		 * '카운터 스트라이크: 글로벌 오펜시브'
		*********************************************/
		// 게임 식별 완료
		dds_bGameCheck = true;
	}
	else if (StrEqual(gamename, "tf", false))
	{
		/********************************************
		 * 팀 포트리스
		*********************************************/
		// 게임 식별 완료
		dds_bGameCheck = true;
	}
}

/**
 * Entity :: 버블 생성
 *
 * @param client				클라이언트 인덱스
 */
public void Entiry_CreateBubble(int client)
{
	// 클라이언트의 위치 파악
	float fClient_Pos[3];
	GetClientAbsOrigin(client, fClient_Pos);

	// ENV 설정 로드

	// 효과 적용
	TE_Start("Bubbles");
	TE_WriteVector("m_vecMins", fClient_Pos);
	TE_WriteVector("m_vecMaxs", fClient_Pos);
	TE_WriteNum("m_nModelIndex", 모델);
	TE_WriteFloat("m_fHeight", 250.0);
	TE_WriteNum("m_nCount", dds_hCV_BUBBLE_COUNT.IntValue);
	TE_WriteFloat("m_fSpeed", dds_hCV_BUBBLE_SPEED.FloatValue);
	TE_SendToAll();
}


/*******************************************************
 * C A L L B A C K   F U N C T I O N S
*******************************************************/
/**
 * 후킹 :: 클라이언트 별 실시간 후처리
 *
 * @param client					클라이언트 인덱스
 */
public void PostThinkHook(int client)
{
	// 게임에 없으면 통과
	if (!IsClientInGame(client))	return;

	// 봇은 제외
	if (IsFakeClient(client))	return;

	// 게임이 식별되지 않은 경우에는 동작 안함
	if (!dds_bGameCheck)	return;

	// 버블 처리
	if (DDS_GetClientItemCategorySetting(client, DDS_ITEMCG_BB_ID) && (DDS_GetClientAppliedItem(client, DDS_ITEMCG_BB_ID) > 0))
	{
		Entiry_CreateBubble(client);
	}
}