/************************************************************************
 * Dynamic Dollar Shop - [Module] Laser Bullet (Sourcemod)
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
#include <dds>

#define DDS_ADD_NAME			"Dynamic Dollar Shop :: [Module] Laser Bullet"
#define DDS_ITEMCG_LB			4

/*******************************************************
 * V A R I A B L E S
*******************************************************/
// 게임 식별
char dds_sGameIdentity[32];
bool dds_bGameCheck;

// 레이저 설정
Handle dds_hLaserConfig;
Handle dds_hLaserOffset;

/*******************************************************
 * P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = DDS_ADD_NAME,
	author = DDS_ENV_CORE_AUTHOR,
	description = "This can allow clients to use effect when player shots.",
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
	// Event Hook 연결
	HookEvent("bullet_impact", Event_OnBulletImpact);
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

	// 레이저 관련 오프셋 로드
	dds_hLaserConfig = LoadGameConfigFile("laser_tag.games");
	if (dds_hLaserConfig == null)
	{
		SetFailState("%s gamedata/laser_tag.games.txt is not loadable!", DDS_ENV_CORE_CHAT_GLOPREFIX);
		dds_hLaserOffset = null;
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(dds_hLaserConfig, SDKConf_Virtual, "Weapon_ShootPosition");
		PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByValue);
		dds_hLaserOffset = EndPrepSDKCall();
	}
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
		// '레이저 총알' 아이템 종류 생성
		DDS_CreateItemCategory(DDS_ITEMCG_LB);
	}
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


/*******************************************************
 * C A L L B A C K   F U N C T I O N S
*******************************************************/
/**
 * 이벤트 :: 총알이 발사될 때
 *
 * @param event					이벤트 핸들
 * @param name					이벤트 이름 문자열
 * @param dontbroadcast			이벤트 브로드캐스트 차단 여부
 */
public Action Event_OnBulletImpact(Event event, const char[] name, bool dontBroadcast)
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!DDS_IsPluginOn())	return Plugin_Continue;

	// 게임이 식별되지 않은 경우에는 동작 안함
	if (!dds_bGameCheck)	return Plugin_Continue;

	// 이벤트 핸들을 통해 클라이언트 식별
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	// 서버는 통과
	if (client == 0)	return Plugin_Continue;

	// 클라이언트가 게임 내에 없다면 통과
	if (!IsClientInGame(client))	return Plugin_Continue;

	// 클라이언트가 인증을 받지 못했다면 통과
	if (!IsClientAuthorized(client))	return Plugin_Continue;

	// 클라이언트가 살아있지 않다면 통과
	if (!IsPlayerAlive(client))	return Plugin_Continue;

	// 클라이언트가 봇이라면 통과
	if (IsFakeClient(client))	return Plugin_Continue;

	// 오프셋이 제대로 로드가 되었는지 파악
	if (dds_hLaserOffset == null)
	{
		DDS_PrintToChat(client, "'Weapon_ShootPosition' 오프셋을 찾을 수 없습니다. 'laser_tag.games' 파일이 있는지 어드민에게 문의해주세요.");
		return Plugin_Continue;
	}

	// 이펙트 생성
	if (DDS_GetClientItemCategorySetting(client, DDS_ITEMCG_LB) && (DDS_GetClientAppliedItem(client, DDS_ITEMCG_LB) > 0))
	{
		// 환경변수 로드
		char sGetEnv[DDS_ENV_VAR_ENV_SIZE];
		DDS_GetItemInfo(DDS_GetClientAppliedItem(client, DDS_ITEMCG_LB), ItemInfo_ENV, sGetEnv);

		// 환경변수에서 색깔 정보 로드
		char sColorStr[32];
		SelectedStuffToString(sGetEnv, "ENV_DDS_INFO_COLOR", "||", ":", sColorStr, sizeof(sColorStr));

		// 문자열로 된 색상 정보를 int형으로 변환
		int iSetColor[4];
		char sExpStr[4][8];
		ExplodeString(sColorStr, " ", sExpStr, sizeof(sExpStr), sizeof(sExpStr[]));
		for (int i = 0; i < 4; i++) {
			iSetColor[i] = StringToInt(sExpStr[i]);
		}

		// 발사되는 위치 파악
		float fShoot_Pos[3];
		fShoot_Pos[0] = GetEventFloat(event, "x");
		fShoot_Pos[1] = GetEventFloat(event, "y");
		fShoot_Pos[2] = GetEventFloat(event, "z");

		// 총구가 가리키는 위치 파악
		float fDest_Pos[3];
		SDKCall(dds_hLaserOffset, client, fDest_Pos);

		// 발사 위치와 목표 지점 간의 거리 파악
		float fDistance = GetVectorDistance(fShoot_Pos, fDest_Pos);

		float fPer = (0.4 / (fDistance / 100.0));

		// 위치 조정
		float fFinalSet[3];
		fFinalSet[0] = fDest_Pos[0] + ((fShoot_Pos[0] - fDest_Pos[0]) * fPer);
		fFinalSet[1] = fDest_Pos[1] + ((fShoot_Pos[1] - fDest_Pos[1]) * fPer) - 0.08;
		fFinalSet[2] = fDest_Pos[2] + ((fShoot_Pos[2] - fDest_Pos[2]) * fPer);

		// 출력
		TE_SetupBeamPoints(fFinalSet, fShoot_Pos, 프리캐시, 0, 0, 0, 1.0, 3.0, 3.0, 0, 0.0, iSetColor, 0);
		TE_SendToAll();
	}

	return Plugin_Continue;
}