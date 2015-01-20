/************************************************************************
 * Dynamic Dollar Shop - [Module] Laser Bullet (Sourcemod)
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
 D E F I N E S
*******************************************************/
#define LASERID							4

/*******************************************************
 V A R I A B L E S
*******************************************************/
// 게임 감지
//new dds_iGameID;
new bool:dds_bOKGo;

// 훅 이벤트 관련
new bool:dds_bFirstLoadCm;

// GameData 로드
new Handle:dds_hLaserConf = INVALID_HANDLE;
new Handle:dds_hWShootPos = INVALID_HANDLE;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Laser Bullet",
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
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Laser Bullet' has been loaded.");
}

public OnConfigsExecuted()
{
	// 레이저 관련 오프셋 값 로드
	dds_hLaserConf = LoadGameConfigFile("laser_tag.games");
	if(dds_hLaserConf == INVALID_HANDLE)
	{
		SetFailState("%s gamedata/laser_tag.games.txt is not loadable!", DDS_CHAT_PREFIX_EN);
		dds_hWShootPos = INVALID_HANDLE;
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(dds_hLaserConf, SDKConf_Virtual, "Weapon_ShootPosition");
		PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByValue);
		dds_hWShootPos = EndPrepSDKCall();
	}
	
	new String:getname[64];
	
	GetGameFolderName(getname, sizeof(getname));
	
	// 게임에 따른 모델 스킨 관련 프리캐시
	if (StrEqual(getname, "cstrike", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("bullet_impact", Event_OnBulletImpact);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 1;
	}
	else if (StrEqual(getname, "csgo", false))
	{
		if (!dds_bFirstLoadCm)
		{
			HookEvent("bullet_impact", Event_OnBulletImpact);
			dds_bFirstLoadCm = true;
		}
		
		dds_bOKGo = true;
		//dds_iGameID = 3;
	}
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(LASERID, "레이저 총알", "laser");
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* bullet_impact 이벤트 처리 함수 */
public Action:Event_OnBulletImpact(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	if (!dds_bOKGo)	return Plugin_Continue;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (dds_hWShootPos != INVALID_HANDLE)
	{
		if (DDS_GetUserItemStatus(client, LASERID) && (DDS_GetUserItemID(client, LASERID) > 0) && DDS_GetItemUse(LASERID))
		{
			decl Float:origin[3], Float:impact[3], Float:differ[3];
			
			SDKCall(dds_hWShootPos, client, origin);
			impact[0] = GetEventFloat(event, "x");
			impact[1] = GetEventFloat(event, "y");
			impact[2] = GetEventFloat(event, "z");
			
			new Float:dist = GetVectorDistance(origin, impact);
			new Float:per = (0.4 / (dist / 100.0));
			
			differ[0] = origin[0] + ((impact[0] - origin[0]) * per);
			differ[1] = origin[1] + ((impact[1] - origin[1]) * per) - 0.08;
			differ[2] = origin[2] + ((impact[2] - origin[2]) * per);
			
			new tempcolor[4], String:tempval[128], String:exstr[4][128];
			
			DDS_GetItemInfo(DDS_GetUserItemID(client, LASERID), 4, tempval);
			ExplodeString(tempval, " ", exstr, 4, 128);
			
			for (new k; k < 4; k++)
			{
				tempcolor[k] = StringToInt(exstr[k]);
			}
			
			TE_SetupBeamPoints(differ, impact, DDS_GetItemPrecache(LASERID, DDS_GetUserItemID(client, LASERID)), 0, 0, 0, 1.0, 3.0, 3.0, 0, 0.0, tempcolor, 0);
			TE_SendToAll();
			
			#if defined _DEBUG_
			//DDS_PrintDebugMsg(client, true, "(LASER) 코드: %d, 색상: (R)%d (G)%d (B)%d (A)%d", DDS_GetItemPrecache(LASERID, DDS_GetUserItemID(client, LASERID)), tempcolor[0], tempcolor[1], tempcolor[2], tempcolor[3]);
			#endif
		}
	}
	else
	{
		if (DDS_GetUserItemStatus(client, LASERID) && (DDS_GetUserItemID(client, LASERID) > 0))
			DDS_PrintToChat(client, "서버의 sourcemod - gamedata 폴더 안에 laser_tag.games 파일이 없습니다! 어드민에게 문의해주세요!");
	}
	
	return Plugin_Continue;
}