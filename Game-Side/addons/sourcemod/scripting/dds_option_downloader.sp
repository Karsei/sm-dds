/************************************************************************
 * Dynamic Dollar Shop - [Option] Downloader (Sourcemod)
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
	Handle:HDOWNLOADERDBGSWITCH
}

/*******************************************************
 V A R I A B L E S
*******************************************************/
// Cvar 핸들
new dds_eConvar[CONVAR];

// 다운로더 관련
new Handle:dds_sDownConfigFile = INVALID_HANDLE;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Option] Downloader",
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
	dds_eConvar[HDOWNLOADERDBGSWITCH] = CreateConVar("dds_switch_down_dbg", "0", "자체 탑재된 다운로더를 사용할 때 디버그를 출력할지에 대한 여부입니다. 작동을 원하지 않으시다면 0을, 원하신다면 1을 써주세요.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Option] Downloader' has been loaded.");
}

public OnConfigsExecuted()
{
	if (DDS_IsPluginOn())
	{
		// 다운로더 파일 열기
		dds_sDownConfigFile = OpenFile("./addons/sourcemod/configs/dds_downloader.ini", "r");
		if (dds_sDownConfigFile == INVALID_HANDLE)
		{
			DDS_PrintToServer("configs/dds_downloader.ini is not loadable!");
		}
		else
		{
			new String:line[512];
			
			while (ReadFileLine(dds_sDownConfigFile, line, sizeof(line)))
			{
				TrimString(line);
				
				// 세미콜론(주석 처리)을 제외한 라인 로드
				if ((StrContains(line, ";") == -1) && (strlen(line) > 0))
					SetFileToDownloadTable(line);
			}
		}
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
/* 다운로더 파일 처리 함수 */
public SetFileToDownloadTable(const String:dir[])
{
	new Handle:curdir = OpenDirectory(dir);
	new String:filename[64], String:setdir[256], FileType:type;
	
	if (curdir != INVALID_HANDLE)
	{
		// 해당 경로 조사
		while (ReadDirEntry(curdir, filename, sizeof(filename), type))
		{
			if (type == FileType_Directory) // 폴더인 경우
			{
				// 폴더인 경우는 한번 더 조사
				if (FindCharInString(filename, '.', false) == -1)
				{
					Format(setdir, sizeof(setdir), "%s/%s", dir, filename);
					SetFileToDownloadTable(setdir);
				}
			}
			else if (type == FileType_File) // 파일인 경우
			{
				// 파일인 경우는 다운로드 테이블에 등록
				if (GetConVarBool(dds_eConvar[HDOWNLOADERDBGSWITCH]))
					DDS_PrintDebugMsg(0, false, "Adding this File to Download Tables (%s)...", filename);
				
				Format(setdir, sizeof(setdir), "%s/%s", dir, filename);
				AddFileToDownloadsTable(setdir);
			}
		}
		CloseHandle(curdir);
		curdir = INVALID_HANDLE;
	}
	else
	{
		DDS_PrintToServer("Adding to Download table is Failed: %s", dir);
	}
}