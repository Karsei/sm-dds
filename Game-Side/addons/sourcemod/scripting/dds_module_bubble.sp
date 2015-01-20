/************************************************************************
 * Dynamic Dollar Shop - [Module] Bubble (Sourcemod)
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
#include <sdkhooks>
#include <dds>

/*******************************************************
 D E F I N E S
*******************************************************/
#define BUBBLEID						7

/*******************************************************
 E N U M S
*******************************************************/
enum CONVAR
{
	Handle:HBUBBLECOUNT,
	Handle:HBUBBLESPEED
}

/*******************************************************
 V A R I A B L E S
*******************************************************/
// Cvar 핸들
new dds_eConvar[CONVAR];

// 게임 감지
//new dds_iGameID;
new bool:dds_bOKGo;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Bubble",
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
	dds_eConvar[HBUBBLECOUNT] = CreateConVar("dds_shoes_bubble_count", "12", "버블을 착용 시 나타나는 모델의 갯수를 적어주세요.", FCVAR_PLUGIN);
	dds_eConvar[HBUBBLESPEED] = CreateConVar("dds_shoes_bubble_speed", "25.0", "버블을 착용 시 나타나는 모델의 움직임 속도를 적어주세요.", FCVAR_PLUGIN);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Bubble' has been loaded.");
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(BUBBLEID, "버블", "bubble");
}

public OnConfigsExecuted()
{
	new String:getname[64];
	
	GetGameFolderName(getname, sizeof(getname));
	
	// 게임에 따른 모델 스킨 관련 프리캐시
	if (StrEqual(getname, "cstrike", false))
	{
		dds_bOKGo = true;
		//dds_iGameID = 1;
	}
	else if (StrEqual(getname, "tf", false))
	{
		dds_bOKGo = true;
		//dds_iGameID = 2;
	}
	else if (StrEqual(getname, "csgo", false)) // Temp Entity 없음
	{
		dds_bOKGo = false;
		//dds_iGameID = 3;
	}
}

/* 클라이언트 접속 시 처리해야할 작업 */
public OnClientPutInServer(client)
{
	if (DDS_IsPluginOn())
	{
		if (!IsFakeClient(client))
		{
			if (dds_bOKGo)
			{
				// SDKHooks 로드
				SDKHook(client, SDKHook_PostThink, PostThinkHook);
			}
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
			if (dds_bOKGo)
			{
				// SDKHooks 언로드
				SDKUnhook(client, SDKHook_PostThink, PostThinkHook);
			}
		}
	}
}

/* SDKHooks - PostThinkHook */
public PostThinkHook(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (DDS_GetUserItemStatus(client, BUBBLEID) && (DDS_GetUserItemID(client, BUBBLEID) > 0) && DDS_GetItemUse(BUBBLEID))
		{
			if (dds_bOKGo)
			{
				new Float:pos[3];
				
				GetClientAbsOrigin(client, pos);
				
				SetBubble(pos, pos, DDS_GetItemPrecache(BUBBLEID, DDS_GetUserItemID(client, BUBBLEID)), 250.0, GetConVarInt(dds_eConvar[HBUBBLECOUNT]), GetConVarFloat(dds_eConvar[HBUBBLESPEED]));
			}
		}
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 버블 처리 함수 */
public SetBubble(const Float:vecmins[3], const Float:vecmaxs[3], model, Float:height, amount, Float:speed)
{
	TE_Start("Bubbles");
	TE_WriteVector("m_vecMins", vecmins);
	TE_WriteVector("m_vecMaxs", vecmaxs);
	TE_WriteNum("m_nModelIndex", model);
	TE_WriteFloat("m_fHeight", height);
	TE_WriteNum("m_nCount", amount);
	TE_WriteFloat("m_fSpeed", speed);
	TE_SendToAll();
}