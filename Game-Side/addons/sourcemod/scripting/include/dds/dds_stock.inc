/************************************************************************
 * Dynamic Dollar Shop - MAIN INCLUDE :: Stock (Sourcemod)
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
/**
 * 채팅 :: 모든 클라이언트에게 메세지 전달
 *
 * @param client					클라이언트 인덱스
 * @param message					전달할 메세지
 *
 * @ref CS:GO Protobuf 종류 - https://github.com/alliedmodders/hl2sdk/blob/csgo/public/game/shared/csgo/protobuf/cstrike15_usermessages.proto#L68
 */
stock SayText2All(int client, const char[] message)
{
	Handle hMsg = StartMessageAll("SayText2");

	if (hMsg != null)
	{
		if (GetUserMessageType() == "UM_Protobuf")
		{
			PbSetInt(hMsg, "ent_idx", client);
			PbSetBool(hMsg, "chat", true);
			PbSetString(hMsg, "msg_name", message);

			PbAddString(hMsg, "params", "");
			PbAddString(hMsg, "params", "");
			PbAddString(hMsg, "params", "");
			PbAddString(hMsg, "params", "");

			EndMessage();
		}
		else
		{
			BfWriteByte(hMsg, client);
			BfWriteByte(hMsg, true);
			BfWriteString(hMsg, message);
			EndMessage();
		}
	}
}

/**
 * 채팅 :: 특정 클라이언트에게 메세지 전달
 *
 * @param client					클라이언트 인덱스
 * @param target					전달할 목표 클라이언트 인덱스
 * @param message					전달할 메세지
 *
 * @ref CS:GO Protobuf 종류 - https://github.com/alliedmodders/hl2sdk/blob/csgo/public/game/shared/csgo/protobuf/cstrike15_usermessages.proto#L68
 */
stock SayText2One(int client, int target, const char[] message)
{
	Handle hMsg = StartMessageOne("SayText2", target);

	if (hMsg != null)
	{
		if (GetUserMessageType() == "UM_Protobuf")
		{
			PbSetInt(hMsg, "ent_idx", client);
			PbSetBool(hMsg, "chat", false);
			PbSetString(hMsg, "msg_name", message);

			PbAddString(hMsg, "params", "");
			PbAddString(hMsg, "params", "");
			PbAddString(hMsg, "params", "");
			PbAddString(hMsg, "params", "");

			EndMessage();
		}
		else
		{
			BfWriteByte(hMsg, client);
			BfWriteByte(hMsg, false);
			BfWriteString(hMsg, message);
			EndMessage();
		}
	}
}

/**
 * 채팅 :: 개별 채팅 메세지 전달
 *
 * @param client					클라이언트 인덱스
 * @param message					전달할 메세지
 * @param ...						전달할 파라메터
 */
stock DDS_PrintToChat(int client, const char[] message, any:...)
{
	char sMsg[1024];
	char sTempMsg[1024];
	char sGameType[32];

	// 게임 종류 판별
	GetGameFolderName(sGameType, sizeof(sGameType));

	// 포멧 메세지 파라메터 위치 지정
	VFormat(sTempMsg, sizeof(sTempMsg), message, 3);

	// 포멧 지정
	Format(sMsg, sizeof(sMsg), "%s%s \x03%s", StrEqual(sGameType, "csgo", false) ? " \x01\x0B\x04" : "\x04", DDS_ENV_CORE_CHAT_GLOPREFIX, sTempMsg);

	PrintToChat(client, sMsg);
}

/**
 * 채팅 :: 전체 채팅 메세지 전달
 *
 * @param message					전달할 메세지
 * @param ...						전달할 파라메터
 */
stock DDS_PrintToChatAll(const char[] message, any:...)
{
	char sMsg[1024];
	char sTempMsg[1024];
	char sGameType[32];

	// 게임 종류 판별
	GetGameFolderName(sGameType, sizeof(sGameType));

	// 포멧 메세지 파라메터 위치 지정
	VFormat(sTempMsg, sizeof(sTempMsg), message, 2);

	// 포멧 지정
	Format(sMsg, sizeof(sMsg), "%s%s \x03%s", StrEqual(sGameType, "csgo", false) ? " \x01\x0B\x04" : "\x04", DDS_ENV_CORE_CHAT_GLOPREFIX, sTempMsg);

	PrintToChatAll(sMsg);
}

/**
 * 채팅 :: 서버 메세지 전달
 *
 * @param message					전달할 메세지
 * @param ...						전달할 파라메터
 */
stock DDS_PrintToServer(const char[] message, any:...)
{
	char sMsg[1024];
	char sTempMsg[1024];

	// 포멧 메세지 파라메터 위치 지정
	VFormat(sTempMsg, sizeof(sTempMsg), message, 2);

	// 포멧 지정
	Format(sMsg, sizeof(sMsg), "%s %s", DDS_ENV_CORE_CHAT_GLOPREFIX, sTempMsg);

	PrintToServer(sMsg);
}