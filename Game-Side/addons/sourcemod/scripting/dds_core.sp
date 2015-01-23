/************************************************************************
 * Dynamic Dollar Shop - CORE (Sourcemod)
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

/*******************************************************
 * E N U M S
*******************************************************/


/*******************************************************
 * V A R I A B L E S
*******************************************************/
// SQL 데이터베이스
Database dds_hSQLDatabase;

// Log 파일
char dds_sPluginLogFile[256];

// Convar 변수
ConVar dds_hCV_PluginSwtich;
//ConVar dds_hCV_SwtichLog;

/*******************************************************
 * P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop",
	author = DDS_ENV_CORE_AUTHOR,
	description = "DOLLAR SHOP",
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
	// Version 등록
	CreateConVar("sm_dynamicdollarshop_version", DDS_ENV_CORE_VERSION, "Made By. Karsei", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	// Convar 등록
	dds_hCV_PluginSwtich = CreateConVar("dds_switch_plugin", "1", "본 플러그인의 작동 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	//dds_hCV_SwtichLog = CreateConVar("dds_switch_log", "1", "데이터 로그 작성 여부입니다. 활성화를 권장합니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	// 플러그인 로그 작성 등록
	BuildPath(Path_SM, dds_sPluginLogFile, sizeof(dds_sPluginLogFile), "logs/dynamicdollarshop.log");

	// 번역 로드
	LoadTranslations("dynamicdollarshop.phrases");
}

/**
 * API 등록
 */
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	// 라이브러리 등록
	RegPluginLibrary("dds_core");

	// Native 함수 등록
	CreateNative("DDS_IsPluginOn", Native_DDS_IsPluginOn);

	return APLRes_Success;
}

/**
 * 설정이 로드되고 난 후
 */
public void OnConfigsExecuted()
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!dds_hCV_PluginSwtich.BoolValue)	return;

	// SQL 데이터베이스 연결
	Database.Connect(SQL_GetDatabase, "dds");
}

/**
 * 맵이 종료된 후
 */
public void OnMapEnd()
{
	// SQL 데이터베이스 핸들 초기화
	if (dds_hSQLDatabase != null)
	{
		dds_hSQLDatabase.Close();
	}
	dds_hSQLDatabase = null;
}


/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/**
 * LOG :: 오류코드 구분 및 로그 작성
 *
 * @param client			클라이언트 인덱스
 * @param errcode			오류코드
 * @param anydata			추가값
 */
public void LogCodeError(int client, int errcode, const char[] anydata)
{
	char usrauth[32];

	// 실제 클라이언트 구분 후 고유번호 추출
	if (client > 0)	GetClientAuthString(client, usrauth, sizeof(usrauth));

	// 오류코드 구분
	switch (errcode)
	{
		case 1000:
		{
			// SQL 데이터베이스 연결 실패
		}
	}
}

/*******************************************************
 * C A L L B A C K   F U N C T I O N S
*******************************************************/
/**
 * SQL :: 데이터베이스 최초 연결
 */
public void SQL_GetDatabase(Database db, const char[] error, any data)
{
	// 데이터베이스 연결 안될 때
	if ((db == null) || (error[0]))
	{
		LogCodeError(0, 1000, "");
		return;
	}

	// SQL 데이터베이스 핸들 등록
	dds_hSQLDatabase = db;

	// UTF-8 설정
	dds_hSQLDatabase.SetCharset("utf8");
}

/**
 * SQL :: SQL 관련 오류 발생 시
 */
public void SQL_ErrorProcess(Database db, DBResultSet results, const char[] error, any data)
{
	/******
	 * @param data				Handle / ArrayList
	 * 						0 - 클라이언트 인덱스(int), 1 - 오류코드(int), 2 - 추가값(char)
	 ******/
	// 타입 변환(*!*핸들 누수가 있는지?)
	ArrayList hData = view_as<ArrayList>(data);

	int client = hData.Get(0);
	int errcode = hData.Get(1);
	char anydata[256];
	hData.GetString(2, anydata, sizeof(anydata));

	hData.Close();

	// 오류코드 로그 작성
	LogCodeError(client, errcode, anydata);
}


/*******************************************************
 * N A T I V E  &  F O R W A R D  F U N C T I O N S
*******************************************************/
/**
 * Native :: DDS_IsPluginOn
 *
 * @brief	DDS 플러그인의 활성화 여부
*/
public int Native_DDS_IsPluginOn(Handle:plugin, numParams)
{
	return dds_hCV_PluginSwtich.BoolValue;
}