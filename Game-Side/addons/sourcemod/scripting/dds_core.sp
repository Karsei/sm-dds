/************************************************************************
 * Dynamic Dollar Shop - [Core] Core (Sourcemod)
 * 
 * Copyright (C) 2012-2013 Eakgnarok
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
************************************************************************/
#include <sourcemod>
#include <sdktools>
#include <dds>

/*******************************************************
 E N U M S
*******************************************************/
enum CONVAR
{
	Handle:HPLUGINSWITCH,
	Handle:HDATALOGSWITCH,
	Handle:HDATALOGDBSWITCH,
	Handle:HDATALOGDATESWITCH,
	Handle:HDATALOGJMSGSWITCH,
	Handle:HCHATLOGSWITCH,
	Handle:HCHATLOGDBSWITCH,
	Handle:HCHATLOGDATESWITCH,
	Handle:HREPAIRDBSWITCH,
	Handle:HGIFTSWITCH,
	Handle:HITEMGIFTSWITCH,
	Handle:HAUTOADMINSETSWITCH,
	Handle:HFRTAGSAVESWITCH,
	Handle:HFASTKEYF1SWITCH,
	Handle:HFASTKEYF2SWITCH,
	Handle:HFASTKEYNSWITCH,
	Handle:HCHATLINK,
	Handle:HITEMCODENOUSE,
	Handle:HLIMITPEOPLEGETMONEY,
	Handle:HMULTIPLYMONEY,
	Handle:HITEMSELLRATIO,
	Handle:HLIMITRANKNUMBER
}

enum ITEMSET
{
	ITEMID,
	String:ITEMNAME[64],
	ITEMCODE,
	String:ITEMADRS[128],
	ITEMCOLOR[4],
	ITEMPRICE,
	ITEMPROC,
	ITEMPOS[3],
	ITEMANG[3],
	ITEMSPECIAL,
	ITEMTIME,
	String:ITEMOPTION[64],
	ITEMUSE
}

/*******************************************************
 V A R I A B L E S
*******************************************************/
// Cvar 핸들
new dds_eConvar[CONVAR];

// 포워드 처리
new Handle:dds_hClientSetItem = INVALID_HANDLE;
new Handle:dds_hClientBuyItem = INVALID_HANDLE;

// 로그
new Handle:dds_hUserDataLogFile = INVALID_HANDLE;
new Handle:dds_hUserIPLogFile = INVALID_HANDLE;
new Handle:dds_hUserChatLogFile = INVALID_HANDLE;
new String:dds_sPluginLogFile[256];
new String:dds_sUserDataLogFile[256];
new String:dds_sUserIPLogFile[256];
new String:dds_sUserChatLogFile[256];
new bool:dds_bUserRepairLog[MAXPLAYERS+1][2];

// SQL 데이터베이스
new Handle:dds_hDatabase = INVALID_HANDLE;
new dds_iDatabaseUpStatus;
new bool:dds_bIsCheckDataBase;
new bool:dds_bUserDatabaseUse[MAXPLAYERS+1];

// 유저 아이템 관련 저장 데이터베이스
new bool:dds_bUserStatus[MAXPLAYERS+1][ITEMCATEGORY_NUMBER+1];
new dds_iUserMoney[MAXPLAYERS+1];
new dds_iUserClass[MAXPLAYERS+1];
new String:dds_sUserItemName[MAXPLAYERS+1][ITEMCATEGORY_NUMBER+1][64];
new dds_iUserItemID[MAXPLAYERS+1][ITEMCATEGORY_NUMBER+1];
new dds_iUserItemCount[MAXPLAYERS+1][MAXITEM+1];
new dds_iUserItemTime[MAXPLAYERS+1][MAXITEM+1];
new dds_iUserTempData[MAXPLAYERS+1][3];

// 아이템 처리
// dds_eItem 과 dds_iModelCode 의 배열 중 MAXITEM 쪽 부분은 삭제하지 않도록 합니다. (메모리 접근성 오류)
new String:dds_sGetItemCodeList[ITEMCATEGORY_NUMBER+1][3][64];
new String:dds_sItemCodeName[ITEMCATEGORY_NUMBER+1][32];
new bool:dds_bItemCodeUse[ITEMCATEGORY_NUMBER+1];
new dds_iModelCode[MAXITEM+1][ITEMCATEGORY_NUMBER+1][2];
new dds_iCurItem = 1;
new dds_eItem[MAXITEM+1][ITEMSET];

// 채팅
new bool:dds_bTeamChat[MAXPLAYERS+1];
new bool:dds_bFreeTag[MAXPLAYERS+1][2];
new String:dds_sFreeTag[MAXPLAYERS+1][64];

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Core] Core",
	author = "Eakgnarok",
	description = "Many clients can allow to use several items in the game.",
	version = DDS_PLUGIN_VERSION,
	url = "http://eakgnarok.pe.kr"
};

/*******************************************************
 F O R W A R D   F U N C T I O N S
*******************************************************/
public OnPluginStart()
{
	CreateConVar("sm_dynamicdollarshop_version", DDS_PLUGIN_VERSION, "Made By. Eakgnarok", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	dds_eConvar[HPLUGINSWITCH] = CreateConVar("dds_switch_plugin", "1", "본 플러그인의 작동 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HDATALOGSWITCH] = CreateConVar("dds_switch_datalog", "1", "유저의 상점 이용 내역과 관한 로그를 작성할지의 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HDATALOGDBSWITCH] = CreateConVar("dds_switch_datalog_db", "2", "유저의 상점 이용 내역과 관한 로그를 기록할 데이터베이스를 무엇으로 사용할지 정하는 곳입니다. MySQL을 원하신다면 1을, 텍스트 파일을 원하신다면 2을 써주세요.", FCVAR_PLUGIN, true, 1.0, true, 2.0);
	dds_eConvar[HDATALOGDATESWITCH] = CreateConVar("dds_switch_datalog_date", "1", "(텍스트의 경우만 지원)유저의 상점 이용 내역과 관한 로그를 작성할 때, 날짜별로 작성할 지의 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HDATALOGJMSGSWITCH] = CreateConVar("dds_switch_datalog_jmsg", "0", "유저의 상점 이용 내역과 관한 로그를 작성할 때, '게임 참여/퇴장'(서버의 '접속/접속 해제'와는 다릅니다)의 출력 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HCHATLOGSWITCH] = CreateConVar("dds_switch_chatlog", "1", "유저들의 채팅 내용에 관한 로그를 작성할지의 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HCHATLOGDBSWITCH] = CreateConVar("dds_switch_chatlog_db", "2", "유저들의 채팅 내용에 관한 로그를 기록할 데이터베이스를 무엇으로 사용할지 정하는 곳입니다. MySQL을 원하신다면 1을, 텍스트 파일을 원하신다면 2을 써주세요.", FCVAR_PLUGIN, true, 1.0, true, 2.0);
	dds_eConvar[HCHATLOGDATESWITCH] = CreateConVar("dds_switch_chatlog_date", "1", "(텍스트의 경우만 지원)유저들의 채팅 내용에 관한 로그를 작성할 때, 날짜별로 작성할 지의 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HREPAIRDBSWITCH] = CreateConVar("dds_switch_repair", "1", "복구 시스템의 작동 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HGIFTSWITCH] = CreateConVar("dds_switch_gift", "1", "일반 유저들이 금액 선물 기능을 이용할 수 있을지의 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HITEMGIFTSWITCH] = CreateConVar("dds_switch_itemgift", "1", "일반 유저들이 아이템 선물 기능을 이용할 수 있을지의 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HAUTOADMINSETSWITCH] = CreateConVar("dds_switch_autoadmin", "0", "소스모드 어드민을 자동으로 달러샵에서 관리 등급으로 설정하게할지의 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HFRTAGSAVESWITCH] = CreateConVar("dds_switch_save_freetag", "1", "일회용 자유 태그를 장착 시 설정한 태그 문자열이 저장될지의 여부입니다('일회용' 기준이 달라집니다). 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HFASTKEYF1SWITCH] = CreateConVar("dds_switch_use_key_f1", "0", "F1키 단축키 설정입니다. 0 - 작동 해제, 1 - 달러샵 메뉴, 2 - 인벤토리, 3 - 3인칭", FCVAR_PLUGIN, true, 0.0, true, 3.0);
	dds_eConvar[HFASTKEYF2SWITCH] = CreateConVar("dds_switch_use_key_f2", "0", "F2키 단축키 설정입니다. 0 - 작동 해제, 1 - 달러샵 메뉴, 2 - 인벤토리, 3 - 3인칭", FCVAR_PLUGIN, true, 0.0, true, 3.0);
	dds_eConvar[HFASTKEYNSWITCH] = CreateConVar("dds_switch_use_key_n", "1", "N키 단축키 설정입니다. 0 - 작동 해제, 1 - 달러샵 메뉴, 2 - 인벤토리, 3 - 3인칭", FCVAR_PLUGIN, true, 0.0, true, 3.0);
	dds_eConvar[HCHATLINK] = CreateConVar("dds_chat_link", "1", "다른 플러그인과의 채팅 이중 출력을 피하기 위해 그 문제를 조절하도록 만든 ConVar입니다. 반드시 필요합니다.", FCVAR_PLUGIN, true, 1.0, true, 1.0);
	dds_eConvar[HITEMCODENOUSE] = CreateConVar("dds_item_code_nouse", "none", "사용하지 않을 아이템 종류를 정하는 곳입니다. 'none'이 아닌 것은 숫자를 써서 쉼표로 구분해주세요. ('none'은 사용안함)", FCVAR_PLUGIN);
	dds_eConvar[HLIMITPEOPLEGETMONEY] = CreateConVar("dds_money_limit_people", "4", "몇 명 이상의 사람일 때만 유저를 죽여서 금액을 얻게할지를 적어주세요. ('작업' 방지)", FCVAR_PLUGIN);
	dds_eConvar[HMULTIPLYMONEY] = CreateConVar("dds_money_multiply", "1.0", "모든 아이템을 각 아이템 금액의 몇 배의 비율로 구매하게 할 것인지를 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HITEMSELLRATIO] = CreateConVar("dds_item_sell_ratio", "0.2", "아이템을 팔 때 그 아이템 금액의 어느 정도의 비율로 팔 것인지 적어주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	dds_eConvar[HLIMITRANKNUMBER] = CreateConVar("dds_rank_limit_number", "30", "금액 랭킹을 보여줄 때 몇 위까지 보여줄 것인지 적어주세요.", FCVAR_PLUGIN);
	
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_TeamSay);
	
	HookEvent("player_connect", Event_OnPlayerConnect);
	HookEvent("player_disconnect", Event_OnPlayerDisconnect);
	
	BuildPath(Path_SM, dds_sPluginLogFile, sizeof(dds_sPluginLogFile), "logs/dynamicdollarshop.log");
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Core] Core' has been loaded.");
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("DDS_IsPluginOn", Native_DDS_IsPluginOn);
	CreateNative("DDS_GetUserMoney", Native_DDS_GetUserMoney);
	CreateNative("DDS_SetUserMoney", Native_DDS_SetUserMoney);
	CreateNative("DDS_GetUserClass", Native_DDS_GetUserClass);
	CreateNative("DDS_SetUserClass", Native_DDS_SetUserClass);
	CreateNative("DDS_ClearGlobalItemList", Native_DDS_ClearGlobalItemList);
	CreateNative("DDS_UpdateDatabase", Native_DDS_UpdateDatabase);
	CreateNative("DDS_SetGlobalItemList", Native_DDS_SetGlobalItemList);
	CreateNative("DDS_CreateGlobalItem", Native_DDS_CreateGlobalItem);
	CreateNative("DDS_RemoveGlobalItem", Native_DDS_RemoveGlobalItem);	
	CreateNative("DDS_GetUserItemStatus", Native_DDS_GetUserItemStatus);
	CreateNative("DDS_GetUserItemID", Native_DDS_GetUserItemID);
	CreateNative("DDS_SetUserItemID", Native_DDS_SetUserItemID);
	CreateNative("DDS_GetUserItemName", Native_DDS_GetUserItemName);
	CreateNative("DDS_SetUserItemName", Native_DDS_SetUserItemName);
	CreateNative("DDS_GetItemTotalNumber", Native_DDS_GetItemTotalNumber);
	CreateNative("DDS_GetItemUse", Native_DDS_GetItemUse);
	CreateNative("DDS_GetItemCodeName", Native_DDS_GetItemCodeName);
	CreateNative("DDS_GetItemPrecache", Native_DDS_GetItemPrecache);
	CreateNative("DDS_GetItemInfo", Native_DDS_GetItemInfo);
	CreateNative("DDS_GetUserFTagStatus", Native_DDS_GetUserFTagStatus);
	CreateNative("DDS_GetUserFTagStr", Native_DDS_GetUserFTagStr);
	CreateNative("DDS_OpenMainMenu", Native_DDS_OpenMainMenu);
	CreateNative("DDS_GetDatabaseHandle", Native_DDS_GetDatabaseHandle);
	CreateNative("DDS_SetItemProcess", Native_DDS_SetItemProcess);
	CreateNative("DDS_SimpleGiveItem", Native_DDS_SimpleGiveItem);
	CreateNative("DDS_SimpleRemoveItem", Native_DDS_SimpleRemoveItem);
	
	dds_hClientSetItem = CreateGlobalForward("DDS_OnClientSetItem", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	dds_hClientBuyItem = CreateGlobalForward("DDS_OnClientBuyItem", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	
	return APLRes_Success;
}

public OnConfigsExecuted()
{
	if (GetConVarBool(dds_eConvar[HPLUGINSWITCH]))
	{
		// 초반 유저 데이터 초기화
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
				DoResetUserData(i, 1);
		}
		
		// SQL 연결
		SQL_TConnect(SQL_GetDatabase, "dynamicdollarshop");
		
		// 데이터 로그 기록 설정
		if (GetConVarBool(dds_eConvar[HDATALOGSWITCH]))
		{
			if (GetConVarInt(dds_eConvar[HDATALOGDBSWITCH]) == 2) // SQL은 DoFirstProcess() 에서 처리
			{
				if (GetConVarBool(dds_eConvar[HDATALOGDATESWITCH]))
				{
					// 날짜별 기록
					new String:temptime[16];
					FormatTime(temptime, sizeof(temptime), "%y%m%d", GetTime());
					BuildPath(Path_SM, dds_sUserDataLogFile, sizeof(dds_sUserDataLogFile), "logs/dds_userdata_%s.log", temptime);
					BuildPath(Path_SM, dds_sUserIPLogFile, sizeof(dds_sUserIPLogFile), "logs/dds_userip_%s.log", temptime);
				}
				else
				{
					// 하나의 파일로 기록
					BuildPath(Path_SM, dds_sUserDataLogFile, sizeof(dds_sUserDataLogFile), "logs/dds_userdata.log");
					BuildPath(Path_SM, dds_sUserIPLogFile, sizeof(dds_sUserIPLogFile), "logs/dds_userip.log");
				}
			}
		}
		
		// 채팅 로그 기록 설정(텍스트 파일)
		if (GetConVarBool(dds_eConvar[HCHATLOGSWITCH]))
		{
			if (GetConVarInt(dds_eConvar[HCHATLOGDBSWITCH]) == 2)
			{
				if (GetConVarBool(dds_eConvar[HCHATLOGDATESWITCH]))
				{
					// 날짜별 기록
					new String:temptime[16];
					FormatTime(temptime, sizeof(temptime), "%y%m%d", GetTime());
					BuildPath(Path_SM, dds_sUserChatLogFile, sizeof(dds_sUserChatLogFile), "logs/dds_userchat_%s.log", temptime);
				}
				else
				{
					// 하나의 파일로 기록
					BuildPath(Path_SM, dds_sUserChatLogFile, sizeof(dds_sUserChatLogFile), "logs/dds_userchat.log");
				}
			}
		}
		
		// 단축키 설정
		// 0 - 해제, 1 - 달러샵 메뉴, 2 - 인벤토리, 3 - 3인칭
		// ** F1 키 **
		if (GetConVarInt(dds_eConvar[HFASTKEYF1SWITCH]) == 1)	RegConsoleCmd("autobuy", Menu_Main);
		else if (GetConVarInt(dds_eConvar[HFASTKEYF1SWITCH]) == 2)	RegConsoleCmd("autobuy", Menu_Myinven);
		else if (GetConVarInt(dds_eConvar[HFASTKEYF1SWITCH]) == 3)	RegConsoleCmd("autobuy", SwitchPersonView);
		
		// ** F2 키 **
		if (GetConVarInt(dds_eConvar[HFASTKEYF2SWITCH]) == 1)	RegConsoleCmd("rebuy", Menu_Main);
		else if (GetConVarInt(dds_eConvar[HFASTKEYF2SWITCH]) == 2)	RegConsoleCmd("rebuy", Menu_Myinven);
		else if (GetConVarInt(dds_eConvar[HFASTKEYF2SWITCH]) == 3)	RegConsoleCmd("rebuy", SwitchPersonView);
		
		// ** N 키 **
		if (GetConVarInt(dds_eConvar[HFASTKEYNSWITCH]) == 1)	RegConsoleCmd("nightvision", Menu_Main);
		else if (GetConVarInt(dds_eConvar[HFASTKEYNSWITCH]) == 2)	RegConsoleCmd("nightvision", Menu_Myinven);
		else if (GetConVarInt(dds_eConvar[HFASTKEYNSWITCH]) == 3)	RegConsoleCmd("nightvision", SwitchPersonView);
	}
}

public OnAllPluginsLoaded()
{
	// 관련 플러그인에 있는 convar 까지 적용하기 때문에 모든 플러그인이 로드된 후 읽기
	AutoExecConfig(true, "plugin.dynamicdollarshop");
}

public OnMapEnd()
{
	// SQL 데이터베이스 핸들 초기화
	if (dds_hDatabase != INVALID_HANDLE)
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "Closing SQL Database Handle...");
		#endif
		CloseHandle(dds_hDatabase);
	}
	dds_hDatabase = INVALID_HANDLE;
	
	// 데이터베이스 일반 상태 초기화
	dds_iDatabaseUpStatus = 0;
	
	// 데이터베이스 로드 상태 초기화
	dds_bIsCheckDataBase = false;
}

/* 클라이언트 접속 시 처리해야할 작업 */
public OnClientPutInServer(client)
{
	if (GetConVarBool(dds_eConvar[HPLUGINSWITCH]))
	{
		if (!IsFakeClient(client))
		{
			// 유저 데이터 로그 기록
			if (GetConVarBool(dds_eConvar[HDATALOGSWITCH]) && GetConVarBool(dds_eConvar[HDATALOGJMSGSWITCH]))	SetLog(client, 0, 1, 0, 3, 0, "");
			
			// 초반 유저 데이터 초기화
			DoResetUserData(client, 1);
			
			// 클라이언트 데이터베이스 체크 후, 클라이언트 금액, 장착 아이템 로드
			if (client != 0)
			{
				#if defined _DEBUG_
				DDS_PrintDebugMsg(0, false, "User Connected (client: %d)", client);
				#endif
				
				CreateTimer(0.4, Timer_SQLUserConnectLoad, client);
			}
		}
	}
}

/* 클라이언트 접속 해제 시 처리해야할 작업 */
public OnClientDisconnect(client)
{
	if (GetConVarBool(dds_eConvar[HPLUGINSWITCH]))
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			#if defined _DEBUG_
			DDS_PrintDebugMsg(0, false, "User Disconnected (client: %d)", client);
			#endif
			
			// 유저 데이터 로그 기록
			if (GetConVarBool(dds_eConvar[HDATALOGSWITCH]) && GetConVarBool(dds_eConvar[HDATALOGJMSGSWITCH]))	SetLog(client, 0, 2, 0, 4, 0, "");
			
			// 복구 로그 기록
			SetUserRepairLog(client, true, false, 0, 0, 0, 0);
			
			// 유저 접속 해제 설정
			new String:userauth[64], String:genquery[512];
			
			GetClientAuthString(client, userauth, sizeof(userauth));
			
			Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET ingame='0' WHERE authid='%s'", userauth);
			DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
			
			// 초반 유저 데이터 초기화
			DoResetUserData(client, 1);
		}
	}
}

public OnGameFrame()
{
	if (GetConVarBool(dds_eConvar[HPLUGINSWITCH]))
	{
		// 기간제 아이템 실시간 체크
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))	continue;
			
			for (new j = 1; j < dds_iCurItem; j++)
			{
				if (dds_eItem[j][ITEMTIME] <= 0)	continue;
				if (dds_iUserItemTime[i][j] == 0)	continue;
				if (dds_iUserItemTime[i][j] >= GetTime())	continue;
				
				// 해당 아이템 처리
				SetItemProcess(i, 0, 0, j, 4);
				
				// 기간 초기화
				dds_iUserItemTime[i][j] = 0;
			}
		}
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 아이템 종류 이용관련 설정 */
public DoSetItemCodeUse(bool:init, bool:firstset, bool:procset)
{
	// firstset 에 따라 아이템 종류 사용 여부 전체 초기화
	if (init)
	{
		for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
		{
			dds_bItemCodeUse[i] = firstset;
		}
	}
	
	// 사용자 지정으로 설정한 아이템 종류 사용 여부 조절
	if (procset)
	{
		new String:itemcodeno[32];
		
		GetConVarString(dds_eConvar[HITEMCODENOUSE], itemcodeno, sizeof(itemcodeno));
		
		if (!StrEqual(itemcodeno, "none", false) || !StrEqual(itemcodeno, "", false) || !StrEqual(itemcodeno, "0", false))
		{
			new String:exstr[ITEMCATEGORY_NUMBER][4];
			
			ExplodeString(itemcodeno, ",", exstr, sizeof(exstr), sizeof(exstr[]));
			
			for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
			{
				for (new k; k < ITEMCATEGORY_NUMBER; k++)
				{
					if (StringToInt(exstr[k]) == i)
						dds_bItemCodeUse[i] = false;
				}
			}
		}
	}
}

/* 초반 아이템 목록 초기화 */
public DoResetItemList(setcount)
{
	#if defined _DEBUG_
	DDS_PrintDebugMsg(0, false, "Now Initializing Item Data...");
	#endif
	dds_iCurItem = 0;
	
	for (new i = 1; i <= MAXITEM; i++)
	{
		dds_eItem[i][ITEMID] = DEFAULT_NUM;
		Format(dds_eItem[i][ITEMNAME], 64, "");
		dds_eItem[i][ITEMCODE] = DEFAULT_NUM;
		Format(dds_eItem[i][ITEMADRS], 128, "");
		dds_eItem[i][ITEMCOLOR] = DEFAULT_COLOR;
		dds_eItem[i][ITEMPRICE] = DEFAULT_MONEY;
		dds_eItem[i][ITEMPROC] = DEFAULT_PROCESS;
		dds_eItem[i][ITEMPOS] = DEFAULT_POS;
		dds_eItem[i][ITEMANG] = DEFAULT_ANG;
		dds_eItem[i][ITEMSPECIAL] = DEFAULT_SPECIAL;
		dds_eItem[i][ITEMTIME] = DEFAULT_TIME;
		Format(dds_eItem[i][ITEMOPTION], 64, "");
		dds_eItem[i][ITEMUSE] = DEFAULT_USE;
		
		for (new j = 1; j <= ITEMCATEGORY_NUMBER; j++)
		{
			for (new l = 0; l < 2; l++)
			{
				dds_iModelCode[i][j][l] = DEFAULT_NUM;
			}
		}
	}
	
	if (setcount)
		dds_iCurItem = 1;
}

/* 초반 유저 데이터 초기화 처리 함수 */
public DoResetUserData(client, common)
{
	if (common == 1)
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "Now Initializing User's Data...");
		DDS_PrintDebugMsg(client, true, "일부 프로필을 초기화합니다...");
		#endif
		// 금액, 등급, 태그 초기화
		dds_iUserMoney[client] = DEFAULT_MONEY;
		dds_iUserClass[client] = DEFAULT_CLASS;
		Format(dds_sFreeTag[client], 64, "");
		
		#if defined _DEBUG_
		DDS_PrintDebugMsg(client, true, "장착한 아이템을 초기화합니다...");
		#endif
		// 장착 아이템 초기화
		for (new j = 1; j <= ITEMCATEGORY_NUMBER; j++)
		{
			Format(dds_sUserItemName[client][j], 64, DEFAULT_NAME);
			dds_iUserItemID[client][j] = DEFAULT_NUM;
		}
		for (new m = 1; m < dds_iCurItem; m++)
		{
			dds_iUserItemCount[client][m] = DEFAULT_NUM;
			dds_iUserItemTime[client][m] = DEFAULT_NUM;
		}
		
		#if defined _DEBUG_
		DDS_PrintDebugMsg(client, true, "옵션 설정을 초기화합니다...");
		#endif
		// 옵션 설정 초기화
		for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
		{
			dds_bUserStatus[client][i] = true;
		}
		
		// 유저 데이터베이스 사용 초기화
		dds_bUserDatabaseUse[client] = false;
		
		// 기타 설정 초기화
		dds_bUserRepairLog[client][0] = false;
	}
	#if defined _DEBUG_
	DDS_PrintDebugMsg(client, true, "초기화가 완료되었습니다.");
	#endif
}

/* 초반 주요 설정 처리 함수 */
public DoFirstProcess()
{
	#if defined _DEBUG_
	DDS_PrintDebugMsg(0, false, "Now Processing for setting Item lists, Item Data Synchronizaion and Current User's applied Items and Money...");
	#endif
	
	// 아이템 0번의 이름은 기본값으로 설정
	Format(dds_eItem[0][ITEMNAME], 64, DEFAULT_NAME);
	
	// 클라이언트의 금전과 아이템 체크
	DDS_PrintToServer("Now Loading for User's Money and Applied Items...");
	for (new j = 1; j <= MaxClients; j++)
	{
		if (IsClientInGame(j) && !IsFakeClient(j))
		{
			#if defined _DEBUG_
			DDS_PrintDebugMsg(j, true, "데이터베이스를 확인하고 있습니다...");
			#endif
			CreateTimer(0.4, Timer_SQLUserConnectLoad, j);
		}
	}
	
	// 업데이트를 체크해야 한다면 체크
	if (dds_iDatabaseUpStatus > 1)
	{
		dds_iDatabaseUpStatus = 1;
		DoCheckDatabase();
	}
}

/* 데이터베이스 체크 처리 함수 */
public DoCheckDatabase()
{
	DDS_PrintToServer("==== Now Checking All Database Fields for Synchronization... ====");
	DDS_PrintToServer(" ~ Note ~ This will take a little time at first time.");
	DDS_PrintToServer(" ");
	
	new setprocnum[2] = {0, 4}; // 현재 진행, 전체 진행
	
	if (GetConVarInt(dds_eConvar[HDATALOGDBSWITCH]) == 1)
		setprocnum[1]++;
	
	// 아이템 데이터베이스 체크
	setprocnum[0]++; // 사용하면서 앞에다가 ++ 를 바로 붙이고 싶지만 SourcePawn 오류가 있기에 수정
	DDS_PrintToServer(" # [%d/%d] Item Data Table Fields...", setprocnum[0], setprocnum[1]);
	new String:genquery[512];
	
	for (new k = 1; k < dds_iCurItem; k++)
	{
		Format(genquery, sizeof(genquery), "SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='dds_useritem' AND COLUMN_NAME='I%d'", k);
		DDS_SendQuery(dds_hDatabase, SQL_FieldCheck, genquery, k, DBPrio_High);
	}
	
	// 아이템 갯수 데이터베이스 체크
	setprocnum[0]++;
	DDS_PrintToServer(" # [%d/%d] Item Count Data Table Fields...", setprocnum[0], setprocnum[1]);
	for (new t = 1; t < dds_iCurItem; t++)
	{
		Format(genquery, sizeof(genquery), "SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='dds_useritemcount' AND COLUMN_NAME='I%d'", t);
		DDS_SendQuery(dds_hDatabase, SQL_CountFieldCheck, genquery, t, DBPrio_High);
	}
	
	// 옵션 데이터베이스 체크
	setprocnum[0]++;
	DDS_PrintToServer(" # [%d/%d] Option Data Table Fields...", setprocnum[0], setprocnum[1]);
	for (new m = 1; m <= ITEMCATEGORY_NUMBER; m++)
	{
		new String:tempnum[8];
		
		if (m < 10)
			Format(tempnum, sizeof(tempnum), "0%d", m);
		else if (m >= 10)
			Format(tempnum, sizeof(tempnum), "%d", m);
		
		Format(genquery, sizeof(genquery), "SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='dds_useroption' AND COLUMN_NAME='O%s'", tempnum);
		DDS_SendQuery(dds_hDatabase, SQL_OptionFieldCheck, genquery, m, DBPrio_High);
	}
	
	// 데이터 로그 데이터베이스 체크
	if (GetConVarInt(dds_eConvar[HDATALOGDBSWITCH]) == 1) // 텍스트는 OnConfigsExecuted() 에서 처리
	{
		setprocnum[0]++;
		DDS_PrintToServer(" # [%d/%d] Server Log Data Table Fields...", setprocnum[0], setprocnum[1]);
		for (new n = 1; n <= ITEMCATEGORY_NUMBER; n++)
		{
			new String:tempnum[8];
			
			if (n < 10)
				Format(tempnum, sizeof(tempnum), "0%d", n);
			else if (n >= 10)
				Format(tempnum, sizeof(tempnum), "%d", n);
			
			Format(genquery, sizeof(genquery), "SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='dds_serverlog' AND COLUMN_NAME='L%s'", tempnum);
			DDS_SendQuery(dds_hDatabase, SQL_DataLogFieldCheck, genquery, n, DBPrio_High);
		}
	}
	
	// 클라이언트의 금전과 아이템 체크
	setprocnum[0]++;
	DDS_PrintToServer(" # [%d/%d] Loading for User's Money and Applied Items...", setprocnum[0], setprocnum[1]);
	for (new j = 1; j <= MaxClients; j++)
	{
		if (IsClientInGame(j) && !IsFakeClient(j))
		{
			#if defined _DEBUG_
			DDS_PrintDebugMsg(j, true, "데이터베이스를 확인하고 있습니다...");
			#endif
			CreateTimer(0.4, Timer_SQLUserConnectLoad, j);
		}
	}
	
	DDS_PrintToServer("=================================================================");
}

/* 아이템 등록 처리 함수 */
public CreateItem(String:itemname[64], itemcode, String:itemadrs[128], itemcolor[4], itemprice, itemproc, itempos[3], itemang[3], itemspecial, itemtime, String:itemoption[64], itemuse)
{
	if (dds_iCurItem > MAXITEM)
		DDS_PrintToServer("Please Increase 'MAXITEM'(define). Current 'MAXITEM': %d - Current Item Code: %d", MAXITEM, dds_iCurItem);
	
	dds_eItem[dds_iCurItem][ITEMID] = dds_iCurItem;
	Format(dds_eItem[dds_iCurItem][ITEMNAME], 64, itemname);
	dds_eItem[dds_iCurItem][ITEMCODE] = itemcode;
	Format(dds_eItem[dds_iCurItem][ITEMADRS], 128, itemadrs);
	dds_eItem[dds_iCurItem][ITEMCOLOR] = itemcolor;
	dds_eItem[dds_iCurItem][ITEMPRICE] = RoundFloat(itemprice * GetConVarFloat(dds_eConvar[HMULTIPLYMONEY]));
	dds_eItem[dds_iCurItem][ITEMPROC] = itemproc;
	dds_eItem[dds_iCurItem][ITEMPOS] = itempos;
	dds_eItem[dds_iCurItem][ITEMANG] = itemang;
	dds_eItem[dds_iCurItem][ITEMSPECIAL] = itemspecial;
	dds_eItem[dds_iCurItem][ITEMTIME] = itemtime;
	Format(dds_eItem[dds_iCurItem][ITEMOPTION], 64, itemoption);
	dds_eItem[dds_iCurItem][ITEMUSE] = itemuse;
	
	// 1 = 트레일, 2 = 테러스킨, 3 = 대테러스킨, 4 = 레이저, 5 = 이펙트슈즈, 6 = 태그, 7 = 버블, 8 = 조명, 9 = 플래시, 10 = 레이저 포인트, 11 = 파티클, 12 = 타이틀, 13 = 칼 스킨, 14 = 모자, 15 = 날개, 16 = 애완동물
	if (itemproc == 1) // vmt 주소 치환 및 프리캐시(조명, 레이저 포인트, 타이틀 용)
	{
		decl String:extvmt[256];
		
		Format(extvmt, sizeof(extvmt), "%s.vmt", itemadrs);
		Format(dds_eItem[dds_iCurItem][ITEMADRS], 128, extvmt);
		
		PrecacheModel(extvmt, true);
	}
	else if (itemproc == 2) // vmt 주소 치환 및 프리캐시(트레일 용)
	{
		decl String:extvmt[256];
		
		Format(extvmt, sizeof(extvmt), "materials/trails/%s.vmt", itemadrs);
		
		dds_iModelCode[dds_iCurItem][dds_eItem[dds_iCurItem][ITEMCODE]][0] = PrecacheModel(extvmt, true);
	}
	else if (itemproc == 3) // vmt 주소 치환 및 프리캐시 번호 등록(레이저, 이펙트 슈즈, 버블 용)
	{
		decl String:extvmt[256];
		
		Format(extvmt, sizeof(extvmt), "%s.vmt", itemadrs);
		Format(dds_eItem[dds_iCurItem][ITEMADRS], 128, extvmt);
		
		dds_iModelCode[dds_iCurItem][dds_eItem[dds_iCurItem][ITEMCODE]][0] = PrecacheModel(extvmt, true);
	}
	else if (itemproc == 4) // mdl 주소 치환 및 프리캐시(모자, 날개, 애완동물 용)
	{
		decl String:extmdl[256];
		
		Format(extmdl, sizeof(extmdl), "%s.mdl", itemadrs);
		Format(dds_eItem[dds_iCurItem][ITEMADRS], 128, extmdl);
		
		PrecacheModel(extmdl, true);
	}
	else if (itemproc == 5) // mdl 주소 치환 및 프리캐시 번호 등록(테러스킨, 대테러스킨 용)
	{
		decl String:extmdl[256];
		
		Format(extmdl, sizeof(extmdl), "%s.mdl", itemadrs);
		Format(dds_eItem[dds_iCurItem][ITEMADRS], 128, extmdl);
		
		dds_iModelCode[dds_iCurItem][dds_eItem[dds_iCurItem][ITEMCODE]][0] = PrecacheModel(extmdl, true);
	}
	else if (itemproc == 6) // mdl 주소 치환 및 프리캐시 번호 등록(칼 스킨 용)
	{
		decl String:extmdl[256], String:extvmdl[256], String:extwmdl[256];
		
		Format(extmdl, sizeof(extmdl), "%s.mdl", itemadrs);
		Format(dds_eItem[dds_iCurItem][ITEMADRS], 128, extmdl);
		
		// # 을 기준으로 파일 이름 구별
		if (StrContains(extmdl, "#", false) != -1)
		{
			Format(extvmdl, sizeof(extvmdl), extmdl);
			Format(extwmdl, sizeof(extwmdl), extmdl);
			ReplaceString(extvmdl, sizeof(extvmdl), "#", "v");
			ReplaceString(extwmdl, sizeof(extwmdl), "#", "w");
			
			dds_iModelCode[dds_iCurItem][dds_eItem[dds_iCurItem][ITEMCODE]][0] = PrecacheModel(extvmdl, true);
			dds_iModelCode[dds_iCurItem][dds_eItem[dds_iCurItem][ITEMCODE]][1] = PrecacheModel(extwmdl, true);
		}
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "~~~~ KnifeSkin Info ~ V: %s(%d), W: %s(%d)", extvmdl, dds_iModelCode[dds_iCurItem][dds_eItem[dds_iCurItem][ITEMCODE]][0], extwmdl, dds_iModelCode[dds_iCurItem][dds_eItem[dds_iCurItem][ITEMCODE]][1]);
		#endif
	}
	#if defined _DEBUG_
	DDS_PrintDebugMsg(0, false, "Now Created this item data. (itemproc: %d) And Precached this. - Num: %d, Code: %d", itemproc, dds_iCurItem, itemcode);
	#endif
	dds_iCurItem++;
}

/* 아이템 시스템 처리 함수 */
/* (제일 중요한 부분이므로 신경써서 할 것) */
public SetItemProcess(client, target, proctype, itemid, anydata1)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 처리할 수 없습니다!");
		return;
	}
	
	if (!dds_bUserDatabaseUse[client])
	{
		DDS_PrintToChat(client, "유저 정보가 아직 로드되지 않았습니다!");
		return;
	}
	
	/*********************************************************
	
	이 부분부터는 상당히 중요한 부분이므로 신경써서 작업할 것.
	
	*********************************************************/
	/**************************************
	
	<client>
	 - 메인 클라이언트 인덱스
	
	<target>
	 - 대상 클라이언트 인덱스
	
	***************************************/
	new String:userauth[32], String:username[64], String:clauth[32], String:taauth[32];
	
	// 클라이언트 구분 문자열 획득
	if (client > 0)	GetClientAuthString(client, clauth, sizeof(clauth));
	if (target > 0)	GetClientAuthString(client, taauth, sizeof(taauth));
	
	// 주요 구분 문자열 설정
	if (target > 0)
		Format(userauth, sizeof(userauth), taauth);
	else
		Format(userauth, sizeof(userauth), clauth);
	
	/**************************************
	
	<proctype>
	
	-2 - 특정 아이템의 특정 갯수 감소 처리(네이티브)
	
	 # <anydata1>
	 	아이템 갯수
	
	-1 - 특정 아이템의 특정 갯수 증가 처리(네이티브)
	
	 # <anydata1>
		아이템 갯수
	
	0 - 아이템을 버렸을 때
	
	 # <anydata1>
		0 - 인벤토리에서 버렸을 때
		1 - 관리 메뉴에서 아이템을 회수하였을 때
		2 - 장착 메뉴에서 일회용 아이템을 장착 해제했을 때
		3 - 인벤토리에서 되팔았을 때
		4 - 기간이 설정된 아이템이 시간이 지나 소모될 때
	
	1 - 아이템을 선물하거나(관리) 그냥 인벤토리로 옮길 때
	
	 # <anydata1>
		1 - 관리 메뉴에서 아이템을 주었을 때
	
	2 - 아이템을 장착할 때
	
	3 - 아이템을 구매할 때
	
	<itemid>
	 - 전달 아이템 코드
	
	***************************************/
	new String:genquery[512], appid = 0, setstat = -1, bool:passtimeonce;
	
	/** 처리 대상 분별 시작 **/
	appid = client;
	
	// 관리 메뉴에서 아이템을 회수할때는 대상을 변경
	if ((proctype == 0) && (anydata1 == 1))	appid = target;
	
	/************* 아이템 데이터베이스 등록 *************/
	if (dds_iUserItemCount[appid][itemid] > 1) // 특정 아이템의 갯수가 1 개 이상일 경우
	{
		// 기간제 아이템(일회용) 확인
		if (dds_eItem[itemid][ITEMTIME] == -1)
		{
			if (proctype == -2) // 특정 아이템의 특정 갯수 감소 처리 경우
			{
				if ((dds_iUserItemCount[appid][itemid] - anydata1) > 0)	setstat = 1;
				else if ((dds_iUserItemCount[appid][itemid] - anydata1) <= 0)	setstat = 0;
				passtimeonce = true;
			}
			else if (proctype == -1) // 특정 아이템의 특정 갯수 증가 처리 경우
			{
				setstat = 1;
				passtimeonce = true;
			}
			else if ((proctype == 0) || (proctype == 2)) // 버리거나 장착할 경우
			{
				// 인벤토리에 아직 남은 수량은 있으므로 인벤토리 보관 처리
				setstat = 1;
				
				// 회수를 당할 때에는 소유하지 않도록 처리
				if (anydata1 == 1)	setstat = 0;
				
				passtimeonce = true;
			}
			else if (proctype == 1) // 관리에서 선물하거나 인벤토리로 옮길 경우
			{
				// 일회용은 데이터베이스 장착 상태가 없으므로 인벤토리에 보관 처리
				setstat = 1;
				
				passtimeonce = true;
			}
			else if (proctype == 3)
			{
				if ((dds_iUserMoney[appid] >= dds_eItem[itemid][ITEMPRICE]) || (dds_iUserClass[appid] >= 2))
				{
					// 일회용은 데이터베이스 장착 상태가 없으므로 인벤토리에 보관 처리
					setstat = 1;
					
					passtimeonce = true;
				}
			}
		}
		
		// 일반 처리
		if (!passtimeonce)
		{
			if (proctype == -2) // 특정 아이템의 특정 갯수 감소 처리 경우
			{
				if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착 아이템과 전달 아이템이 같을 경우
				{
					// 인벤토리에 남은 수량이 있던 없던 장착하고 있으므로 장착 처리
					setstat = 2;
				}
				else // 장착 아이템과 전달 아이템이 다를 경우
				{
					if ((dds_iUserItemCount[appid][itemid] - anydata1) > 0)	setstat = 1;
					else if ((dds_iUserItemCount[appid][itemid] - anydata1) <= 0)	setstat = 0;
				}
			}
			else if (proctype == -1) // 특정 아이템의 특정 갯수 증가 처리 경우
			{
				if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착하고 있는 아이템과 현 특정 아이템이 같을 경우
					setstat = 2; // 계속 장착하고 있어야 하므로 장착 처리
				else
					setstat = 1; // 인벤토리 소유 처리
			}
			else if (proctype == 0) // 버릴 경우
			{
				if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착 아이템과 전달 아이템이 같을 경우
				{
					// 인벤토리에 남은 수량은 있지만 장착하고 있으므로 장착 처리
					setstat = 2;
					
					if (anydata1 == 1)	setstat = 0; // 회수를 당할 때에는 소유하지 않도록 처리
					else if (anydata1 == 4)	setstat = 0; // 기간이 설정된 아이템은 소유하지 않도록 처리
				}
				else // 장착 아이템과 전달 아이템이 다를 경우
				{
					// 인벤토리 보관 처리
					setstat = 1;
					
					if (anydata1 == 1)	setstat = 0; // 회수를 당할 때에는 소유하지 않도록 처리
					else if (anydata1 == 4)	setstat = 0; // 기간이 설정된 아이템은 소유하지 않도록 처리
				}
			}
			else if (proctype == 1) // 관리에서 선물하거나 인벤토리로 옮길 경우 (*******************)
			{
				setstat = 1;
			}
			else if (proctype == 2) // 장착할 경우
			{
				if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착 아이템과 전달 아이템이 같을 경우
					setstat = 2; // 인벤토리에 남은 수량은 있지만 장착하고 있으므로 장착 처리
				else
					setstat = 2; // 인벤토리에 남은 수량은 있지만 장착하고 있으므로 장착 처리
			}
			else if (proctype == 3) // 구매할 경우
			{
				if ((dds_iUserMoney[appid] >= dds_eItem[itemid][ITEMPRICE]) || (dds_iUserClass[appid] >= 2))
				{
					if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착하고 있는 아이템과 현 특정 아이템이 같을 경우
						setstat = 2; // 계속 장착하고 있어야 하므로 장착 처리
					else
						setstat = 1; // 인벤토리 소유 처리
				}
			}
		}
	}
	else if (dds_iUserItemCount[appid][itemid] <= 1) // 특정 아이템의 갯수가 1 개 이하일 경우
	{
		// 기간제 아이템(일회용) 확인
		if (dds_eItem[itemid][ITEMTIME] == -1)
		{
			if (proctype == -2) // 특정 아이템의 특정 갯수 감소 처리 경우
			{
				if ((dds_iUserItemCount[appid][itemid] - anydata1) > 0)	setstat = 1;
				else if ((dds_iUserItemCount[appid][itemid] - anydata1) <= 0)	setstat = 0;
				passtimeonce = true;
			}
			else if (proctype == -1) // 특정 아이템의 특정 갯수 증가 처리 경우
			{
				setstat = 1;
				passtimeonce = true;
			}
			else if ((proctype == 0) || (proctype == 2))	// 버리거나 장착할 경우
			{
				setstat = 0;
				passtimeonce = true;
			}
			else if (proctype == 1)
			{
				setstat = 1;
				passtimeonce = true;
			}
			else if (proctype == 3)
			{
				if ((dds_iUserMoney[appid] >= dds_eItem[itemid][ITEMPRICE]) || (dds_iUserClass[appid] >= 2))
				{
					setstat = 1;
					passtimeonce = true;
				}
			}
		}
		
		// 일반 처리
		if (!passtimeonce)
		{
			if (proctype == -2) // 특정 아이템의 특정 갯수 감소 처리 경우
			{
				if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착 아이템과 전달 아이템이 같을 경우
				{
					// 인벤토리에 남은 수량이 있던 없던 장착하고 있으므로 장착 처리
					setstat = 2;
				}
				else // 장착 아이템과 전달 아이템이 다를 경우
				{
					if ((dds_iUserItemCount[appid][itemid] - anydata1) > 0)	setstat = 1;
					else if ((dds_iUserItemCount[appid][itemid] - anydata1) <= 0)	setstat = 0;
				}
			}
			else if (proctype == -1) // 특정 아이템의 특정 갯수 증가 처리 경우
			{
				if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착하고 있는 아이템과 현 특정 아이템이 같을 경우
					setstat = 2; // 계속 장착하고 있어야 하므로 장착 처리
				else
					setstat = 1; // 인벤토리 소유 처리
			}
			else if (proctype == 0) // 버릴 경우
			{
				if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착하고 있는 아이템과 현 특정 아이템이 같을 경우
				{
					// 어쨌든 장착하고 있으므로 장착 처리
					setstat = 2;
					
					if (anydata1 == 1)	setstat = 0; // 회수를 당할 때에는 소유하지 않도록 처리
					else if (anydata1 == 4)	setstat = 0; // 기간이 설정된 아이템은 소유하지 않도록 처리
				}
				else
				{
					setstat = 0;
				}
			}
			else if (proctype == 1) // 관리에서 선물하거나 인벤토리로 옮길 경우 (*******************)
			{
				setstat = 1;
			}
			else if (proctype == 2) // 장착할 경우
			{
				if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착하고 있는 아이템과 현 특정 아이템이 같을 경우
					setstat = 2; // 인벤토리에 남은 수량은 있지만 장착하고 있으므로 장착 처리
				else
					setstat = 2; // 장착 처리(갯수가 1개 정도가 있다면 남은 수량은 있게 하면서 장착)
			}
			else if (proctype == 3) // 구매할 경우
			{
				if ((dds_iUserMoney[appid] >= dds_eItem[itemid][ITEMPRICE]) || (dds_iUserClass[appid] >= 2))
				{
					if (dds_iUserItemID[appid][dds_eItem[itemid][ITEMCODE]] == itemid) // 장착하고 있는 아이템과 현 특정 아이템이 같을 경우
						setstat = 2; // 계속 장착하고 있어야 하므로 장착 처리
					else
						setstat = 1; // 인벤토리 소유 처리
				}
			}
		}
	}
	
	if (setstat != -1)
	{
		Format(genquery, sizeof(genquery), "UPDATE dds_useritem SET I%d='%d' WHERE authid='%s'", itemid, setstat, userauth);
		DDS_SendQuery(dds_hDatabase, SQL_Info_InvenUpdate, genquery, appid);
	}
	/************* 아이템 데이터베이스 끝 *************/
	
	/************* 아이템 개수 데이터베이스 등록 *************/
	// 아이템 개수가 기존에 음수였다면 0으로 수정(만일의 경우를 대비한 방지)
	if (dds_iUserItemCount[client][itemid] < 0)
		dds_iUserItemCount[client][itemid] = 0;
	
	// 각 처리 방법에 따른 갯수 처리
	if (proctype == -2) // 특정 아이템의 특정 갯수 감소 처리 경우
	{
		dds_iUserItemCount[client][itemid] -= anydata1;
		
		if (dds_iUserItemCount[client][itemid] < 0)
			dds_iUserItemCount[client][itemid] = 0;
	}
	else if (proctype == -1) // 특정 아이템의 특정 갯수 증가 처리 경우
	{
		dds_iUserItemCount[client][itemid] += anydata1;
	}
	else if (proctype == 0 || proctype == 2) // 버리거나 장착할 경우
	{
		// 특정 아이템의 갯수가 0 보다 큰 경우는 항상 감소 처리
		if (dds_iUserItemCount[client][itemid] > 0)
			dds_iUserItemCount[client][itemid]--;
		
		// 압수를 당한 경우에는 0으로 설정
		if (anydata1 == 1)
			dds_iUserItemCount[target][itemid] = 0;
		
		// 기간이 지난 아이템인 경우에는 0으로 설정
		if (anydata1 == 4)
			dds_iUserItemCount[client][itemid] = 0;
	}
	else if (proctype == 1) // 관리에서 선물하거나 인벤토리로 옮길 경우
	{
		if (target > 0)
			dds_iUserItemCount[target][itemid]++;
		else
			dds_iUserItemCount[client][itemid]++;
	}
	else if (proctype == 3) // 구매할 경우
	{
		if ((dds_iUserMoney[client] >= dds_eItem[itemid][ITEMPRICE]) || (dds_iUserClass[client] >= 2))
			dds_iUserItemCount[client][itemid]++;
	}
	
	Format(genquery, sizeof(genquery), "UPDATE dds_useritemcount SET I%d='%d' WHERE authid='%s'", itemid, dds_iUserItemCount[client][itemid], userauth);
	DDS_SendQuery(dds_hDatabase, SQL_Info_InvenUpdate, genquery, client);
	/************* 아이템 개수 데이터베이스 끝 *************/
	
	/** 처리 대상 분별 끝 **/
	appid = client;
	
	/** 유저 복구 로그 작성 **/
	if (target > 0)
		SetUserRepairLog(target, false, true, itemid, dds_eItem[itemid][ITEMCODE], setstat, dds_iUserItemCount[target][itemid]);
	else
		SetUserRepairLog(client, false, true, itemid, dds_eItem[itemid][ITEMCODE], setstat, dds_iUserItemCount[client][itemid]);
	
	/************* 기간제 아이템 처리 시작 *************/
	new timeprocid, timeappid, String:timeprocauth[32];
	
	// 타겟 및 처리 방법 선정
	if ((proctype == 1) && (target > 0) && (anydata1 == 1))
	{
		Format(timeprocauth, sizeof(timeprocauth), taauth);
		timeappid = target;
		timeprocid = 1;
	}
	else if (proctype == -1)
	{
		Format(timeprocauth, sizeof(timeprocauth), clauth);
		timeappid = client;
		timeprocid = 1;
	}
	else if ((proctype == 0) || (proctype == -2))
	{
		if (proctype == 0)
		{
			if ((anydata1 == 0) || (anydata1 == 3) || (anydata1 == 4))
			{
				Format(timeprocauth, sizeof(timeprocauth), clauth);
				timeappid = client;
				timeprocid = 2;
			}
			else if (anydata1 == 1)
			{
				Format(timeprocauth, sizeof(timeprocauth), taauth);
				timeappid = target;
				timeprocid = 2;
			}
		}
		else if (proctype == -2)
		{
			Format(timeprocauth, sizeof(timeprocauth), clauth);
			timeappid = client;
			timeprocid = 2;
		}
	}
	else if (proctype == 3)
	{
		if ((dds_iUserMoney[client] >= dds_eItem[itemid][ITEMPRICE]) || (dds_iUserClass[client] >= 2))
		{
			Format(timeprocauth, sizeof(timeprocauth), clauth);
			timeappid = client;
			timeprocid = 1;
		}
	}
	
	if (timeprocid == 1) // 등록
	{
		if (dds_iUserClass[timeappid] < 3)
		{
			if (dds_eItem[itemid][ITEMTIME] > 0)
			{
				new setutime = GetTime() + (dds_eItem[itemid][ITEMTIME] * 60);
				
				// replace into 를 쓰거나 on duplicate key update 를 쓰고 싶지만 당분간 이렇게 처리
				Format(genquery, sizeof(genquery), "DELETE FROM dds_useritemtime WHERE authid='%s' AND itemid='%d'", timeprocauth, itemid);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, timeappid);
				Format(genquery, sizeof(genquery), "INSERT INTO dds_useritemtime(authid, itemid, utime) VALUES('%s', '%d', '%d')", timeprocauth, itemid, setutime);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, timeappid);
				/*
				Format(genquery, sizeof(genquery), "REPLACE INTO dds_useritemtime SET authid='%s', itemid='%d', utime='%d' WHERE authid='%s' AND itemid='%d'", timeprocauth, itemid, setutime, timeprocauth, itemid);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, timeappid);
				*/
				dds_iUserItemTime[timeappid][itemid] = setutime;
			}
		}
	}
	else if (timeprocid == 2) // 삭제
	{
		if (dds_eItem[itemid][ITEMTIME] > 0)
		{
			if (dds_iUserItemTime[timeappid][itemid] > 0)
			{
				if (dds_iUserItemCount[timeappid][itemid] <= 0)
				{
					// 등록된 시간 데이터 삭제
					Format(genquery, sizeof(genquery), "DELETE FROM dds_useritemtime WHERE authid='%s' AND itemid='%d'", timeprocauth, itemid);
					DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, timeappid);
					
					// 시간 초기화
					dds_iUserItemTime[timeappid][itemid] = 0;
				}
			}
		}
	}
	/************* 기간제 아이템 처리 끝 *************/
	
	/** proctype 값에 따른 처리 **/
	if (proctype == 0)
	{
		/**************************************
		
		anydata1
		
		0 - 인벤토리에서 버렸을 때
		1 - 관리 메뉴에서 아이템을 회수하였을 때
		2 - 장착 메뉴에서 일회용 아이템을 장착 해제했을 때
		3 - 인벤토리에서 되팔았을 때
		4 - 기간이 설정된 아이템이 시간이 지나 소모될 때
		
		***************************************/
		if (anydata1 == 0)
		{
			// 로그 작성
			SetLog(client, 0, 5, itemid, 0, 0, "");
			
			DDS_PrintToChat(client, "'[%s] %s'을(를) 버렸습니다.", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
		}
		else if (anydata1 == 1)
		{
			if (dds_iUserItemID[target][dds_eItem[itemid][ITEMCODE]] == itemid) // 현재 장착하고 있는 아이템이 회수 아이템과 같은 경우는 초기화
			{
				Format(dds_sUserItemName[target][dds_eItem[itemid][ITEMCODE]], 64, DEFAULT_NAME);
				dds_iUserItemID[target][dds_eItem[itemid][ITEMCODE]] = 0;
			}
			
			// 로그 작성
			SetLog(client, target, 6, itemid, 4, 0, "");
			
			GetClientName(target, username, sizeof(username));
			DDS_PrintToChat(client, "%s 님의 '[%s] %s'을(를) 회수하였습니다.", username, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
			GetClientName(client, username, sizeof(username));
			DDS_PrintToChat(target, "어드민(%s)이 '[%s] %s'을(를) 회수하였습니다.", username, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
		}
		else if (anydata1 == 2)
		{
			if (dds_eItem[itemid][ITEMCODE] == IsThereThisItemCode_num("tag"))
			{
				if (GetConVarBool(dds_eConvar[HFRTAGSAVESWITCH]))
				{
					if (StrEqual(dds_eItem[itemid][ITEMOPTION], "freetag", false))
					{
						Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET freetag='' WHERE authid='%s'", userauth);
						DDS_SendQuery(dds_hDatabase, SQL_Info_ProfileUpdate, genquery, client);
					}
				}
			}
			
			DDS_PrintToChat(client, "'[%s] %s'가(이) 소모되어 버려졌습니다.", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
		}
		else if (anydata1 == 3)
		{
			decl tempmoney;
			
			tempmoney = RoundToFloor(dds_eItem[itemid][ITEMPRICE] * GetConVarFloat(dds_eConvar[HITEMSELLRATIO]));
			SetUserMoney(client, 2, tempmoney);
			
			// 로그 작성
			SetLog(client, 0, 4, itemid, 0, 0, "");
			
			DDS_PrintToChat(client, "'[%s] %s'을(를) 팔고, %d %s을(를) 얻었습니다.", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], tempmoney, DDS_MONEY_NAME_KO);
		}
		else if (anydata1 == 4)
		{
			if (dds_iUserItemID[client][dds_eItem[itemid][ITEMCODE]] == itemid) // 현재 장착하고 있는 아이템이 회수 아이템과 같은 경우는 초기화
			{
				Format(dds_sUserItemName[client][dds_eItem[itemid][ITEMCODE]], 64, DEFAULT_NAME);
				dds_iUserItemID[client][dds_eItem[itemid][ITEMCODE]] = 0;
			}
			
			DDS_PrintToChat(timeappid, "'[%s] %s'가(이) 기간이 만료되어 아이템이 소모되었습니다.", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
		}
	}
	else if (proctype == 1)
	{
		/**************************************
		
		itemid
		
		 - 유저가 선물할 아이템 코드
		
		target
		
		 - 전달되는 유저
		
		***************************************/
		if (target > 0)
		{
			if (dds_iUserClass[client] >= 3)
			{
				/**************************************
				
				anydata1
				
				1 - 관리 메뉴에서 아이템을 주었을 때
				
				***************************************/
				if (anydata1 == 1)
				{
					// 로그 작성
					SetLog(client, target, 6, itemid, 3, 0, "");
					
					GetClientName(target, username, sizeof(username));
					DDS_PrintToChat(client, "%s 님에게 '[%s] %s'을(를) 선물하였습니다.", username, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
					GetClientName(client, username, sizeof(username));
					DDS_PrintToChat(target, "어드민(%s)으로부터 '[%s] %s'을(를) 받았습니다.", username, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
				}
			}
		}
		else
		{
			DDS_PrintToChat(client, "'[%s] %s'가(이) 인벤토리로 옮겨졌습니다.", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
		}
	}
	else if (proctype == 2)
	{
		/**************************************
		
		itemid
		
		 - 유저가 고른 아이템 코드
		
		***************************************/
		// 기존에 장착된 아이템은 각 종류에 따라서 인벤토리로 이동
		for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
		{
			if (((itemid == 0) && (anydata1 > 0)) || 
				((dds_eItem[itemid][ITEMCODE] == i) && (dds_iUserItemID[client][i] > 0))
				)
			{
				/*
				
				itemid 와 tempid 구분 주의할 것!
				
				*/
				new tempid;
				
				if (dds_eItem[itemid][ITEMCODE] == i)
					tempid = dds_iUserItemID[client][i];
				
				if (dds_eItem[tempid][ITEMTIME] == -1) // 기간제 아이템(일회용) 확인
					SetItemProcess(client, 0, 0, tempid, 2);
				else
					SetItemProcess(client, 0, 1, tempid, 0);
			}
		}
		
		// 각 종류에 따라서 장착된 아이템으로 설정
		for (new k = 1; k <= ITEMCATEGORY_NUMBER; k ++)
		{
			if (dds_eItem[itemid][ITEMCODE] == k)
			{
				Format(dds_sUserItemName[client][k], 64, dds_eItem[itemid][ITEMNAME]);
				
				dds_iUserItemID[client][k] = itemid;
				
				if (k == IsThereThisItemCode_num("tag"))
				{
					if (dds_bFreeTag[client][1] && !StrEqual(dds_eItem[itemid][ITEMOPTION], "freetag", false))
						dds_bFreeTag[client][1] = false;
				}
			}
		}
		
		DDS_PrintToChat(client, "'[%s] %s'을(를) 장착하였습니다.", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
		
		// 포워드 처리
		Process_OnClientSetItem(client, dds_eItem[itemid][ITEMCODE], itemid);
		
		// '자유형 태그' 장착 시
		if (StrEqual(dds_eItem[itemid][ITEMOPTION], "freetag", false) && !dds_bFreeTag[client][0])
		{
			dds_bFreeTag[client][0] = true;
			dds_bFreeTag[client][1] = false;
			DDS_PrintToChat(client, "설정할 태그를 입력하세요.");
		}
	}
	else if (proctype == 3)
	{
		if ((dds_iUserMoney[client] < dds_eItem[itemid][ITEMPRICE]) && (dds_iUserClass[client] < 2))
		{
			DDS_PrintToChat(client, "%d %s가(이) 부족합니다.", dds_eItem[itemid][ITEMPRICE]-dds_iUserMoney[client], DDS_MONEY_NAME_KO);
			return;
		}
		
		// VIP 아래의 등급들은 돈 지불
		if (dds_iUserClass[client] < 2)	SetUserMoney(client, 3, dds_eItem[itemid][ITEMPRICE]);
		
		// 로그
		if (GetConVarBool(dds_eConvar[HDATALOGSWITCH]))	SetLog(client, 0, 3, itemid, 0, 0, "");
		
		DDS_PrintToChat(client, "'[%s] %s'의 구매를 성공적으로 완료하였습니다.", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
		
		// 포워드 처리
		Process_OnClientBuyItem(client, dds_eItem[itemid][ITEMCODE], itemid);
	}
}

/* 금액 갱신 처리 함수 */
public SetUserMoney(client, mode, amount)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 처리할 수 없습니다!");
		return;
	}
	
	if (!dds_bUserDatabaseUse[client])
	{
		DDS_PrintToChat(client, "유저 정보가 아직 로드되지 않았습니다!");
		return;
	}
	
	if (!IsClientInGame(client))
	{
		LogToFile(dds_sPluginLogFile, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		DDS_PrintToServer("client %d is not in game.", client);
		
		return;
	}
	
	if ((mode < 1) || (mode > 3))
	{
		LogToFile(dds_sPluginLogFile, "%s 'mode' should be the number between 1 to 3.", DDS_CHAT_PREFIX_EN);
		DDS_PrintToServer("'mode' should be the number between 1 to 3.", client);
		
		return;
	}
	
	if (amount < 0)
	{
		LogToFile(dds_sPluginLogFile, "%s 'amount' should be higher than 0 or same.", DDS_CHAT_PREFIX_EN);
		DDS_PrintToServer("'amount' should be higher than 0 or same.", client);
		
		return;
	}
	
	if (!dds_bUserDatabaseUse[client])
	{
		DDS_PrintToChat(client, "유저 정보가 아직 로드되지 않았습니다!");
		return;
	}
	
	if (mode == 1) // 그대로 적용
		dds_iUserMoney[client] = amount;
	else if (mode == 2) // 합하여 적용
		dds_iUserMoney[client] += amount;
	else if (mode == 3) // 빼서 적용
		dds_iUserMoney[client] -= amount;
	
	SetUserRepairLog(client, true, false, 0, 0, 0, 0);
	
	new String:genquery[512], String:userauth[32];
	
	GetClientAuthString(client, userauth, sizeof(userauth));
	
	Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET money='%d' WHERE authid='%s'", dds_iUserMoney[client], userauth);
	DDS_SendQuery(dds_hDatabase, SQL_Info_ChangeMoney, genquery, client);
}

/********************************
 * 메뉴 출력
********************************/
/* 기본 메뉴 출력 함수 */
public Action:Menu_Main(client, args)
{
	if (!GetConVarBool(dds_eConvar[HPLUGINSWITCH]))	return Plugin_Continue;
	
	new Handle:dds_hMenuMain = CreateMenu(Menu_SMain);
	new String:buffer[128];
	
	Format(buffer, sizeof(buffer), "%s\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuMain, buffer);
	SetMenuExitButton(dds_hMenuMain, true);
	
	Format(buffer, sizeof(buffer), "내 정보");
	AddMenuItem(dds_hMenuMain, "1", buffer);
	Format(buffer, sizeof(buffer), "내 장착 아이템");
	AddMenuItem(dds_hMenuMain, "2", buffer);
	Format(buffer, sizeof(buffer), "내 인벤토리");
	AddMenuItem(dds_hMenuMain, "3", buffer);
	Format(buffer, sizeof(buffer), "아이템 구매");
	AddMenuItem(dds_hMenuMain, "4", buffer);
	Format(buffer, sizeof(buffer), "옵션\n ");
	AddMenuItem(dds_hMenuMain, "5", buffer);
	Format(buffer, sizeof(buffer), "플러그인 정보");
	AddMenuItem(dds_hMenuMain, "6", buffer);
	
	DisplayMenu(dds_hMenuMain, client, MENU_TIME_FOREVER);
	
	return Plugin_Continue;
}

/* 내 정보 메뉴 출력 함수 */
public Menu_Myinfo(client)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정상적으로 정보를 로드할 수 없습니다.");
		return;
	}
	
	if (!dds_bUserDatabaseUse[client])
	{
		DDS_PrintToChat(client, "유저 정보가 아직 로드되지 않았습니다!");
		return;
	}
	
	new Handle:dds_hMenuMyinfo = CreateMenu(Menu_SNothing2);
	new String:buffer[256], String:tempinfo[2][64], String:tempclass[32];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 내 정보\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuMyinfo, buffer);
	SetMenuExitButton(dds_hMenuMyinfo, true);
	SetMenuExitBackButton(dds_hMenuMyinfo, true);
	
	GetClientName(client, tempinfo[0], 64);
	GetClientAuthString(client, tempinfo[1], 64);
	
	if (dds_iUserClass[client] == 0)	Format(tempclass, sizeof(tempclass), "0 - 일반 유저");
	else if (dds_iUserClass[client] == 1)	Format(tempclass, sizeof(tempclass), "1 - 특별 유저");
	else if (dds_iUserClass[client] == 2)	Format(tempclass, sizeof(tempclass), "2 - VIP");
	else if (dds_iUserClass[client] == 3)	Format(tempclass, sizeof(tempclass), "3 - 관리자");
	else if (dds_iUserClass[client] == 4)	Format(tempclass, sizeof(tempclass), "4 - 최고 관리자");
	
	Format(buffer, sizeof(buffer), "자기 자신의 현재 정보입니다.\n \n닉네임: %s\n스팀 고유번호: %s\n%s: %d\n \n등급: %s", tempinfo[0], tempinfo[1], DDS_MONEY_NAME_KO, dds_iUserMoney[client], tempclass);
	AddMenuItem(dds_hMenuMyinfo, "1", buffer, ITEMDRAW_DISABLED);
	
	DisplayMenu(dds_hMenuMyinfo, client, MENU_TIME_FOREVER);
}

/* 내 장착 아이템 메뉴 출력 함수 */
public Menu_Myitemset(client)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 로드할 수 없습니다.");
		return;
	}
	
	new Handle:dds_hMenuMyitemset = CreateMenu(Menu_SMyitemset);
	new String:buffer[256];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 내 장착 아이템\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuMyitemset, buffer);
	SetMenuExitButton(dds_hMenuMyitemset, true);
	SetMenuExitBackButton(dds_hMenuMyitemset, true);
	
	for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
	{
		if (!dds_bItemCodeUse[i])	continue;	// 사용자 지정 아이템 종류 사용 유/무 체크
		
		new String:tempnum[4], String:tempitemname[64];
		
		IntToString(i, tempnum, sizeof(tempnum));
		
		Format(tempitemname, sizeof(tempitemname), dds_sUserItemName[client][i]);
		Format(buffer, sizeof(buffer), "장착된 %s: %s", dds_sItemCodeName[i], tempitemname);
		
		AddMenuItem(dds_hMenuMyitemset, tempnum, buffer);
	}
	
	DisplayMenu(dds_hMenuMyitemset, client, MENU_TIME_FOREVER);
}

/* 내 인벤토리 메뉴 출력 함수 */
public Action:Menu_Myinven(client, args)
{
	if (!GetConVarBool(dds_eConvar[HPLUGINSWITCH]))	return Plugin_Continue;
	
	new Handle:dds_hMenuMyinven = CreateMenu(Menu_SMyinven);
	new String:buffer[256], String:tempstr[4];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 내 인벤토리\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuMyinven, buffer);
	SetMenuExitButton(dds_hMenuMyinven, true);
	SetMenuExitBackButton(dds_hMenuMyinven, true);
	
	for (new select = 0; select < ITEMCATEGORY_NUMBER+1; select++)
	{
		if (!dds_bItemCodeUse[select] && (select > 0))	continue;	// '전체' 제외 사용자 지정 아이템 종류 사용 유/무 체크
		
		IntToString(select, tempstr, sizeof(tempstr));
		Format(buffer, sizeof(buffer), "%s 아이템", dds_sItemCodeName[select]);
		
		AddMenuItem(dds_hMenuMyinven, tempstr, buffer);
	}
	DisplayMenu(dds_hMenuMyinven, client, MENU_TIME_FOREVER);
	
	return Plugin_Continue;
}

/* 내 인벤토리 - 선택 항목 확인 메뉴 출력 함수 */
public Menu_Myinven_Sub(client, itemid)
{
	new Handle:dds_hMenuMyinven_Sub = CreateMenu(Menu_SMyinven_Sub);
	new String:buffer[512], String:sendparam[8], String:tempworth[16];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 내 인벤토리 - 선택 항목 - 확인\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuMyinven_Sub, buffer);
	SetMenuExitButton(dds_hMenuMyinven_Sub, true);
	SetMenuExitBackButton(dds_hMenuMyinven_Sub, true);
	
	if (dds_eItem[itemid][ITEMSPECIAL] == 0)
		Format(tempworth, sizeof(tempworth), "일반");
	else if (dds_eItem[itemid][ITEMSPECIAL] == 1)
		Format(tempworth, sizeof(tempworth), "특별");
	else if (dds_eItem[itemid][ITEMSPECIAL] == 2)
		Format(tempworth, sizeof(tempworth), "한정");
	
	Format(buffer, sizeof(buffer), "사용하기");
	Format(sendparam, sizeof(sendparam), "1 %d", itemid);
	AddMenuItem(dds_hMenuMyinven_Sub, sendparam, buffer);
	Format(buffer, sizeof(buffer), "되팔기");
	Format(sendparam, sizeof(sendparam), "2 %d", itemid);
	if ((dds_iUserClass[client] > 1) && (dds_iUserClass[client] < 4))	// 등급 2 ~ 3은 되팔기 사용 불가
		AddMenuItem(dds_hMenuMyinven_Sub, sendparam, buffer, ITEMDRAW_DISABLED);
	else
		AddMenuItem(dds_hMenuMyinven_Sub, sendparam, buffer);
	
	Format(buffer, sizeof(buffer), "버리기\n ");
	Format(sendparam, sizeof(sendparam), "3 %d", itemid);
	AddMenuItem(dds_hMenuMyinven_Sub, sendparam, buffer);
	Format(buffer, sizeof(buffer), "다음 아이템을 선택하셨습니다.\n \n아이템 번호: %d\n아이템 종류: %s\n아이템 이름: %s\n아이템 가격: %d %s (파는 경우: %d %s)\n \n아이템 가치: %s", dds_eItem[itemid][ITEMID], dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], dds_eItem[itemid][ITEMPRICE], DDS_MONEY_NAME_KO, RoundToFloor(dds_eItem[itemid][ITEMPRICE]*GetConVarFloat(dds_eConvar[HITEMSELLRATIO])), DDS_MONEY_NAME_KO, tempworth);
	AddMenuItem(dds_hMenuMyinven_Sub, "4", buffer, ITEMDRAW_DISABLED);
	
	DisplayMenu(dds_hMenuMyinven_Sub, client, MENU_TIME_FOREVER);
}

/* 아이템 구매 메뉴 출력 함수 */
public Menu_Itemlist(client)
{
	new Handle:dds_hMenuItemlist = CreateMenu(Menu_SItemlist);
	new String:buffer[256], String:tempstr[4];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 아이템 구매\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuItemlist, buffer);
	SetMenuExitButton(dds_hMenuItemlist, true);
	SetMenuExitBackButton(dds_hMenuItemlist, true);
	
	for (new select = 0; select < ITEMCATEGORY_NUMBER+1; select++)
	{
		if (!dds_bItemCodeUse[select] && (select > 0))	continue;	// '전체' 제외 사용자 지정 아이템 종류 사용 유/무 체크
		
		IntToString(select, tempstr, sizeof(tempstr));
		Format(buffer, sizeof(buffer), "%s 아이템", dds_sItemCodeName[select]);
		
		AddMenuItem(dds_hMenuItemlist, tempstr, buffer);
	}
	DisplayMenu(dds_hMenuItemlist, client, MENU_TIME_FOREVER);
}

/* 아이템 구매 - 선택 항목 메뉴 출력 함수 */
public Menu_Itemlist_Selected(client, itemcode, String:itemtitle[64])
{
	new Handle:dds_hMenuItemlistSelected = CreateMenu(Menu_SItemlist_Selected);
	new String:buffer[256], String:tempid[4];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 아이템 구매 - %s\n ", DDS_MENU_PRIMARY_TITLE, itemtitle);
	SetMenuTitle(dds_hMenuItemlistSelected, buffer);
	SetMenuExitButton(dds_hMenuItemlistSelected, true);
	SetMenuExitBackButton(dds_hMenuItemlistSelected, true);
	
	new count;
	
	if (itemcode == 0)
	{
		for (new i = 1; i < dds_iCurItem; i++)
		{
			if (dds_eItem[i][ITEMSPECIAL] == 2)	continue;	// 아이템 가치 체크(한정 패스)
			if (dds_eItem[i][ITEMUSE] == 0)	continue;	// 특정 아이템 사용 유/무 체크
			if (!dds_bItemCodeUse[dds_eItem[i][ITEMCODE]])	continue;	// 사용자 지정 아이템 종류 사용 유/무 체크
			
			if (dds_iUserClass[client] >= 1)
			{
				IntToString(dds_eItem[i][ITEMID], tempid, sizeof(tempid));
				Format(buffer, sizeof(buffer), "[%s] %s - %d %s", dds_sItemCodeName[dds_eItem[i][ITEMCODE]], dds_eItem[i][ITEMNAME], dds_eItem[i][ITEMPRICE], DDS_MONEY_NAME_KO);
				
				AddMenuItem(dds_hMenuItemlistSelected, tempid, buffer);
				
				count++;
			}
			else if (dds_iUserClass[client] < 1)
			{
				if (dds_eItem[i][ITEMSPECIAL] == 0)
				{
					IntToString(dds_eItem[i][ITEMID], tempid, sizeof(tempid));
					Format(buffer, sizeof(buffer), "[%s] %s - %d %s", dds_sItemCodeName[dds_eItem[i][ITEMCODE]], dds_eItem[i][ITEMNAME], dds_eItem[i][ITEMPRICE], DDS_MONEY_NAME_KO);
					
					AddMenuItem(dds_hMenuItemlistSelected, tempid, buffer);
					
					count++;
				}
			}
		}
	}
	else
	{
		for (new i = 1; i < dds_iCurItem; i++)
		{
			if (dds_eItem[i][ITEMCODE] == itemcode)
			{
				if (dds_eItem[i][ITEMSPECIAL] == 2)	continue;	// 아이템 가치 체크(한정 패스)
				if (dds_eItem[i][ITEMUSE] == 0)	continue;	// 특정 아이템 사용 유/무 체크
				
				if (dds_iUserClass[client] >= 1)
				{
					IntToString(dds_eItem[i][ITEMID], tempid, sizeof(tempid));
					
					Format(buffer, sizeof(buffer), "%s - %d %s", dds_eItem[i][ITEMNAME], dds_eItem[i][ITEMPRICE], DDS_MONEY_NAME_KO);
					AddMenuItem(dds_hMenuItemlistSelected, tempid, buffer);
					
					count++;
				}
				else if (dds_iUserClass[client] < 1)
				{
					if (dds_eItem[i][ITEMSPECIAL] == 0)
					{
						IntToString(dds_eItem[i][ITEMID], tempid, sizeof(tempid));
						
						Format(buffer, sizeof(buffer), "%s - %d %s", dds_eItem[i][ITEMNAME], dds_eItem[i][ITEMPRICE], DDS_MONEY_NAME_KO);
						AddMenuItem(dds_hMenuItemlistSelected, tempid, buffer);
						
						count++;
					}
				}
			}
		}
	}
	
	if (count == 0)
	{
		Format(buffer, sizeof(buffer), "없음");
		AddMenuItem(dds_hMenuItemlistSelected, "0", buffer, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(dds_hMenuItemlistSelected, client, MENU_TIME_FOREVER);
}

/* 아이템 구매 - 선택 항목 - 구매 확인 메뉴 출력 함수 */
public Menu_Itembuy(client, itemid)
{
	new Handle:dds_hMenuItemlist = CreateMenu(Menu_SItembuy);
	new String:buffer[256], String:sendparam[8], String:tempworth[16];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 아이템 구매 - %s - 구매 확인\n ", DDS_MENU_PRIMARY_TITLE, dds_eItem[itemid][ITEMNAME]);
	SetMenuTitle(dds_hMenuItemlist, buffer);
	SetMenuExitButton(dds_hMenuItemlist, true);
	SetMenuExitBackButton(dds_hMenuItemlist, true);
	
	if (dds_eItem[itemid][ITEMSPECIAL] == 0)
		Format(tempworth, sizeof(tempworth), "일반");
	else if (dds_eItem[itemid][ITEMSPECIAL] == 1)
		Format(tempworth, sizeof(tempworth), "특별");
	
	Format(buffer, sizeof(buffer), "확인");
	Format(sendparam, sizeof(sendparam), "1 %d", itemid);
	AddMenuItem(dds_hMenuItemlist, sendparam, buffer);
	Format(buffer, sizeof(buffer), "취소\n ");
	Format(sendparam, sizeof(sendparam), "2 %d", itemid);
	AddMenuItem(dds_hMenuItemlist, sendparam, buffer);
	Format(buffer, sizeof(buffer), "다음 아이템을 구매합니다.\n \n아이템 번호: %d\n아이템 종류: %s\n아이템 이름: %s\n아이템 가격: %d %s\n \n아이템 가치: %s", dds_eItem[itemid][ITEMID], dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], dds_eItem[itemid][ITEMPRICE], DDS_MONEY_NAME_KO, tempworth);
	AddMenuItem(dds_hMenuItemlist, "3", buffer, ITEMDRAW_DISABLED);
	
	DisplayMenu(dds_hMenuItemlist, client, MENU_TIME_FOREVER);
}

/* 옵션 메뉴 출력 함수 */
public Menu_Option(client)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 로드할 수 없습니다.");
		return;
	}
	
	new Handle:dds_hMenuOption = CreateMenu(Menu_SOption);
	new String:buffer[256];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 옵션\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuOption, buffer);
	SetMenuExitButton(dds_hMenuOption, true);
	SetMenuExitBackButton(dds_hMenuOption, true);
	
	for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
	{
		if (!dds_bItemCodeUse[i])	continue;	// 사용자 지정 아이템 종류 사용 유/무 체크
		
		new String:tempstatus[16], String:tempcatenum[4];
		
		if (dds_bUserStatus[client][i])
			Format(tempstatus, sizeof(tempstatus), "활성화");
		else
			Format(tempstatus, sizeof(tempstatus), "비활성화");
		
		IntToString(i, tempcatenum, sizeof(tempcatenum));
		Format(buffer, sizeof(buffer), "%s: %s", dds_sItemCodeName[i], tempstatus);
		
		AddMenuItem(dds_hMenuOption, tempcatenum, buffer);
	}
	
	DisplayMenu(dds_hMenuOption, client, MENU_TIME_FOREVER);
}

/* 플러그인 정보 메뉴 출력 함수 */
public Menu_PluginInfo(client)
{
	new Handle:dds_hMenuPluginInfo = CreateMenu(Menu_SPlugininfo);
	new String:buffer[256];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 플러그인 정보\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuPluginInfo, buffer);
	SetMenuExitButton(dds_hMenuPluginInfo, true);
	SetMenuExitBackButton(dds_hMenuPluginInfo, true);
	
	Format(buffer, sizeof(buffer), "명령어 정보");
	AddMenuItem(dds_hMenuPluginInfo, "1", buffer);
	Format(buffer, sizeof(buffer), "개발자 정보");
	AddMenuItem(dds_hMenuPluginInfo, "2", buffer);
	Format(buffer, sizeof(buffer), "저작권 정보");
	AddMenuItem(dds_hMenuPluginInfo, "3", buffer);
	
	DisplayMenu(dds_hMenuPluginInfo, client, MENU_TIME_FOREVER);
}

/* 플러그인 정보 - 하위 메뉴 출력 함수 */
public Menu_PluginInfo_Sub(client, showcode)
{
	new Handle:dds_hMenuPluginInfo_Sub = CreateMenu(Menu_SPlugininfo_Sub);
	new String:buffer[256];
	
	if (showcode == 1)
	{		
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 플러그인 정보 - 명령어 정보\n ", DDS_MENU_PRIMARY_TITLE);
		SetMenuTitle(dds_hMenuPluginInfo_Sub, buffer);
		SetMenuExitButton(dds_hMenuPluginInfo_Sub, true);
		SetMenuExitBackButton(dds_hMenuPluginInfo_Sub, true);
		
		Format(buffer, sizeof(buffer), "%s - 상점 메뉴를 엽니다.", DDS_CHAT_MAINCOMMAND);
		AddMenuItem(dds_hMenuPluginInfo_Sub, "1", buffer);
		Format(buffer, sizeof(buffer), "!정보(또는 !info) - 특정 유저의 상점 정보를 봅니다.");
		AddMenuItem(dds_hMenuPluginInfo_Sub, "2", buffer);
		if (GetConVarBool(dds_eConvar[HGIFTSWITCH]))
		{
			Format(buffer, sizeof(buffer), "!%s(또는 !%s) - 특정 유저에게 금액을 줍니다.", DDS_MONEY_NAME_KO, DDS_MONEY_NAME_EN);
			AddMenuItem(dds_hMenuPluginInfo_Sub, "3", buffer);
		}
		if (GetConVarBool(dds_eConvar[HITEMGIFTSWITCH]))
		{
			Format(buffer, sizeof(buffer), "!아이템(또는 !item) - 특정 유저에게 아이템을 줍니다.");
			AddMenuItem(dds_hMenuPluginInfo_Sub, "4", buffer);
		}
		
		DisplayMenu(dds_hMenuPluginInfo_Sub, client, MENU_TIME_FOREVER);
	}
	else if (showcode == 2)
	{
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 플러그인 정보 - 개발자 정보\n ", DDS_MENU_PRIMARY_TITLE);
		SetMenuTitle(dds_hMenuPluginInfo_Sub, buffer);
		SetMenuExitButton(dds_hMenuPluginInfo_Sub, true);
		SetMenuExitBackButton(dds_hMenuPluginInfo_Sub, true);
		
		Format(buffer, sizeof(buffer), "Made By. Eakgnarok");
		AddMenuItem(dds_hMenuPluginInfo_Sub, "1", buffer);
		Format(buffer, sizeof(buffer), "(http://eakgnarok.pe.kr)\n ");
		AddMenuItem(dds_hMenuPluginInfo_Sub, "2", buffer);
		Format(buffer, sizeof(buffer), "This Plugin is 'Dynamic Dollar Shop (v%s)'.", DDS_PLUGIN_VERSION);
		AddMenuItem(dds_hMenuPluginInfo_Sub, "3", buffer);
		
		DisplayMenu(dds_hMenuPluginInfo_Sub, client, MENU_TIME_FOREVER);
	}
	else if (showcode == 3)
	{
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 플러그인 정보 - 저작권 정보\n ", DDS_MENU_PRIMARY_TITLE);
		SetMenuTitle(dds_hMenuPluginInfo_Sub, buffer);
		SetMenuExitButton(dds_hMenuPluginInfo_Sub, true);
		SetMenuExitBackButton(dds_hMenuPluginInfo_Sub, true);
		
		Format(buffer, sizeof(buffer), "GNU General Public License 3 (GNU GPL v3)\n ");
		AddMenuItem(dds_hMenuPluginInfo_Sub, "1", buffer);
		Format(buffer, sizeof(buffer), "자세한 저작권 정보: http://www.gnu.org/licenses/");
		AddMenuItem(dds_hMenuPluginInfo_Sub, "2", buffer);
		
		DisplayMenu(dds_hMenuPluginInfo_Sub, client, MENU_TIME_FOREVER);
	}
}

/* 유저 정보 메뉴 출력 함수 */
public Menu_UserInfo(client, target)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정상적으로 정보를 로드할 수 없습니다.");
		return;
	}
	
	new Handle:dds_hMenuUserInfo = CreateMenu(Menu_SNothing1);
	new String:buffer[256], String:targetname[64], String:targetauth[64], String:tempclass[32];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 유저 정보\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuUserInfo, buffer);
	SetMenuExitButton(dds_hMenuUserInfo, true);
	
	GetClientName(target, targetname, sizeof(targetname));
	GetClientAuthString(target, targetauth, sizeof(targetauth));
	
	if (dds_iUserClass[target] == 0)	Format(tempclass, sizeof(tempclass), "0 - 일반 유저");
	else if (dds_iUserClass[target] == 1)	Format(tempclass, sizeof(tempclass), "1 - 특별 유저");
	else if (dds_iUserClass[target] == 2)	Format(tempclass, sizeof(tempclass), "2 - VIP");
	else if (dds_iUserClass[target] == 3)	Format(tempclass, sizeof(tempclass), "3 - 관리자");
	else if (dds_iUserClass[target] == 4)	Format(tempclass, sizeof(tempclass), "4 - 최고 관리자");
	
	Format(buffer, sizeof(buffer), "%s 님의 현재 정보입니다.\n \n닉네임: %s\n스팀 고유번호: %s\n소지 %s: %d\n \n등급: %s", targetname, targetname, targetauth, DDS_MONEY_NAME_KO, dds_iUserMoney[target], tempclass);
	AddMenuItem(dds_hMenuUserInfo, "1", buffer, ITEMDRAW_DISABLED);
	
	DisplayMenu(dds_hMenuUserInfo, client, MENU_TIME_FOREVER);
}

/* 관리 메뉴 출력 함수 */
public Menu_Admin(client)
{
	// 관리자 권한을 갖고 있다면 가능하도록 처리
	if (dds_iUserClass[client] < 3)
	{
		DDS_PrintToChat(client, "해당 기능을 실행할 권한이 없습니다.");
		return;
	}
	
	new Handle:dds_hMenuAdmin = CreateMenu(Menu_SAdmin);
	new String:buffer[256];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuAdmin, buffer);
	SetMenuExitButton(dds_hMenuAdmin, true);
	
	Format(buffer, sizeof(buffer), "%s 주기", DDS_MONEY_NAME_KO);
	AddMenuItem(dds_hMenuAdmin, "1", buffer);
	Format(buffer, sizeof(buffer), "%s 뺏기", DDS_MONEY_NAME_KO);
	AddMenuItem(dds_hMenuAdmin, "2", buffer);
	AddMenuItem(dds_hMenuAdmin, "3", "아이템 주기");
	AddMenuItem(dds_hMenuAdmin, "4", "아이템 뺏기");
	AddMenuItem(dds_hMenuAdmin, "5", "등급 조정");
	
	DisplayMenu(dds_hMenuAdmin, client, MENU_TIME_FOREVER);
}

/* 관리 - 금액 메뉴 출력 함수 */
public Menu_AdminMoney(client, select)
{
	new Handle:dds_hMenuAdminMoney = CreateMenu(Menu_SAdminMoney);
	new String:buffer[256], String:sendparam[16];
	
	if (select == 1)
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 금액 주기 - 금액 선택\n ", DDS_MENU_PRIMARY_TITLE);
	else if (select == 2)
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 금액 뺏기 - 금액 선택\n ", DDS_MENU_PRIMARY_TITLE);
	
	SetMenuTitle(dds_hMenuAdminMoney, buffer);
	SetMenuExitButton(dds_hMenuAdminMoney, true);
	SetMenuExitBackButton(dds_hMenuAdminMoney, true);
	
	// 금액 조정은 여기서!
	Format(buffer, sizeof(buffer), "10 %s", DDS_MONEY_NAME_KO);
	Format(sendparam, sizeof(sendparam), "10 %d", select);
	AddMenuItem(dds_hMenuAdminMoney, sendparam, buffer);
	Format(buffer, sizeof(buffer), "50 %s", DDS_MONEY_NAME_KO);
	Format(sendparam, sizeof(sendparam), "50 %d", select);
	AddMenuItem(dds_hMenuAdminMoney, sendparam, buffer);
	Format(buffer, sizeof(buffer), "100 %s", DDS_MONEY_NAME_KO);
	Format(sendparam, sizeof(sendparam), "100 %d", select);
	AddMenuItem(dds_hMenuAdminMoney, sendparam, buffer);
	Format(buffer, sizeof(buffer), "500 %s", DDS_MONEY_NAME_KO);
	Format(sendparam, sizeof(sendparam), "500 %d", select);
	AddMenuItem(dds_hMenuAdminMoney, sendparam, buffer);
	Format(buffer, sizeof(buffer), "1000 %s", DDS_MONEY_NAME_KO);
	Format(sendparam, sizeof(sendparam), "1000 %d", select);
	AddMenuItem(dds_hMenuAdminMoney, sendparam, buffer);
	if (select == 2)
	{
		Format(buffer, sizeof(buffer), "모든 금액");
		Format(sendparam, sizeof(sendparam), "-1 %d", select);
		AddMenuItem(dds_hMenuAdminMoney, sendparam, buffer);
	}
	
	DisplayMenu(dds_hMenuAdminMoney, client, MENU_TIME_FOREVER);
}

/* 관리 - 금액 - 유저 선택 메뉴 출력 함수 */
public Menu_AdminMoney_User(client, money, select)
{
	new Handle:dds_hMenuAdminMoney_User = CreateMenu(Menu_SAdminMoney_User);
	new String:buffer[256];
	
	new count, String:sendparam[16];
	
	if (select == 1)
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 금액 주기 - 유저 선택\n ", DDS_MENU_PRIMARY_TITLE);
	else if (select == 2)
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 금액 뺏기 - 유저 선택\n ", DDS_MENU_PRIMARY_TITLE);
	
	SetMenuTitle(dds_hMenuAdminMoney_User, buffer);
	SetMenuExitButton(dds_hMenuAdminMoney_User, true);
	SetMenuExitBackButton(dds_hMenuAdminMoney_User, true);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			decl String:username[64];
			
			GetClientName(i, username, sizeof(username));
			
			Format(buffer, sizeof(buffer), "%s", username);
			Format(sendparam, sizeof(sendparam), "%d %d^%d", i, money, select);
			
			AddMenuItem(dds_hMenuAdminMoney_User, sendparam, buffer);
			
			count++;
		}
	}
	
	if (count == 0)
	{
		Format(buffer, sizeof(buffer), "없음");
		AddMenuItem(dds_hMenuAdminMoney_User, "0", buffer, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(dds_hMenuAdminMoney_User, client, MENU_TIME_FOREVER);
}

/* 관리 - 아이템 메뉴 출력 함수 */
public Menu_AdminItem(client, select)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 로드할 수 없습니다.");
		return;
	}
	
	new Handle:dds_hMenuAdminItem = CreateMenu(Menu_SAdminitem);
	new String:buffer[256];
	
	new String:sendparam[16];
	
	if (select == 1)
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 아이템 주기 - 아이템 선택\n ", DDS_MENU_PRIMARY_TITLE);
	else if (select == 2)
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 아이템 뺏기 - 아이템 선택\n ", DDS_MENU_PRIMARY_TITLE);
	
	SetMenuTitle(dds_hMenuAdminItem, buffer);
	SetMenuExitButton(dds_hMenuAdminItem, true);
	SetMenuExitBackButton(dds_hMenuAdminItem, true);
	
	for (new i = 1; i < dds_iCurItem; i++)
	{
		if (dds_eItem[i][ITEMUSE] == 0)	continue;	// 특정 아이템 사용 유/무 체크
		if (!dds_bItemCodeUse[dds_eItem[i][ITEMCODE]])	continue;	// 사용자 지정 아이템 종류 사용 유/무 체크
		
		Format(buffer, sizeof(buffer), "[%s] %s", dds_sItemCodeName[dds_eItem[i][ITEMCODE]], dds_eItem[i][ITEMNAME]);
		Format(sendparam, sizeof(sendparam), "%d %d", i, select);
		
		AddMenuItem(dds_hMenuAdminItem, sendparam, buffer);
	}
	
	DisplayMenu(dds_hMenuAdminItem, client, MENU_TIME_FOREVER);
}

/* 관리 - 아이템 - 유저 선택 메뉴 출력 함수 */
public Menu_AdminItem_User(client, itemid, select)
{
	new Handle:dds_hMenuAdminItem_User = CreateMenu(Menu_SAdminitem_User);
	new String:buffer[256];
	
	new count, String:sendparam[16];
	
	if (select == 1)
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 아이템 주기 - 유저 선택\n ", DDS_MENU_PRIMARY_TITLE);
	else if (select == 2)
		Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 아이템 뺏기 - 유저 선택\n ", DDS_MENU_PRIMARY_TITLE);
	
	SetMenuTitle(dds_hMenuAdminItem_User, buffer);
	SetMenuExitButton(dds_hMenuAdminItem_User, true);
	SetMenuExitBackButton(dds_hMenuAdminItem_User, true);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			decl String:username[64];
			
			GetClientName(i, username, sizeof(username));
			
			Format(buffer, sizeof(buffer), "%s", username);
			Format(sendparam, sizeof(sendparam), "%d %d-%d", i, itemid, select);
			
			AddMenuItem(dds_hMenuAdminItem_User, sendparam, buffer);
			
			count++;
		}
	}
	
	if (count == 0)
	{
		Format(buffer, sizeof(buffer), "없음");
		AddMenuItem(dds_hMenuAdminItem_User, "0", buffer, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(dds_hMenuAdminItem_User, client, MENU_TIME_FOREVER);
}

/* 관리 - 등급 조정 메뉴 출력 함수 */
public Menu_AdminClass(client)
{
	if (dds_iUserClass[client] < 3)
	{
		DDS_PrintToChat(client, "이용할 권한이 없습니다.");
		return;
	}
	
	new Handle:dds_hMenuAdminClass = CreateMenu(Menu_SAdminclass);
	new String:buffer[256];
	
	new count;
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 등급 조정 - 유저 선택\n ", DDS_MENU_PRIMARY_TITLE);
	
	SetMenuTitle(dds_hMenuAdminClass, buffer);
	SetMenuExitButton(dds_hMenuAdminClass, true);
	SetMenuExitBackButton(dds_hMenuAdminClass, true);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			decl String:username[64], String:userid[6];
			
			GetClientName(i, username, sizeof(username));
			
			IntToString(i, userid, sizeof(userid));
			Format(buffer, sizeof(buffer), "%s", username);
			
			AddMenuItem(dds_hMenuAdminClass, userid, buffer);
			
			count++;
		}
	}
	
	if (count == 0)
	{
		Format(buffer, sizeof(buffer), "없음");
		AddMenuItem(dds_hMenuAdminClass, "0", buffer, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(dds_hMenuAdminClass, client, MENU_TIME_FOREVER);
}

/* 관리 - 등급 조정 - 등급 선택 메뉴 출력 함수 */
public Menu_AdminClass_Sub(client, target)
{
	new Handle:dds_hMenuAdminClass_Sub = CreateMenu(Menu_SAdminclass_Sub);
	new String:buffer[256];
	
	new String:username[64], String:sendparam[16];
	
	GetClientName(target, username, sizeof(username));
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 관리 - 등급 조정 - 등급 선택 (%s)\n ", DDS_MENU_PRIMARY_TITLE, username);
	
	SetMenuTitle(dds_hMenuAdminClass_Sub, buffer);
	SetMenuExitButton(dds_hMenuAdminClass_Sub, true);
	SetMenuExitBackButton(dds_hMenuAdminClass_Sub, true);
	
	// 화면 상으로 나타날 때는 아래 쪽이 짤려서 나오는 것을 참고
	Format(buffer, sizeof(buffer), "등급 0 - 일반 유저 (일반 아이템 유료)");
	Format(sendparam, sizeof(sendparam), "0 %d", target);
	AddMenuItem(dds_hMenuAdminClass_Sub, sendparam, buffer);
	Format(buffer, sizeof(buffer), "등급 1 - 특별 유저 (일반+특별 아이템 유료)");
	Format(sendparam, sizeof(sendparam), "1 %d", target);
	AddMenuItem(dds_hMenuAdminClass_Sub, sendparam, buffer);
	Format(buffer, sizeof(buffer), "등급 2 - VIP (모든 아이템 무료)");
	Format(sendparam, sizeof(sendparam), "2 %d", target);
	AddMenuItem(dds_hMenuAdminClass_Sub, sendparam, buffer);
	
	if (dds_iUserClass[client] == 4)
	{
		Format(buffer, sizeof(buffer), "등급 3 - 관리자 (모든 아이템 무료, 일반 관리)");
		Format(sendparam, sizeof(sendparam), "3 %d", target);
		AddMenuItem(dds_hMenuAdminClass_Sub, sendparam, buffer);
		Format(buffer, sizeof(buffer), "등급 4 - 최고 관리자 (모든 아이템 무료, 일반 관리, 최고 관리)");
		Format(sendparam, sizeof(sendparam), "4 %d", target);
		AddMenuItem(dds_hMenuAdminClass_Sub, sendparam, buffer);
	}
	
	DisplayMenu(dds_hMenuAdminClass_Sub, client, MENU_TIME_FOREVER);
}

/* 아이템 목록 보기 명령어 */
public ShowAllItemList(client, String:searchitem[])
{
	new Handle:dds_hMenuItemList = CreateMenu(Menu_SNothing1);
	new String:buffer[128];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 아이템 목록\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuItemList, buffer);
	SetMenuExitButton(dds_hMenuItemList, true);
	
	new count;
	
	for (new i = 1; i < dds_iCurItem; i++)
	{
		if (dds_eItem[i][ITEMUSE] == 0)	continue;
		if (!dds_bItemCodeUse[dds_eItem[i][ITEMCODE]])	continue;
		if ((dds_iUserClass[client] < 1) && (dds_eItem[i][ITEMSPECIAL] == 1))	continue;
		if ((dds_iUserClass[client] < 3) && (dds_eItem[i][ITEMSPECIAL] == 2))	continue;
		if ((strlen(searchitem) > 0) && (StrContains(dds_eItem[i][ITEMNAME], searchitem, false) == -1))	continue;
		
		Format(buffer, sizeof(buffer), "ID %d ~ [%s] %s (%d %s)", 
										dds_eItem[i][ITEMID], dds_sItemCodeName[dds_eItem[i][ITEMCODE]], dds_eItem[i][ITEMNAME], dds_eItem[i][ITEMPRICE], DDS_MONEY_NAME_KO);
		AddMenuItem(dds_hMenuItemList, "", buffer);
		
		count++;
	}
	if (count == 0)
	{
		Format(buffer, sizeof(buffer), "없음");
		AddMenuItem(dds_hMenuItemList, "", buffer, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(dds_hMenuItemList, client, MENU_TIME_FOREVER);
}

/* 자유형 태그 설정 확인 메뉴 */
public Menu_FreeTagValidate(client, String:settag[])
{
	new Handle:dds_hMenuChkTag = CreateMenu(Menu_SChkTag);
	new String:buffer[128], String:sendparam[64];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 자유형 태그 설정\n \n * 설정할 태그: %s\n ", DDS_MENU_PRIMARY_TITLE, settag);
	SetMenuTitle(dds_hMenuChkTag, buffer);
	SetMenuExitButton(dds_hMenuChkTag, true);
	
	Format(buffer, sizeof(buffer), "확인");
	Format(sendparam, sizeof(sendparam), "1 %s", settag);
	AddMenuItem(dds_hMenuChkTag, sendparam, buffer);
	Format(buffer, sizeof(buffer), "취소\n \n이대로 계속 하시겠습니까?\n('취소'하시면 아이템이 소모됩니다!)");
	Format(sendparam, sizeof(sendparam), "2 %s", settag);
	AddMenuItem(dds_hMenuChkTag, sendparam, buffer);
	
	DisplayMenu(dds_hMenuChkTag, client, MENU_TIME_FOREVER);
}

/* 데이터 초기화 확인 메뉴 */
public Menu_InitializeDatabase(client)
{
	// 최고 관리자 권한을 갖고 있다면 가능하도록 처리
	if (dds_iUserClass[client] < 4)
	{
		DDS_PrintToChat(client, "해당 기능을 실행할 권한이 없습니다.");
		return;
	}
	
	new Handle:dds_hMenuInitData = CreateMenu(Menu_SInitData);
	new String:buffer[256];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 데이터 초기화 확인\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuInitData, buffer);
	SetMenuExitButton(dds_hMenuInitData, true);
	
	Format(buffer, sizeof(buffer), "확인");
	AddMenuItem(dds_hMenuInitData, "1", buffer);
	Format(buffer, sizeof(buffer), "취소\n \n* 경고 *\n \n삭제 대상: 데이터베이스에 기록되어 있는 모든 데이터\n \n위의 대상을 삭제합니다.\n \n계속 하시겠습니까?");
	AddMenuItem(dds_hMenuInitData, "2", buffer);
	
	DisplayMenu(dds_hMenuInitData, client, MENU_TIME_FOREVER);
}

/* 데이터 초기화 재확인 메뉴 */
public Menu_InitializeDatabaseRe(client)
{
	new Handle:dds_hMenuInitData_Re = CreateMenu(Menu_SInitData_Re);
	new String:buffer[256];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 데이터 초기화 재확인\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuInitData_Re, buffer);
	SetMenuExitButton(dds_hMenuInitData_Re, true);
	
	Format(buffer, sizeof(buffer), "확인");
	AddMenuItem(dds_hMenuInitData_Re, "1", buffer);
	Format(buffer, sizeof(buffer), "취소\n \n삭제된 이후에는 데이터를 다시 복구할 수 없습니다!\n \n계속 하시겠습니까?");
	AddMenuItem(dds_hMenuInitData_Re, "2", buffer);
	
	DisplayMenu(dds_hMenuInitData_Re, client, MENU_TIME_FOREVER);
}

/* 데이터베이스 복구 확인 01 메뉴 */
public Menu_UserRepairValidate01(client)
{
	// 최고 관리자 권한을 갖고 있다면 가능하도록 처리
	if (dds_iUserClass[client] < 4)
	{
		DDS_PrintToChat(client, "해당 기능을 실행할 권한이 없습니다.");
		return;
	}
	if (!GetConVarBool(dds_eConvar[HREPAIRDBSWITCH]))
	{
		DDS_PrintToChat(client, "데이터복구 기능이 비활성화되어 있으므로 사용하실 수 없습니다.");
		return;
	}
	
	dds_iUserTempData[client][0] = 0;
	dds_iUserTempData[client][1] = 0;
	
	new Handle:dds_hMenuUserRepair01 = CreateMenu(Menu_SUserRepair01);
	new String:buffer[512], String:sendparam[64], String:clnick[64];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 데이터 복구 - 유저 선택\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuUserRepair01, buffer);
	SetMenuExitButton(dds_hMenuUserRepair01, true);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))	continue;
		
		GetClientName(i, clnick, sizeof(clnick));
		
		Format(buffer, sizeof(buffer), clnick);
		Format(sendparam, sizeof(sendparam), "%d", i);
		
		AddMenuItem(dds_hMenuUserRepair01, sendparam, buffer);
	}
	
	DisplayMenu(dds_hMenuUserRepair01, client, MENU_TIME_FOREVER);
}

/* 데이터베이스 복구 확인 02 메뉴 */
public Menu_UserRepairValidate02(client, target)
{
	new Handle:dds_hMenuUserRepair02 = CreateMenu(Menu_SUserRepair02);
	new String:buffer[512], String:sendparam[16];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 데이터 복구 - 모드 선택\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuUserRepair02, buffer);
	SetMenuExitButton(dds_hMenuUserRepair02, true);
	
	Format(buffer, sizeof(buffer), "UNIX 체크 모드");
	Format(sendparam, sizeof(sendparam), "%d^%d", 1, target);
	AddMenuItem(dds_hMenuUserRepair02, sendparam, buffer);
	Format(buffer, sizeof(buffer), "간편 체크 모드");
	Format(sendparam, sizeof(sendparam), "%d^%d", 2, target);
	AddMenuItem(dds_hMenuUserRepair02, sendparam, buffer);
	
	DisplayMenu(dds_hMenuUserRepair02, client, MENU_TIME_FOREVER);
}

/* 데이터베이스 복구 확인 03 메뉴 */
public Menu_UserRepairValidate03(client, String:msg[])
{
	if ((dds_iUserTempData[client][0] <= 0) || (dds_iUserTempData[client][1] <= 0))
	{
		dds_bUserRepairLog[client][0] = false;
		DDS_PrintToChat(client, "내부의 잘못된 처리로 인하여 데이터 복구 모드가 비활성화되었습니다.");
		return;
	}
	if (strlen(msg) <= 0)
	{
		DDS_PrintToChat(client, "날짜 파라메터를 올바르게 작성해주세요.");
		return;
	}
	
	new modeset = dds_iUserTempData[client][0];
	new target = dds_iUserTempData[client][1];
	
	new String:chkmode[32];
	
	if (modeset == 1)
		Format(chkmode, sizeof(chkmode), "UNIX 체크 모드");
	else if (modeset == 2)
		Format(chkmode, sizeof(chkmode), "간편 체크 모드");
	
	new String:msgcopy[64], String:showtimestr[64], String:exstr[2][64], timesave[6], String:timesavestr[64];
	
	strcopy(msgcopy, sizeof(msgcopy), msg);
	
	if (modeset == 2)
	{
		// 시간 배열 - 저렇게 Format 을 해놓으면 파라메터에 순서를 엇갈리게 했을 때 웃기게 되는 상황 발생하니 참고
		do
		{
			for (new i = 0; i < sizeof(msgcopy); i++)
			{
				if (msgcopy[i] == 'Y')
				{
					ExplodeString(msgcopy, "Y", exstr, sizeof(exstr), sizeof(exstr[]));
					strcopy(msgcopy, sizeof(msgcopy), exstr[1]);
					timesave[0] = StringToInt(exstr[0]);
					Format(showtimestr, sizeof(showtimestr), "%s%d 년 ", showtimestr, timesave[0]);
					
					break;
				}
				else if (msgcopy[i] == 'M')
				{
					ExplodeString(msgcopy, "M", exstr, sizeof(exstr), sizeof(exstr[]));
					strcopy(msgcopy, sizeof(msgcopy), exstr[1]);
					timesave[1] = StringToInt(exstr[0]);
					Format(showtimestr, sizeof(showtimestr), "%s%d 월 ", showtimestr, timesave[1]);
					
					break;
				}
				else if (msgcopy[i] == 'D')
				{
					ExplodeString(msgcopy, "D", exstr, sizeof(exstr), sizeof(exstr[]));
					strcopy(msgcopy, sizeof(msgcopy), exstr[1]);
					timesave[2] = StringToInt(exstr[0]);
					Format(showtimestr, sizeof(showtimestr), "%s%d 일 ", showtimestr, timesave[2]);
					
					break;
				}
				else if (msgcopy[i] == 'h')
				{
					ExplodeString(msgcopy, "h", exstr, sizeof(exstr), sizeof(exstr[]));
					strcopy(msgcopy, sizeof(msgcopy), exstr[1]);
					timesave[3] = StringToInt(exstr[0]);
					Format(showtimestr, sizeof(showtimestr), "%s%d 시간 ", showtimestr, timesave[3]);
					
					break;
				}
				else if (msgcopy[i] == 'm')
				{
					ExplodeString(msgcopy, "m", exstr, sizeof(exstr), sizeof(exstr[]));
					strcopy(msgcopy, sizeof(msgcopy), exstr[1]);
					timesave[4] = StringToInt(exstr[0]);
					Format(showtimestr, sizeof(showtimestr), "%s%d 분 ", showtimestr, timesave[4]);
					
					break;
				}
				else if (msgcopy[i] == 's')
				{
					ExplodeString(msgcopy, "s", exstr, sizeof(exstr), sizeof(exstr[]));
					strcopy(msgcopy, sizeof(msgcopy), exstr[1]);
					timesave[5] = StringToInt(exstr[0]);
					Format(showtimestr, sizeof(showtimestr), "%s%d 초 ", showtimestr, timesave[5]);
					
					break;
				}
			}
		} while (strlen(exstr[1]) != 0);
		Format(timesavestr, sizeof(timesavestr), "%d-%d-%d-%d-%d-%d", timesave[0], timesave[1], timesave[2], timesave[3], timesave[4], timesave[5]);
	}
	
	new Handle:dds_hMenuUserRepair03 = CreateMenu(Menu_SUserRepair03);
	new String:buffer[512], String:sendparam[64], String:clnick[64];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 데이터 복구\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuUserRepair03, buffer);
	SetMenuExitButton(dds_hMenuUserRepair03, true);
	
	Format(buffer, sizeof(buffer), "확인");
	if (modeset == 1)
		Format(sendparam, sizeof(sendparam), "1(%s#%d^%d", msg, modeset, target);
	else if (modeset == 2)
		Format(sendparam, sizeof(sendparam), "1(%s#%d^%d", timesavestr, modeset, target);
	AddMenuItem(dds_hMenuUserRepair03, sendparam, buffer);
	GetClientName(client, clnick, sizeof(clnick));
	if (modeset == 1)
		Format(buffer, sizeof(buffer), "취소\n \n * 모드: %s\n * UNIX 시간: (지금으로부터) %s 초 전\n \n선택 유저: %s", chkmode, msg, clnick);
	else if (modeset == 2)
		Format(buffer, sizeof(buffer), "취소\n \n * 모드: %s\n * 선택 이전 시간: (지금으로부터) %s전\n \n선택 유저: %s", chkmode, showtimestr, clnick);
	Format(sendparam, sizeof(sendparam), "2");
	AddMenuItem(dds_hMenuUserRepair03, sendparam, buffer);
	
	DisplayMenu(dds_hMenuUserRepair03, client, MENU_TIME_FOREVER);
}

/********************************
 * 태그 처리 관련
********************************/
/* 태그 처리 함수 */
public SetTag(client, String:tagmsg[])
{
	if (GetConVarBool(dds_eConvar[HFRTAGSAVESWITCH]))
	{
		if (dds_hDatabase == INVALID_HANDLE)
		{
			DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 로드할 수 없습니다.");
			return;
		}
		
		if (!dds_bUserDatabaseUse[client])
		{
			DDS_PrintToChat(client, "유저 정보가 아직 로드되지 않았습니다!");
			return;
		}
		
		new String:temptagmsg[64];
		
		strcopy(temptagmsg, sizeof(temptagmsg), tagmsg);
		
		SetPreventSQLInject(temptagmsg, temptagmsg, sizeof(temptagmsg));
		
		new String:genquery[512], String:userauth[32];
		
		GetClientAuthString(client, userauth, sizeof(userauth));
		
		Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET freetag='%s' WHERE authid='%s'", tagmsg, userauth);
		DDS_SendQuery(dds_hDatabase, SQL_Info_ProfileUpdate, genquery, client);
	}
	
	Format(dds_sFreeTag[client], 64, tagmsg);
	DDS_PrintToChat(client, "태그 설정이 완료되었습니다(설정한 태그: '%s').", tagmsg);
	dds_bFreeTag[client][0] = false;
	dds_bFreeTag[client][1] = true;
}

/********************************
 * 로그
********************************/
/* 데이터 로그 기록 처리 함수 */
public SetLog(client, target, action, itemid, anydata1, anydata2, String:anydata3[])
{
	new String:curdate[32], String:curtime[32], String:clusername[64], String:tausername[64], String:cluserauth[64], String:tauserauth[64], String:cluserip[32], String:logmsg[1024], String:genquery[1024];
	
	if (((client > 0) && IsClientInGame(client)) || (client == -1))
	{
		if (client != -1)
		{
			GetClientName(client, clusername, sizeof(clusername));
			GetClientAuthString(client, cluserauth, sizeof(cluserauth));
			GetClientIP(client, cluserip, sizeof(cluserip), true);
			
			SetPreventSQLInject(clusername, clusername, sizeof(clusername));
		}
		else if (client == -1)
		{
			if (strlen(anydata3) > 0)
			{
				new String:exstr[3][64];
				
				ExplodeString(anydata3, "||", exstr, sizeof(exstr), sizeof(exstr[]));
				
				Format(clusername, sizeof(clusername), exstr[0]);
				Format(cluserauth, sizeof(cluserauth), exstr[1]);
				Format(cluserip, sizeof(cluserip), exstr[2]);
				
				SetPreventSQLInject(clusername, clusername, sizeof(clusername));
			}
		}
	}
	if ((target > 0) && IsClientInGame(target))
	{
		GetClientName(target, tausername, sizeof(tausername));
		GetClientAuthString(target, tauserauth, sizeof(tauserauth));
		
		SetPreventSQLInject(tausername, tausername, sizeof(tausername));
	}
	
	if (GetConVarInt(dds_eConvar[HDATALOGDBSWITCH]) == 1)
	{
		new svport, String:paramdata1[64], String:paramdata2[64], String:setdata[256], String:setparam[256];
		
		svport = GetConVarInt(FindConVar("hostport"));
		
		if ((action > 2) || (((action == 1) || (action == 2)) && ((anydata1 == 3) || (anydata1 == 4))))
		{
			new count;
			
			for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
			{
				new String:tempnum[8];
				
				if (i < 10)
					Format(tempnum, sizeof(tempnum), "0%d", i);
				else if (i >= 10)
					Format(tempnum, sizeof(tempnum), "%d", i);
				
				if (dds_iUserItemID[client][i] > 0)
				{
					if (count == 0)
					{
						Format(setdata, sizeof(setdata), ", L%s", tempnum);
						Format(setparam, sizeof(setparam), ", '%s'", dds_eItem[dds_iUserItemID[client][i]][ITEMNAME]);
					}
					else if (count > 0)
					{
						Format(setdata, sizeof(setdata), "%s, L%s", setdata, tempnum);
						Format(setparam, sizeof(setparam), "%s, '%s'", setparam, dds_eItem[dds_iUserItemID[client][i]][ITEMNAME]);
					}
					count++;
				}
			}
		}
		
		if (action == 0) // IP 기록
		{
			return;
		}
		else if (action == 3 || action == 4) // 구매, 되팔기
		{
			Format(paramdata1, sizeof(paramdata1), "[%s] %s (금액: %d)", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], dds_eItem[itemid][ITEMPRICE]);
			Format(paramdata2, sizeof(paramdata2), "%d", dds_iUserMoney[client]);
		}
		else if (action == 5) // 버리기
		{
			Format(paramdata1, sizeof(paramdata1), "[%s] %s (금액: %d)", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], dds_eItem[itemid][ITEMPRICE]);
		}
		else if (action == 6) // 관리
		{
			if ((anydata1 == 1) || (anydata1 == 2)) // 금액 주기, 금액 뺏기
			{
				Format(paramdata1, sizeof(paramdata1), "%d", anydata2);
				Format(paramdata2, sizeof(paramdata2), "%d", dds_iUserMoney[target]);
			}
			else if ((anydata1 == 3) || (anydata1 == 4)) // 아이템 주기, 아이템 뺏기
			{
				Format(paramdata1, sizeof(paramdata1), "[%s] %s", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
			}
			else if (anydata1 == 5) // 등급 조정
			{
				Format(paramdata1, sizeof(paramdata1), "%d", anydata2);
			}
		}
		else if (action == 7) // 선물
		{
			if ((anydata1 == 1) || (anydata1 == 3)) // 금액, 금액 예약 수령
			{
				Format(paramdata1, sizeof(paramdata1), "%d", anydata2);
			}
			else if ((anydata1 == 2) || (anydata1 == 4))// 아이템, 아이템 예약 수령
			{
				Format(paramdata1, sizeof(paramdata1), "[%s] %s", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
				Format(paramdata2, sizeof(paramdata2), "%d", anydata2);
			}
		}
		
		Format(genquery, sizeof(genquery), "INSERT INTO dds_serverlog(date, svport, action, subaction, clnickname, clauthid, tanickname, taauthid, ip, anydata1, anydata2%s) VALUES('%d', '%d', '%d', '%d', '%s', '%s', '%s', '%s', '%s', '%s', '%s'%s)", 
											setdata, GetTime(), svport, action, anydata1, clusername, cluserauth, tausername, tauserauth, cluserip, paramdata1, paramdata2, setparam);
		DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
	}
	else if (GetConVarInt(dds_eConvar[HDATALOGDBSWITCH]) == 2)
	{
		FormatTime(curdate, sizeof(curdate), "%y/%m/%d", GetTime());
		FormatTime(curtime, sizeof(curtime), "%H:%M:%S", GetTime());
		
		if (action == 0) // IP 기록
		{
			if (anydata1 == 1) // 접속
			{
				Format(logmsg, sizeof(logmsg), "[%s][%s][접속] 닉네임: %s (%s), IP: %s", 
												curdate, curtime, clusername, cluserauth, cluserip);
			}
			else if (anydata1 == 2) // 접속 해제
			{
				Format(logmsg, sizeof(logmsg), "[%s][%s][접속 해제] 닉네임: %s (%s), IP: %s", 
												curdate, curtime, clusername, cluserauth, cluserip);
			}
		}
		else if (action == 1 || action == 2) // 접속, 접속 해제, 게임 참여, 게임 퇴장
		{
			new String:actionname[32];
			
			if (anydata1 == 1)	Format(actionname, sizeof(actionname), "~접속~");
			else if (anydata1 == 2)	Format(actionname, sizeof(actionname), "~접속 해제~");
			else if (anydata1 == 3)	Format(actionname, sizeof(actionname), "게임 참여");
			else if (anydata1 == 4)	Format(actionname, sizeof(actionname), "게임 퇴장");
			
			if (anydata1 == 1 || anydata1 == 2)
			{
				Format(logmsg, sizeof(logmsg), "[%s][%s][%s] 닉네임: %s (%s), IP: %s", 
												curdate, curtime, actionname, clusername, cluserauth, cluserip);
			}
			else if (anydata1 == 3 || anydata1 == 4)
			{
				new String:itemdata[512], count;
				
				for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
				{
					if (dds_iUserItemID[client][i] > 0)
					{
						if (count == 0)
							Format(itemdata, sizeof(itemdata), "(%s)%s", dds_sItemCodeName[i], dds_eItem[dds_iUserItemID[client][i]][ITEMNAME]);
						else if (count > 0)
							Format(itemdata, sizeof(itemdata), "%s (%s)%s", itemdata, dds_sItemCodeName[i], dds_eItem[dds_iUserItemID[client][i]][ITEMNAME]);
						
						count++;
					}
				}
				
				if (count == 0)
					Format(itemdata, sizeof(itemdata), "<아무것도 장착하지 않음>");
				
				Format(logmsg, sizeof(logmsg), "[%s][%s][%s] 닉네임: %s (%s), 금액: %d, 장착 아이템: %s", 
												curdate, curtime, actionname, clusername, cluserauth, dds_iUserMoney[client], itemdata);
			}
		}
		else if (action == 3) // 구매
		{
			Format(logmsg, sizeof(logmsg), "[%s][%s][구매] 닉네임: %s (%s), 구매 아이템: [%s] %s (금액: %d), 남은 금액: %d", 
											curdate, curtime, clusername, cluserauth, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], dds_eItem[itemid][ITEMPRICE], dds_iUserMoney[client]);
		}
		else if (action == 4) // 되팔기
		{
			Format(logmsg, sizeof(logmsg), "[%s][%s][되팔기] 닉네임: %s (%s), 되팔은 아이템: [%s] %s (금액: %d), 남은 금액: %d", 
											curdate, curtime, clusername, cluserauth, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], dds_eItem[itemid][ITEMPRICE], dds_iUserMoney[client]);
		}
		else if (action == 5) // 버리기
		{
			Format(logmsg, sizeof(logmsg), "[%s][%s][버리기] 닉네임: %s (%s), 버린 아이템: [%s] %s (금액: %d)", 
											curdate, curtime, clusername, cluserauth, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], dds_eItem[itemid][ITEMPRICE]);
		}
		else if (action == 6) // 관리
		{
			decl String:setproc[32];
			
			if (anydata1 == 1)	Format(setproc, sizeof(setproc), "금액 주기");
			else if (anydata1 == 2)	Format(setproc, sizeof(setproc), "금액 뺏기");
			else if (anydata1 == 3)	Format(setproc, sizeof(setproc), "아이템 주기");
			else if (anydata1 == 4)	Format(setproc, sizeof(setproc), "아이템 뺏기");
			else if (anydata1 == 5)	Format(setproc, sizeof(setproc), "등급 조정");
			else if (anydata1 == 6)	Format(setproc, sizeof(setproc), "금액 선물");
			else if (anydata1 == 7)	Format(setproc, sizeof(setproc), "아이템 선물");
			
			if ((anydata1 == 1) || (anydata1 == 2))
				Format(logmsg, sizeof(logmsg), "[%s][%s][어드민 관리 - %s] 어드민 닉네임: %s (%s), 대상 닉네임: %s (%s), 선택한 금액: %d, 대상의 남은 금액: %d", 
												curdate, curtime, setproc, clusername, cluserauth, tausername, tauserauth, anydata2, dds_iUserMoney[target]);
			else if ((anydata1 == 3) || (anydata1 == 4))
				Format(logmsg, sizeof(logmsg), "[%s][%s][어드민 관리 - %s] 어드민 닉네임: %s (%s), 대상 닉네임: %s (%s), 선택한 아이템: [%s] %s", 
												curdate, curtime, setproc, clusername, cluserauth, tausername, tauserauth, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME]);
			else if (anydata1 == 5)
				Format(logmsg, sizeof(logmsg), "[%s][%s][어드민 관리 - %s] 어드민 닉네임: %s (%s), 대상 닉네임: %s (%s), 변경한 등급: %d", 
												curdate, curtime, setproc, clusername, cluserauth, tausername, tauserauth, anydata2);
		}
		else if (action == 7) // 선물
		{
			decl String:setproc[32];
			
			if (anydata1 == 1)	Format(setproc, sizeof(setproc), "금액");
			else if (anydata1 == 2)	Format(setproc, sizeof(setproc), "아이템");
			else if (anydata1 == 3)	Format(setproc, sizeof(setproc), "금액 예약");
			else if (anydata1 == 4)	Format(setproc, sizeof(setproc), "아이템 예약");
			
			if (anydata1 == 1)
				Format(logmsg, sizeof(logmsg), "[%s][%s][선물 - %s] 보낸 사람 닉네임: %s (%s), 받은 사람 닉네임: %s (%s), 받은 금액: %d", curdate, curtime, setproc, clusername, cluserauth, tausername, tauserauth, anydata2);
			else if (anydata1 == 2)
				Format(logmsg, sizeof(logmsg), "[%s][%s][선물 - %s] 보낸 사람 닉네임: %s (%s), 받은 사람 닉네임: %s (%s), 받은 아이템: [%s] %s, 갯수: %d 개", curdate, curtime, setproc, clusername, cluserauth, tausername, tauserauth, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], anydata2);
			else if (anydata1 == 3)
				Format(logmsg, sizeof(logmsg), "[%s][%s][선물 - %s] 받은 사람 닉네임: %s (%s), 받은 금액: %d", curdate, curtime, setproc, clusername, cluserauth, anydata2);
			else if (anydata1 == 4)
				Format(logmsg, sizeof(logmsg), "[%s][%s][선물 - %s] 받은 사람 닉네임: %s (%s), 받은 아이템: [%s] %s, 갯수: %d 개", curdate, curtime, setproc, clusername, cluserauth, dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], anydata2);
		}
		
		if (action == 0)
		{
			dds_hUserIPLogFile = OpenFile(dds_sUserIPLogFile, "a");
			if (dds_hUserIPLogFile != INVALID_HANDLE)
			{
				WriteFileLine(dds_hUserIPLogFile, logmsg);
				CloseHandle(dds_hUserIPLogFile);
			}
		}
		else if (action > 0)
		{
			dds_hUserDataLogFile = OpenFile(dds_sUserDataLogFile, "a");
			if (dds_hUserDataLogFile != INVALID_HANDLE)
			{
				WriteFileLine(dds_hUserDataLogFile, logmsg);
				CloseHandle(dds_hUserDataLogFile);
			}
		}
	}
}

/* 채팅 로그 기록 처리 함수 */
public SetChatLog(client, String:message[])
{
	new String:curdate[32], String:curtime[32], String:clusername[64], String:cluserauth[64], String:cluserip[32], String:tempmsg[512];
	
	if ((client > 0) && IsClientInGame(client))
	{
		GetClientName(client, clusername, sizeof(clusername));
		GetClientAuthString(client, cluserauth, sizeof(cluserauth));
		GetClientIP(client, cluserip, sizeof(cluserip), true);
	}
	
	Format(tempmsg, sizeof(tempmsg), message);
	
	SetPreventSQLInject(clusername, clusername, sizeof(clusername));
	SetPreventSQLInject(tempmsg, tempmsg, sizeof(tempmsg));
	
	FormatTime(curdate, sizeof(curdate), "%y/%m/%d", GetTime());
	FormatTime(curtime, sizeof(curtime), "%H:%M:%S", GetTime());
	
	if (GetConVarInt(dds_eConvar[HCHATLOGDBSWITCH]) == 1)
	{
		new svport, String:genquery[512];
		
		svport = GetConVarInt(FindConVar("hostport"));
		
		Format(genquery, sizeof(genquery), "INSERT INTO dds_serverchat(date, svport, nickname, authid, ip, msg) VALUES('%d', '%d', '%s', '%s', '%s', '%s')", 
											GetTime(), svport, clusername, cluserauth, cluserip, tempmsg);
		DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
	}
	else if (GetConVarInt(dds_eConvar[HCHATLOGDBSWITCH]) == 2)
	{
		new String:logmsg[512];
		
		Format(logmsg, sizeof(logmsg), "[%s][%s] 닉네임: %s (%s), IP: %s, 내용: %s", 
										curdate, curtime, clusername, cluserauth, cluserip, message);
		
		dds_hUserChatLogFile = OpenFile(dds_sUserChatLogFile, "a");
		if (dds_hUserChatLogFile != INVALID_HANDLE)
		{
			WriteFileLine(dds_hUserChatLogFile, logmsg);
			CloseHandle(dds_hUserChatLogFile);
		}
	}
}

/* 유저 로그 기록 처리 함수 */
public SetUserRepairLog(client, bool:applybasic, bool:applyitem, itemid, itemcode, itemstat, itemcount)
{
	if (!GetConVarBool(dds_eConvar[HREPAIRDBSWITCH]))	return;
	
	new String:username[64], String:userauth[64], String:genquery[512];
	
	if ((client > 0) && IsClientInGame(client))
	{
		GetClientName(client, username, sizeof(username));
		GetClientAuthString(client, userauth, sizeof(userauth));
		
		SetPreventSQLInject(username, username, sizeof(username));
		
		if (applybasic)
		{
			Format(genquery, sizeof(genquery), "INSERT INTO dds_userlog_basic(authid, date, money, class) VALUES('%s', '%d', '%d', '%d')", 
												userauth, GetTime(), dds_iUserMoney[client], dds_iUserClass[client]);
			DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
		}
		if (applyitem)
		{
			Format(genquery, sizeof(genquery), "INSERT INTO dds_userlog_item(authid, date, itemid, itemcode, itemstat, itemcount, itemappid) VALUES('%s', '%d', '%d', '%d', '%d', '%d', '%d')", 
												userauth, GetTime(), itemid, itemcode, itemstat, itemcount, dds_iUserItemID[client][itemcode]);
			DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
		}
	}
}

/********************************
 * 선물 처리
********************************/
/* 금액 선물 처리 함수 */
public TransMoneyGift(client, any:data)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 본 기능을 이용하실 수 없습니다.");
		return;
	}
	
	new String:settarget[64], moneyamount;
	
	GetArrayString(data, 0, settarget, sizeof(settarget));
	moneyamount = GetArrayCell(data, 1);
	
	CloseHandle(data);
	
	if (GetConVarBool(dds_eConvar[HGIFTSWITCH]) || (dds_iUserClass[client] > 2))
	{
		new String:tempname[64], String:tempuserauth[32], count, chknum;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				if (StrContains(settarget, "STEAM_", false) != -1)
				{
					GetClientName(i, tempname, sizeof(tempname));
					GetClientAuthString(i, tempuserauth, sizeof(tempuserauth));
					if (StrEqual(tempuserauth, settarget, false))
					{
						count++;
						chknum = i;
					}
				}
				else
				{
					GetClientName(i, tempname, sizeof(tempname));
					if (StrContains(tempname, settarget, false) != -1)
					{
						if ((strlen(tempname) > 0) && (strlen(settarget) != 0))
						{
							count++;
							chknum = i;
						}
					}
				}
			}
		}
		
		if (count == 1)
		{
			if (moneyamount <= 0)
			{
				if (moneyamount == 0)
				{
					DDS_PrintToChat(client, "금액을 입력하세요.");
					return;
				}
				else if (moneyamount < 0)
				{
					DDS_PrintToChat(client, "금액은 0 %s 보다 높게 써야합니다.", DDS_MONEY_NAME_KO);
					return;
				}
			}
			if ((dds_iUserMoney[client] < moneyamount) && (dds_iUserClass[client] < 3))
			{
				DDS_PrintToChat(client, "%d %s이(가) 부족합니다.", moneyamount-dds_iUserMoney[client], DDS_MONEY_NAME_KO);
				return;
			}
			if ((client == chknum) && (dds_iUserClass[client] < 3))
			{
				DDS_PrintToChat(client, "자기 자신에게 선물할 수 없습니다.");
				return;
			}
			
			if (dds_iUserClass[client] < 3) // 주체가 어드민이 아닌 경우
			{
				// 유저 금액 설정
				SetUserMoney(client, 3, moneyamount);
				SetUserMoney(chknum, 2, moneyamount);
				
				SetLog(client, chknum, 7, 0, 1, moneyamount, "");
				
				GetClientName(chknum, tempname, sizeof(tempname));
				DDS_PrintToChat(client, "%s 님에게 %d %s을(를) 선물하였습니다.", tempname, moneyamount, DDS_MONEY_NAME_KO);
				GetClientName(client, tempname, sizeof(tempname));
				DDS_PrintToChat(chknum, "%s 님으로부터 %d %s을(를) 받았습니다.", tempname, moneyamount, DDS_MONEY_NAME_KO);
			}
			else // 주체가 어드민인 경우
			{
				SetUserMoney(chknum, 2, moneyamount);
				
				SetLog(client, chknum, 7, 0, 1, moneyamount, "");
				
				if (client == chknum) // 주체와 대상이 같은 경우
				{
					DDS_PrintToChat(client, "%d %s을(를) 받았습니다.", moneyamount, DDS_MONEY_NAME_KO);
				}
				else if (client != chknum) // 주체와 대상이 다른 경우
				{
					GetClientName(chknum, tempname, sizeof(tempname));
					DDS_PrintToChat(client, "%s 님에게 %d %s을(를) 선물하였습니다.", tempname, moneyamount, DDS_MONEY_NAME_KO);
					GetClientName(client, tempname, sizeof(tempname));
					DDS_PrintToChat(chknum, "%s 님으로부터 %d %s을(를) 받았습니다.", tempname, moneyamount, DDS_MONEY_NAME_KO);
				}
			}
		}
		else if (count > 1)
		{
			DDS_PrintToChat(client, "해당 이름이 포함된 유저가 1명 이상입니다.");
		}
		else if (count < 1)
		{
			if (StrContains(settarget, "STEAM_", false) != -1)
			{
				if (dds_iUserClass[client] > 2)
				{
					new String:genquery[512], Handle:sendparam = CreateArray(64);
					
					PushArrayCell(sendparam, client);
					PushArrayCell(sendparam, 1);
					PushArrayString(sendparam, settarget);
					PushArrayCell(sendparam, moneyamount);
					
					Format(genquery, sizeof(genquery), "SELECT * FROM dds_userreserved WHERE authid='%s' AND type='2'", tempuserauth);
					DDS_SendQuery(dds_hDatabase, SQL_FindAuthIDForGift, genquery, sendparam);
				}
				else
				{
					DDS_PrintToChat(client, "고유번호를 이용한 선물은 관리자만 가능합니다.");
				}
			}
			else
			{
				if (strlen(settarget) > 0)
					DDS_PrintToChat(client, "해당 이름이 포함된 유저가 없습니다.");
				else
					DDS_PrintToChat(client, "사용법: !%s(!%s) \"이름(또는 고유번호)\" \"금액\"", DDS_MONEY_NAME_KO, DDS_MONEY_NAME_EN);
			}
		}
	}
	else
	{
		DDS_PrintToChat(client, "금액 선물 기능이 활성화가 되어 있지 않습니다.");
	}
}

/* 아이템 선물 처리 함수 */
public TransItemGift(client, any:data)
{
	if (dds_hDatabase == INVALID_HANDLE)
	{
		DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 본 기능을 이용하실 수 없습니다.");
		return;
	}
	
	new String:settarget[64], setitemid, setitemamount;
	
	GetArrayString(data, 0, settarget, sizeof(settarget));
	setitemid = GetArrayCell(data, 1);
	setitemamount = GetArrayCell(data, 2);
	
	CloseHandle(data);
	
	if (GetConVarBool(dds_eConvar[HITEMGIFTSWITCH]) || (dds_iUserClass[client] > 2))
	{
		if (dds_iUserClass[client] == 2)
		{
			DDS_PrintToChat(client, "VIP 등급은 아이템 선물 기능을 사용할 수 없습니다!");
			return;
		}
		
		new String:tempname[64], String:tempuserauth[32], count, chknum;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				if (StrContains(settarget, "STEAM_", false) != -1)
				{
					GetClientName(i, tempname, sizeof(tempname));
					GetClientAuthString(i, tempuserauth, sizeof(tempuserauth));
					if (StrEqual(tempuserauth, settarget, false))
					{
						count++;
						chknum = i;
					}
				}
				else
				{
					GetClientName(i, tempname, sizeof(tempname));
					if (StrContains(tempname, settarget, false) != -1)
					{
						if ((strlen(tempname) > 0) && (strlen(settarget) != 0))
						{
							count++;
							chknum = i;
						}
					}
				}
			}
		}
		
		if (count == 1)
		{
			if (setitemid <= 0)
			{
				if (setitemid == 0)
				{
					DDS_PrintToChat(client, "아이템 ID를 입력해주세요.");
					return;
				}
				else if (setitemid < 0)
				{
					DDS_PrintToChat(client, "아이템 ID는 0 보다 높게 써야합니다.");
					return;
				}
			}
			if (setitemamount <= 0)
			{
				if (setitemamount == 0)
				{
					DDS_PrintToChat(client, "아이템 갯수를 입력해주세요.");
				}
				else if (setitemamount < 0)
				{
					DDS_PrintToChat(client, "아이템 갯수는 0 보다 높게 써야합니다.");
				}
			}
			
			new itemchk;
			
			for (new i = 1; i < dds_iCurItem; i++)
			{
				if (setitemid == i)	itemchk++;
			}
			
			if (itemchk == 0)
			{
				DDS_PrintToChat(client, "해당하는 아이템 ID가 존재하지 않습니다.");
				return;
			}
			if ((dds_iUserItemCount[client][setitemid] < setitemamount) && (dds_iUserClass[client] <= 2))
			{
				DDS_PrintToChat(client, "보유하고 있는 아이템이 없거나 갯수가 모자릅니다.");
				return;
			}
			
			if (dds_iUserClass[client] <= 2)
				DDS_SimpleRemoveItem(client, setitemid, setitemamount);
			
			DDS_SimpleGiveItem(chknum, setitemid, setitemamount);
			
			SetLog(client, chknum, 7, setitemid, 2, setitemamount, "");
			
			GetClientName(chknum, tempname, sizeof(tempname));
			DDS_PrintToChat(client, "%s 님에게 %d 개의 '[%s] %s'을(를) 선물하였습니다.", tempname, setitemamount, dds_sItemCodeName[dds_eItem[setitemid][ITEMCODE]], dds_eItem[setitemid][ITEMNAME]);
			GetClientName(client, tempname, sizeof(tempname));
			DDS_PrintToChat(chknum, "%s 님으로부터 %d 개의 '[%s] %s'을(를) 받았습니다.", tempname, setitemamount, dds_sItemCodeName[dds_eItem[setitemid][ITEMCODE]], dds_eItem[setitemid][ITEMNAME]);
		}
		else if (count > 1)
		{
			DDS_PrintToChat(client, "해당 이름이 포함된 유저가 1명 이상입니다.");
		}
		else if (count < 1)
		{
			if (StrContains(settarget, "STEAM_", false) != -1)
			{
				if (dds_iUserClass[client] > 2)
				{
					new String:genquery[512], Handle:sendparam = CreateArray(64);
					
					PushArrayCell(sendparam, client);
					PushArrayCell(sendparam, 1);
					PushArrayString(sendparam, settarget);
					PushArrayCell(sendparam, setitemid);
					PushArrayCell(sendparam, setitemamount);
					
					Format(genquery, sizeof(genquery), "SELECT * FROM dds_userreserved WHERE authid='%s' AND type='3'", tempuserauth);
					DDS_SendQuery(dds_hDatabase, SQL_FindAuthIDForItemGift, genquery, sendparam);
				}
				else
				{
					DDS_PrintToChat(client, "고유번호를 이용한 선물은 관리자만 가능합니다.");
				}
			}
			else
			{
				if (strlen(settarget) > 0)
					DDS_PrintToChat(client, "해당 이름이 포함된 유저가 없습니다.");
				else
					DDS_PrintToChat(client, "사용법: !아이템(!item) \"이름(또는 고유번호)\" \"아이템ID\" \"갯수\"");
			}
		}
	}
	else
	{
		DDS_PrintToChat(client, "아이템 선물 기능이 활성화가 되어 있지 않습니다.");
	}
}

/********************************
 * 기타
********************************/
/* 인칭 전환 */
public Action:SwitchPersonView(client, args)
{
	if (!IsPlayerAlive(client))	return;
	
	new entval = GetEntProp(client, Prop_Send, "m_iObserverMode");
	
	if (entval == 0)
	{
		// 3인칭 설정
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(client, Prop_Send, "m_iFOV", 120);
	}
	else if (entval == 1)
	{
		// 1인칭 설정
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", -1);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
	}
}

/* 아이템 종류 확인(bool) 처리 함수 */
public bool:IsThereThisItemCode_bool(String:name[32])
{
	for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
	{
		if (StrEqual(dds_sGetItemCodeList[i][2], name, false))
			return true;
	}
	
	return false;
}

/* 아이템 종류 확인(Num) 처리 함수 */
public IsThereThisItemCode_num(String:name[32])
{
	for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
	{
		if (StrEqual(dds_sGetItemCodeList[i][2], name, false))
			return i;
	}
	
	return 0;
}

Nothing()
{
	
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
public Action:Command_Say(client, args)
{
	if (!GetConVarBool(dds_eConvar[HPLUGINSWITCH]))	return Plugin_Continue;
	
	// 서버 채팅은 통과
	if (client == 0)	return Plugin_Continue;
	
	new String:msg[256], String:name[256], String:chatparam[4][256];
	
	GetClientName(client, name, sizeof(name));
	GetCmdArgString(msg, sizeof(msg));
	
	msg[strlen(msg)-1] = '\x0';
	
	// 채팅 로그 기록
	if (GetConVarBool(dds_eConvar[HCHATLOGSWITCH]))
		SetChatLog(client, msg[1]);
	
	// 공백을 기준으로 채팅 자체의 내용을 파라메터 파악
	ExplodeString(msg[1], " ", chatparam, sizeof(chatparam), sizeof(chatparam[]));
	
	// 태그 설정 처리 부분
	if (dds_bFreeTag[client][0])
	{
		Menu_FreeTagValidate(client, msg[1]);
		
		return Plugin_Handled;
	}
	// 유저 데이터베이스 복구 처리 부분
	if (dds_bUserRepairLog[client][0])
	{
		Menu_UserRepairValidate03(client, msg[1]);
		
		return Plugin_Handled;
	}
	// 메인 상점 메뉴 명령어에 느낌표가 들어갔다면 해당 문자 삭제
	new String:maincmdchk[3][32];
	
	strcopy(maincmdchk[0], 32, DDS_CHAT_MAINCOMMAND);
	ReplaceString(maincmdchk[0], 32, "!", "", false);
	
	Format(maincmdchk[1], 32, "!%s", maincmdchk[0]);
	Format(maincmdchk[2], 32, "/%s", maincmdchk[0]);
	
	// 메인 상점 메뉴 명령어
	if (StrEqual(msg[1], maincmdchk[1], false) || StrEqual(msg[1], maincmdchk[2], false))
	{
		Menu_Main(client, 0);
	}
	// 유저 정보 명령어
	if (StrEqual(chatparam[0], "!정보", false) || StrEqual(chatparam[0], "!info", false) || StrEqual(chatparam[0], "/정보", false) || StrEqual(chatparam[0], "/info", false))
	{
		new String:tempname[64], count, chknum;
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				GetClientName(i, tempname, sizeof(tempname));
				if (StrContains(tempname, chatparam[1], false) != -1)
				{
					if ((strlen(tempname) > 0) && (strlen(chatparam[1]) != 0))
					{
						count++;
						chknum = i;
					}
				}
			}
		}
		
		if (count == 1)
		{
			Menu_UserInfo(client, chknum);
		}
		else if (count > 1)
		{
			DDS_PrintToChat(client, "해당 이름이 포함된 유저가 2명 이상입니다.");
		}
		else if (count < 1)
		{
			if (strlen(chatparam[1]) > 0)
			{
				DDS_PrintToChat(client, "해당 이름이 포함된 유저가 없습니다.");
			}
			else
			{
				DDS_PrintToChat(client, "사용법: !정보(!info) \"이름\"");
			}
		}
	}
	// 금액 선물 명령어
	new String:mcmdtemp[4][32];
	
	Format(mcmdtemp[0], 32, "!%s", DDS_MONEY_NAME_KO); // 한글 명령어(!)
	Format(mcmdtemp[1], 32, "/%s", DDS_MONEY_NAME_KO); // 한글 명령어(/)
	Format(mcmdtemp[2], 32, "!%s", DDS_MONEY_NAME_EN); // 영어 명령어(!)
	Format(mcmdtemp[3], 32, "/%s", DDS_MONEY_NAME_EN); // 영어 명령어(/)
	
	if (StrEqual(chatparam[0], mcmdtemp[0], false) || StrEqual(chatparam[0], mcmdtemp[1], false) || StrEqual(chatparam[0], mcmdtemp[2], false) || StrEqual(chatparam[0], mcmdtemp[3], false))
	{
		new Handle:moneyparam = CreateArray(64);
		
		PushArrayString(moneyparam, chatparam[1]);
		PushArrayCell(moneyparam, StringToInt(chatparam[2]));
		
		TransMoneyGift(client, moneyparam);
	}
	// 아이템 선물
	if (StrEqual(chatparam[0], "!아이템", false) || StrEqual(chatparam[0], "!item", false) || StrEqual(chatparam[0], "/아이템", false) || StrEqual(chatparam[0], "/item", false))
	{
		new Handle:itemparam = CreateArray(64);
		
		PushArrayString(itemparam, chatparam[1]);
		PushArrayCell(itemparam, StringToInt(chatparam[2]));
		PushArrayCell(itemparam, StringToInt(chatparam[3]));
		
		TransItemGift(client, itemparam);
	}
	// 아이템 목록 보기 명령어
	if (StrEqual(chatparam[0], "!아이템목록", false) || StrEqual(chatparam[0], "!itemlist", false) || StrEqual(chatparam[0], "/아이템목록", false) || StrEqual(chatparam[0], "/itemlist", false))
	{
		ShowAllItemList(client, chatparam[1]);
	}
	// VIP 등급 추가
	if (StrEqual(chatparam[0], "!vip추가", false) || StrEqual(chatparam[0], "!addvip", false) || StrEqual(chatparam[0], "/vip추가", false) || StrEqual(chatparam[0], "/addvip", false))
	{
		// 최고 관리자 권한을 갖고 있다면 가능하도록 처리
		if (dds_iUserClass[client] >= 4)
		{
			if (strlen(chatparam[1]) > 0)
			{
				new String:genquery[512], Handle:sendparam = CreateArray(64);
				
				PushArrayCell(sendparam, client);
				PushArrayCell(sendparam, 1);
				PushArrayString(sendparam, chatparam[1]);
				
				Format(genquery, sizeof(genquery), "SELECT * FROM dds_userreserved WHERE authid='%s' AND type='1'", chatparam[1]);
				DDS_SendQuery(dds_hDatabase, SQL_FindAuthIDForVIP, genquery, sendparam);
			}
			else
			{
				DDS_PrintToChat(client, "사용법: !vip추가(!addvip) \"고유번호\"");
			}
		}
		else
		{
			DDS_PrintToChat(client, "해당 기능을 실행할 권한이 없습니다.");
		}
	}
	// 관리 메뉴 명령어
	if (StrEqual(msg[1], "!관리", false) || StrEqual(msg[1], "!ad", false) || StrEqual(msg[1], "/관리", false) || StrEqual(msg[1], "/ad", false))
	{
		Menu_Admin(client);
	}
	// 데이터 초기화 메뉴 명령어
	if (StrEqual(msg[1], "!데이터초기화", false) || StrEqual(msg[1], "!datainit", false) || StrEqual(msg[1], "/데이터초기화", false) || StrEqual(msg[1], "/datainit", false))
	{
		Menu_InitializeDatabase(client);
	}
	// 데이터 초기화 메뉴 명령어
	if (StrEqual(msg[1], "!데이터복구", false) || StrEqual(msg[1], "!datarepair", false) || StrEqual(msg[1], "/데이터복구", false) || StrEqual(msg[1], "/datarepair", false))
	{
		Menu_UserRepairValidate01(client);
	}
	// 금액 랭킹 명령어
	if (StrEqual(msg[1], "!금액랭킹", false) || StrEqual(msg[1], "!dollarrank", false) || StrEqual(msg[1], "/금액랭킹", false) || StrEqual(msg[1], "/dollarrank", false))
	{
		new String:genquery[512];
		
		Format(genquery, sizeof(genquery), "SELECT * FROM dds_userbasic ORDER BY money DESC");
		DDS_SendQuery(dds_hDatabase, SQL_ShowDollarRank, genquery, client);
	}
	
	dds_bTeamChat[client] = false;
	
	return IsThereThisItemCode_bool("tag") ? Plugin_Handled : Plugin_Continue;
}

public Action:Command_TeamSay(client, args)
{
	dds_bTeamChat[client] = true;
	Command_Say(client, args);
	
	return Plugin_Handled;
}

/********************************
 * SQL 관련
********************************/
/*
dds_userbasic - 유저 프로필 테이블. ID(식별숫자), 닉네임, 유저 이름, 비밀번호, 고유번호, 달러, 가입일자
dds_useritem - 유저 아이템 상황 테이블. 고유번호, 여러 개의 아이템 번호
*/
/* SQL 메인 처리 함수 */
public SQL_GetDatabase(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	#if defined _DEBUG_
	DDS_PrintDebugMsg(0, false, "Connecting SQL Database and Setting UTF-8 Character...");
	#endif
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Database failure (ID 1000): %s.", DDS_CHAT_PREFIX_EN, error);
		DDS_PrintToServer("Database failure (ID 1000): %s", error);
		return;
	}
	// 데이터베이스 핸들을 전역변수에 저장
	dds_hDatabase = hndl;
	
	new String:charquery[64];
	
	// UTF-8 로 처리하도록 설정
	Format(charquery, sizeof(charquery), "SET NAMES \"UTF8\"");
	DDS_SendQuery(hndl, SQL_ErrorProcess, charquery, data, DBPrio_High);
	
	// 초기 설정 작업
	DoFirstProcess();
}

/* SQL - 일반 에러 출력 함수 */
public SQL_ErrorProcess(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Query Failed (ID 1001): %s", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 질의를 전달하는데 실패하였습니다. (ID 1001)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
	}
}

/* SQL - 데이터베이스에 등록된 유저 계정 체크 (유저 접속 후) */
public SQL_CheckUserAccount(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve fields from the database (ID 1010): %s", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 초기 유저 프로필 정보를 가져오는데 실패하였습니다. (ID 1010)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new num, String:userauth[64], String:genquery[512];
	
	GetClientAuthString(data, userauth, sizeof(userauth));
	
	while (SQL_MoreRows(hndl))
	{
		// 출력해야할 데이터가 더 남아있지 않다면 취소
		if (!SQL_FetchRow(hndl))	continue;
		
		num++;
	}
	if (num == 0)
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "Creating this User's Database (Type: 2, client: %d)...", data);
		#endif
		new String:usernick[64], String:curdate[32];
		
		GetClientName(data, usernick, sizeof(usernick));
		FormatTime(curdate, sizeof(curdate), "%Y/%m/%d %X", GetTime()); // 참고 주소 - http://cplusplus.com/reference/clibrary/ctime/strftime/
		
		SetPreventSQLInject(usernick, usernick, sizeof(usernick));
		
		// 유저 입장 후 데이터베이스에 유저 계정이 없다면 레코드 생성
		// 프로필 저장을 위한 등급 설정
		dds_iUserClass[data] = 0;
		
		if (GetAdminFlag(GetUserAdmin(data), Admin_Root, Access_Effective)) // root 어드민 권한을 가지고 있는 경우
			dds_iUserClass[data] = 4;
		
		if (GetConVarBool(dds_eConvar[HAUTOADMINSETSWITCH]))
		{
			if (GetAdminFlag(GetUserAdmin(data), Admin_Kick, Access_Effective)) // kick 어드민 권한을 가지고 있는 경우
				dds_iUserClass[data] = 3;
		}
		
		// 유저 프로필 저장
		Format(genquery, sizeof(genquery), "INSERT INTO dds_userbasic(nickname, authid, money, class, joindate, ingame) VALUES('%s', '%s', '%d', '%d', '%s', '1')", usernick, userauth, DEFAULT_MONEY, dds_iUserClass[data], curdate);
		DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, data);
		// 유저 아이템 저장
		Format(genquery, sizeof(genquery), "INSERT INTO dds_useritem(authid) VALUES('%s')", userauth);
		DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, data);
		// 유저 아이템 갯수 저장
		Format(genquery, sizeof(genquery), "INSERT INTO dds_useritemcount(authid) VALUES('%s')", userauth);
		DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, data);
		// 옵션 설정 저장
		Format(genquery, sizeof(genquery), "INSERT INTO dds_useroption(authid) VALUES('%s')", userauth);
		DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, data);
		
		// 유저 데이터베이스 사용 활성화
		dds_bUserDatabaseUse[data] = true;
		
		// 복구 로그 기록
		SetUserRepairLog(data, true, false, 0, 0, 0, 0);
	}
	else
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "Updating this User's Database and Loading Options (Type: 3, client: %d)...", data);
		#endif
		// 유저 프로필 로드
		Format(genquery, sizeof(genquery), "SELECT * FROM dds_userbasic WHERE authid='%s'", userauth);
		DDS_SendQuery(dds_hDatabase, SQL_BasicLoad, genquery, data);
		
		if (dds_bIsCheckDataBase)
		{
			// 유저 아이템 로드
			Format(genquery, sizeof(genquery), "SELECT * FROM dds_useritem WHERE authid='%s'", userauth);
			DDS_SendQuery(dds_hDatabase, SQL_ItemLoad, genquery, data);
			
			// 유저 아이템 개수 로드
			Format(genquery, sizeof(genquery), "SELECT * FROM dds_useritemcount WHERE authid='%s'", userauth);
			DDS_SendQuery(dds_hDatabase, SQL_ItemCountLoad, genquery, data);
			
			// 옵션 설정 로드
			Format(genquery, sizeof(genquery), "SELECT * FROM dds_useroption WHERE authid='%s'", userauth);
			DDS_SendQuery(dds_hDatabase, SQL_OptionLoad, genquery, data);
		}
	}
	
	// 최근의 이름과 접속 정보를 갱신
	new String:grecuname[64];
	
	GetClientName(data, grecuname, sizeof(grecuname));
	SetPreventSQLInject(grecuname, grecuname, sizeof(grecuname));
	
	Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET nickname='%s', ingame='1' WHERE authid='%s'", grecuname, userauth);
	DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, data);
	
	// 예약 유저 로드
	for (new i = 1; i <= 3; i++)
	{
		new Handle:sendparam = CreateArray(64);
		
		PushArrayCell(sendparam, data);
		PushArrayCell(sendparam, 0);
		PushArrayString(sendparam, userauth);
		
		Format(genquery, sizeof(genquery), "SELECT * FROM dds_userreserved WHERE authid='%s' AND type='%d'", userauth, i);
		if (i == 1)
		{
			DDS_SendQuery(dds_hDatabase, SQL_FindAuthIDForVIP, genquery, sendparam);
		}
		else if (i > 1)
		{
			if (dds_bIsCheckDataBase)
			{
				if (i == 2)
					DDS_SendQuery(dds_hDatabase, SQL_FindAuthIDForGift, genquery, sendparam);
				else if (i == 3)
					DDS_SendQuery(dds_hDatabase, SQL_FindAuthIDForItemGift, genquery, sendparam);
			}
		}
	}
	
	// 기간제 아이템 시간 체크
	Format(genquery, sizeof(genquery), "SELECT * FROM dds_useritemtime WHERE authid='%s'", userauth);
	DDS_SendQuery(dds_hDatabase, SQL_ItemTimeLoad, genquery, data);
}

/* SQL - 데이터 테이블 필드 체크 함수 */
public SQL_FieldCheck(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to check fields from the database (ID 1011): %s.", DDS_CHAT_PREFIX_EN, error);
		return;
	}
	
	new count;
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		count++;
	}
	
	if (count == 0)
	{
		DDS_PrintToServer("    - There is no field(Item Data). Let's create a Item Data Field! - %d", data);
		
		new String:genquery[512];
		
		Format(genquery, sizeof(genquery), "ALTER TABLE dds_useritem ADD I%d INT(4) NOT NULL DEFAULT '0'", data);
		DDS_SendQuery(dds_hDatabase, SQL_FieldCheck1, genquery, data);
	}
}

/* SQL - 데이터 테이블 필드1 체크 함수 */
public SQL_FieldCheck1(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to check fields from the database (ID 1012): %s.", DDS_CHAT_PREFIX_EN, error);
		return;
	}
	DDS_PrintToServer("    - Working for creating a Item Data Field is now Finished! - %d", data);
}

/* SQL - 데이터 갯수 테이블 필드 체크 함수 */
public SQL_CountFieldCheck(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to check fields from the database (ID 1013): %s.", DDS_CHAT_PREFIX_EN, error);
		return;
	}
	
	new count;
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		count++;
	}
	
	if (count == 0)
	{
		DDS_PrintToServer("    - There is no field(Item Count Data). Let's create a Item Count Data Field! - %d", data);
		
		new String:genquery[512];
		
		Format(genquery, sizeof(genquery), "ALTER TABLE dds_useritemcount ADD I%d INT(8) NOT NULL DEFAULT '0'", data);
		DDS_SendQuery(dds_hDatabase, SQL_CountFieldCheck1, genquery, data);
	}
}

/* SQL - 데이터 갯수 테이블 필드1 체크 함수 */
public SQL_CountFieldCheck1(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to check fields from the database (ID 1014): %s.", DDS_CHAT_PREFIX_EN, error);
		return;
	}
	DDS_PrintToServer("    - Working for creating a Item Count Data Field is now Finished! - %d", data);
}

/* SQL - 옵션 테이블 필드 체크 함수 */
public SQL_OptionFieldCheck(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to check fields from the database (ID 1015): %s.", DDS_CHAT_PREFIX_EN, error);
		return;
	}
	
	new count;
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		count++;
	}
	
	if (count == 0)
	{
		DDS_PrintToServer("    - There is no field(Option Data). Let's create a Option Data Field! - %d", data);
		
		new String:tempnum[8];
		
		if (data < 10)
			Format(tempnum, sizeof(tempnum), "0%d", data);
		else if (data >= 10)
			Format(tempnum, sizeof(tempnum), "%d", data);
		
		new String:genquery[512];
		
		Format(genquery, sizeof(genquery), "ALTER TABLE dds_useroption ADD O%s INT(4) NOT NULL DEFAULT '1'", tempnum);
		DDS_SendQuery(dds_hDatabase, SQL_OptionFieldCheck1, genquery, data);
	}
	else if (count > 0)
	{
		if (data == ITEMCATEGORY_NUMBER)
		{
			if (GetConVarInt(dds_eConvar[HDATALOGDBSWITCH]) != 1)
			{
				dds_bIsCheckDataBase = true;
				DDS_PrintToServer(" ## Checking Main Databases is Done.");
			}
		}
	}
}

/* SQL - 옵션 테이블 필드1 체크 함수 */
public SQL_OptionFieldCheck1(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to check fields from the database (ID 1016): %s.", DDS_CHAT_PREFIX_EN, error);
		return;
	}
	DDS_PrintToServer("    - Working for creating a Option Data Field is now Finished! - %d", data);
	
	if (data == ITEMCATEGORY_NUMBER)
	{
		if (GetConVarInt(dds_eConvar[HDATALOGDBSWITCH]) != 1)
		{
			dds_bIsCheckDataBase = true;
			DDS_PrintToServer(" ## Checking Main Databases is Done.");
		}
	}
}

/* SQL - 로그 테이블 필드 체크 함수 */
public SQL_DataLogFieldCheck(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to check fields from the database (ID 1017): %s.", DDS_CHAT_PREFIX_EN, error);
		return;
	}
	
	new count;
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		count++;
	}
	
	if (count == 0)
	{
		DDS_PrintToServer("    - There is no field(Log Item Data). Let's create a Log Item Data Field! - %d", data);
		
		new String:tempnum[8];
		
		if (data < 10)
			Format(tempnum, sizeof(tempnum), "0%d", data);
		else if (data >= 10)
			Format(tempnum, sizeof(tempnum), "%d", data);
		
		new String:genquery[512];
		
		Format(genquery, sizeof(genquery), "ALTER TABLE dds_serverlog ADD L%s VARCHAR(128) NOT NULL DEFAULT ''", tempnum);
		DDS_SendQuery(dds_hDatabase, SQL_DataLogFieldCheck1, genquery, data);
	}
	else if (count > 0)
	{
		if (data == ITEMCATEGORY_NUMBER)
		{
			dds_bIsCheckDataBase = true;
			DDS_PrintToServer(" ## Checking Main Databases is Done.");
		}
	}
}

/* SQL - 로그 테이블 필드1 체크 함수 */
public SQL_DataLogFieldCheck1(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to check fields from the database (ID 1018): %s.", DDS_CHAT_PREFIX_EN, error);
		return;
	}
	DDS_PrintToServer("    - Working for creating a Log Item Data Field is now Finished! - %d", data);
	
	if (data == ITEMCATEGORY_NUMBER)
	{
		dds_bIsCheckDataBase = true;
		DDS_PrintToServer(" ## Checking Main Databases is Done.");
	}
}

/* SQL - 초기 프로필 로드 함수 */
public SQL_BasicLoad(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user's money, class and tag from the database (ID 1019): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 프로필 목록을 가져오는데 실패하였습니다. (ID 1019)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new String:getfreetag[64];
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		dds_iUserMoney[data] = SQL_FetchInt(hndl, 5);
		dds_iUserClass[data] = SQL_FetchInt(hndl, 6);
		SQL_FetchString(hndl, 8, getfreetag, sizeof(getfreetag));
	}
	
	if (GetConVarBool(dds_eConvar[HFRTAGSAVESWITCH]))
	{
		if (strlen(getfreetag) > 0)
		{
			for (new i = 1; i < dds_iCurItem; i++)
			{
				if (StrEqual(dds_eItem[i][ITEMOPTION], "freetag", false))
				{
					dds_iUserItemID[data][IsThereThisItemCode_num("tag")] = i;
					Format(dds_sUserItemName[data][dds_eItem[i][ITEMCODE]], 64, dds_eItem[i][ITEMNAME]);
					Format(dds_sFreeTag[data], 64, getfreetag);
					dds_bFreeTag[data][1] = true;
					break;
				}
			}
		}
	}
	
	#if defined _DEBUG_
	DDS_PrintDebugMsg(data, true, "금액과 등급을 로드했습니다.");
	#endif
}

/* SQL - 초기 아이템 로드 함수 */
public SQL_ItemLoad(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user's item list from the database (ID 1020): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 아이템 목록을 가져오는데 실패하였습니다. (ID 1020)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new checkitem;
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		for (new i = 1; i < dds_iCurItem; i++)
		{
			if (dds_eItem[i][ITEMUSE] == 0)	continue;	// 특정 아이템 사용 유/무 체크
			
			checkitem = SQL_FetchInt(hndl, i+1);
			
			// 각 아이템에 할당된 값이 현재 적용된 값으로서의 '2'인 경우는 아이템을 적용하도록 한다.
			if (checkitem == 2)
			{
				for (new k = 1; k <= ITEMCATEGORY_NUMBER; k++)
				{
					if (dds_eItem[i][ITEMCODE] == k)
					{
						Format(dds_sUserItemName[data][k], 64, dds_eItem[i][ITEMNAME]);

						dds_iUserItemID[data][k] = dds_eItem[i][ITEMID];
					}
				}
			}
		}
	}
	
	#if defined _DEBUG_
	DDS_PrintDebugMsg(data, true, "아이템을 로드했습니다.");
	#endif
}

/* SQL - 초기 아이템 개수 로드 함수 */
public SQL_ItemCountLoad(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user's item count list from the database (ID 1021): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 아이템 갯수 목록을 가져오는데 실패하였습니다. (ID 1021)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		for (new i = 1; i < dds_iCurItem; i++)
		{
			if (dds_eItem[i][ITEMUSE] == 0)	continue;	// 특정 아이템 사용 유/무 체크
			
			// dds_iUserItemCount[data][i]
			dds_iUserItemCount[data][i] = SQL_FetchInt(hndl, i+1);
		}
	}
	
	#if defined _DEBUG_
	DDS_PrintDebugMsg(data, true, "아이템 개수를 로드했습니다.");
	#endif
}

/* SQL - 옵션 설정 로드 함수 */
public SQL_OptionLoad(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user's option sets from the database (ID 1022): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 옵션을 가져오는데 실패하였습니다. (ID 1022)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new firset = 1;
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
		{
			dds_bUserStatus[data][i] = SQL_FetchInt(hndl, firset+i) > 0 ? true : false;
		}
	}
	#if defined _DEBUG_
	DDS_PrintDebugMsg(data, true, "옵션 설정을 로드했습니다.");
	#endif
	
	// 유저 데이터베이스 사용 활성화
	dds_bUserDatabaseUse[data] = true;
	
	// 복구 로그 기록
	SetUserRepairLog(data, true, false, 0, 0, 0, 0);
}

/* SQL - 장착 아이템 인벤토리 체크 함수 */
public SQL_CurInvenItem(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user's inventory lists from the database (ID 1023): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 장착 인벤토리를 가져오는데 실패하였습니다. (ID 1023)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new Handle:dds_hMenuCurInvenItem = CreateMenu(Menu_SCurInvenItem);
	new String:buffer[256];
	
	// 수정해야할 부분
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 내 장착 아이템 - 항목\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuCurInvenItem, buffer);
	SetMenuExitButton(dds_hMenuCurInvenItem, true);
	SetMenuExitBackButton(dds_hMenuCurInvenItem, true);
	
	new bool:nousing, checkitem, count, client, itemcode;
	
	client = GetArrayCell(data, 0);
	itemcode = GetArrayCell(data, 1);
	
	CloseHandle(data);
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		for (new i = 1; i < dds_iCurItem; i++)
		{
			if (dds_eItem[i][ITEMUSE] == 0)	continue;
			
			checkitem = SQL_FetchInt(hndl, i+1);
			
			if (dds_eItem[i][ITEMCODE] == itemcode)
			{
				if (!nousing)
				{
					for (new k = 1; k <= ITEMCATEGORY_NUMBER; k++)
					{
						if ((dds_iUserItemID[client][k] > 0) && (itemcode == k))
						{
							AddMenuItem(dds_hMenuCurInvenItem, "0", "장착 해제");
							dds_iUserTempData[client][2] = itemcode;
							nousing = true;
						}
					}
				}
				if (checkitem == 1)
				{
					if ((dds_eItem[i][ITEMTIME] == -1) && (dds_iUserItemID[client][itemcode] == i))	continue;

					decl String:tempid[4];
					
					IntToString(i, tempid, sizeof(tempid));
					
					Format(buffer, sizeof(buffer), "[%s] %s - %d 개", dds_sItemCodeName[dds_eItem[i][ITEMCODE]], dds_eItem[i][ITEMNAME], dds_iUserItemCount[client][i]);
					AddMenuItem(dds_hMenuCurInvenItem, tempid, buffer);
					
					count++;
				}
			}
		}
	}
	
	if (count == 0)
	{
		Format(buffer, sizeof(buffer), "없음");
		AddMenuItem(dds_hMenuCurInvenItem, "0", buffer, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(dds_hMenuCurInvenItem, client, MENU_TIME_FOREVER);
}

/* SQL - 인벤토리 체크 함수 */
public SQL_InvenCheck(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user's inventory lists from the database (ID 1024): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 인벤토리 목록을 가져오는데 실패하였습니다. (ID 1024)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new Handle:dds_hMenuInvenShow = CreateMenu(Menu_SInvenshow);
	new String:buffer[256];
	
	new String:checkitem[4], count;
	
	for (new select = 0; select < ITEMCATEGORY_NUMBER+1; select++)
	{
		if (select == dds_iUserTempData[data][0])
			Format(buffer, sizeof(buffer), "%s\n현재 위치: 내 인벤토리 - %s\n ", DDS_MENU_PRIMARY_TITLE, dds_sItemCodeName[select]);
	}
	
	SetMenuTitle(dds_hMenuInvenShow, buffer);
	SetMenuExitButton(dds_hMenuInvenShow, true);
	SetMenuExitBackButton(dds_hMenuInvenShow, true);

	// 여기서 dds_iUserTempData[data][0] 은 선택한 아이템 종류 번호

	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		for (new i = 1; i < dds_iCurItem; i++)
		{
			if (dds_eItem[i][ITEMUSE] == 0)	continue;
			if (!dds_bItemCodeUse[dds_eItem[i][ITEMCODE]])	continue;
			if ((dds_eItem[i][ITEMTIME] == -1) && (dds_iUserItemID[data][dds_iUserTempData[data][0]] == i))	continue;
			
			SQL_FetchString(hndl, i+1, checkitem, sizeof(checkitem));
			
			if (StringToInt(checkitem) == 1)
			{
				if (dds_eItem[i][ITEMCODE] == dds_iUserTempData[data][0])
				{
					decl String:tempid[4];
					
					IntToString(dds_eItem[i][ITEMID], tempid, sizeof(tempid));
					Format(buffer, sizeof(buffer), "[%s] %s - %d 개", dds_sItemCodeName[dds_eItem[i][ITEMCODE]], dds_eItem[i][ITEMNAME], dds_iUserItemCount[data][i]);
					AddMenuItem(dds_hMenuInvenShow, tempid, buffer);
					
					count++;
				}
				else if (dds_iUserTempData[data][0] == 0)
				{
					decl String:tempid[4];
					
					IntToString(dds_eItem[i][ITEMID], tempid, sizeof(tempid));
					Format(buffer, sizeof(buffer), "[%s] %s - %d 개", dds_sItemCodeName[dds_eItem[i][ITEMCODE]], dds_eItem[i][ITEMNAME], dds_iUserItemCount[data][i]);
					AddMenuItem(dds_hMenuInvenShow, tempid, buffer);
					
					count++;
				}
			}
		}
	}
	
	if (count == 0)
	{
		Format(buffer, sizeof(buffer), "없음");
		AddMenuItem(dds_hMenuInvenShow, "0", buffer, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(dds_hMenuInvenShow, data, MENU_TIME_FOREVER);
}

/* SQL - 프로필 변경 체크 함수 */
public SQL_Info_ProfileUpdate(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to update a user's class or tag from the database (ID 1025): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 등급 또는 태그 갱신을 실패하였습니다. (ID 1025)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
}

/* SQL - 인벤토리 변경 체크 함수 */
public SQL_Info_InvenUpdate(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to update a user's item from the database (ID 1026): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 인벤토리 갱신을 실패하였습니다. (ID 1026)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
}

/* SQL - 아이템 구매 처리 함수 */
public SQL_Info_ItemBuy(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to insert a bought item from the database (ID 1027): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 아이템 구입 후 인벤토리를 갱신하는데 실패하였습니다. (ID 1027)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
}

/* SQL - 금액 변경 처리 함수 */
public SQL_Info_ChangeMoney(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to update user's money from the database (ID 1028): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 금액의 갱신을 실패하였습니다. (ID 1028)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
}

/* SQL - VIP 추가 처리 함수 */
public SQL_FindAuthIDForVIP(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve vip user list from the database (ID 1029): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 예약된 유저 VIP 목록을 가져오는데 실패하였습니다. (ID 1029)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new client = GetArrayCell(data, 0), type = GetArrayCell(data, 1), String:authid[32];
	new count, String:chkauthid[32], String:genquery[512];
	
	GetArrayString(data, 2, authid, sizeof(authid));
	
	CloseHandle(data);
	
	/*
	
	type
	
	0 - 유저 접속 시 VIP 체크
	1 - VIP 직접 추가하기 위한 고유번호 체크
	
	*/
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		SQL_FetchString(hndl, 1, chkauthid, sizeof(chkauthid));
		
		if (StrEqual(chkauthid, authid, false))
			count++;
	}
	
	if (count == 0)
	{
		if (type == 1)
		{
			new curcount, checkid;
			
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i))
				{
					new String:tempauth[32];
					
					GetClientAuthString(i, tempauth, sizeof(tempauth));
					
					if (StrEqual(authid, tempauth, false))
					{
						curcount++;
						checkid = i;
					}
				}
			}
			
			if (curcount == 0)
			{
				Format(genquery, sizeof(genquery), "INSERT INTO dds_userreserved(authid, type) VALUES('%s', '1')", authid);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				
				DDS_PrintToChat(client, "해당 고유번호를 VIP 예약 등록하였습니다.");
			}
			else if (curcount == 1)
			{
				if (dds_iUserClass[checkid] < 2)
				{
					new String:tempname[64];
					
					dds_iUserClass[checkid] = 2;
					
					Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET class='%d' WHERE authid='%s'", 2, authid);
					DDS_SendQuery(dds_hDatabase, SQL_Info_ProfileUpdate, genquery, checkid);
					
					GetClientName(checkid, tempname, sizeof(tempname));
					DDS_PrintToChat(client, "%s 님의 등급을 '2'으로 변경하였습니다.", tempname);
					GetClientName(client, tempname, sizeof(tempname));
					DDS_PrintToChat(checkid, "어드민(%s)이 유저님을 등급 '2'으로 변경하였습니다.", tempname);
				}
				else if (dds_iUserClass[checkid] >= 2)
				{
					DDS_PrintToChat(client, "해당 유저님은 VIP 이상의 등급을 이미 가지고 있습니다.");
				}
			}
		}
	}
	else if (count > 0)
	{
		if (type == 0)
		{
			if (dds_iUserClass[client] < 2)
			{
				Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET class='2' WHERE authid='%s'", authid);
				DDS_SendQuery(dds_hDatabase, SQL_Info_ProfileUpdate, genquery, client);
				
				dds_iUserClass[client] = 2;
				
				Format(genquery, sizeof(genquery), "DELETE FROM dds_userreserved WHERE authid='%s' AND type='1'", authid);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				
				DDS_PrintToChat(client, "예약된 VIP 유저에 속하여 VIP 등급으로 변경되었습니다.");
			}
			else if (dds_iUserClass[client] >= 2)
			{
				Format(genquery, sizeof(genquery), "DELETE FROM dds_userreserved WHERE authid='%s' AND type='1'", authid);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
			}
		}
		else if (type == 1)
		{
			DDS_PrintToChat(client, "이미 해당 고유번호가 등록되어 있습니다.");
		}
	}
}

/* SQL - 금액 선물 처리 함수 */
public SQL_FindAuthIDForGift(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve gift user list from the database (ID 1030): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 예약된 유저 금액 목록을 가져오는데 실패하였습니다. (ID 1030)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new client = GetArrayCell(data, 0), type = GetArrayCell(data, 1), moneyamount, String:authid[32];
	
	if (type == 1)
		moneyamount = GetArrayCell(data, 3);
	
	new chkid, String:chkauthid[32], chkmoneyamount, String:genquery[512];
	
	GetArrayString(data, 2, authid, sizeof(authid));
	
	CloseHandle(data);
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		chkid = SQL_FetchInt(hndl, 0);
		SQL_FetchString(hndl, 1, chkauthid, sizeof(chkauthid));
		chkmoneyamount = SQL_FetchInt(hndl, 3);
		
		if (StrEqual(chkauthid, authid, false))
		{
			if (type == 0)
			{
				SetUserMoney(client, 2, chkmoneyamount);
				
				Format(genquery, sizeof(genquery), "DELETE FROM dds_userreserved WHERE id='%d'", chkid);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				
				SetLog(client, 0, 7, 0, 3, chkmoneyamount, "");
				
				DDS_PrintToChat(client, "예약된 금액 선물 유저에 속하여 %d %s가(이) 추가적으로 지급되었습니다.", chkmoneyamount, DDS_MONEY_NAME_KO);
			}
		}
	}
	
	if (type == 1)
	{
		if (moneyamount > 0)
		{
			if (dds_hDatabase != INVALID_HANDLE)
			{
				Format(genquery, sizeof(genquery), "INSERT INTO dds_userreserved(authid, type, anydata1) VALUES('%s', '2', '%d')", authid, moneyamount);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				
				DDS_PrintToChat(client, "해당 고유번호를 금액 선물 예약 등록하였습니다.");
			}
			else
			{
				DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 저장할 수 없습니다.");
			}
		}
		else if (moneyamount == 0)
		{
			DDS_PrintToChat(client, "금액을 입력하세요.");
		}
		else if (moneyamount < 0)
		{
			DDS_PrintToChat(client, "금액은 0 %s 보다 높게 써야합니다.", DDS_MONEY_NAME_KO);
		}
	}
}

/* SQL - 아이템 선물 처리 함수 */
public SQL_FindAuthIDForItemGift(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve item gift user list from the database (ID 1031): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 예약된 유저 아이템 목록을 가져오는데 실패하였습니다. (ID 1031)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new client = GetArrayCell(data, 0), type = GetArrayCell(data, 1), setitemid, setitemamount, String:authid[32];
	
	if (type == 1)
	{
		setitemid = GetArrayCell(data, 3);
		setitemamount = GetArrayCell(data, 4);
	}
	
	new chkid, String:chkauthid[32], chkitemid, chkitemcount, String:genquery[512];
	
	GetArrayString(data, 2, authid, sizeof(authid));
	
	CloseHandle(data);
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		chkid = SQL_FetchInt(hndl, 0);
		SQL_FetchString(hndl, 1, chkauthid, sizeof(chkauthid));
		chkitemid = SQL_FetchInt(hndl, 3);
		chkitemcount = SQL_FetchInt(hndl, 4);
		
		if (StrEqual(chkauthid, authid, false))
		{
			if (type == 0)
			{
				DDS_SimpleGiveItem(client, chkitemid, chkitemcount);
				
				Format(genquery, sizeof(genquery), "DELETE FROM dds_userreserved WHERE id='%d'", chkid);
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				
				SetLog(client, 0, 7, chkitemid, 4, chkitemcount, "");
				
				DDS_PrintToChat(client, "예약된 아이템 선물 유저에 속하여 %d 개의 '[%s] %s'가(이) 추가적으로 지급되었습니다.", chkitemcount, dds_sItemCodeName[dds_eItem[chkitemid][ITEMCODE]], dds_eItem[chkitemid][ITEMNAME]);
			}
		}
	}
	
	if (type == 1)
	{
		if (setitemid > 0)
		{
			if (setitemamount > 0)
			{
				if (dds_hDatabase != INVALID_HANDLE)
				{
					Format(genquery, sizeof(genquery), "INSERT INTO dds_userreserved(authid, type, anydata1, anydata2) VALUES('%s', '3', '%d', '%d')", authid, setitemid, setitemamount);
					DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
					
					DDS_PrintToChat(client, "해당 고유번호를 아이템 선물 예약 등록하였습니다.");
				}
				else
				{
					DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 저장할 수 없습니다.");
				}
			}
			else if (setitemamount == 0)
			{
				DDS_PrintToChat(client, "아이템 갯수를 입력해주세요.");
			}
			else if (setitemamount < 0)
			{
				DDS_PrintToChat(client, "아이템 갯수는 0 보다 높게 써야합니다.");
			}
		}
		else if (setitemid == 0)
		{
			DDS_PrintToChat(client, "아이템 ID를 입력하세요.");
		}
		else if (setitemid < 0)
		{
			DDS_PrintToChat(client, "아이템 ID는 0 보다 높게 써야합니다.", DDS_MONEY_NAME_KO);
		}
	}
}

/* SQL - 데이터 복구(프로필) 처리 함수 */
public SQL_UserRepair01(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user basic log from the database (ID 1032): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 예약된 유저 아이템 목록을 가져오는데 실패하였습니다. (ID 1032)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new client, target, String:saveunix[64], String:taauthid[32], String:tanick[64], String:genquery[512];
	
	client = GetArrayCell(data, 0);
	target = GetArrayCell(data, 1);
	GetArrayString(data, 2, saveunix, sizeof(saveunix));
	
	CloseHandle(data);
	
	// 유저 데이터베이스 사용 비활성화
	dds_bUserDatabaseUse[target] = false;
	
	GetClientAuthString(target, taauthid, sizeof(taauthid));
	GetClientName(target, tanick, sizeof(tanick));
	
	new logrows = SQL_GetAffectedRows(hndl), count;
	
	DDS_PrintToChat(target, " - # 관리자가 복구를 진행하고 있습니다.");
	DDS_PrintToChat(target, " - # 진행할 동안 금액, 등급, 아이템 등 사용 및 적용이 불가능합니다.");
	
	DDS_PrintToChat(client, " - # 먼저 %s 님의 프로필 복구를 시작합니다.", tanick);
	DDS_PrintToChat(client, " - ## 총 %d 개의 기록을 찾았습니다. 복구 처리를 시작합니다..", logrows);
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		count++;
		
		dds_iUserMoney[target] = SQL_FetchInt(hndl, 3);
		dds_iUserClass[target] = SQL_FetchInt(hndl, 4);
		DDS_PrintToChat(client, " - ## [%d / %d] 프로필 기록 로드", count, logrows);
	}
	new Handle:sendparam[2];
	
	sendparam[0] = CreateArray(6);
	
	PushArrayCell(sendparam[0], client);
	PushArrayCell(sendparam[0], 1);
	
	Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET money='%d', class='%d' WHERE authid='%s'", dds_iUserMoney[target], dds_iUserClass[target], taauthid);
	DDS_SendQuery(dds_hDatabase, SQL_Info_Repair, genquery, sendparam[0]);
	
	// 정상화(임시)
	dds_bUserRepairLog[client][0] = false;
	dds_bUserDatabaseUse[target] = true;
	
	DDS_PrintToChat(client, " - # 모든 데이터 복구가 성공적으로 완료되었습니다.");
	DDS_PrintToChat(target, " - # 모든 데이터 복구가 성공적으로 완료되었습니다.");
	/*
	DDS_PrintToChat(client, " - # 프로필 복구가 완료되었습니다.");
	DDS_PrintToChat(target, " - # 프로필 복구가 완료되었습니다.");
	
	sendparam[1] = CreateArray(6);
	
	PushArrayCell(sendparam[1], client);
	PushArrayCell(sendparam[1], target);
	
	Format(genquery, sizeof(genquery), "SELECT * FROM dds_userlog_item WHERE authid='%s' AND date>='%s' ORDER BY id DESC", taauthid, saveunix);
	DDS_SendQuery(dds_hDatabase, SQL_UserRepair02, genquery, sendparam[1]);
	*/
}

/* SQL - 데이터 복구(아이템) 처리 함수 */
public SQL_UserRepair02(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user basic log from the database (ID 1033): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 예약된 유저 아이템 목록을 가져오는데 실패하였습니다. (ID 1033)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new client, target, String:taauthid[64];
	
	client = GetArrayCell(data, 0);
	target = GetArrayCell(data, 1);
	
	CloseHandle(data);
	
	GetClientAuthString(target, taauthid, sizeof(taauthid));
	
	new String:genquery[512], bool:reyes, logrows = SQL_GetAffectedRows(hndl), count, logitemid, logitemcode, logitemstat, logitemcount, logappid;
	
	DDS_PrintToChat(client, " - # 이제 아이템 복구를 시작합니다.");
	DDS_PrintToChat(client, " - ## 총 %d 개의 기록을 찾았습니다. 복구 처리를 시작합니다..", logrows);
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		logitemid = SQL_FetchInt(hndl, 3);
		logitemcode = SQL_FetchInt(hndl, 4);
		logitemstat = SQL_FetchInt(hndl, 5);
		logitemcount = SQL_FetchInt(hndl, 6);
		logappid = SQL_FetchInt(hndl, 7);
		
		if (logitemstat == 0)
		{
			reyes = true;
			count++;
			
			Format(dds_sUserItemName[client][logitemcode], 64, dds_eItem[logappid][ITEMNAME]);
			dds_iUserItemID[client][logitemcode] = logappid;
			dds_iUserItemCount[client][logitemid] = logitemcount;
		}
		else if (logitemstat == 1)
		{
			reyes = true;
			count++;
			
			Format(dds_sUserItemName[client][logitemcode], 64, dds_eItem[logappid][ITEMNAME]);
			dds_iUserItemID[client][logitemcode] = logappid;
			dds_iUserItemCount[client][logitemid] = logitemcount;
		}
		else if (logitemstat == 2)
		{
			reyes = true;
			count++;
			
			Format(dds_sUserItemName[client][logitemcode], 64, dds_eItem[logitemid][ITEMNAME]);
			dds_iUserItemID[client][logitemcode] = logitemid;
			dds_iUserItemCount[client][logitemid] = logitemcount;
		}
		
		if (reyes)
		{
			reyes = false;
			
			new Handle:sendparam = CreateArray(6);
			
			PushArrayCell(sendparam, client);
			PushArrayCell(sendparam, 2);
			PushArrayCell(sendparam, count);
			PushArrayCell(sendparam, logrows);
			
			Format(genquery, sizeof(genquery), "UPDATE dds_useritem SET I%d='%d' WHERE authid='%s'", logitemid, logitemstat, taauthid);
			DDS_SendQuery(dds_hDatabase, SQL_Info_Repair, genquery, client);
			Format(genquery, sizeof(genquery), "UPDATE dds_useritemcount SET I%d='%d' WHERE authid='%s'", logitemid, logitemcount, taauthid);
			DDS_SendQuery(dds_hDatabase, SQL_Info_Repair, genquery, sendparam);
		}
	}
	
	// 정상화
	dds_bUserRepairLog[client][0] = false;
	dds_bUserDatabaseUse[target] = true;
	
	DDS_PrintToChat(client, " - # 모든 데이터 복구가 성공적으로 완료되었습니다.");
	DDS_PrintToChat(target, " - # 모든 데이터 복구가 성공적으로 완료되었습니다.");
}

/* SQL - 금액 변경 처리 함수 */
public SQL_Info_Repair(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to update user database(repair) from the database (ID 1034): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 복구를 실패하였습니다. (ID 1034)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new client, mode, count, allcount;
	
	client = GetArrayCell(data, 0);
	mode = GetArrayCell(data, 1);
	if (mode == 2)
	{
		count = GetArrayCell(data, 2);
		allcount = GetArrayCell(data, 3);
		
		DDS_PrintToChat(client, " - ## [%d / %d] 아이템 복구 기록 완료", count, allcount);
	}
	
	CloseHandle(data);
}

/* SQL - 기간제 아이템 시간 처리 함수 */
public SQL_ItemTimeLoad(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user database(item time) from the database (ID 1035): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저의 아이템 당 시간을 가져오는데 실패하였습니다. (ID 1035)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new itemid, itemsvtime;
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		itemid = SQL_FetchInt(hndl, 2);
		itemsvtime = SQL_FetchInt(hndl, 3);
		
		if ((itemid > 0) && (itemsvtime > 0) && (dds_eItem[itemid][ITEMTIME] > 0))
		{
			dds_iUserItemTime[data][itemid] = itemsvtime;
			
			if ((itemsvtime >= GetTime()) && ((itemsvtime - GetTime()) <= 86400))
			{
				new String:tafortime[64];
				
				FormatTime(tafortime, sizeof(tafortime), "%Y년 %m월 %d일 %H시 %M분 %S초", itemsvtime);
				DDS_PrintToChat(data, "'[%s] %s'가(이) %s에 만료됩니다.", dds_sItemCodeName[dds_eItem[itemid][ITEMCODE]], dds_eItem[itemid][ITEMNAME], tafortime);
			}
		}
	}
}

/* SQL - 금액 랭킹 메뉴 처리 함수 */
public SQL_ShowDollarRank(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if ((hndl == INVALID_HANDLE) || (error[0]))
	{
		LogToFile(dds_sPluginLogFile, "%s Failed to retrieve user database(money) from the database (ID 1036): %s.", DDS_CHAT_PREFIX_EN, error);
		if (data > 0)
		{
			DDS_PrintToChat(data, "오류가 발생했습니다: 유저 프로필 목록을 가져오는데 실패하였습니다. (ID 1036)");
			DDS_PrintToChat(data, "오류가 발생했습니다: <원인> %s", error);
		}
		return;
	}
	
	new Handle:dds_hMenuUserDollarRank = CreateMenu(Menu_SNothing1);
	new String:buffer[256];
	
	Format(buffer, sizeof(buffer), "%s\n현재 위치: 금액 랭킹\n ", DDS_MENU_PRIMARY_TITLE);
	SetMenuTitle(dds_hMenuUserDollarRank, buffer);
	SetMenuExitButton(dds_hMenuUserDollarRank, true);
	
	new count, String:getuname[64], getumoney;
	
	while (SQL_MoreRows(hndl))
	{
		if (!SQL_FetchRow(hndl))	continue;
		
		count++;
		
		if (count > GetConVarInt(dds_eConvar[HLIMITRANKNUMBER]))	break;
		
		SQL_FetchString(hndl, 1, getuname, sizeof(getuname));
		getumoney = SQL_FetchInt(hndl, 5);
		
		Format(buffer, sizeof(buffer), "[%d] %s - %d %s", count, getuname, getumoney, DDS_MONEY_NAME_KO);
		AddMenuItem(dds_hMenuUserDollarRank, "", buffer, ITEMDRAW_DISABLED);
	}
	if (count == 0)
	{
		Format(buffer, sizeof(buffer), "없음");
		AddMenuItem(dds_hMenuUserDollarRank, "", buffer, ITEMDRAW_DISABLED);
	}
	
	DisplayMenu(dds_hMenuUserDollarRank, data, MENU_TIME_FOREVER);
}

/********************************
 * 이벤트 훅
********************************/
/* player_connect 이벤트 처리 함수 */
// (진심으로 클라이언트가 새롭게 들어왔을 때에 발생)
public Action:Event_OnPlayerConnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(dds_eConvar[HPLUGINSWITCH]))	return Plugin_Continue;
	
	new String:username[64], String:userauth[64], String:userip[32], String:sendparam[256];
	
	GetEventString(event, "name", username, sizeof(username));
	GetEventString(event, "networkid", userauth, sizeof(userauth));
	GetEventString(event, "address", userip, sizeof(userip));
	
	SplitString(userip, ":", userip, sizeof(userip));
	
	Format(sendparam, sizeof(sendparam), "%s||%s||%s", username, userauth, userip);
	
	// 유저 데이터 로그 기록
	if (GetConVarBool(dds_eConvar[HDATALOGSWITCH]))	SetLog(-1, 0, 1, 0, 1, 0, sendparam);
	
	// 유저 아이피 로그 기록(텍스트를 위한 것)
	SetLog(-1, 0, 0, 0, 1, 0, sendparam);
	
	return Plugin_Continue;
}

/* player_disconnect 이벤트 처리 함수 */
// (맵 체인지 중에 일어나지 않고, 진심으로 클라이언트가 나갈 때에 발생)
public Action:Event_OnPlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(dds_eConvar[HPLUGINSWITCH]))	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (client > 0)
	{
		if (dds_hDatabase != INVALID_HANDLE)
		{
			// 유저 데이터 로그 기록
			if (GetConVarBool(dds_eConvar[HDATALOGSWITCH]))	SetLog(client, 0, 2, 0, 2, 0, "");
			
			// 유저 아이피 로그 기록(텍스트를 위한 것)
			SetLog(client, 0, 0, 0, 2, 0, "");
		}
	}
	
	return Plugin_Continue;
}

/********************************
 * 메뉴 처리
********************************/
/* 기본 메뉴 처리 함수 */
public Menu_SMain(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		switch(iInfo)
		{
			case 1:
			{
				Menu_Myinfo(client);
			}
			case 2:
			{
				Menu_Myitemset(client);
			}
			case 3:
			{
				Menu_Myinven(client, 0);
			}
			case 4:
			{
				Menu_Itemlist(client);
			}
			case 5:
			{
				Menu_Option(client);
			}
			case 6:
			{
				Menu_PluginInfo(client);
			}
		}
	}
}

/* 내 장착 아이템 메뉴 처리 함수 */
public Menu_SMyitemset(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:userauth[32], String:genquery[512];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		GetClientAuthString(client, userauth, sizeof(userauth));
		
		new Handle:sendparam = CreateArray(8);
		
		PushArrayCell(sendparam, client);
		PushArrayCell(sendparam, iInfo);
		
		// 유저의 장착된 아이템 로드
		Format(genquery, sizeof(genquery), "SELECT * FROM dds_useritem WHERE authid='%s'", userauth);
		DDS_SendQuery(dds_hDatabase, SQL_CurInvenItem, genquery, sendparam);
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Main(client, 0);
		}
	}
}

/* 내 장착 아이템 - 하위 메뉴 처리 함수 */
public Menu_SCurInvenItem(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], itemid, proctype, setanydata1;
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		if (iInfo == 0) // 장착 해제
		{
			for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
			{
				if (dds_iUserTempData[client][2] == i)
				{
					itemid = dds_iUserItemID[client][i];
					
					if (dds_eItem[itemid][ITEMTIME] == -1)
					{
						proctype = 0;
						setanydata1 = 2;
					}
					else
					{
						proctype = 1;
						setanydata1 = 0;
					}
					
					if (dds_bUserDatabaseUse[client])
					{
						dds_iUserItemID[client][i] = 0;
						Format(dds_sUserItemName[client][i], 64, DEFAULT_NAME);
					}
				}
			}
		}
		else // 장착
		{
			itemid = iInfo;
			proctype = 2;
			setanydata1 = 0;
		}
		SetItemProcess(client, 0, proctype, itemid, setanydata1);
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Myitemset(client);
		}
	}
}

/* 내 인벤토리 메뉴 처리 함수 */
public Menu_SMyinven(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:userauth[32], String:genquery[512];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		dds_iUserTempData[client][0] = iInfo;
		
		GetClientAuthString(client, userauth, sizeof(userauth));
		
		// 유저 인벤토리 로드
		Format(genquery, sizeof(genquery), "SELECT * FROM dds_useritem WHERE authid='%s'", userauth);
		
		if (dds_hDatabase != INVALID_HANDLE)
			DDS_SendQuery(dds_hDatabase, SQL_InvenCheck, genquery, client);
		else
			DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 로드할 수 없습니다.");
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Main(client, 0);
		}
	}
}

/* 내 인벤토리 - 하위 메뉴 처리 함수 */
public Menu_SInvenshow(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		Menu_Myinven_Sub(client, iInfo);
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			dds_iUserTempData[client][0] = 0;
			Menu_Myinven(client, 0);
		}
	}
}

/* 내 인벤토리 - 선택 항목 확인 메뉴 처리 함수 */
public Menu_SMyinven_Sub(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:explodestr[2][8];
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, " ", explodestr, 2, 8);
		
		new paramset = StringToInt(explodestr[0]);
		new itemid = StringToInt(explodestr[1]);
		
		if (paramset == 1)
		{
			// 사용하기
			SetItemProcess(client, 0, 2, itemid, 0);
		}
		else if (paramset == 2)
		{
			// 되팔기
			SetItemProcess(client, 0, 0, itemid, 3);
		}
		else if (paramset == 3)
		{
			// 버리기
			SetItemProcess(client, 0, 0, itemid, 0);
		}
		else if (paramset == 4)
		{
			Nothing();
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			dds_iUserTempData[client][0] = 0;
			Menu_Myinven(client, 0);
		}
	}
}

/* 아이템 구매 메뉴 처리 함수 */
public Menu_SItemlist(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:buffer[64];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		for (new select = 0; select < ITEMCATEGORY_NUMBER+1; select++)
		{
			if (select == iInfo)
			{
				Format(buffer, sizeof(buffer), "%s 아이템", dds_sItemCodeName[select]);
				Menu_Itemlist_Selected(client, select, buffer);
			}
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Main(client, 0);
		}
	}
}

/* 아이템 구매 - 선택 항목 메뉴 처리 함수 */
public Menu_SItemlist_Selected(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		Menu_Itembuy(client, iInfo);
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Itemlist(client);
		}
	}
}

/* 아이템 구매 - 선택 항목 - 구매 확인 메뉴 처리 함수 */
public Menu_SItembuy(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:explodestr[2][8];
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, " ", explodestr, 2, 8);
		
		new select = StringToInt(explodestr[0]);
		new itemid = StringToInt(explodestr[1]);
		
		if (select == 1)
		{
			// 구매 확인
			// 아이템 구매
			
			if (dds_hDatabase == INVALID_HANDLE)
			{
				DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 저장할 수 없습니다.");
				return;
			}
			if (!dds_bUserDatabaseUse[client])
			{
				DDS_PrintToChat(client, "유저 정보가 아직 로드되지 않았습니다!");
				return;
			}
			
			SetItemProcess(client, 0, 3, itemid, 0);
		}
		else if (select == 2)
		{
			// 구매 취소
			Menu_Itemlist(client);
		}
		else if (select == 3)
		{
			Nothing();
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Itemlist(client);
		}
	}
}

/* 옵션 메뉴 처리 함수 */
public Menu_SOption(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:userauth[32], String:genquery[512];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		GetClientAuthString(client, userauth, sizeof(userauth));
		
		for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
		{
			if (iInfo == i)
			{
				new String:tempnum[4];
				
				if (i < 10)
					Format(tempnum, sizeof(tempnum), "0%d", i);
				else if (i >= 10)
					Format(tempnum, sizeof(tempnum), "%d", i);
				
				if (dds_bUserStatus[client][i])
				{
					dds_bUserStatus[client][i] = false;
					Format(genquery, sizeof(genquery), "UPDATE dds_useroption SET O%s='0' WHERE authid='%s'", tempnum, userauth);
				}
				else
				{
					dds_bUserStatus[client][i] = true;
					Format(genquery, sizeof(genquery), "UPDATE dds_useroption SET O%s='1' WHERE authid='%s'", tempnum, userauth);
				}
				
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				
				Menu_Option(client);
			}
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Main(client, 0);
		}
	}
}

/* 정보 메뉴 처리 함수 */
public Menu_SPlugininfo(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		for (new select = 1; select <= 3; select++)
		{
			if (select == iInfo)
				Menu_PluginInfo_Sub(client, select);
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Main(client, 0);
		}
	}
}

/* 정보 - 하위 메뉴 처리 함수 */
public Menu_SPlugininfo_Sub(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		switch(iInfo)
		{
			default:
			{
				Nothing();
			}
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_PluginInfo(client);
		}
	}
}

/* 관리 메뉴 처리 함수 */
public Menu_SAdmin(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		switch (iInfo)
		{
			case 1:
			{
				// 금액 주기
				Menu_AdminMoney(client, 1);
			}
			case 2:
			{
				// 금액 뺏기
				Menu_AdminMoney(client, 2);
			}
			case 3:
			{
				// 아이템 주기
				Menu_AdminItem(client, 1);
			}
			case 4:
			{
				// 아이템 뺏기
				Menu_AdminItem(client, 2);
			}
			case 5:
			{
				// 등급 설정
				Menu_AdminClass(client);
			}
		}
	}
}

/* 관리 - 금액 메뉴 처리 함수 */
public Menu_SAdminMoney(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:explodestr[2][16];
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, " ", explodestr, 2, 16);
		
		Menu_AdminMoney_User(client, StringToInt(explodestr[0]), StringToInt(explodestr[1]));
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Admin(client);
		}
	}
}

/* 관리 - 금액 - 유저 선택 메뉴 처리 함수 */
public Menu_SAdminMoney_User(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		if (dds_hDatabase == INVALID_HANDLE)
		{
			DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 저장할 수 없습니다.");
			return;
		}
		
		new String:info[32], String:explodestr1[2][16], String:explodetemp[16], String:explodestr2[2][16], tempmoney;
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, " ", explodestr1, 2, 16);
		
		Format(explodetemp, sizeof(explodetemp), explodestr1[1]);
		
		ExplodeString(explodetemp, "^", explodestr2, 2, 16);
		
		new target = StringToInt(explodestr1[0]);
		new setmoney = StringToInt(explodestr2[0]);
		new select = StringToInt(explodestr2[1]);
		
		if (select == 1) // 금액 주기
		{
			tempmoney = dds_iUserMoney[target]+setmoney;
		}
		else if (select == 2) // 금액 뺏기
		{
			if (setmoney != -1)
			{
				if ((dds_iUserMoney[target]-setmoney) < 0)
					tempmoney = 0;
				else
					tempmoney = dds_iUserMoney[target]-setmoney;
			}
			else
			{
				tempmoney = 0;
			}
		}
		
		new copymoney, String:tempname[64];
		
		copymoney = dds_iUserMoney[target];
		SetUserMoney(target, 1, tempmoney);
		
		if (select == 1) // 금액 주기
		{
			SetLog(client, target, 6, 0, 1, setmoney, "");
			
			GetClientName(target, tempname, sizeof(tempname));
			DDS_PrintToChat(client, "%s 님에게 %d %s을(를) 주었습니다.", tempname, setmoney, DDS_MONEY_NAME_KO);
			GetClientName(client, tempname, sizeof(tempname));
			DDS_PrintToChat(target, "어드민(%s)으로부터 %d %s을(를) 받았습니다.", tempname, setmoney, DDS_MONEY_NAME_KO);
		}
		else if (select == 2) // 금액 뺏기
		{
			if (setmoney != -1)
			{
				SetLog(client, target, 6, 0, 2, setmoney, "");
				
				GetClientName(target, tempname, sizeof(tempname));
				DDS_PrintToChat(client, "%s 님의 %d %s을(를) 회수하였습니다.", tempname, setmoney, DDS_MONEY_NAME_KO);
				GetClientName(client, tempname, sizeof(tempname));
				DDS_PrintToChat(target, "어드민(%s)이 유저 님의 %d %s을(를) 회수하였습니다.", tempname, setmoney, DDS_MONEY_NAME_KO);
			}
			else
			{
				SetLog(client, target, 6, 0, 2, copymoney, "");
				
				GetClientName(target, tempname, sizeof(tempname));
				DDS_PrintToChat(client, "%s 님의 모든 %s[%d %s]을(를) 회수하였습니다.", tempname, DDS_MONEY_NAME_KO, copymoney, DDS_MONEY_NAME_KO);
				GetClientName(client, tempname, sizeof(tempname));
				DDS_PrintToChat(target, "어드민(%s)이 유저 님의 모든 %s[%d %s]을(를) 회수하였습니다.", tempname, DDS_MONEY_NAME_KO, copymoney, DDS_MONEY_NAME_KO);
			}
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Admin(client);
		}
	}
}

/* 관리 - 아이템 메뉴 처리 함수 */
public Menu_SAdminitem(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:explodestr[2][16];
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, " ", explodestr, 2, 16);
		
		Menu_AdminItem_User(client, StringToInt(explodestr[0]), StringToInt(explodestr[1]));
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Admin(client);
		}
	}
}

/* 관리 - 아이템 - 유저 선택 메뉴 처리 함수 */
public Menu_SAdminitem_User(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:explodestr1[2][16], String:explodetemp[16], String:explodestr2[2][16];
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, " ", explodestr1, 2, 16);
		
		Format(explodetemp, sizeof(explodetemp), explodestr1[1]);
		
		ExplodeString(explodetemp, "-", explodestr2, 2, 16);
		
		new target = StringToInt(explodestr1[0]);
		new itemid = StringToInt(explodestr2[0]);
		new select = StringToInt(explodestr2[1]);
		
		if (select == 1) // 아이템 주기
		{
			SetItemProcess(client, target, 1, itemid, 1);
		}
		else if (select == 2) // 아이템 뺏기
		{
			SetItemProcess(client, target, 0, itemid, 1);
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Admin(client);
		}
	}
}

/* 관리 - 등급 조정 - 유저 선택 메뉴 처리 함수 */
public Menu_SAdminclass(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], iInfo;
		GetMenuItem(menu, data, info, sizeof(info));
		iInfo = StringToInt(info);
		
		Menu_AdminClass_Sub(client, iInfo);
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Admin(client);
		}
	}
}

/* 관리 - 등급 조정 - 등급 선택 메뉴 처리 함수 */
public Menu_SAdminclass_Sub(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:explodestr[2][16], String:userauth[32], String:genquery[512], String:username[64];
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, " ", explodestr, 2, 16);
		
		new select = StringToInt(explodestr[0]);
		new target = StringToInt(explodestr[1]);
		
		switch(select)
		{
			default:
			{
				if (dds_hDatabase == INVALID_HANDLE)
				{
					DDS_PrintToChat(client, "서버에서 데이터베이스 연결이 되지 않아 정보를 저장할 수 없습니다.");
					CloseHandle(menu);
					return;
				}
				
				GetClientAuthString(target, userauth, sizeof(userauth));
				
				Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET class='%d' WHERE authid='%s'", select, userauth);
				DDS_SendQuery(dds_hDatabase, SQL_Info_ProfileUpdate, genquery, target);
				
				dds_iUserClass[target] = select;
				
				GetClientName(client, username, sizeof(username));
				DDS_PrintToChat(target, "어드민(%s)이 유저님을 등급 '%d'으로 변경하였습니다.", username, select);
				GetClientName(target, username, sizeof(username));
				DDS_PrintToChat(client, "%s 님의 등급을 '%d'으로 변경했습니다.", username, select);
				
				SetLog(client, target, 6, 0, 5, select, "");
				SetUserRepairLog(target, true, false, 0, 0, 0, 0);
			}
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_AdminClass(client);
		}
	}
}

/* 자유형 태그 설정 확인 메뉴 처리 함수 */
public Menu_SChkTag(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:explodestr[2][64], String:setfreetag[64];
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, " ", explodestr, 2, 64);
		
		new select = StringToInt(explodestr[0]);
		Format(setfreetag, sizeof(setfreetag), explodestr[1]);
		
		switch(select)
		{
			case 1:
			{
				SetTag(client, setfreetag);
			}
			case 2:
			{
				dds_iUserItemID[client][IsThereThisItemCode_num("tag")] = 0;
				Format(dds_sUserItemName[client][IsThereThisItemCode_num("tag")], 64, DEFAULT_NAME);
				dds_bFreeTag[client][0] = false;
				dds_bFreeTag[client][1] = false;
				DDS_PrintToChat(client, "자유형 태그 설정이 취소되었습니다.");
			}
		}
	}
}

/* 데이터 초기화 확인 메뉴 처리 함수 */
public Menu_SInitData(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], iInfo;
		GetMenuItem(menu, data, info, sizeof(info));
		iInfo = StringToInt(info);
		
		switch(iInfo)
		{
			case 1:
			{
				Menu_InitializeDatabaseRe(client);
			}
			case 2:
			{
				Nothing();
			}
		}
	}
}

/* 데이터 초기화 재확인 메뉴 처리 함수 */
public Menu_SInitData_Re(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], iInfo;
		GetMenuItem(menu, data, info, sizeof(info));
		iInfo = StringToInt(info);
		
		switch(iInfo)
		{
			case 1:
			{
				new String:genquery[512];
				
				// 데이터베이스를 잘 파악하고 작성할 것
				Format(genquery, sizeof(genquery), "DELETE FROM dds_userbasic");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_useritem");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_useritemcount");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_useritemtime");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_useroption");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_userreserved");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_userlog_basic");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_userlog_item");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_serverlog");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				Format(genquery, sizeof(genquery), "DELETE FROM dds_serverchat");
				DDS_SendQuery(dds_hDatabase, SQL_ErrorProcess, genquery, client);
				
				for (new i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i))
						DoResetUserData(i, 1);
				}
				
				DDS_PrintToChatAll("관리자가 달러샵 유저 데이터베이스를 모두 초기화하였습니다.");
				DDS_PrintToChatAll("맵을 바꾸거나 달러샵 코어와 관련 모든 플러그인을 다시 로드하시면 다시 작동됩니다.");
				
				SetConVarInt(dds_eConvar[HPLUGINSWITCH], 0);
			}
			case 2:
			{
				Nothing();
			}
		}
	}
}

/* 데이터베이스 복구 확인 01 처리 함수 */
public Menu_SUserRepair01(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], iInfo;
		GetMenuItem(menu, data, info, sizeof(info));
		iInfo = StringToInt(info);
		
		Menu_UserRepairValidate02(client, iInfo);
	}
}

/* 데이터베이스 복구 확인 02 처리 함수 */
public Menu_SUserRepair02(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:exstr[2][32];
		GetMenuItem(menu, data, info, sizeof(info));
		
		ExplodeString(info, "^", exstr, sizeof(exstr), sizeof(exstr[]));
		
		new select = StringToInt(exstr[0]);
		new target = StringToInt(exstr[1]);
		
		dds_bUserRepairLog[client][0] = true;
		dds_iUserTempData[client][0] = select;
		dds_iUserTempData[client][1] = target;
		DDS_PrintToChat(client, "이제 날짜 파라메터를 입력하세요.");
	}
}

/* 데이터베이스 복구 확인 03 처리 함수 */
public Menu_SUserRepair03(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32], String:explodestr1[2][64], String:explodestr2[2][64], String:explodestr3[2][64], String:explodestr4[6][16];
		GetMenuItem(menu, data, info, sizeof(info));
		
		new select, target, modeset, timesave[6], String:saveunix[64];
		
		ExplodeString(info, "^", explodestr1, 2, 64);
		target = StringToInt(explodestr1[1]);
		ExplodeString(explodestr1[0], "#", explodestr2, 2, 64);
		modeset = StringToInt(explodestr2[1]);
		ExplodeString(explodestr2[0], "(", explodestr3, 2, 64);
		select = StringToInt(explodestr3[0]);
		
		if (modeset == 1)
		{
			Format(saveunix, sizeof(saveunix), explodestr3[1]);
		}
		else if (modeset == 2)
		{
			ExplodeString(explodestr3[1], "-", explodestr4, 6, 16);
			for (new i = 0; i < 6; i++)
			{
				timesave[i] = StringToInt(explodestr4[i]);
			}
			Format(saveunix, sizeof(saveunix), "%d", GetTime() - (timesave[0] * 365 * 24 * 3600 + timesave[1] * 31 * 24 * 3600 + timesave[2] * 24 * 3600 + timesave[3] * 3600 + timesave[4] * 60));
		}
		
		switch(select)
		{
			case 1:
			{
				new String:genquery[512], String:taauthid[32], Handle:sendparam;
				
				GetClientAuthString(target, taauthid, sizeof(taauthid));
				
				sendparam = CreateArray(16);
				
				PushArrayCell(sendparam, client);
				PushArrayCell(sendparam, target);
				PushArrayString(sendparam, saveunix);
				
				Format(genquery, sizeof(genquery), "SELECT * FROM dds_userlog_basic WHERE authid='%s' AND date>='%s' ORDER BY id DESC", taauthid, saveunix);
				DDS_SendQuery(dds_hDatabase, SQL_UserRepair01, genquery, sendparam);
			}
			case 2:
			{
				dds_bUserRepairLog[client][0] = false;
				DDS_PrintToChat(client, "데이터 복구 모드가 비활성화되었습니다.");
			}
		}
	}
}

/* 일반 메뉴 동작 X 처리 함수1 */
public Menu_SNothing1(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

/* 일반 메뉴 동작 X 처리 함수2 */
public Menu_SNothing2(Handle:menu, MenuAction:action, client, data)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if (action == MenuAction_Select)
	{
		new String:info[32];
		GetMenuItem(menu, data, info, sizeof(info));
		new iInfo = StringToInt(info);
		
		switch(iInfo)
		{
			default:
			{
				Nothing();
			}
		}
	}
	
	if (action == MenuAction_Cancel)
	{
		if (data == MenuCancel_ExitBack)
		{
			Menu_Main(client, 0);
		}
	}
}

/********************************
 * 타이머
********************************/
/* 타이머 - SQL 유저 입장 처리 함수 */
public Action:Timer_SQLUserConnectLoad(Handle:timer, any:client)
{
	new String:userauth[64], String:genquery[512];
	
	GetClientAuthString(client, userauth, sizeof(userauth));
	
	#if defined _DEBUG_
	DDS_PrintDebugMsg(0, false, "Checking this User's Database (Type: 1, client: %d)...", client);
	#endif
	// 유저 입장 후 데이터베이스 내 유저 계정 확인
	Format(genquery, sizeof(genquery), "SELECT * FROM dds_userbasic WHERE authid='%s'", userauth);
	DDS_SendQuery(dds_hDatabase, SQL_CheckUserAccount, genquery, client);
}

/*******************************************************
 N A T I V E  &  F O R W A R D  F U N C T I O N S
*******************************************************/
/* 네이티브 - DDS_IsPluginOn */
public Native_DDS_IsPluginOn(Handle:plugin, numParams)
{
	return GetConVarBool(dds_eConvar[HPLUGINSWITCH]);
}

/* 네이티브 - DDS_GetUserMoney */
public Native_DDS_GetUserMoney(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return 0;
	}
	
	return dds_iUserMoney[client];
}

/* 네이티브 - DDS_SetUserMoney */
public Native_DDS_SetUserMoney(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new mode = GetNativeCell(2);
	new amount = GetNativeCell(3);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	if ((mode < 1) || (mode > 3))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'mode' should be the number between 1 to 3.", DDS_CHAT_PREFIX_EN);
		return;
	}
	
	if (amount < 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'amount' should be higher than 0 or same.", DDS_CHAT_PREFIX_EN);
		return;
	}
	
	SetUserMoney(client, mode, amount);
}

/* 네이티브 - DDS_GetUserClass */
public Native_DDS_GetUserClass(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return 0;
	}
	
	return dds_iUserClass[client];
}

/* 네이티브 - DDS_SetUserClass */
public Native_DDS_SetUserClass(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new classid = GetNativeCell(2);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	new String:genquery[512], String:userauth[64];
	
	GetClientAuthString(client, userauth, sizeof(userauth));
	
	Format(genquery, sizeof(genquery), "UPDATE dds_userbasic SET class='%d' WHERE authid='%s'", classid, userauth);
	DDS_SendQuery(dds_hDatabase, SQL_Info_ProfileUpdate, genquery, client);
	
	dds_iUserClass[client] = classid;
}

/* 네이티브 - DDS_ClearGlobalItemList */
public Native_DDS_ClearGlobalItemList(Handle:plugin, numParams)
{
	new bool:setcount = bool:GetNativeCell(1);
	
	DoResetItemList(setcount);
}

/* 네이티브 - DDS_UpdateDatabase */
public Native_DDS_UpdateDatabase(Handle:plugin, numParams)
{
	if (dds_iDatabaseUpStatus == 1) // SQL이 활성화가 되어있을 때
		DoCheckDatabase();
	else if (dds_iDatabaseUpStatus == 0) // SQL이 비활성화 되어있을 때
		dds_iDatabaseUpStatus = 2;
}

/* 네이티브 - DDS_SetGlobalItemList */
public Native_DDS_SetGlobalItemList(Handle:plugin, numParams)
{
	new String:itemname[64], itemcode, String:itemadrs[128], itemcolor[4], itemprice, itemproc, itempos[3], itemang[3], itemspecial, itemtime, String:itemoption[64], itemuse;
	
	GetNativeString(1, itemname, sizeof(itemname));
	itemcode = GetNativeCell(2);
	GetNativeString(3, itemadrs, sizeof(itemadrs));
	GetNativeArray(4, itemcolor, sizeof(itemcolor));
	itemprice = GetNativeCell(5);
	itemproc = GetNativeCell(6);
	GetNativeArray(7, itempos, sizeof(itempos));
	GetNativeArray(8, itemang, sizeof(itemang));
	itemspecial = GetNativeCell(9);
	itemtime = GetNativeCell(10);
	GetNativeString(11, itemoption, sizeof(itemoption));
	itemuse = GetNativeCell(12);
	
	CreateItem(itemname, itemcode, itemadrs, itemcolor, itemprice, itemproc, itempos, itemang, itemspecial, itemtime, itemoption, itemuse);
}

/* 네이티브 - DDS_CreateGlobalItem */
public Native_DDS_CreateGlobalItem(Handle:plugin, numParams)
{
	new indexid = GetNativeCell(1);
	new String:content[64], String:name[32], count;
	
	GetNativeString(2, content, sizeof(content));
	GetNativeString(3, name, sizeof(name));
	
	if (indexid < 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'indexid'(%d) is lower than 0.", DDS_CHAT_PREFIX_EN, indexid);
		return;
	}
	
	// 기존에 추가된 인덱스 번호가 추가된 것이 있는지 확인
	for (new i = 1; i <= ITEMCATEGORY_NUMBER; i++)
	{
		if (StringToInt(dds_sGetItemCodeList[i][0]) == indexid)
			count++;
	}
	
	if (count > 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s Item Code (%d) is already added!", DDS_CHAT_PREFIX_EN, indexid);
		return;
	}
	else if (count == 0) // 추가된 것이 없다면 새롭게 추가
	{
		Format(dds_sGetItemCodeList[indexid][0], 64, "%d", indexid);
		Format(dds_sGetItemCodeList[indexid][1], 64, content);
		Format(dds_sGetItemCodeList[indexid][2], 64, name);
		
		// 아이템 종류 이용관련 설정
		DoSetItemCodeUse(true, false, false);
		
		// 아이템 종류 이름 정렬 및 아이템 이용관련 활성화
		for (new m = 0; m <= ITEMCATEGORY_NUMBER; m++)
		{
			if (m == 0)
			{
				Format(dds_sItemCodeName[m], 32, "전체");
				continue;
			}
			else if (m > 0)
			{
				if (StringToInt(dds_sGetItemCodeList[m][0]) == m)
				{
					Format(dds_sItemCodeName[m], 32, dds_sGetItemCodeList[m][1]);
					dds_bItemCodeUse[m] = true;
				}
			}
		}
		
		// 아이템 이용관련 재설정
		DoSetItemCodeUse(false, false, true);
	}
}

/* 네이티브 - DDS_RemoveGlobalItem */
public Native_DDS_RemoveGlobalItem(Handle:plugin, numParams)
{
	new indexid = GetNativeCell(1);
	
	if (indexid < 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'indexid'(%d) is lower than 0.", DDS_CHAT_PREFIX_EN, indexid);
		return;
	}
	
	Format(dds_sGetItemCodeList[indexid][0], 64, "%d", indexid);
	Format(dds_sGetItemCodeList[indexid][1], 64, "");
	Format(dds_sGetItemCodeList[indexid][2], 64, "");
	
	Format(dds_sItemCodeName[indexid], 32, dds_sGetItemCodeList[indexid][1]);
	dds_bItemCodeUse[indexid] = false;
}

/* 네이티브 - DDS_GetUserItemStatus */
public Native_DDS_GetUserItemStatus(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new itemcode = GetNativeCell(2);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return 0;
	}
	
	if (itemcode <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemcode);
		return 0;
	}
	
	if (itemcode > ITEMCATEGORY_NUMBER)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be lower than 'ITEMCATEGORY_NUMBER'(%d) or same.", DDS_CHAT_PREFIX_EN, itemcode, ITEMCATEGORY_NUMBER);
		return 0;
	}
	
	return dds_bUserStatus[client][itemcode];
}

/* 네이티브 - DDS_GetUserItemID */
public Native_DDS_GetUserItemID(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new itemcode = GetNativeCell(2);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return 0;
	}
	
	if (itemcode <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemcode);
		return 0;
	}
	
	if (itemcode > ITEMCATEGORY_NUMBER)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be lower than 'ITEMCATEGORY_NUMBER'(%d) or same.", DDS_CHAT_PREFIX_EN, itemcode, ITEMCATEGORY_NUMBER);
		return 0;
	}
	
	return dds_iUserItemID[client][itemcode];
}

/* 네이티브 - DDS_SetUserItemID */
public Native_DDS_SetUserItemID(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new itemcode = GetNativeCell(2);
	new itemid = GetNativeCell(3);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	if (itemcode <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemcode);
		return;
	}
	
	if (itemcode > ITEMCATEGORY_NUMBER)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be lower than 'ITEMCATEGORY_NUMBER'(%d) or same.", DDS_CHAT_PREFIX_EN, itemcode, ITEMCATEGORY_NUMBER);
		return;
	}
	
	dds_iUserItemID[client][itemcode] = itemid;
}

/* 네이티브 - DDS_SetUserItemName */
public Native_DDS_SetUserItemName(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new itemcode = GetNativeCell(2);
	new String:getnamestr[64];
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	if (itemcode <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemcode);
		return;
	}
	
	if (itemcode > ITEMCATEGORY_NUMBER)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be lower than 'ITEMCATEGORY_NUMBER'(%d) or same.", DDS_CHAT_PREFIX_EN, itemcode, ITEMCATEGORY_NUMBER);
		return;
	}
	
	GetNativeString(3, getnamestr, sizeof(getnamestr));
	Format(dds_sUserItemName[client][itemcode], 64, getnamestr);
}

/* 네이티브 - DDS_GetUserItemName */
public Native_DDS_GetUserItemName(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new itemcode = GetNativeCell(2);
	new bflength = GetNativeCell(4);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	if (itemcode <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemcode);
		return;
	}
	
	if (itemcode > ITEMCATEGORY_NUMBER)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be lower than 'ITEMCATEGORY_NUMBER'(%d) or same.", DDS_CHAT_PREFIX_EN, itemcode, ITEMCATEGORY_NUMBER);
		return;
	}
	
	SetNativeString(3, dds_sUserItemName[client][itemcode], bflength, true);
}

/* 네이티브 - DDS_GetItemTotalNumber */
public Native_DDS_GetItemTotalNumber(Handle:plugin, numParams)
{
	return (dds_iCurItem > 0) ? dds_iCurItem-1 : dds_iCurItem;
}

/* 네이티브 - DDS_GetItemUse */
public Native_DDS_GetItemUse(Handle:plugin, numParams)
{
	new itemcode = GetNativeCell(1);
	
	if (itemcode <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemcode);
		return 0;
	}
	
	if (itemcode > ITEMCATEGORY_NUMBER)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be lower than 'ITEMCATEGORY_NUMBER'(%d) or same.", DDS_CHAT_PREFIX_EN, itemcode, ITEMCATEGORY_NUMBER);
		return 0;
	}
	
	return dds_bItemCodeUse[itemcode];
}

/* 네이티브 - DDS_GetItemCodeName */
public Native_DDS_GetItemCodeName(Handle:plugin, numParams)
{
	new itemcode = GetNativeCell(1);
	new bflength = GetNativeCell(3);
	
	if (itemcode <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemcode);
		return;
	}
	
	if (itemcode > ITEMCATEGORY_NUMBER)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) should be lower than 'ITEMCATEGORY_NUMBER'(%d) or same.", DDS_CHAT_PREFIX_EN, itemcode, ITEMCATEGORY_NUMBER);
		return;
	}
	
	SetNativeString(2, dds_sItemCodeName[itemcode], bflength, true);
}

/* 네이티브 - DDS_GetItemPrecache */
public Native_DDS_GetItemPrecache(Handle:plugin, numParams)
{
	new itemcode = GetNativeCell(1);
	new itemid = GetNativeCell(2);
	new anydata = GetNativeCell(3);
	
	if (itemcode < 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) is lower than 0.", DDS_CHAT_PREFIX_EN, itemcode);
		return 0;
	}
	
	if (ITEMCATEGORY_NUMBER < itemcode)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemcode'(%d) is upper than max category number('ITEMCATEGORY_NUMBER'(define)).", DDS_CHAT_PREFIX_EN, itemcode);
		return 0;
	}
	
	if (itemid > (dds_iCurItem-1))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemid'(%d) is not added.", DDS_CHAT_PREFIX_EN, itemid);
		return 0;
	}
	
	if ((anydata < 0) || (anydata > 1))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'anydata'(%d) should be the number between 0 to 1.", DDS_CHAT_PREFIX_EN, anydata);
		return 0;
	}
	
	return dds_iModelCode[itemid][itemcode][anydata];
}

/* 네이티브 - DDS_GetItemInfo */
public Native_DDS_GetItemInfo(Handle:plugin, numParams)
{
	new itemid = GetNativeCell(1);
	new select = GetNativeCell(2);
	
	if (itemid > (dds_iCurItem-1))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemid'(%d) is not added.", DDS_CHAT_PREFIX_EN, itemid);
		return;
	}
	
	if ((select < 0) || (select > 11))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'select'(%d) should be the number between 0 to 11.", DDS_CHAT_PREFIX_EN, select);
		return;
	}
	
	new datacolor[4], datapos[3], dataang[3];
	
	new String:result[128];
	
	if (select == 0) // ID
	{
		Format(result, sizeof(result), "%d", dds_eItem[itemid][ITEMID]);
	}
	else if (select == 1) // NAME
	{
		Format(result, sizeof(result), dds_eItem[itemid][ITEMNAME]);
	}
	else if (select == 2) // CODE
	{
		Format(result, sizeof(result), "%d", dds_eItem[itemid][ITEMCODE]);
	}
	else if (select == 3) // ADRS
	{
		Format(result, sizeof(result), dds_eItem[itemid][ITEMADRS]);
	}
	else if (select == 4) // COLOR
	{
		for (new i = 0; i < 4; i++)
		{
			datacolor[i] = dds_eItem[itemid][ITEMCOLOR][i];
		}
		
		Format(result, sizeof(result), "%d %d %d %d", datacolor[0], datacolor[1], datacolor[2], datacolor[3]);
	}
	else if (select == 5) // PRICE
	{
		Format(result, sizeof(result), "%d", dds_eItem[itemid][ITEMPRICE]);
	}
	else if (select == 6) // PROC
	{
		Format(result, sizeof(result), "%d", dds_eItem[itemid][ITEMPROC]);
	}
	else if (select == 7) // POS
	{
		for (new i = 0; i < 3; i++)
		{
			datapos[i] = dds_eItem[itemid][ITEMPOS][i];
		}
		
		Format(result, sizeof(result), "%d %d %d", datapos[0], datapos[1], datapos[2]);
	}
	else if (select == 8) // ANG
	{
		for (new i = 0; i < 3; i++)
		{
			dataang[i] = dds_eItem[itemid][ITEMANG][i];
		}
		
		Format(result, sizeof(result), "%d %d %d", dataang[0], dataang[1], dataang[2]);
	}
	else if (select == 9) // SPECIAL
	{
		Format(result, sizeof(result), "%d", dds_eItem[itemid][ITEMSPECIAL]);
	}
	else if (select == 10) // OPTION
	{
		Format(result, sizeof(result), dds_eItem[itemid][ITEMOPTION]);
	}
	else if (select == 11) // USE
	{
		Format(result, sizeof(result), "%d", dds_eItem[itemid][ITEMUSE]);
	}
	
	SetNativeString(3, result, sizeof(result), true);
}

/* 네이티브 - DDS_GetUserFTagStatus */
public Native_DDS_GetUserFTagStatus(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return 0;
	}
	
	return dds_bFreeTag[client][1];
}

/* 네이티브 - DDS_GetUserFTagStr */
public Native_DDS_GetUserFTagStr(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	SetNativeString(2, dds_sFreeTag[client], 64, true);
}

/* 네이티브 - DDS_OpenMainMenu */
public Native_DDS_OpenMainMenu(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	Menu_Main(client, 0);
}

/* 네이티브 - DDS_GetDatabaseHandle */
public Native_DDS_GetDatabaseHandle(Handle:plugin, numParams)
{
	SetNativeCellRef(1, Handle:dds_hDatabase);
}

/* 네이티브 - DDS_SetItemProcess */
public Native_DDS_SetItemProcess(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new target = GetNativeCell(2);
	new proctype = GetNativeCell(3);
	new itemid = GetNativeCell(4);
	new anydata = GetNativeCell(5);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	if (!IsClientInGame(target))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s target %d is not in game.", DDS_CHAT_PREFIX_EN, target);
		return;
	}
	
	if (itemid > (dds_iCurItem-1))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemid'(%d) is not added.", DDS_CHAT_PREFIX_EN, itemid);
		return;
	}
	
	if (itemid <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemid'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemid);
		return;
	}
	
	SetItemProcess(client, target, proctype, itemid, anydata);
}

/* 네이티브 - DDS_SimpleGiveItem */
public Native_DDS_SimpleGiveItem(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new itemid = GetNativeCell(2);
	new amount = GetNativeCell(3);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	if (itemid > (dds_iCurItem-1))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemid'(%d) is not added.", DDS_CHAT_PREFIX_EN, itemid);
		return;
	}
	
	if (itemid <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemid'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemid);
		return;
	}
	
	if (amount <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'amount' should be higher than 0.", DDS_CHAT_PREFIX_EN);
		return;
	}
	
	SetItemProcess(client, 0, -1, itemid, amount);
}

/* 네이티브 - DDS_SimpleRemoveItem */
public Native_DDS_SimpleRemoveItem(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new itemid = GetNativeCell(2);
	new amount = GetNativeCell(3);
	
	if (!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s client %d is not in game.", DDS_CHAT_PREFIX_EN, client);
		return;
	}
	
	if (itemid > (dds_iCurItem-1))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemid'(%d) is not added.", DDS_CHAT_PREFIX_EN, itemid);
		return;
	}
	
	if (itemid <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'itemid'(%d) should be upper than 0.", DDS_CHAT_PREFIX_EN, itemid);
		return;
	}
	
	if (amount <= 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s 'amount' should be higher than 0.", DDS_CHAT_PREFIX_EN);
		return;
	}
	
	SetItemProcess(client, 0, -2, itemid, amount);
}

/* 포워드 처리 - DDS_OnClientSetItem */
Process_OnClientSetItem(client, itemcode, itemid)
{
	Call_StartForward(dds_hClientSetItem);
	Call_PushCell(client);
	Call_PushCell(itemcode);
	Call_PushCell(itemid);
	Call_Finish();
}

/* 포워드 처리 - DDS_OnClientBuyItem */
Process_OnClientBuyItem(client, itemcode, itemid)
{
	Call_StartForward(dds_hClientBuyItem);
	Call_PushCell(client);
	Call_PushCell(itemcode);
	Call_PushCell(itemid);
	Call_Finish();
}