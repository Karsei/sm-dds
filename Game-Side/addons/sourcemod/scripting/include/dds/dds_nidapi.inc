/************************************************************************
 * Dynamic Dollar Shop - Native and Forward Include (Sourcemod)
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
/**
 * DDS 플러그인의 사용 유/무를 가져옵니다.
 * @return		플러그인이 켜져있다면 true, 그렇지 않으면 false.
 */
native bool:DDS_IsPluginOn();

/**
 * 유저의 금액을 가져옵니다.
 * 
 * @param client					클라이언트 인덱스
 * @return		특정 클라이언트의 금액.
 */
native DDS_GetUserMoney(client);

/**
 * 유저의 금액을 설정합니다.
 * 
 * @param client					클라이언트 인덱스
 * @param mode						처리 번호
 * (1 - 클라이언트의 현재 금액에 설정한 금액으로 맞춤, 2 - 클라이언트의 현재 금액에 설정한 금액을 더함, 3 - 클라이언트의 현재 금액에 설정한 금액을 뺌)
 * @param amount					금액
 */
native DDS_SetUserMoney(client, mode = 1, amount = 0);

/**
 * 유저의 등급을 가져옵니다.
 * 
 * @param client					클라이언트 인덱스
 * @return		특정 클라이언트의 등급.
 */
native DDS_GetUserClass(client);

/**
 * 유저의 등급을 설정합니다.
 * 
 * @param client					클라이언트 인덱스
 * @param classid					설정할 등급 번호
 */
native DDS_SetUserClass(client, classid);

/**
 * 아이템 목록을 초기화합니다.
 * 
 * @param setcount					아이템 갯수 1개 초기 설정 여부
 */
native DDS_ClearGlobalItemList(bool:setcount = true);

/**
 * DDS의 모든 SQL 데이터베이스를 체크하고 때에 따라 갱신합니다.
 */
native DDS_UpdateDatabase();

/**
 * 아이템을 추가합니다.
 *
 * @param itemname					아이템 이름
 * @param itemcode					이이템 종류 번호
 * @param itemadrs					아이템 경로 주소
 * @param itemcolor					아이템 색상
 * @param itemprice					아이템 가격
 * @param itemproc					아이템 등록 처리 방법
 * @param itempos					아이템 위치
 * @param itemang					아이템 각도
 * @param itemspecial				아이템 가치
 * @param itemtime					아이템 기간제 설정
 * @param itemoption				아이템 기타 부가 옵션
 * @param itemuse					아이템 사용 유/무
 */
native DDS_SetGlobalItemList(String:itemname[64] = DEFAULT_NAME, 
							itemcode = DEFAULT_NUM, 
							String:itemadrs[128] = DEFAULT_ADDRESS, 
							itemcolor[4] = DEFAULT_COLOR, 
							itemprice = DEFAULT_MONEY, 
							itemproc = DEFAULT_PROCESS, 
							itempos[3] = DEFAULT_POS, 
							itemang[3] = DEFAULT_ANG, 
							itemspecial = DEFAULT_SPECIAL, 
							itemtime = DEFAULT_TIME, 
							String:itemoption[64] = DEFAULT_OPTION, 
							itemuse = DEFAULT_USE);

/**
 * 새로운 아이템 종류를 추가합니다.
 *
 * @param indexid					추가할 아이템 순서 또는 종류 번호
 * @param content					추가할 아이템 종류 출력 이름
 * @param name						추가할 아이템 종류 이름
 */
native DDS_CreateGlobalItem(indexid, String:content[64], String:name[32]);

/**
 * 기존에 만들어진 특정 아이템 종류를 삭제합니다.
 *
 * @param indexid					삭제할 아이템 순서 또는 종류 번호
 */
native DDS_RemoveGlobalItem(indexid);

/**
 * 유저의 특정 아이템 종류의 옵션 설정 여부를 가져옵니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemcode					가져올 아이템 종류 번호
 * @return		특정 아이템 종류의 옵션이 켜져있다면 true, 그렇지 않다면 false.
 */
native bool:DDS_GetUserItemStatus(client, itemcode);

/**
 * 유저가 장착한 특정 아이템 종류의 아이템 ID를 가져옵니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemcode					가져올 아이템 종류 번호
 */
native DDS_GetUserItemID(client, itemcode);

/**
 * 유저가 장착할 특정 아이템 종류의 아이템 ID를 설정합니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemcode					설정할 아이템 종류 번호
 * @param itemid					설정할 아이템 번호
 */
native DDS_SetUserItemID(client, itemcode, itemid = 0);

/**
 * 유저가 장착한 특정 아이템 종류의 아이템 이름을 가져옵니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemcode					가져올 아이템 종류 번호
 * @param buffer					아이템 이름을 저장할 문자열
 * @param bufferlength				문자열 크기
 */
native DDS_GetUserItemName(client, itemcode, String:buffer[], bufferlength);

/**
 * 유저가 장착할 특정 아이템 종류의 아이템 이름을 설정합니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemcode					설정할 아이템 종류 번호
 * @param buffer					설정할 아이템 이름 문자열
 */
native DDS_SetUserItemName(client, itemcode, String:buffer[] = "");

/**
 * 달러샵에 등록된 총 아이템 갯수를 가져옵니다.
 *
 * @return		총 아이템 갯수
 */
native DDS_GetItemTotalNumber();

/**
 * 특정 아이템 종류의 사용 유/무를 가져옵니다.
 *
 * @param itemcode					가져올 아이템 종류 번호
 * @return		특정 아이템 종류를 사용할 수 있다면 true, 그렇지 않다면 false.
 */
native bool:DDS_GetItemUse(itemcode);

/**
 * 특정 아이템 종류의 이름을 가져옵니다.
 *
 * @param itemcode					가져올 아이템 종류 번호
 * @param buffer					아이템 이름을 저장할 문자열
 * @param bufferlength				문자열 크기
 */
native DDS_GetItemCodeName(itemcode, String:buffer[], bufferlength);

/**
 * 장착한 아이템의 프리캐시 번호를 가져옵니다.
 *
 * @param itemcode					대상 아이템 종류 번호
 * @param itemid					대상 아이템 번호
 * @param anydata					기타 파라메터
 */
native DDS_GetItemPrecache(itemcode, itemid, anydata = 0);

/**
 * 아이템 정보를 불러와서 특정 항목을 가져옵니다.
 *
 * @param itemid					대상 아이템 번호
 * @param select					항목 인덱스
 * @param buffer					정보가 담긴 문자열
 */
native DDS_GetItemInfo(itemid, select, String:buffer[]);

/**
 * 유저의 자유형 태그 장착 상태를 가져옵니다.
 *
 * @param client					클라이언트 인덱스
 */
native bool:DDS_GetUserFTagStatus(client);

/**
 * 유저의 자유형 태그 문자열을 가져옵니다.
 *
 * @param client					클라이언트 인덱스
 * @param buffer					문자열
 */
native DDS_GetUserFTagStr(client, String:buffer[]);

/**
 * 달러샵 메인 메뉴를 엽니다.
 *
 * @param client					클라이언트 인덱스
 */
native DDS_OpenMainMenu(client);

/**
 * DDS의 SQL 데이터베이스 핸들을 가져옵니다.
 *
 * @param sqlhd						SQL 데이터베이스 핸들
 */
native DDS_GetDatabaseHandle(&Handle:sqlhd);

/**
 * 주요 아이템 처리 시스템을 이용하여 아이템 정보를 설정합니다.
 *
 * @param client					주요 클라이언트 인덱스
 * @param target					대상 클라이언트 인덱스
 * @param proctype					시스템 처리 번호('dds_core.sp' 참고)
 * @param itemid					대상 아이템 번호
 * @param anydata					기타 파라메터
 */
native DDS_SetItemProcess(client, target, proctype, itemid, anydata);

/**
 * 간단히 유저에게 특정 갯수의 특정 아이템을 줍니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemid					대상 아이템 번호
 * @param amount					대상 아이템 갯수
 */
native DDS_SimpleGiveItem(client, itemid, amount);

/**
 * 간단히 유저로부터 특정 갯수의 특정 아이템을 제거합니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemid					대상 아이템 번호
 * @param amount					대상 아이템 갯수
 */
native DDS_SimpleRemoveItem(client, itemid, amount);

/**
 * (dds_module_tag.sp) 채팅 내용 출력 전에 호출합니다.
 *
 * @param client					클라이언트 인덱스
 * @param msg						채팅 메세지
 */
forward Action:DDS_ClientChat_Pre(client, String:msg[]);

/**
 * (dds_module_tag.sp) 채팅 내용 출력 후에 호출합니다.
 *
 * @param client					클라이언트 인덱스
 * @param msg						채팅 메세지
 */
forward DDS_ClientChat_Post(client, String:msg[]);

/**
 * 아이템 장착을 한 후에 호출합니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemcode					장착한 아이템 종류 번호
 * @param itemid					장착한 아이템 번호
 */
forward DDS_OnClientSetItem(client, itemcode, itemid);

/**
 * 아이템 구매를 한 후에 호출합니다.
 *
 * @param client					클라이언트 인덱스
 * @param itemcode					구매한 아이템 종류 번호
 * @param itemid					구매한 아이템 번호
 */
forward DDS_OnClientBuyItem(client, itemcode, itemid);