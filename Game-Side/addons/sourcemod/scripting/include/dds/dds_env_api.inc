/************************************************************************
 * Dynamic Dollar Shop - MAIN INCLUDE :: ENV API LIST (Sourcemod)
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
 * @brief	DDS 플러그인의 활성화 유무를 가져옵니다.
 *			'dds_switch_plugin' Convar에 의하여 결정됩니다.
 *
 * @return	DDS 플러그인이 활성화되었다면 true, 그렇지 않다면 false
 */
native bool DDS_IsPluginOn();

/**
 * @brief	DDS 플러그인의 SQL 활성화 유무를 가져옵니다.
 *			SQL 데이터베이스가 성공적으로 연결되고, 필요 정보까지 다 불러왔다면 활성화됩니다.
 *
 * @return	서버측 SQL 데이터베이스가 활성화되었다면 true, 그렇지 않다면 false
 */
native bool DDS_GetServerSQLStatus();

/**
 * @brief	클라이언트 별 SQL 활성화 유무를 가져옵니다.
 *			클라이언트가 접속하여 초반 필요 정보들을 성공적으로 불러왔다면 활성화됩니다.
 *
 * @param client				클라이언트 인덱스
 * @return	클라이언트 SQL 데이터베이스가 활성화되었다면 true, 그렇지 않다면 false
 */
native bool DDS_GetClientSQLStatus(client);

/**
 * @brief	DDS 플러그인에 아이템 종류 플러그인을 연결합니다.
 *			연결하여 사용하면 데이터베이스에 등록되어 있는 모든 아이템 종류 코드와 비교하여
 *			등록되어 있으면 활성화되며 쓸 수 있게 됩니다.
 *			참고로, 이 함수는 'OnLibraryAdded("dds_core")'' 포워드 함수를 이용하여 쓰는 것이 좋습니다.
 *
 * @param catecode				아이템 종류 코드
 */
native void DDS_CreateItemCategory(int catecode);

/**
 * @brief	DDS 플러그인에 연결된 아이템 종류 플러그인이 제대로 등록되었는지 상태를 반환합니다.
 *
 * @param catecode				아이템 종류 코드
 * @return	정상적으로 등록되었다면 true, 그렇지 않다면 false
 */
native bool DDS_GetItemCategoryStatus(int catecode);

/**
 * @brief	DDS 플러그인에 등록된 아이템 정보를 가져옵니다.
 *			등록된 아이템 정보는 SQL 데이터베이스에서 가져오게 되며 코어에서 필터링을 거쳐 최종적으로 등록됩니다.
 *			이 함수는 최종적으로 등록된 아이템 정보를 가져 옵니다.
 *
 * @param itemidx				아이템 번호
 * @return	정상적으로 등록되었다면 true, 그렇지 않다면 false
 */
//native bool DDS_GetItemInfo(int itemidx);

/**
 * @brief	클라이언트가 가지고 있는 금액을 가져옵니다.
 *
 * @param client				클라이언트 인덱스
 * @return	클라이언트의 금액, 실패 시 -1 반환
 */
native int DDS_GetClientMoney(int client);

/**
 * @brief	클라이언트가 현재 장착한 아이템의 데이터베이스 번호를 가져옵니다.
 *
 * @param client				클라이언트 인덱스
 * @param catecode				아이템 종류 코드
 * @return	클라이언트가 현재 장착한 데이터베이스 번호, 실패 시 -1 반환
 */
native int DDS_GetClientAppliedDB(int client, int catecode);

/**
 * @brief	클라이언트가 현재 장착한 아이템 번호를 가져옵니다.
 *
 * @param client				클라이언트 인덱스
 * @param catecode				아이템 종류 코드
 * @return	클라이언트가 현재 장착한 아이템 번호, 실패 시 -1 반환
 */
native int DDS_GetClientAppliedItem(int client, int catecode);

/**
 * @brief	DDS 플러그인에서 SQL 데이터베이스로부터 모든 아이템 종류를 불러오고 난 후에 발생합니다.
 *			코어에서 데이터베이스로부터 아이템 종류를 등록한 뒤에 무언가를 해야할 때 쓰시면 좋습니다.
 */
forward void DDS_OnLoadSQLItemCategory();

/**
 * @brief	DDS 플러그인에서 클라이언트가 데이터를 전달할 무언가를 할 때 발생합니다.
 *			예를 들면 아이템을 사거나 버리거나 금액을 얻는 등의 행동을 할 때 발생합니다.
 *
 * @param client				클라이언트 인덱스
 * @param process				행동 구별
 * @param data					추가 파라메터
 */
forward void DDS_OnDataProcess(int client, const char[] process, const char[] data);