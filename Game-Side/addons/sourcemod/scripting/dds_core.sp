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

// 로그 파일
char dds_sPluginLogFile[256];

// Convar 변수
ConVar dds_hCV_PluginSwitch;
ConVar dds_hCV_SwitchDisplayChat;
//ConVar dds_hCV_SwtichLog;

// 팀 채팅
bool dds_bTeamChat[MAXPLAYERS + 1];

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
	dds_hCV_PluginSwitch = CreateConVar("dds_switch_plugin", "1", "본 플러그인의 작동 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_hCV_SwitchDisplayChat = CreateConVar("dds_switch_chat", "0", "채팅을 할 때 메세지 출력 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	//dds_hCV_SwtichLog = CreateConVar("dds_switch_log", "1", "데이터 로그 작성 여부입니다. 활성화를 권장합니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	// 플러그인 로그 작성 등록
	BuildPath(Path_SM, dds_sPluginLogFile, sizeof(dds_sPluginLogFile), "logs/dynamicdollarshop.log");

	// 번역 로드
	LoadTranslations("dynamicdollarshop.phrases");

	// 콘솔 커맨트 연결
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_TeamSay);
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
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

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
	char usrauth[20];

	// 실제 클라이언트 구분 후 고유번호 추출
	if (client > 0)	GetClientAuthId(client, AuthId_SteamID64, usrauth, sizeof(usrauth));

	// 클라이언트와 서버 구분하여 접두 메세지 설정
	char sDetOutput[512];
	char sOutput[512];
	char sPrefix[128];
	char sErrDesc[1024];

	if (client > 0) // 클라이언트
	{
		Format(sPrefix, sizeof(sPrefix), "%s [Error :: ID %d]", DDS_ENV_CORE_CHAT_GLOPREFIX, errcode);
		if (strlen(sErrDesc) > 0) Format(sErrDesc, sizeof(sErrDesc), "%s [Error Desc :: ID %d]", DDS_ENV_CORE_CHAT_GLOPREFIX, errcode);
	}
	else if (client == 0) // 서버
	{
		Format(sPrefix, sizeof(sPrefix), "%s [%t :: ID %d]", DDS_ENV_CORE_CHAT_GLOPREFIX, "error occurred", errcode);
		if (strlen(sErrDesc) > 0) Format(sErrDesc, sizeof(sErrDesc), "%s [%t :: ID %d]", DDS_ENV_CORE_CHAT_GLOPREFIX, "error desc", errcode);
	}

	Format(sDetOutput, sizeof(sDetOutput), "%s", sPrefix);
	Format(sOutput, sizeof(sOutput), "%s", sPrefix);

	// 오류코드 구분
	switch (errcode)
	{
		case 1000:
		{
			// SQL 데이터베이스 연결 실패
			Format(sDetOutput, sizeof(sDetOutput), "%s Connecting Database is Failure!", sDetOutput);
		}
	}

	// 클라이언트와 서버 구분하여 로그 출력
	if (client > 0) // 클라이언트
	{
		// 클라이언트 메세지 전송
		DDS_PrintToChat(client, sOutput);
		if (strlen(sErrDesc) > 0) DDS_PrintToChat(client, sErrDesc);

		// 서버 메세지 전송
		DDS_PrintToServer("%s (client: %N)", sDetOutput, client);
		if (strlen(sErrDesc) > 0) DDS_PrintToServer("%s (client: %N)", sErrDesc, client);

		// 로그 파일 작성
		LogToFile(dds_sPluginLogFile, "%s (client: %N)", sDetOutput, client);
		if (strlen(sErrDesc) > 0) LogToFile(dds_sPluginLogFile, "%s (client: %N)", sErrDesc, client);
	}
	else if (client == 0) // 서버
	{
		// 서버 메세지 전송
		DDS_PrintToServer(sDetOutput);
		if (strlen(sErrDesc) > 0) DDS_PrintToServer(sErrDesc);

		// 로그 파일 작성
		LogToFile(dds_sPluginLogFile, "%s (Server)", sDetOutput);
		if (strlen(sErrDesc) > 0) LogToFile(dds_sPluginLogFile, "%s (Server)", sErrDesc);
	}
}


/**
 * 메뉴 :: 메인 메뉴 출력
 *
 * @param client			클라이언트 인덱스
 * @param args				기타
*/
public Action:Menu_Main(int client, int args)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return Plugin_Continue;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlMain);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n ", "menu common title");
	mMain.SetTitle(buffer);

	// '내 프로필'
	Format(buffer, sizeof(buffer), "%t", "menu main myprofile");
	mMain.AddItem("1", buffer);
	// '내 장착 아이템'
	Format(buffer, sizeof(buffer), "%t", "menu main mycuritem");
	mMain.AddItem("2", buffer);
	// '내 인벤토리'
	Format(buffer, sizeof(buffer), "%t", "menu main myinven");
	mMain.AddItem("3", buffer);
	// '아이템 구매'
	Format(buffer, sizeof(buffer), "%t", "menu main buy category");
	mMain.AddItem("4", buffer);
	// '설정'
	Format(buffer, sizeof(buffer), "%t\n ", "menu main setting");
	mMain.AddItem("5", buffer);
	// '플러그인 정보'
	Format(buffer, sizeof(buffer), "%t", "menu main plugininfo");
	mMain.AddItem("9", buffer);

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);

	return Plugin_Continue;
}

/**
 * 메뉴 :: 프로필 메뉴 출력
 *
 * @param client			클라이언트 인덱스
 * @param args				기타
*/
public Action:Menu_Profile(int client, int args)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return Plugin_Continue;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlProfile);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t\n ", "menu common title", "menu common curpos", "menu main myprofile");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 필요 정보
	char sUsrName[32];
	char sUsrAuthId[20];

	GetClientName(client, sUsrName, sizeof(sUsrName));
	GetClientAuthId(client, AuthId_SteamID64, sUsrAuthId, sizeof(sUsrAuthId));

	Format(buffer, sizeof(buffer), 
		"%t: %s\n%t: %s", 
		"global nickname", sUsrName, "global authid", sUsrAuthId);
	mMain.AddItem("1", buffer, ITEMDRAW_DISABLED);

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);

	return Plugin_Continue;
}

/*******************************************************
 * C A L L B A C K   F U N C T I O N S
*******************************************************/
/**
 * 커맨드 :: 전체 채팅
 *
 * @param client				클라이언트 인덱스
 * @param args					기타
 */
public Action:Command_Say(int client, int args)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return Plugin_Continue;

	// 서버 채팅은 통과
	if (client == 0)	return Plugin_Continue;

	// 메세지 받고 맨 끝 따옴표 제거
	char sMsg[256];

	GetCmdArgString(sMsg, sizeof(sMsg));
	sMsg[strlen(sMsg)-1] = '\x0';

	// 파라메터 추출 후 분리
	char sMainCmd[32];
	char sParamStr[4][64];
	int sParamIdx;

	sParamIdx = SplitString(sMsg[1], " ", sMainCmd, sizeof(sMainCmd));
	ExplodeString(sMsg[1 + sParamIdx], " ", sParamStr, sizeof(sParamStr), sizeof(sParamStr[]));

	// 느낌표나 슬래시가 있다면 제거
	ReplaceString(sMainCmd, sizeof(sMainCmd), "!", "", false);
	ReplaceString(sMainCmd, sizeof(sMainCmd), "/", "", false);

	// 메인 메뉴
	if (StrEqual(sMainCmd, DDS_ENV_USER_MAINMENU, false))
	{
		Menu_Main(client, 0);
	}

	return dds_hCV_SwitchDisplayChat.BoolValue ? Plugin_Continue : Plugin_Handled;
}

/**
 * 커맨드 :: 팀 채팅
 *
 * @param client				클라이언트 인덱스
 * @param args					기타
 */
public Action:Command_TeamSay(int client, int args)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return Plugin_Continue;

	// 팀 채팅을 했다는 변수를 남기고 일반 채팅과 동일하게 간주
	dds_bTeamChat[client] = true;
	Command_Say(client, args);

	return Plugin_Handled;
}

/**
 * SQL :: 데이터베이스 최초 연결
 *
 * @param db					데이터베이스 연결 핸들
 * @param error					오류 문자열
 * @param data					기타
 */
public void SQL_GetDatabase(Database db, const char[] error, any data)
{
	// 데이터베이스 연결 안될 때
	if ((db == null) || (error[0]))
	{
		LogCodeError(0, 1000, error);
		return;
	}

	// SQL 데이터베이스 핸들 등록
	dds_hSQLDatabase = db;

	// UTF-8 설정
	dds_hSQLDatabase.SetCharset("utf8");
}

/**
 * SQL :: SQL 관련 오류 발생 시
 *
 * @param db					데이터베이스 연결 핸들
 * @param results				결과 쿼리
 * @param error					오류 문자열
 * @param data					기타
 */
public void SQL_ErrorProcess(Database db, DBResultSet results, const char[] error, any data)
{
	/******
	 * @param data				Handle / ArrayList
	 * 					0 - 클라이언트 인덱스(int), 1 - 오류코드(int), 2 - 추가값(char)
	 ******/
	// 타입 변환(*!*핸들 누수가 있는지?)
	ArrayList hData = view_as<ArrayList>(data);

	int client = hData.Get(0);
	int errcode = hData.Get(1);
	char anydata[256];
	hData.GetString(2, anydata, sizeof(anydata));

	delete hData;

	// 오류코드 로그 작성
	LogCodeError(client, errcode, anydata);
}


/**
 * 메뉴 핸들 :: 메인 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlMain(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}

	if (action == MenuAction_Select)
	{
		char sInfo[32];
		menu.GetItem(item, sInfo, sizeof(sInfo));
		int iInfo = StringToInt(sInfo);

		switch (iInfo)
		{
			case 1:
			{
				// 내 프로필
				Menu_Profile(client, 0);
			}
			case 2:
			{
				// 내 장착 아이템
			}
			case 3:
			{
				// 내 인벤토리
			}
			case 4:
			{
				// 아이템 구매
			}
			case 5:
			{
				// 설정
			}
			case 9:
			{
				// 플러그인 정보
			}
		}
	}
}

/**
 * 메뉴 핸들 :: 프로필 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlProfile(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}

	if (action == MenuAction_Select)
	{
		char sInfo[32];
		menu.GetItem(item, sInfo, sizeof(sInfo));
		int iInfo = StringToInt(sInfo);

		switch (iInfo)
		{
			default:
			{
				// 없음
			}
		}
	}

	if (action == MenuAction_Cancel)
	{
		if (item == MenuCancel_ExitBack)
		{
			Menu_Main(client, 0);
		}
	}
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
	return dds_hCV_PluginSwitch.BoolValue;
}