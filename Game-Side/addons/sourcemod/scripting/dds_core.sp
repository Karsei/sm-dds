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
#include <geoip>
#include <dds>

#define _DEBUG_

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

// 유저 소유
int dds_iUserMoney[MAXPLAYERS + 1];
int dds_iUserAppliedItem[MAXPLAYERS + 1][DDS_ENV_ITEMCG_MAX + 1];

/*******************************************************
 * P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = DDS_ENV_CORE_NAME,
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

	/** SQL 데이터베이스 연결 **/
	//Database.Connect(SQL_GetDatabase, "dds");
	SQL_TConnect(SQL_GetDatabase, "dds");

	/** 단축키 연결 **/
	// N 키
	RegConsoleCmd("nightvision", Menu_Main);
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

/**
 * 클라이언트가 접속하면서 스팀 고유번호를 받았을 때
 *
 * @param client			클라이언트 인덱스
 * @param auth				클라이언트 고유 번호(타입 2)
 */
public void OnClientAuthorized(client, const String:auth[])
{
	// 플러그인이 꺼져 있을 때는 동작 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	// 봇은 제외
	if (IsFakeClient(client))	return;

	// 유저 데이터 초기화
	Init_UserData(client, 2);

	// 유저 정보 확인
	CreateTimer(0.4, SQL_Timer_UserLoad, client);
}

/**
 * 클라이언트가 서버로부터 나가고 있을 때
 *
 * @param client			클라이언트 인덱스
 */
public void OnClientDisconnect(client)
{
	// 게임에 없으면 통과
	if (!IsClientInGame(client))	return;

	// 봇은 제외
	if (IsFakeClient(client))	return;

	// 클라이언트 고유 번호 추출
	char sUsrAuthId[20];
	GetClientAuthId(client, AuthId_SteamID64, sUsrAuthId, sizeof(sUsrAuthId));

	// 오류 검출 생성
	ArrayList hMakeErr = CreateArray(8);
	hMakeErr.Push(client);
	hMakeErr.Push(1013);
	hMakeErr.PushString("");

	// 유저 정보 갱신
	char sSendQuery[256];

	Format(sSendQuery, sizeof(sSendQuery), "UPDATE `dds_user_profile` SET `ingame` = '0' WHERE `authid` = '%s'", sUsrAuthId);
	dds_hSQLDatabase.Query(SQL_ErrorProcess, sSendQuery, hMakeErr);

	// 유저 데이터 초기화
	Init_UserData(client, 2);

	#if defined _DEBUG_
	DDS_PrintToServer(":: DEBUG :: User Disconnect - Update (client: %N)", client);
	#endif
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
	Format(dds_eItem[0][Name], 64, "EN:X");

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
	Format(dds_eItemCategory[0][Name], 64, "EN:Total||KO:전체");

	#if defined _DEBUG_
	DDS_PrintToServer(":: DEBUG :: Server Data Initialization Complete");
	#endif
}

/**
 * 초기화 :: 유저 데이터
 *
 * @param client			클라이언트 인덱스
 * @param mode				처리 모드(1 - 전체 초기화, 2 - 특정 클라이언트 초기화)
 */
public void Init_UserData(int client, int mode)
{
	switch (mode)
	{
		case 1:
		{
			/** 전체 초기화 **/
			for (int i = 0; i <= MAXPLAYERS; i++)
			{
				// 팀 채팅
				dds_bTeamChat[i] = false;

				// 금액
				dds_iUserMoney[i] = 0;

				// 장착 아이템
				for (int k = 0; k <= DDS_ENV_ITEMCG_MAX; k++)
				{
					dds_iUserAppliedItem[i][k] = 0;
				}
			}
		}
		case 2:
		{
			/** 특정 클라이언트 초기화 **/
			// 팀 채팅
			dds_bTeamChat[client] = false;

			// 금액
			dds_iUserMoney[client] = 0;

			// 장착 아이템
			for (int i = 0; i <= DDS_ENV_ITEMCG_MAX; i++)
			{
				dds_iUserAppliedItem[client][i] = 0;
			}
		}
	}

	#if defined _DEBUG_
	DDS_PrintToServer(":: DEBUG :: User Data Initialization Complete (client: %N, mode: %d)", client, mode);
	#endif
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
		case 1010:
		{
			// 유저가 접속하여 정보를 로드할 때
			Format(sOutput, sizeof(sOutput), "%s %t", sOutput, "error sql usrprofile load");
			Format(sDetOutput, sizeof(sDetOutput), "%s Retriving User Profile DB is Failure! (AuthID: %s)", sDetOutput, usrauth);
		}
		case 1011:
		{
			// 유저 체크 후 레코드가 없어 레코드를 만들 때
			Format(sOutput, sizeof(sOutput), "%s %t", sOutput, "error sql usrprofile make");
			Format(sDetOutput, sizeof(sDetOutput), "%s Making User Profile is Failure! (AuthID: %s)", sDetOutput, usrauth);
		}
		case 1012:
		{
			// 유저 체크 후 레코드가 있어 정보를 갱신할 때
			Format(sOutput, sizeof(sOutput), "%s %t", sOutput, "error sql usrprofile cnupdate");
			Format(sDetOutput, sizeof(sDetOutput), "%s Updating User Profile is Failure! (C&U) (AuthID: %s)", sDetOutput, usrauth);
		}
		case 1013:
		{
			// 유저가 서버로부터 나가면서 갱신 처리할 때
			Format(sOutput, sizeof(sOutput), "%s %t", sOutput, "error sql usrprofile dnupdate");
			Format(sDetOutput, sizeof(sDetOutput), "%s Updating User Profile is Failure! (D&U) (AuthID: %s)", sDetOutput, usrauth);
		}
		case 1014:
		{
			// 유저 체크하면서 프로필 목록이 잘못되었을 경우
			Format(sOutput, sizeof(sOutput), "%s %t", sOutput, "error sql usrprofile invalid");
			Format(sDetOutput, sizeof(sDetOutput), "%s Retrived User Profile DB is invalid. (AuthID: %s)", sDetOutput, usrauth);
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
	Init_UserData(0, 1);

	/** 데이터 로드 **/
	char sSendQuery[512];

	// 아이템 카테고리 로드
	Format(sSendQuery, sizeof(sSendQuery), "SELECT * FROM `dds_item_category` WHERE `status` = '1' ORDER BY `orderidx` ASC");
	dds_hSQLDatabase.Query(SQL_LoadItemCategory, sSendQuery, 0, DBPrio_High);
	// 아이템 목록 로드
	Format(sSendQuery, sizeof(sSendQuery), "SELECT * FROM `dds_item_list` ORDER BY `ilidx` ASC");
	dds_hSQLDatabase.Query(SQL_LoadItemList, sSendQuery, 0, DBPrio_High);
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
	Format(buffer, sizeof(buffer), "%t", "menu main buyitem");
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
		"%t\n \n%t: %s\n%t: %s\n%t: %d", 
		"menu myprofile introduce", "global nickname", sUsrName, "global authid", sUsrAuthId, "global money", dds_iUserMoney[client]);
	mMain.AddItem("1", buffer, ITEMDRAW_DISABLED);

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);

	return Plugin_Continue;
}

/**
 * 메뉴 :: 내 장착 아이템 메뉴 출력
 *
 * @param client			클라이언트 인덱스
*/
public Menu_CurItem(int client)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlCurItem);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t\n ", "menu common title", "menu common curpos", "menu main mycuritem");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 갯수 파악
	int count;

	// 정보 작성
	for (int i = 0; i <= dds_iItemCategoryCount; i++)
	{
		// '전체' 통과
		if (i == 0)	continue;

		// 번호를 문자열로 치환
		char sTempIdx[4];
		IntToString(dds_eItemCategory[i][Code], sTempIdx, sizeof(sTempIdx));

		// 클라이언트 국가에 따른 아이템과 종류 이름 추출
		char sCGName[16];
		char sItemName[32];
		SelectedGeoNameToString(client, dds_eItemCategory[i][Name], sCGName, sizeof(sCGName));
		SelectedGeoNameToString(client, dds_eItem[dds_iUserAppliedItem[client][i]][Name], sItemName, sizeof(sItemName));

		// 메뉴 아이템 등록
		Format(buffer, sizeof(buffer), "%t %s %t: %s", "menu mycuritem applied", sCGName, "global item", sItemName);
		mMain.AddItem(sTempIdx, buffer);

		// 갯수 증가
		count++;

		#if defined _DEBUG_
		DDS_PrintToChat(client, "\x05:: DEBUG ::\x01 My CurItem Menu ~ CG (ID: %d, CateName: %s, ItemName: %s, Count: %d)", i, sCGName, sItemName, count);
		#endif
	}

	// 아이템 종류가 없을 때
	if (count == 0)
	{
		// '없음' 출력
		Format(buffer, sizeof(buffer), "%t", "global none");
		mMain.AddItem("0", buffer, ITEMDRAW_DISABLED);
	}

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 내 인벤토리 메뉴 출력
 *
 * @param client			클라이언트 인덱스
*/
public Menu_Inven(int client)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlInven);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t\n ", "menu common title", "menu common curpos", "menu main myinven");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 갯수 파악
	int count;

	// 정보 작성
	for (int i = 0; i <= dds_iItemCategoryCount; i++)
	{
		// 번호를 문자열로 치환
		char sTempIdx[4];
		IntToString(dds_eItemCategory[i][Code], sTempIdx, sizeof(sTempIdx));

		// 클라이언트 국가에 따른 아이템 종류 이름 추출
		char sCGName[16];
		SelectedGeoNameToString(client, dds_eItemCategory[i][Name], sCGName, sizeof(sCGName));

		// 메뉴 아이템 등록
		Format(buffer, sizeof(buffer), "%s %t", sCGName, "global item");
		mMain.AddItem(sTempIdx, buffer);

		// 갯수 증가
		count++;

		#if defined _DEBUG_
		DDS_PrintToChat(client, "\x05:: DEBUG ::\x01 My Inven Menu ~ CG (ID: %d, CateName: %s, Count: %d)", i, sCGName, count);
		#endif
	}

	// 아이템 종류가 없을 때
	if (count == 0)
	{
		// '없음' 출력
		Format(buffer, sizeof(buffer), "%t", "global none");
		mMain.AddItem("0", buffer, ITEMDRAW_DISABLED);
	}

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 아이템 구매 메뉴 출력
 *
 * @param client			클라이언트 인덱스
*/
public Menu_BuyItem(int client)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlBuyItem);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t\n ", "menu common title", "menu common curpos", "menu main buyitem");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 갯수 파악
	int count;

	// 정보 작성
	for (int i = 0; i <= dds_iItemCategoryCount; i++)
	{
		// 번호를 문자열로 치환
		char sTempIdx[4];
		IntToString(dds_eItemCategory[i][Code], sTempIdx, sizeof(sTempIdx));

		// 클라이언트 국가에 따른 아이템 종류 이름 추출
		char sCGName[16];
		SelectedGeoNameToString(client, dds_eItemCategory[i][Name], sCGName, sizeof(sCGName));

		// 메뉴 아이템 등록
		Format(buffer, sizeof(buffer), "%s %t", sCGName, "global item");
		mMain.AddItem(sTempIdx, buffer);

		// 갯수 증가
		count++;

		#if defined _DEBUG_
		DDS_PrintToChat(client, "\x05:: DEBUG ::\x01 Buy Item Menu ~ CG (ID: %d, CateName: %s, Count: %d)", i, sCGName, count);
		#endif
	}

	// 아이템 종류가 없을 때
	if (count == 0)
	{
		// '없음' 출력
		Format(buffer, sizeof(buffer), "%t", "global none");
		mMain.AddItem("0", buffer, ITEMDRAW_DISABLED);
	}

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 아이템 구매-종류 세부 메뉴 출력
 *
 * @param client			클라이언트 인덱스
 * @param catecode			아이템 종류 코드
*/
public Menu_BuyItem_CateIn(int client, int catecode)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlBuyItem_CateIn);

	// 클라이언트 국가에 따른 아이템 종류 이름 추출
	char sCGName[16];
	for (int i = 0; i <= dds_iItemCategoryCount; i++)
	{
		if (catecode != dds_eItemCategory[i][Code])	continue;

		SelectedGeoNameToString(client, dds_eItemCategory[i][Name], sCGName, sizeof(sCGName));
		break;
	}

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t-%s\n ", "menu common title", "menu common curpos", "menu main buyitem", sCGName);
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 갯수 파악
	int count;

	// 정보 작성
	for (int i = 0; i <= dds_iItemCount; i++)
	{
		// 0번은 제외
		if (i == 0)	continue;

		// '전체'' 항목이 아니면서 선택한 아이템 종류가 아닌 아이템은 제외
		if ((catecode != dds_eItem[i][CateCode]) && catecode != 0)	continue;

		// 번호를 문자열로 치환
		char sTempIdx[4];
		IntToString(i, sTempIdx, sizeof(sTempIdx));

		// 클라이언트 국가에 따른 아이템 이름 추출
		char sItemName[32];
		SelectedGeoNameToString(client, dds_eItem[i][Name], sItemName, sizeof(sItemName));

		// 메뉴 아이템 등록
		Format(buffer, sizeof(buffer), "%s - %d %t", sItemName, dds_eItem[i][Money], "global money");
		mMain.AddItem(sTempIdx, buffer);

		// 갯수 증가
		count++;

		#if defined _DEBUG_
		DDS_PrintToChat(client, "\x05:: DEBUG ::\x01 Buy Item-CateIn Menu ~ CG (CateCode: %d, ItemName: %s, ItemIdx: %d, Count: %d)", catecode, sItemName, i, count);
		#endif
	}

	// 아이템 종류가 없을 때
	if (count == 0)
	{
		// '없음' 출력
		Format(buffer, sizeof(buffer), "%t", "global none");
		mMain.AddItem("0", buffer, ITEMDRAW_DISABLED);
	}

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 아이템 구매-정보 세부 메뉴 출력
 *
 * @param client			클라이언트 인덱스
 * @param itemidx			아이템 번호
*/
public Menu_BuyItem_ItemDetail(int client, int itemidx)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlBuyItem_ItemDetail);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t-%t\n ", "menu common title", "menu common curpos", "menu main buyitem", "menu main buyitem check");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 전달 파라메터 기초 생성
	char sParam[8];
	Format(sParam, sizeof(sParam), "%d||%d||", itemidx, dds_eItem[itemidx][CateCode]);

	// 클라이언트 국가에 따른 아이템 종류 이름 추출
	char sItemName[32];
	SelectedGeoNameToString(client, dds_eItem[itemidx][Name], sItemName, sizeof(sItemName));

	// 메뉴 아이템 등록
	Format(buffer, sizeof(buffer), "%t", "global confirm");
	Format(sParam, sizeof(sParam), "%s%d", sParam, 1);
	mMain.AddItem(sParam, buffer);
	Format(buffer, sizeof(buffer), "%t\n ", "global cancel");
	Format(sParam, sizeof(sParam), "%s%d", sParam, 2);
	mMain.AddItem(sParam, buffer);
	Format(buffer, sizeof(buffer), "%t\n \n%t: %s\n%t: %d", "menu buyitem willbuy", "global name", sItemName, "global money", dds_eItem[itemidx][Money]);
	mMain.AddItem("0", buffer, ITEMDRAW_DISABLED);

	#if defined _DEBUG_
	DDS_PrintToChat(client, "\x05:: DEBUG ::\x01 Buy Item-ItemDetail Menu ~ CG (ItemIdx: %d, ItemName: %s)", itemidx, sItemName);
	#endif

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 설정 메뉴 출력
 *
 * @param client			클라이언트 인덱스
*/
public Menu_Setting(int client)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlSetting);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t\n ", "menu common title", "menu common curpos", "menu main setting");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 메뉴 아이템 등록
	Format(buffer, sizeof(buffer), "%t", "menu setting system");
	mMain.AddItem("1", buffer);
	Format(buffer, sizeof(buffer), "%t", "menu setting item");
	mMain.AddItem("2", buffer);

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 설정-시스템 메뉴 출력
 *
 * @param client			클라이언트 인덱스
*/
public Menu_Setting_System(int client)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlSetting_System);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t\n ", "menu common title", "menu common curpos", "menu setting system");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 메뉴 아이템 등록
	Format(buffer, sizeof(buffer), "%t", "global none");
	mMain.AddItem("1", buffer, ITEMDRAW_DISABLED);

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 설정-아이템 메뉴 출력
 *
 * @param client			클라이언트 인덱스
*/
public Menu_Setting_Item(int client)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlSetting_Item);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t\n ", "menu common title", "menu common curpos", "menu setting item");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 갯수 파악
	int count;

	// 정보 작성
	for (int i = 0; i <= dds_iItemCategoryCount; i++)
	{
		// '전체' 통과
		if (i == 0)	continue;
		
		// 번호를 문자열로 치환
		char sTempIdx[4];
		IntToString(dds_eItemCategory[i][Code], sTempIdx, sizeof(sTempIdx));

		// 클라이언트 국가에 따른 아이템 종류 이름 추출
		char sCGName[16];
		SelectedGeoNameToString(client, dds_eItemCategory[i][Name], sCGName, sizeof(sCGName));

		// 메뉴 아이템 등록
		Format(buffer, sizeof(buffer), "%s %t", sCGName, "global item");
		mMain.AddItem(sTempIdx, buffer);

		// 갯수 증가
		count++;

		#if defined _DEBUG_
		DDS_PrintToChat(client, "\x05:: DEBUG ::\x01 Setting-Item Menu ~ CG (ID: %d, CateName: %s, Count: %d)", i, sCGName, count);
		#endif
	}

	// 아이템 종류가 없을 때
	if (count == 0)
	{
		// '없음' 출력
		Format(buffer, sizeof(buffer), "%t", "global none");
		mMain.AddItem("0", buffer, ITEMDRAW_DISABLED);
	}

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 플러그인 정보 메뉴 출력
 *
 * @param client			클라이언트 인덱스
*/
public Menu_PluginInfo(int client)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlPluginInfo);

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %t\n ", "menu common title", "menu common curpos", "menu main plugininfo");
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 메뉴 아이템 등록
	Format(buffer, sizeof(buffer), "%t", "menu plugininfo cmd");
	mMain.AddItem("1", buffer);
	Format(buffer, sizeof(buffer), "%t", "menu plugininfo author");
	mMain.AddItem("2", buffer);
	Format(buffer, sizeof(buffer), "%t", "menu plugininfo license");
	mMain.AddItem("3", buffer);

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
}

/**
 * 메뉴 :: 플러그인 정보-세부 메뉴 출력
 *
 * @param client			클라이언트 인덱스
*/
public Menu_PluginInfo_Detail(int client, int select)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return;

	char buffer[256];
	Menu mMain = new Menu(Main_hdlPluginInfo_Detail);

	// 세부 제목 설정
	char sDetailTitle[32];
	switch (select)
	{
		case 1:
		{
			Format(sDetailTitle, sizeof(sDetailTitle), "%t", "menu plugininfo cmd");
		}
		case 2:
		{
			Format(sDetailTitle, sizeof(sDetailTitle), "%t", "menu plugininfo author");
		}
		case 3:
		{
			Format(sDetailTitle, sizeof(sDetailTitle), "%t", "menu plugininfo license");
		}
	}

	// 제목 설정
	Format(buffer, sizeof(buffer), "%t\n%t: %s\n ", "menu common title", "menu common curpos", sDetailTitle);
	mMain.SetTitle(buffer);
	mMain.ExitBackButton = true;

	// 메뉴 아이템 등록
	switch (select)
	{
		case 1:
		{
			// 명령어 정보
			Format(buffer, sizeof(buffer), "!%s: %t", DDS_ENV_USER_MAINMENU, "menu plugininfo cmd desc main");
			mMain.AddItem("1", buffer);
		}
		case 2:
		{
			// 개발자 정보
			Format(buffer, sizeof(buffer), "%s - v%s\n ", DDS_ENV_CORE_NAME, DDS_ENV_CORE_VERSION);
			mMain.AddItem("1", buffer);
			Format(buffer, sizeof(buffer), "Made By. Karsei\n(http://karsei.pe.kr)");
			mMain.AddItem("2", buffer);
		}
		case 3:
		{
			// 저작권 정보
			Format(buffer, sizeof(buffer), "GNU General Public License 3 (GNU GPL v3)\n ");
			mMain.AddItem("1", buffer);
			Format(buffer, sizeof(buffer), "%t: http://www.gnu.org/licenses/", "menu plugininfo license detail");
			mMain.AddItem("2", buffer);
		}
	}

	// 메뉴 출력
	mMain.Display(client, MENU_TIME_FOREVER);
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
		dds_eItemCategory[dds_iItemCategoryCount + 1][Code] = results.FetchInt(0);
		results.FetchString(1, dds_eItemCategory[dds_iItemCategoryCount + 1][Name], 64);

		#if defined _DEBUG_
		DDS_PrintToServer(":: DEBUG :: Category Loaded (ID: %d, GloName: %s, TotalCount: %d)", dds_eItemCategory[dds_iItemCategoryCount + 1][Code], dds_eItemCategory[dds_iItemCategoryCount + 1][Name], dds_iItemCategoryCount + 1);
		#endif

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
		dds_eItem[dds_iItemCount + 1][Index] = results.FetchInt(0);
		results.FetchString(1, dds_eItem[dds_iItemCount + 1][Name], 64);
		dds_eItem[dds_iItemCount + 1][CateCode] = results.FetchInt(2);
		dds_eItem[dds_iItemCount + 1][Money] = results.FetchInt(3);
		dds_eItem[dds_iItemCount + 1][HavTime] = results.FetchInt(4);
		results.FetchString(5, dds_eItem[dds_iItemCount + 1][Env], 256);

		#if defined _DEBUG_
		DDS_PrintToServer(":: DEBUG :: Item Loaded (ID: %d, GloName: %s, CateCode: %d, Money: %d, Time: %d, TotalCount: %d)", dds_eItem[dds_iItemCount + 1][Index], dds_eItem[dds_iItemCount + 1][Name], dds_eItem[dds_iItemCount + 1][CateCode], dds_eItem[dds_iItemCount + 1][Money], dds_eItem[dds_iItemCount + 1][HavTime], dds_iItemCount + 1);
		#endif

		// 아이템 등록 갯수 증가
		dds_iItemCount++;
	}
}

/**
 * SQL 유저 :: 유저 정보 로드 딜레이
 *
 * @param timer					타이머 핸들
 * @param client				클라이언트 인덱스
 */
public Action:SQL_Timer_UserLoad(Handle timer, any client)
{
	// 플러그인이 켜져 있을 때에는 작동 안함
	if (!dds_hCV_PluginSwitch.BoolValue)	return Plugin_Stop;

	// 클라이언트 고유 번호 추출
	char sUsrAuthId[20];
	GetClientAuthId(client, AuthId_SteamID64, sUsrAuthId, sizeof(sUsrAuthId));

	// 데이터 로드
	char sSendQuery[512];

	Format(sSendQuery, sizeof(sSendQuery), "SELECT * FROM `dds_user_profile` WHERE `authid` = '%s'", sUsrAuthId);
	dds_hSQLDatabase.Query(SQL_UserLoad, sSendQuery, client);

	return Plugin_Stop;
}

/**
 * SQL 유저 :: 유저 정보 로드
 *
 * @param db					데이터베이스 연결 핸들
 * @param results				결과 쿼리
 * @param error					오류 문자열
 * @param client				클라이언트 인덱스
 */
public void SQL_UserLoad(Database db, DBResultSet results, const char[] error, any client)
{
	// 쿼리 오류 검출
	if (db == null || error[0])
	{
		LogCodeError(client, 1010, error);
		return;
	}

	// 갯수 파악
	int count;

	// 임시 정보 저장
	int iTempMoney;

	// 쿼리 결과
	while (results.MoreRows)
	{
		// 제시할 행이 없다면 통과
		if (!results.FetchRow())	continue;

		// 데이터 추가
		iTempMoney = results.FetchInt(2);

		// 유저 파악 갯수 증가
		count++;

		#if defined _DEBUG_
		DDS_PrintToServer(":: DEBUG :: User Load - Checked (client: %N, Money: %d)", client, iTempMoney);
		#endif
	}

	/** 추후 작업 **/
	char sSendQuery[256];

	// 클라이언트 고유 번호 추출
	char sUsrAuthId[20];
	GetClientAuthId(client, AuthId_SteamID64, sUsrAuthId, sizeof(sUsrAuthId));

	if (count == 0)
	{
		/** 등록된 것이 없다면 정보 생성 **/
		// 오류 검출 생성
		ArrayList hMakeErr = CreateArray(8);
		hMakeErr.Push(client);
		hMakeErr.Push(1011);
		hMakeErr.PushString("");

		// 쿼리 전송
		Format(sSendQuery, sizeof(sSendQuery), "INSERT INTO `dds_user_profile` (`idx`, `authid`, `money`, `ingame`) VALUES (NULL, '%s', '0', '1')", sUsrAuthId);
		dds_hSQLDatabase.Query(SQL_ErrorProcess, sSendQuery, hMakeErr);

		#if defined _DEBUG_
		DDS_PrintToServer(":: DEBUG :: User Load - Make (client: %N)", client);
		#endif
	}
	else if (count == 1)
	{
		/** 등록된 것이 있다면 정보 로드 및 갱신 **/
		// 오류 검출 생성
		ArrayList hMakeErr = CreateArray(8);
		hMakeErr.Push(client);
		hMakeErr.Push(1012);
		hMakeErr.PushString("");

		// 금액 로드
		dds_iUserMoney[client] = iTempMoney;

		// 인게임 처리
		Format(sSendQuery, sizeof(sSendQuery), "UPDATE `dds_user_profile` SET `ingame` = '1' WHERE `authid` = '%s'", sUsrAuthId);
		dds_hSQLDatabase.Query(SQL_ErrorProcess, sSendQuery, hMakeErr);

		#if defined _DEBUG_
		DDS_PrintToServer(":: DEBUG :: User Load - Update (client: %N)", client);
		#endif
	}
	else
	{
		/** 잘못된 정보 **/
		LogCodeError(client, 1014, "The number of this user profile db must be one.");
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
				Menu_CurItem(client);
			}
			case 3:
			{
				// 내 인벤토리
				Menu_Inven(client);
			}
			case 4:
			{
				// 아이템 구매
				Menu_BuyItem(client);
			}
			case 5:
			{
				// 설정
				Menu_Setting(client);
			}
			case 9:
			{
				// 플러그인 정보
				Menu_PluginInfo(client);
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

/**
 * 메뉴 핸들 :: 내 장착 아이템 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlCurItem(Menu menu, MenuAction action, int client, int item)
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
			/**
			 * iInfo
			 * 
			 * @Desc 등록된 아이템 종류 코드 ('전체' 없음)
			 */
			default:
			{
				// 아직 없음
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

/**
 * 메뉴 핸들 :: 내 인벤토리 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlInven(Menu menu, MenuAction action, int client, int item)
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
			/**
			 * iInfo
			 * 
			 * @Desc 등록된 아이템 종류 코드
			 */
			default:
			{
				// 아직 없음
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

/**
 * 메뉴 핸들 :: 아이템 구매 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlBuyItem(Menu menu, MenuAction action, int client, int item)
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

		/**
		 * iInfo
		 * 
		 * @Desc 등록된 아이템 종류 코드
		 */
		Menu_BuyItem_CateIn(client, iInfo);
	}

	if (action == MenuAction_Cancel)
	{
		if (item == MenuCancel_ExitBack)
		{
			Menu_Main(client, 0);
		}
	}
}

/**
 * 메뉴 핸들 :: 아이템 구매-종류 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlBuyItem_CateIn(Menu menu, MenuAction action, int client, int item)
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

		/**
		 * iInfo
		 * 
		 * @Desc 등록된 아이템 번호
		 */
		Menu_BuyItem_ItemDetail(client, iInfo);
	}

	if (action == MenuAction_Cancel)
	{
		if (item == MenuCancel_ExitBack)
		{
			Menu_BuyItem(client);
		}
	}
}

/**
 * 메뉴 핸들 :: 아이템 구매-정보 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlBuyItem_ItemDetail(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}

	char sInfo[32];
	menu.GetItem(item, sInfo, sizeof(sInfo));

	// 파라메터 분리
	char sGetParam[3][8];
	ExplodeString(sInfo, "||", sGetParam, sizeof(sGetParam), sizeof(sGetParam[]));

	if (action == MenuAction_Select)
	{
		/**
		 * sGetParam
		 * 
		 * @Desc [1] - 아이템 번호, [2] - 아이템 종류 코드, [3] 1 - 확인 / 2- 취소 
		 */
		switch (StringToInt(sGetParam[2]))
		{
			case 1:
			{
				// 확인
			}
			case 2:
			{
				// 취소
				// 없음(그냥 닫게 만듬)
			}
		}
	}

	if (action == MenuAction_Cancel)
	{
		if (item == MenuCancel_ExitBack)
		{
			Menu_BuyItem_CateIn(client, StringToInt(sGetParam[1]));
		}
	}
}


/**
 * 메뉴 핸들 :: 설정 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlSetting(Menu menu, MenuAction action, int client, int item)
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
			/**
			 * iInfo
			 * 
			 * @Desc 1 - 시스템 설정, 2 - 아이템 활성화 상태 설정
			 */
			case 1:
			{
				// 시스템 설정
				Menu_Setting_System(client);
			}
			case 2:
			{
				// 아이템 설정
				Menu_Setting_Item(client);
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

/**
 * 메뉴 핸들 :: 설정-시스템 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlSetting_System(Menu menu, MenuAction action, int client, int item)
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
			/**
			 * iInfo
			 * 
			 * @Desc 아직 없음
			 */
			case 1:
			{
				// 아직 없음
			}
		}
	}

	if (action == MenuAction_Cancel)
	{
		if (item == MenuCancel_ExitBack)
		{
			Menu_Setting(client);
		}
	}
}

/**
 * 메뉴 핸들 :: 설정-아이템 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlSetting_Item(Menu menu, MenuAction action, int client, int item)
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
			/**
			 * iInfo
			 * 
			 * @Desc 등록된 아이템 종류 코드
			 */
			case 1:
			{
				// 아직 없음
			}
		}
	}

	if (action == MenuAction_Cancel)
	{
		if (item == MenuCancel_ExitBack)
		{
			Menu_Setting(client);
		}
	}
}

/**
 * 메뉴 핸들 :: 플러그인 정보 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlPluginInfo(Menu menu, MenuAction action, int client, int item)
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

		/**
		 * iInfo
		 * 
		 * @Desc 1 - 명령어 정보, 2 - 개발자 정보, 3 - 저작권 정보
		 */
		if ((iInfo > 0) && (iInfo < 4))
		{
			Menu_PluginInfo_Detail(client, iInfo);
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

/**
 * 메뉴 핸들 :: 플러그인 정보-세부 메뉴 핸들러
 *
 * @param menu				메뉴 핸들
 * @param action			메뉴 액션
 * @param client 			클라이언트 인덱스
 * @param item				메뉴 아이템 소유 문자열
 */
public Main_hdlPluginInfo_Detail(Menu menu, MenuAction action, int client, int item)
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
			/**
			 * iInfo
			 * 
			 * @Desc 없음
			 */
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
			Menu_PluginInfo(client);
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