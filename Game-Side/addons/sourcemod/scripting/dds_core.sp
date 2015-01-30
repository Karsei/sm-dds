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
enum Item
{
	Index,
	String:Name[64],
	CateCode,
	Money,
	HavTime,
	String:Env[256]
}

enum ItemCG
{
	String:Name[64],
	Code,
	String:Env[256]
}


/*******************************************************
 * V A R I A B L E S
*******************************************************/
// SQL 데이터베이스
Database dds_hSQLDatabase = null;

// 로그 파일
char dds_sPluginLogFile[256];

// Convar 변수
ConVar dds_hCV_PluginSwitch;
ConVar dds_hCV_SwitchDisplayChat;
//ConVar dds_hCV_SwtichLog;

// 팀 채팅
bool dds_bTeamChat[MAXPLAYERS + 1];

// 아이템
int dds_iItemCount;
int dds_eItem[DDS_ENV_ITEM_MAX + 1][Item];

// 아이템 종류
int dds_iItemCategoryCount;
int dds_eItemCategory[DDS_ENV_ITEMCG_MAX + 1][ItemCG];

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
	//Database.Connect(SQL_GetDatabase, "dds");
	SQL_TConnect(SQL_GetDatabase, "dds");
}

/**
 * 맵이 종료된 후
 */
public void OnMapEnd()
{
	// SQL 데이터베이스 핸들 초기화
	if (dds_hSQLDatabase != null)
	{
		delete dds_hSQLDatabase;
	}
	dds_hSQLDatabase = null;
}


/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/**
 * 초기화 :: 서버 데이터
 */
public void Init_ServerData()
{
	/** 아이템 **/
	// 아이템 갯수
	dds_iItemCount = 0;
	// 아이템 목록
	for (int i = 0; i <= DDS_ENV_ITEM_MAX; i++)
	{
		dds_eItem[i][Index] = 0;
		Format(dds_eItem[i][Name], 64, "");
		dds_eItem[i][CateCode] = 0;
		dds_eItem[i][Money] = 0;
		dds_eItem[i][HavTime] = 0;
		Format(dds_eItem[i][Env], 256, "");
	}
	// 아이템 0번 'X' 설정
	Format(dds_eItem[0][Name], 64, "X");

	/** 아이템 종류 **/
	// 아이템 종류 갯수
	dds_iItemCategoryCount = 0;
	// 아이템 종류 목록
	for (int i = 0; i <= DDS_ENV_ITEMCG_MAX; i++)
	{
		Format(dds_eItemCategory[i][Name], 64, "");
		dds_eItemCategory[i][Code] = 0;
		Format(dds_eItemCategory[i][Env], 256, "");
	}
	// 아이템 종류 0번 '전체' 설정
	Format(dds_eItemCategory[0][Name], 64, "전체Total");
}

/**
 * 초기화 :: 유저 데이터
 */
public void Init_UserData()
{
	/** 채팅 **/
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		// 팀 채팅
		dds_bTeamChat[i] = false;
	}
}


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
		Format(sPrefix, sizeof(sPrefix), "[Error :: ID %d]", errcode);
		if (strlen(sErrDesc) > 0) Format(sErrDesc, sizeof(sErrDesc), "[Error Desc :: ID %d] %s", errcode, anydata);
	}
	else if (client == 0) // 서버
	{
		Format(sPrefix, sizeof(sPrefix), "[%t :: ID %d]", "error occurred", errcode);
		if (strlen(sErrDesc) > 0) Format(sErrDesc, sizeof(sErrDesc), "[%t :: ID %d] %s", "error desc", errcode, anydata);
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
		case 1001:
		{
			// SQL 데이터베이스 핸들 전달 실패
			Format(sDetOutput, sizeof(sDetOutput), "%s Database Handle is null!", sDetOutput);
		}
		case 1002:
		{
			// SQL 데이터베이스 초기화 시 아이템 카테고리 로드
			Format(sDetOutput, sizeof(sDetOutput), "%s Retriving Item Category DB is Failure!", sDetOutput);
		}
		case 1003:
		{
			// SQL 데이터베이스 초기화 시 아이템 목록 로드
			Format(sDetOutput, sizeof(sDetOutput), "%s Retriving Item List DB is Failure!", sDetOutput);
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
 * SQL :: 초기화 및 SQL 데이터베이스에 있는 데이터 로드
 */
public void SQL_DDSDatabaseInit()
{
	/** 초기화 **/
	// 서버
	Init_ServerData();
	// 유저
	Init_UserData();

	/** 데이터 로드 **/
	// 아이템 카테고리 로드
	dds_hSQLDatabase.Query(SQL_LoadItemCategory, "SELECT * FROM `dds_item_category` WHERE `status`='1' ORDER BY `orderidx` ASC", 0, DBPrio_High);
	// 아이템 목록 로드
	dds_hSQLDatabase.Query(SQL_LoadItemList, "SELECT * FROM `dds_item_list` ORDER BY `ilidx` ASC", 0, DBPrio_High);
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
		"%t\n \n%t: %s\n%t: %s", 
		"menu introduce myprofile", "global nickname", sUsrName, "global authid", sUsrAuthId);
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
	if (sParamIdx == -1)
	{
		strcopy(sMainCmd, sizeof(sMainCmd), sMsg[1]);
		strcopy(sParamStr[0], 64, sMsg[1]);
	}

	// 느낌표나 슬래시가 있다면 제거
	ReplaceString(sMainCmd, sizeof(sMainCmd), "!", "", false);
	ReplaceString(sMainCmd, sizeof(sMainCmd), "/", "", false);

	// 메인 메뉴
	if (StrEqual(sMainCmd, DDS_ENV_USER_MAINMENU, false))
	{
		Menu_Main(client, 0);
	}

	// 팀 채팅 기록 초기화
	dds_bTeamChat[client] = false;

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
//public void SQL_GetDatabase(Database db, const char[] error, any data)
public void SQL_GetDatabase(Handle owner, Handle db, const char[] error, any data)
{
	// 데이터베이스 연결 안될 때
	if ((db == null) || (error[0]))
	{
		LogCodeError(0, 1000, error);
		return;
	}

	// SQL 데이터베이스 핸들 등록
	dds_hSQLDatabase = db;

	if (dds_hSQLDatabase == null)
	{
		LogCodeError(0, 1001, error);
		return;
	}

	// UTF-8 설정
	dds_hSQLDatabase.SetCharset("utf8");

	// 초기화 및 SQL 데이터베이스에 있는 데이터 로드
	SQL_DDSDatabaseInit();
}

/**
 * SQL :: 일반 SQL 쿼리 오류 발생 시
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
 * SQL 초기 데이터 :: 아이템 카테고리
 *
 * @param db					데이터베이스 연결 핸들
 * @param results				결과 쿼리
 * @param error					오류 문자열
 * @param data					기타
 */
public void SQL_LoadItemCategory(Database db, DBResultSet results, const char[] error, any data)
{
	// 쿼리 오류 검출
	if (db == null || error[0])
	{
		LogCodeError(0, 1002, error);
		return;
	}

	// 쿼리 결과
	while (results.MoreRows)
	{
		// 제시할 행이 없다면 통과
		if (!results.FetchRow())	continue;

		// 데이터 추가
		dds_eItemCategory[dds_iItemCategoryCount][Code] = results.FetchInt(0);
		results.FetchString(1, dds_eItemCategory[dds_iItemCategoryCount][Name], 64);

		// 아이템 종류 등록 갯수 증가
		dds_iItemCategoryCount++;
	}
}

/**
 * SQL 초기 데이터 :: 아이템 목록
 *
 * @param db					데이터베이스 연결 핸들
 * @param results				결과 쿼리
 * @param error					오류 문자열
 * @param data					기타
 */
public void SQL_LoadItemList(Database db, DBResultSet results, const char[] error, any data)
{
	// 쿼리 오류 검출
	if (db == null || error[0])
	{
		LogCodeError(0, 1003, error);
		return;
	}

	// 쿼리 결과
	while (results.MoreRows)
	{
		// 제시할 행이 없다면 통과
		if (!results.FetchRow())	continue;

		// 데이터 추가
		dds_eItem[dds_iItemCount][Index] = results.FetchInt(0);
		results.FetchString(1, dds_eItem[dds_iItemCount][Name], 64);
		dds_eItem[dds_iItemCount][CateCode] = results.FetchInt(2);
		dds_eItem[dds_iItemCount][Money] = results.FetchInt(3);
		dds_eItem[dds_iItemCount][HavTime] = results.FetchInt(4);
		results.FetchString(5, dds_eItem[dds_iItemCount][Env], 256);

		// 아이템 등록 갯수 증가
		dds_iItemCount++;
	}
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