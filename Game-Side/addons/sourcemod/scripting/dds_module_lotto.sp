/************************************************************************
 * Dynamic Dollar Shop - [Module] Lotto (Sourcemod)
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

#define DDS_ADD_NAME			"Dynamic Dollar Shop :: [Module] Lotto"
#define DDS_ITEMCG_LOTTO_ID		17

/*******************************************************
 * P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = DDS_ADD_NAME,
	author = DDS_ENV_CORE_AUTHOR,
	description = "This can allow clients to use Lotto function.",
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
	// 없음
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
		// '복권' 아이템 종류 생성
		DDS_CreateItemCategory(DDS_ITEMCG_LOTTO_ID);
	}
}

/**
 * 클라이언트가 접속하면서 스팀 고유번호를 받았을 때
 *
 * @param client			클라이언트 인덱스
 * @param auth				클라이언트 고유 번호(타입 2)
 */



/*******************************************************
 * G E N E R A L   F U N C T I O N S
*******************************************************/
/**
 * System :: 복권!
 *
 * @param client			클라이언트 인덱스
 */
public void System_Lottto(int client)
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!DDS_IsPluginOn())	return;

	float fMinRatio = 0.0;			// 최소 확률
	float fMaxRatio = 10000.0;		// 최대 확률

	// 확률 선정
	float fRanRatio = GetRandomFloat(fMinRatio, fMaxRatio);

	// 확률을 퍼센트로 변경
	float fRanPercent = (fRanRatio / fMaxRatio) * 100.0;

	// 확률에 따른 구분 처리
	if (fRanPercent <= 5.0)
	{

	}
	else
	{
		// 꽝!
	}
}