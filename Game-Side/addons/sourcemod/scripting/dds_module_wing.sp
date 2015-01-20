/************************************************************************
 * Dynamic Dollar Shop - [Module] Wing (Sourcemod)
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
#include <sdkhooks>
#include <sdktools>
#include <dds>

/*******************************************************
 D E F I N E S
*******************************************************/
#define WINGID							15

/*******************************************************
 V A R I A B L E S
*******************************************************/
// 게임 감지
//new dds_iGameID;
new bool:dds_bOKGo;

// 훅 이벤트 관련
new bool:dds_bFirstLoadCm;

// Entity 설정
new dds_iItemEnt[MAXPLAYERS+1];

// GameData 로드
new Handle:dds_hForwardConf = INVALID_HANDLE;
new Handle:dds_hForwardSet = INVALID_HANDLE;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Wing",
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
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Wing' has been loaded.");
}

public OnConfigsExecuted()
{
	// 포워드를 찾기 위한 시그네쳐 값 로드
	dds_hForwardConf = LoadGameConfigFile("forward.gamedata");
	if (dds_hForwardConf == INVALID_HANDLE)
	{
		SetFailState("%s gamedata/forward.gamedata.txt is not loadable!", DDS_CHAT_PREFIX_EN);
		dds_hForwardConf = INVALID_HANDLE;
	}
	else
	{
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetFromConf(dds_hForwardConf, SDKConf_Signature, "LookupAttachment");
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		dds_hForwardSet = EndPrepSDKCall();
	}
	
	new String:getname[64];
	
	GetGameFolderName(getname, sizeof(getname));
	
	// 게임에 따른 모델 스킨 관련 프리캐시
	if (StrEqual(getname, "cstrike", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("round_freeze_end", Event_OnRoundStart);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 1;
	}
	else if (StrEqual(getname, "tf", false)) // 참고: 기본 모델에 전부 forward 값 없음
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("arena_round_start", Event_OnRoundStart);
			HookEvent("teamplay_round_start", Event_OnRoundStart);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 2;
	}
	else if (StrEqual(getname, "csgo", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("round_freeze_end", Event_OnRoundStart);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 3;
	}
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(WINGID, "날개", "wing");
}

/* 클라이언트 접속 시 처리해야할 작업 */
public OnClientPutInServer(client)
{
	if (DDS_IsPluginOn())
	{
		if (!IsFakeClient(client))
		{
			// 엔티티 초기화
			dds_iItemEnt[client] = -1;
		}
	}
}

/* 클라이언트 접속 해제 시 처리해야할 작업 */
public OnClientDisconnect(client)
{
	if (DDS_IsPluginOn())
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			// 엔티티 초기화
			dds_iItemEnt[client] = -1;
		}
	}
}

/* SDKHooks - SetTransmit */
public Action:SetTransmit(entity, client)
{
	// 날개는 3인칭 시점(콘솔의 thirdperson 는 X)에서만 보이도록 설정
	if (entity == dds_iItemEnt[client])
	{
		if (GetEntProp(client, Prop_Send, "m_iObserverMode") == 1)
			return Plugin_Continue;
		else
			return Plugin_Handled;
	}
	else
	{
		// 제 3 자가 보았을 때 모델이 나타나도록 설정
		if (IsClientObserver(client))
		{
			new obtarget = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			
			if (obtarget > 0)
			{
				if (entity == dds_iItemEnt[obtarget])
				{
					if (GetEntProp(client, Prop_Send, "m_iObserverMode") == 1)
						return Plugin_Handled;
					else
						return Plugin_Continue;
				}
				else
				{
					return Plugin_Continue;
				}
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else
		{
			return Plugin_Continue;
		}
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 날개 처리 함수 */
public SetWing(client, const String:model[], bool:create)
{
	if (create)
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "WING: %d (Set: Create-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		dds_iItemEnt[client] = CreateEntityByName("prop_dynamic_override");
		
		DispatchKeyValue(dds_iItemEnt[client], "model", model);
		DispatchKeyValue(dds_iItemEnt[client], "solid", "0");
		DispatchKeyValue(dds_iItemEnt[client], "disableshadows", "1");
		SetEntPropEnt(dds_iItemEnt[client], Prop_Send, "m_hOwnerEntity", client);
		DispatchSpawn(dds_iItemEnt[client]);
		
		AcceptEntityInput(dds_iItemEnt[client], "TurnOn", dds_iItemEnt[client], dds_iItemEnt[client], 0);
		
		new Float:origin[3], Float:angle[3], Float:anfor[3], Float:anrig[3], Float:anup[3], Float:entpos[3];
		
		GetClientAbsOrigin(client, origin);
		GetClientAbsAngles(client, angle);
		
		new String:tempval[128], String:exstr[3][128];
		
		// 각도 설정
		DDS_GetItemInfo(DDS_GetUserItemID(client, WINGID), 8, tempval);
		ExplodeString(tempval, " ", exstr, 3, 128);
		
		for (new i = 0; i < 3; i++)
		{
			angle[i] += float(StringToInt(exstr[i]));
		}
		
		// 위치 설정
		DDS_GetItemInfo(DDS_GetUserItemID(client, WINGID), 7, tempval);
		ExplodeString(tempval, " ", exstr, 3, 128);
		
		for (new i = 0; i < 3; i++)
		{
			entpos[i] = float(StringToInt(exstr[i]));
		}
		
		GetAngleVectors(angle, anfor, anrig, anup);
		
		// 최종 동적 위치 설정
		for (new k = 0; k < 3; k++)
		{
			origin[k] += anrig[k] * entpos[k] + anfor[k] * entpos[k] + anup[k] * entpos[k];
		}
		
		if (!FindForwardValue(client, "forward"))
			origin[2] += 24.0;
		
		SDKHook(dds_iItemEnt[client], SDKHook_SetTransmit, SetTransmit);
		
		TeleportEntity(dds_iItemEnt[client], origin, angle, NULL_VECTOR);
		
		SetVariantString("!activator");
		AcceptEntityInput(dds_iItemEnt[client], "SetParent", client, dds_iItemEnt[client], 0);
		
		if (!FindForwardValue(client, "forward"))
			SetVariantString("defusekit");
		else
			SetVariantString("forward");
		
		AcceptEntityInput(dds_iItemEnt[client], "SetParentAttachmentMaintainOffset", dds_iItemEnt[client], dds_iItemEnt[client], 0);
		
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "WING: %d (Set: Create-AFTER, client: %d)", dds_iItemEnt[client], client);
		//DDS_PrintDebugMsg(client, true, "(WING) 모델: %s, Pos: %f %f %f, Ang: %f %f %f", model, origin[0], origin[1], origin[2], angle[0], angle[1], angle[2]);
		#endif
	}
	else
	{
		#if defined _DEBUG_
		DDS_PrintDebugMsg(0, false, "WING: %d (Set: NoCreate-PREV, client: %d)", dds_iItemEnt[client], client);
		#endif
		
		if (IsValidEntity(dds_iItemEnt[client]) && (dds_iItemEnt[client] != -1))
		{
			AcceptEntityInput(dds_iItemEnt[client], "Kill");
			
			#if defined _DEBUG_
			DDS_PrintDebugMsg(0, false, "WING: %d (Set: NoCreate-AFTER, client: %d)", dds_iItemEnt[client], client);
			#endif
		}
		dds_iItemEnt[client] = -1;
	}
}

/* Forward 값 찾기 처리 함수 */
public FindForwardValue(client, String:set[])
{
	if (dds_hForwardSet == INVALID_HANDLE)
		return 0;
	
	if ((client == 0) || !IsClientInGame(client))
		return 0;
	
	return SDKCall(dds_hForwardSet, client, set);
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* round_freeze_end 이벤트 처리 함수 */
public Action:Event_OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
		{
			new String:wingadrs[128];
			
			DDS_GetItemInfo(DDS_GetUserItemID(i, WINGID), 3, wingadrs);
			if (DDS_GetUserItemStatus(i, WINGID) && (DDS_GetUserItemID(i, WINGID) > 0) && DDS_GetItemUse(WINGID))
				SetWing(i, wingadrs, true);
		}
	}
	
	return Plugin_Continue;
}

/* player_spawn 이벤트 처리 함수 */
public Action:Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
	{
		new String:wingadrs[128];
		
		DDS_GetItemInfo(DDS_GetUserItemID(client, WINGID), 3, wingadrs);
		if (DDS_GetUserItemStatus(client, WINGID) && (DDS_GetUserItemID(client, WINGID) > 0) && DDS_GetItemUse(WINGID))
			SetWing(client, wingadrs, true);
	}
	
	return Plugin_Continue;
}

/* player_death 이벤트 처리 함수 */
public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (DDS_GetUserItemStatus(client, WINGID) && (DDS_GetUserItemID(client, WINGID) > 0))
		SetWing(client, "", false);
	
	return Plugin_Continue;
}