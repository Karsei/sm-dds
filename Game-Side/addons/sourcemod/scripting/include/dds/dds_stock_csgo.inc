/************************************************************************
 * Dynamic Dollar Shop - Stock Include for CS:GO (Sourcemod)
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
#include <protobuf>

// CS:GO User Message 관련 개발 문서 - http://hg.alliedmods.net/hl2sdks/hl2sdk-csgo/file/tip/public/game/shared/csgo/protobuf/cstrike15_usermessages.proto#l130

/* 클라이언트 별 전체 메세지 전달 함수 */
stock SayText2All(client, const String:message[])
{
	new Handle:buffer = StartMessageAll("SayText2");
	
	if (buffer != INVALID_HANDLE)
	{
		PbSetInt(buffer, "ent_idx", client);
		PbSetBool(buffer, "chat", true);
		PbSetString(buffer, "msg_name", message);
		EndMessage();
	}
}

/* 클라이언트 별 개별 메세지 전달 함수 */
stock SayText2One(client, target, const String:message[])
{
	new Handle:buffer = StartMessageOne("SayText2", target);
	
	if (buffer != INVALID_HANDLE)
	{
		PbSetInt(buffer, "ent_idx", client);
		PbSetBool(buffer, "chat", false);
		PbSetString(buffer, "msg_name", message);
		EndMessage(); 
	}
}

/* 특정 채팅 메세지 전달 */
stock DDS_PrintToChat(client, const String:message[], any:...)
{
	new String:setchange[1024], String:buffer[1024];
	
	VFormat(setchange, sizeof(setchange), message, 3);
	Format(buffer, sizeof(buffer), "\x04%s \x03%s", DDS_CHAT_PREFIX_KO, setchange);
	
	PrintToChat(client, buffer);
}

/* 전체 채팅 메세지 전달 */
stock DDS_PrintToChatAll(const String:message[], any:...)
{
	new String:setchange[1024], String:buffer[1024];
	
	VFormat(setchange, sizeof(setchange), message, 2);
	Format(buffer, sizeof(buffer), "\x04%s \x03%s", DDS_CHAT_PREFIX_KO, setchange);
	
	PrintToChatAll(buffer);
}

/* 서버 메세지 전달 */
stock DDS_PrintToServer(const String:message[], any:...)
{
	new String:setchange[1024], String:buffer[1024];
	
	VFormat(setchange, sizeof(setchange), message, 2);
	Format(buffer, sizeof(buffer), "%s %s", DDS_CHAT_PREFIX_EN, setchange);
	
	PrintToServer(buffer);
}

/* 디버그 메세지 전달 */
stock DDS_PrintDebugMsg(client, bool:inchat, const String:message[], any:...)
{
	new String:setchange[1024], String:buffer[1024];
	
	VFormat(setchange, sizeof(setchange), message, 4);
	
	if (inchat) // 채팅창
	{
		Format(buffer, sizeof(buffer), "\x04%s \x05-DEBUG- \x03%s", DDS_CHAT_PREFIX_KO, setchange);
		
		PrintToChat(client, buffer);
	}
	else if (!inchat) // 서버 콘솔
	{
		Format(buffer, sizeof(buffer), "%s -DEBUG- %s", DDS_CHAT_PREFIX_EN, setchange);
		
		PrintToServer(buffer);
	}
}

/* 질의 처리 함수 */
stock DDS_SendQuery(Handle:sqlhd, SQLTCallback:sqlfuncset, const String:query[], any:data = 0, DBPriority:prio = DBPrio_Normal, bool:appclient = false, bool:appvar = false, client = 0, String:errmsg[] = "")
{
	if (sqlhd != INVALID_HANDLE)
	{
		if (appclient)
		{
			if (appvar)
				SQL_TQuery(sqlhd, sqlfuncset, query, data, prio);
			else
				DDS_PrintToChat(client, errmsg);
		}
		else
		{
			SQL_TQuery(sqlhd, sqlfuncset, query, data, prio);
		}
	}
	else
	{
		DDS_PrintToServer("Database Handle is Invalid Handle!");
	}
}

/* 서버 인원 체크 */
stock GetClientCountEx(bool:server = false, bool:bot = false, mode = 1, team = -1)
{
	new count = 0;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))	continue;
		if (!bot && IsFakeClient(i))	continue;
		
		if (mode == 1) // 죽든 상관없이
		{
			if (team == -1)
				count++;
			else if ((team >= 0) && (team < 4) && (GetClientTeam(i) == team))
				count++;
		}
		else if (mode == 2) // 살아있는 사람만
		{
			if (!IsPlayerAlive(i))	continue;
			
			if (team == -1)
				count++;
			else if ((team >= 0) && (team < 4) && (GetClientTeam(i) == team))
				count++;
		}
	}
	return server ? count+1 : count;
}

/* SQL 인젝션 보안 */
stock SetPreventSQLInject(const String:input[], String:output[], oplength)
{
	new String:tempstr[1024];
	
	strcopy(tempstr, sizeof(tempstr), input);
	
	ReplaceString(tempstr, sizeof(tempstr), "'", "''", false);
	ReplaceString(tempstr, sizeof(tempstr), "`", "`", false);
	ReplaceString(tempstr, sizeof(tempstr), "\\", "\\\\", false);
	
	strcopy(output, oplength, tempstr);
}