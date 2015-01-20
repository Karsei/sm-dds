/************************************************************************
 * Dynamic Dollar Shop - [Addon] Admin Extension (Sourcemod)
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
#include <dds>

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Addon] Admin Extension",
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
	RegAdminCmd("dds_admin_give_money", Command_GiveMoney, ADMFLAG_ROOT, "특정 유저의 금액을 설정합니다.");
	RegAdminCmd("dds_admin_give_class", Command_GiveClass, ADMFLAG_ROOT, "특정 유저의 등급을 설정합니다.");
	RegAdminCmd("dds_admin_give_item", Command_GiveItem, ADMFLAG_ROOT, "특정 유저에게 특정 갯수를 가진 특정 아이템을 줍니다.");
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Addon] Admin Extension' has been loaded.");
}

/*******************************************************
 C A L L B A C K   F U N C T I O N S
*******************************************************/
/* 특정 유저의 금액 처리 */
public Action:Command_GiveMoney(client, args)
{
	if (args < 3)
	{
		if (client <= 0)
			DDS_PrintToServer("Usage: !dds_admin_give_money \"Name\" \"Mode\" \"Money\"");
		else
			DDS_PrintToChat(client, "사용법: !dds_admin_give_money \"이름\" \"처리번호\" \"금액\"");
		
		return Plugin_Continue;
	}
	
	new String:taname[64], String:tamode[4], String:tamoney[32], target, setmode, setmoney, String:fname[64];
	
	GetCmdArg(1, taname, sizeof(taname));
	GetCmdArg(2, tamode, sizeof(tamode));
	GetCmdArg(3, tamoney, sizeof(tamoney));
	
	new count;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))	continue;
		
		GetClientName(i, fname, sizeof(fname));
		
		if (StrContains(fname, taname, false) != -1)
		{
			target = i;
			count++;
		}
	}
	
	if (count < 1)
	{
		if (client <= 0)
			DDS_PrintToServer("No matching player name in game!");
		else
			DDS_PrintToChat(client, "서버 내에 일치하는 플레이어의 이름이 없습니다!");
		
		return Plugin_Continue;
	}
	if (count > 1)
	{
		if (client <= 0)
			DDS_PrintToServer("Matching player name is more than 1!");
		else
			DDS_PrintToChat(client, "해당 이름이 들어있는 사람이 1명 이상입니다!");
		
		return Plugin_Continue;
	}
	
	setmode = StringToInt(tamode);
	if ((setmode < 1) && (setmode > 3))
	{
		if (client <= 0)
			DDS_PrintToServer("'Mode' should be 1 to 3!");
		else
			DDS_PrintToChat(client, "'처리방법'은 1 에서 3 까지만 가능합니다!");
		
		return Plugin_Continue;
	}
	
	setmoney = StringToInt(tamoney);
	if (setmoney <= 0)
	{
		if (client <= 0)
			DDS_PrintToServer("'Money' should be upper than 0!");
		else
			DDS_PrintToChat(client, "'금액'은 0 보다 커야합니다!");
		
		return Plugin_Continue;
	}
	
	DDS_SetUserMoney(target, setmode, setmoney);
	
	GetClientName(target, fname, sizeof(fname));
	
	if (client <= 0)
		DDS_PrintToServer("Setting player('%s')'s money to '%d' by mode('%d') is Done.", fname, setmoney, setmode);
	else
		DDS_PrintToChat(client, "'%s' 님의 금액을 처리방법 '%d'으로 금액 '%d'을 설정하였습니다.", fname, setmode, setmoney);
	
	DDS_PrintToChat(target, "어드민이 유저님의 금액에 변화를 주었습니다. 금액을 참고하세요.");
	
	return Plugin_Continue;
}

/* 특정 유저의 등급 처리 */
public Action:Command_GiveClass(client, args)
{
	if (args < 2)
	{
		if (client <= 0)
			DDS_PrintToServer("Usage: !dds_admin_give_class \"Name\" \"ClassID\"");
		else
			DDS_PrintToChat(client, "사용법: !dds_admin_give_class \"이름\" \"등급번호\"");
		
		return Plugin_Continue;
	}
	
	new String:taname[64], String:taclassid[4], target, setclassid, String:fname[64];
	
	GetCmdArg(1, taname, sizeof(taname));
	GetCmdArg(2, taclassid, sizeof(taclassid));
	
	new count;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))	continue;
		
		GetClientName(i, fname, sizeof(fname));
		
		if (StrContains(fname, taname, false) != -1)
		{
			target = i;
			count++;
		}
	}
	
	if (count < 1)
	{
		if (client <= 0)
			DDS_PrintToServer("No matching player name in game!");
		else
			DDS_PrintToChat(client, "서버 내에 일치하는 플레이어의 이름이 없습니다!");
		
		return Plugin_Continue;
	}
	if (count > 1)
	{
		if (client <= 0)
			DDS_PrintToServer("Matching player name is more than 1!");
		else
			DDS_PrintToChat(client, "해당 이름이 들어있는 사람이 1명 이상입니다!");
		
		return Plugin_Continue;
	}
	
	setclassid = StringToInt(taclassid);
	if (setclassid < 0)
	{
		if (client <= 0)
			DDS_PrintToServer("'ClassID' should be 0 to 4!");
		else
			DDS_PrintToChat(client, "'등급번호'는 0 에서 4 까지만 가능합니다!");
		
		return Plugin_Continue;
	}
	
	DDS_SetUserClass(target, setclassid);
	
	GetClientName(target, fname, sizeof(fname));
	
	if (client <= 0)
		DDS_PrintToServer("Setting player('%s')'s class to '%d' is Done.", fname, setclassid);
	else
		DDS_PrintToChat(client, "'%s' 님의 등급을 '%d'로 변경하였습니다.", fname, setclassid);
	
	DDS_PrintToChat(target, "어드민이 유저님을 등급 '%d'으로 변경하였습니다.", setclassid);
	
	return Plugin_Continue;
}

/* 특정 유저에게 주는 아이템 처리 */
public Action:Command_GiveItem(client, args)
{
	if (args < 3)
	{
		if (client <= 0)
			DDS_PrintToServer("Usage: !dds_admin_give_item \"Name\" \"ItemID\" \"ItemAmount\"");
		else
			DDS_PrintToChat(client, "사용법: !dds_admin_give_item \"이름\" \"아이템번호\" \"아이템갯수\"");
		
		return Plugin_Continue;
	}
	
	new String:taname[64], String:taitemid[16], String:taitemamount[32], target, setitemid, setitemamount, String:fname[64];
	
	GetCmdArg(1, taname, sizeof(taname));
	GetCmdArg(2, taitemid, sizeof(taitemid));
	GetCmdArg(3, taitemamount, sizeof(taitemamount));
	
	new count;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))	continue;
		
		GetClientName(i, fname, sizeof(fname));
		
		if (StrContains(fname, taname, false) != -1)
		{
			target = i;
			count++;
		}
	}
	
	if (count < 1)
	{
		if (client <= 0)
			DDS_PrintToServer("No matching player name in game!");
		else
			DDS_PrintToChat(client, "서버 내에 일치하는 플레이어의 이름이 없습니다!");
		
		return Plugin_Continue;
	}
	if (count > 1)
	{
		if (client <= 0)
			DDS_PrintToServer("Matching player name is more than 1!");
		else
			DDS_PrintToChat(client, "해당 이름이 들어있는 사람이 1명 이상입니다!");
		
		return Plugin_Continue;
	}
	
	setitemid = StringToInt(taitemid);
	if (setitemid <= 0)
	{
		if (client <= 0)
			DDS_PrintToServer("'ItemID' should be upper than 0!");
		else
			DDS_PrintToChat(client, "'아이템번호'는 0 보다 커야합니다!");
		
		return Plugin_Continue;
	}
	
	if (setitemid > DDS_GetItemTotalNumber())
	{
		if (client <= 0)
			DDS_PrintToServer("'ItemID'(%d) is not added!", setitemid);
		else
			DDS_PrintToChat(client, "'아이템번호'(%d)는 추가되어진 아이템 번호가 아닙니다!", setitemid);
		
		return Plugin_Continue;
	}
	
	setitemamount = StringToInt(taitemamount);
	if (setitemamount <= 0)
	{
		if (client <= 0)
			DDS_PrintToServer("'ItemAmount' should be upper than 0!");
		else
			DDS_PrintToChat(client, "'아이템갯수'는 0 보다 커야합니다!");
		
		return Plugin_Continue;
	}
	
	DDS_SimpleGiveItem(target, setitemid, setitemamount);
	
	GetClientName(target, fname, sizeof(fname));
	
	if (client <= 0)
		DDS_PrintToServer("Giving player('%s') '%d' Item('%d') is Done.", fname, setitemamount, setitemid);
	else
		DDS_PrintToChat(client, "'%s' 님에게 '%d'개의 아이템('%d')을 주었습니다.", fname, setitemamount, setitemid);
	
	DDS_PrintToChat(target, "어드민이 유저님이 소지하고 있는 아이템(ID: %d)에 변화를 주었습니다. 아이템을 참고하세요.", setitemid);
	
	return Plugin_Continue;
}