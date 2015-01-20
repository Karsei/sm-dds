/************************************************************************
 * Dynamic Dollar Shop - [Module] Tag (Sourcemod)
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
#include <basecomm>
#include <dds>

/*******************************************************
 D E F I N E S
*******************************************************/
#define TAGID							6

/*******************************************************
 V A R I A B L E S
*******************************************************/
// 포워드
new Handle:dds_hForwardChatPre = INVALID_HANDLE;
new Handle:dds_hForwardChatPost = INVALID_HANDLE;

// 팀 관련
new bool:dds_bTeamChat[MAXPLAYERS+1];

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Tag",
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
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_TeamSay);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Tag' has been loaded.");
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	dds_hForwardChatPre = CreateGlobalForward("DDS_ClientChat_Pre", ET_Hook, Param_Cell, Param_String);
	dds_hForwardChatPost = CreateGlobalForward("DDS_ClientChat_Post", ET_Ignore, Param_Cell, Param_String);
	
	return APLRes_Success;
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(TAGID, "태그", "tag");
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
public Action:Command_Say(client, args)
{
	if (!DDS_IsPluginOn())	return Plugin_Continue;
	
	// 서버 채팅은 통과
	if (client == 0)	return Plugin_Continue;
	
	// sm_gag 관련하여 적절하게 동작하도록 처리
	if (BaseComm_IsClientGagged(client))	return Plugin_Continue;
	
	new String:msg[256], String:name[256], String:buffer[256], String:langname[4], bool:IsKorea;
	
	GetClientName(client, name, sizeof(name));
	GetCmdArgString(msg, sizeof(msg));
	
	msg[strlen(msg)-1] = '\x0';
	
	// 클라이언트의 언어 파악
	GetLanguageInfo(GetClientLanguage(client), langname, sizeof(langname));
	
	//if (langcode == 15 || langcode == 16)
	if (StrEqual(langname, "ko", false))
		IsKorea = true;
	else
		IsKorea = false;
	
	// 태그 처리 부분
	new String:msgformat[256], String:freetagset[64];
	
	DDS_GetUserFTagStr(client, freetagset);
	
	if (DDS_GetUserItemStatus(client, TAGID) && (DDS_GetUserItemID(client, TAGID) > 0) && DDS_GetItemUse(TAGID))
	{
		new String:tagname[128];
		
		DDS_GetItemInfo(DDS_GetUserItemID(client, TAGID), 1, tagname);
		
		// 자유형 태그에 따른 메세지 처리
		if (!DDS_GetUserFTagStatus(client))
			Format(msgformat, sizeof(msgformat), "\x04[%s] \x03%s \x01:  %s", tagname, name, msg[1]);
		else
			Format(msgformat, sizeof(msgformat), "\x04[%s] \x03%s \x01:  %s", freetagset, name, msg[1]);
	}
	else if ((DDS_GetUserItemStatus(client, TAGID) && !(DDS_GetUserItemID(client, TAGID) > 0)) || (!DDS_GetUserItemStatus(client, TAGID) && (DDS_GetUserItemID(client, TAGID) > 0)) || (!DDS_GetUserItemStatus(client, TAGID) && !(DDS_GetUserItemID(client, TAGID) > 0)))
	{
		// 일반 메세지 처리
		Format(msgformat, sizeof(msgformat), "\x03%s \x01:  %s", name, msg[1]);
	}
	
	if (IsPlayerAlive(client))
	{
		if (!dds_bTeamChat[client])
		{
			Format(buffer, sizeof(buffer), "%s", msgformat);
		}
		else
		{
			if (IsKorea)
			{
				if (GetClientTeam(client) == 2)	Format(buffer, sizeof(buffer), "\x01(테러리스트)%s", msgformat);
				else if (GetClientTeam(client) == 3)	Format(buffer, sizeof(buffer), "\x01(대테러부대)%s", msgformat);
			}
			else
			{
				if (GetClientTeam(client) == 2)	Format(buffer, sizeof(buffer), "\x01(Terrorist)%s", msgformat);
				else if (GetClientTeam(client) == 3)	Format(buffer, sizeof(buffer), "\x01(Counter-Terrorist)%s", msgformat);
			}
		}
	}
	else
	{
		if (GetClientTeam(client) == 1)
		{
			if (!dds_bTeamChat[client])
			{
				if (IsKorea)	Format(buffer, sizeof(buffer), "\x01*관전* %s", msgformat);
				else	Format(buffer, sizeof(buffer), "\x01*SPEC* %s", msgformat);
			}
			else
			{
				if (IsKorea)	Format(buffer, sizeof(buffer), "\x01(관전) %s", msgformat);
				else	Format(buffer, sizeof(buffer), "\x01(SPEC) %s", msgformat);
			}
		}
		else
		{
			if (!dds_bTeamChat[client])
			{
				if (IsKorea)	Format(buffer, sizeof(buffer), "\x01*사망* %s", msgformat);
				else	Format(buffer, sizeof(buffer), "\x01*DEAD* %s", msgformat);
			}
			else
			{
				if (IsKorea)
				{
					if (GetClientTeam(client) == 2)	Format(buffer, sizeof(buffer), "\x01*사망*(테러리스트)%s", msgformat);
					else if (GetClientTeam(client) == 3)	Format(buffer, sizeof(buffer), "\x01*사망*(대테러부대)%s", msgformat);
				}
				else
				{
					if (GetClientTeam(client) == 2)	Format(buffer, sizeof(buffer), "\x01*DEAD*(Terrorist)%s", msgformat);
					else if (GetClientTeam(client) == 3)	Format(buffer, sizeof(buffer), "\x01*DEAD*(Counter-Terrorist)%s", msgformat);
				}
			}
		}
	}
	
	// 포워드 전 체크
	new Action:chatresult = Process_ClientChat_Pre(client, msg[1]);
	if (chatresult == Plugin_Handled)	return Plugin_Handled;
	
	// 채팅 앞쪽 문자 체크
	if ((msg[1] != '/') && (msg[1] != '@'))
	{
		if (dds_bTeamChat[client])
		{
			for (new k = 1; k <= MaxClients; k++)
			{
				if (IsClientInGame(k))
				{
					if ((GetClientTeam(client) == 1) && (GetClientTeam(k) == 1))
						SayText2One(client, k, buffer);
					else if ((GetClientTeam(client) == 2) && (GetClientTeam(k) == 2))
						SayText2One(client, k, buffer);
					else if ((GetClientTeam(client) == 3) && (GetClientTeam(k) == 3))
						SayText2One(client, k, buffer);
				}
			}
		}
		else
		{
			SayText2All(client, buffer);
			PrintToServer(buffer);
		}
	}
	
	// 팀 채팅 여부 초기화
	dds_bTeamChat[client] = false;
	
	// 포워드 후 체크
	Process_ClientChat_Post(client, msg[1]);
	
	return Plugin_Handled;
}

public Action:Command_TeamSay(client, args)
{
	dds_bTeamChat[client] = true;
	Command_Say(client, args);
	
	return Plugin_Handled;
}

Action:Process_ClientChat_Pre(client, String:msg[])
{
	new Action:result;
	
	Call_StartForward(dds_hForwardChatPre);
	Call_PushCell(client);
	Call_PushString(msg);
	Call_Finish(result);
	
	return result;
}

Process_ClientChat_Post(client, String:msg[])
{
	Call_StartForward(dds_hForwardChatPost);
	Call_PushCell(client);
	Call_PushString(msg);
	Call_Finish();
}