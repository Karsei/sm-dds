/************************************************************************
 * Dynamic Dollar Shop - [Module] Lotto (Sourcemod)
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
 D E F I N E S
*******************************************************/
#define LOTTOID							17

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Module] Lotto",
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
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Module] Lotto' has been loaded.");
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
		DDS_CreateGlobalItem(LOTTOID, "복권", "lotto");
}

/* 아이템 장착 후에 처리할 작업 */
public DDS_OnClientSetItem(client, itemcode, itemid)
{
	if (DDS_IsPluginOn())
	{
		if (IsClientInGame(client))
		{
			if (itemcode == LOTTOID)
			{
				DoLotto(client);
			}
		}
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
public DoLotto(client)
{
	DDS_PrintToChat(client, "복권을 긁고 있습니다...");
	
	new Float:setmin = 0.0, Float:setmax = 10000.0;
	new Float:ranfloat, Float:ranper;
	
	ranfloat = GetRandomFloat(setmin, setmax);
	ranper = (ranfloat / setmax) * 100.0;
	
	new itemtotal = DDS_GetItemTotalNumber();
	
	if (ranper <= 80.0) // 확률이 80.0% 일 때
	{
		if (itemtotal < 1)
		{
			DDS_PrintToChat(client, "달러샵에 등록된 아이템이 부족하여 아이템을 얻지 못했습니다.");
			return;
		}
		
		new ranitemid = GetRandomInt(1, itemtotal);
		new String:itemname[32], String:tempcodestr[8], String:itemcodename[32];
		
		DDS_GetItemInfo(ranitemid, 1, itemname);
		DDS_GetItemInfo(ranitemid, 2, tempcodestr);
		DDS_GetItemCodeName(StringToInt(tempcodestr), itemcodename, sizeof(itemcodename));
		
		DDS_SimpleGiveItem(client, ranitemid, 1);
		
		DDS_PrintToChat(client, "'[%s] %s'을(를) 얻었습니다!", itemcodename, itemname);
	}
	else
	{
		DDS_PrintToChat(client, "꽝!");
	}
}