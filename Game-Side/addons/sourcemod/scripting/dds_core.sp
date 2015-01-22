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
enum Convar
{
	PluginSwitch,
	SwitchLog
}

/*******************************************************
 * V A R I A B L E S
*******************************************************/
// SQL 데이터베이스
new Handle:dds_hSQLDatabase = INVALID_HANDLE;

// Log 파일
new String:dds_sPluginLogFile[256];

// Convar 변수
new dds_eConvar[Convar];

/*******************************************************
 * P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo
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
public OnPluginStart()
{
	// Version 등록
	CreateConVar("sm_dynamicdollarshop_version", DDS_ENV_CORE_VERSION, "Made By. Karsei", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	// Convar 등록
	dds_eConvar[PluginSwitch] = CreateConVar("dds_switch_plugin", "1", "본 플러그인의 작동 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[SwitchLog] = CreateConVar("dds_switch_log", "1", "로그 작성 여부입니다. 활성화를 권장합니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	// 플러그인 로그 작성 등록
	BuildPath(Path_SM, dds_sPluginLogFile, sizeof(dds_sPluginLogFile), "logs/dynamicdollarshop.log")

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
public OnConfigsExecuted()
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!GetConVarBool(dds_eConvar[PluginSwitch]))	return;

	// SQL 데이터베이스 연결
	SQL_TConnect(SQL_GetDatabase, "dynamicdollarshop");
}

/**
 * 맵이 종료된 후
 */
public OnMapEnd()
{
	// SQL 데이터베이스 핸들 초기화
	if (dds_hSQLDatabase != INVALID_HANDLE)
	{
		CloseHandle(dds_hSQLDatabase);
	}
	dds_hSQLDatabase = INVALID_HANDLE;
}


/*******************************************************
 * C A L L B A C K   F U N C T I O N S
*******************************************************/
/**
 * SQL :: 데이터베이스 최초 연결
 */
public SQL_GetDatabase(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	// 데이터베이스 연결 안될 때
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		return;
	}

	// SQL 데이터베이스 핸들 등록
	dds_hSQLDatabase = hndl;

	// UTF-8 설정
	SQL_SetCharset(, "utf8");
}

/**
 * SQL :: SQL 관련 오류 발생 시
 */
public SQL_ErrorProcess(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	// 
}


/*******************************************************
 * N A T I V E  &  F O R W A R D  F U N C T I O N S
*******************************************************/
/**
 * Native :: DDS_IsPluginOn
 *
 * @brief	DDS 플러그인의 활성화 여부
*/
public Native_DDS_IsPluginOn(Handle:plugin, numParams)
{
	return GetConVarBool(dds_eConvar[PluginSwitch]);
}