/************************************************************************
 * Dynamic Dollar Shop - [Core] Item List (Sourcemod)
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
 V A R I A B L E S
*******************************************************/
new bool:dds_bInitSet;

/*******************************************************
 P L U G I N  I N F O R M A T I O N
*******************************************************/
public Plugin:myinfo = 
{
	name = "Dynamic Dollar Shop :: [Core] Item List",
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
	DDS_PrintToServer("'Dynamic Dollar Shop :: [Core] Item List' has been loaded.");
}

public OnAllPluginsLoaded()
{
	if (DDS_IsPluginOn())
	{
		dds_bInitSet = true;
		AddItemList();
	}
}

public OnConfigsExecuted()
{
	if (DDS_IsPluginOn())
	{
		if (dds_bInitSet)
			AddItemList();
	}
}

/*******************************************************
 G E N E R A L   F U N C T I O N S
*******************************************************/
public AddItemList()
{
	// 아이템 리스트 초기화
	DDS_ClearGlobalItemList(true);
	
	/********************************************************************
	
	 - 아이템 생성 부분 -
	
	반드시 DDS_SetGlobalItemList 을 추가할 때에는 항상 뒤쪽에 추가할 것!!!
	(중간에 추가하거나 빼면 데이터베이스가 엇갈리기 때문에 유저들이 소지하고 있는 것이 바뀌게 되는
	끔직한 상황이 발생할 수도 있습니다. 하여간에 순서만 뒤틀리지만 않으면 됩니다.)
	
	첫번째 - 아이템 이름.
	두번째 - 아이템 종류 번호. (1 = 트레일, 
								2 = 테러스킨, 
								3 = 대테러스킨, 
								4 = 레이저, 
								5 = 이펙트 슈즈, 
								6 = 태그, 
								7 = 버블, 
								8 = 조명, 
								9 = 플래시, 
								10 = 레이저 포인트, 
								11 = 파티클, 
								12 = 타이틀, 
								13 = 칼 스킨, 
								14 = 모자, 
								15 = 날개, 
								16 = 애완동물)
	세번째 - 주로 경로 설정이 필요한 아이템(태그와 플래시는 아님).
			 트레일은 materials/trails 에 있는 파일의 이름만 적으세요.
			 칼 스킨은 아래와 같이 해주세요.
			 (예시: 'model/weapons/test/v_example.mdl', 'model/weapons/test/w_example.mdl' 이렇게 파일 2개가 있다면
			 'model/weapons/test/#_example' <- 이렇게 적어주세요.)
			 그 외 나머지는 경로를 다 적되, 확장자는 적지 마세요.
			 
	네번째 - 색상 설정(색상 순서는 Red Blue Green Alpha). 
			 레이저 총알과 이펙트 슈즈에 사용되며 그 외의 아이템은 DEFAULT_COLOR 으로 설정하면 됩니다.
	다섯번째 - 해당 아이템 가격. 0으로 설정시 무료로 살 수 있게 됩니다.
	여섯번째 - 아이템 등록 처리 방법.
	일곱번째 - 위치 설정(모자, 날개만 해당).
	여덟번째 - 각도 설정(모자, 날개만 해당).
	아홉번째 - 특별 아이템 설정(0 - 일반, 1 - 특별, 2 - 한정).
	열번째 - 기간제 아이템 설정(-1 - 일회용, 0 - 영구, [분단위시간] - 기간).
	열한번째 - 기타 부가 옵션 설정.
	열두번째 - 아이템 사용 유/무(0 - 이용안함, 1 - 이용함).
	
	 - 참고 사항 -
	
	열한번째인 기타 부가 옵션 설정은 각 아이템 종류에 따른 기타 옵션입니다.
	현재 태그와 애완동물만 지원하고 있습니다.
	
	태그 -> 'freetag' 를 넣으면 일회용 자유 태그로 구분되어집니다. 하나만 해주는게 좋습니다.
	애완동물 -> 기본 행동 애니메이션을 정합니다. 기본적으로 idle로 설정되어집니다.
	
	********************************************************************/
	DDS_SetGlobalItemList("큰별", 1, "star", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("무지개", 1, "rainbow", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("마리오", 1, "mario", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("돈", 1, "money", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("버섯", 1, "mushroom", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("햄버거", 1, "burger", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("하루히", 1, "haruhi_suzumiya", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("커피", 1, "coffee2", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("별들", 1, "stars", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("LOL", 1, "lol", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("화난표정", 1, "angry", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("졸라맨", 1, "aol", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("사과", 1, "apple", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("화살표", 1, "arrow", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("웃는얼굴", 1, "awesomeface", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("거품", 1, "bubbles", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("분홍색곰", 1, "carebear", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("키마이라", 1, "chimaira", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("크롬", 1, "chrome", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("CS:S", 1, "css", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("DOD:S", 1, "dods", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("점들", 1, "dots", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("부활절달걀", 1, "easteregg", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파이어버드", 1, "firebird", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파이어폭스", 1, "firefox", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("발자국", 1, "footprint", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("굼바", 1, "goomba", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("장애인표시", 1, "handy", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("스마일", 1, "happy", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("HL2", 1, "hl2", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("코나타", 1, "konata", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("리눅스", 1, "linux", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("하트", 1, "love", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("루이지", 1, "luigi", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("피카츄", 1, "pikachu", DEFAULT_COLOR, 100, 2, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("흰곰돌이T", 2, "models/player/whitebear/whitebear", DEFAULT_COLOR, 100, 5, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("흰곰돌이CT", 3, "models/player/whitebear/whitebear", DEFAULT_COLOR, 100, 5, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("빨간색", 4, "materials/sprites/laser", {255, 0, 0, 255}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("주황색", 4, "materials/sprites/laser", {255, 108, 0, 200}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("노란색", 4, "materials/sprites/laser", {255, 242, 0, 200}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("초록색", 4, "materials/sprites/laser", {0, 255, 0, 255}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파란색", 4, "materials/sprites/laser", {0, 0, 255, 255}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("보라색", 4, "materials/sprites/laser", {134, 0, 255, 200}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("플라즈마", 4, "materials/sprites/plasma", {255, 255, 255, 255}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("크리스탈", 4, "materials/sprites/tp_beam001", {255, 255, 255, 255}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("빨간색", 5, "materials/sprites/laser", {255, 0, 0, 255}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("주황색", 5, "materials/sprites/laser", {255, 108, 0, 200}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("노란색", 5, "materials/sprites/laser", {255, 242, 0, 200}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("초록색", 5, "materials/sprites/laser", {0, 255, 0, 255}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파란색", 5, "materials/sprites/laser", {0, 0, 255, 255}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("보라색", 5, "materials/sprites/laser", {134, 0, 255, 200}, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("일회용 자유 태그", 6, DEFAULT_ADDRESS, DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, -1, "freetag", DEFAULT_USE);
	DDS_SetGlobalItemList("잉여", 6, DEFAULT_ADDRESS, DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("가나다", 6, DEFAULT_ADDRESS, DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("빨간색", 7, "materials/sprites/combineball_glow_red_1", DEFAULT_COLOR, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파란색", 7, "materials/sprites/combineball_glow_blue_1", DEFAULT_COLOR, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("검정색", 7, "materials/sprites/combineball_glow_black_1", DEFAULT_COLOR, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("검은구슬", 7, "materials/sprites/strider_blackball", DEFAULT_COLOR, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("거품", 7, "materials/sprites/bubble", DEFAULT_COLOR, 100, 3, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("빨간색", 8, "materials/sprites/redglow1", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("밝은 빨간색", 8, "materials/sprites/redglow4", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파란색", 8, "materials/sprites/blueglow1", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("초록색", 8, "materials/sprites/greenglow1", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("빨간색", 9, DEFAULT_ADDRESS, {255, 0, 0, 255}, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("주황색", 9, DEFAULT_ADDRESS, {255, 108, 0, 200}, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("노란색", 9, DEFAULT_ADDRESS, {255, 242, 0, 200}, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("초록색", 9, DEFAULT_ADDRESS, {0, 255, 0, 255}, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파란색", 9, DEFAULT_ADDRESS, {0, 0, 255, 255}, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("보라색", 9, DEFAULT_ADDRESS, {134, 0, 255, 200}, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("빨간색", 10, "materials/sprites/redglow1", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("주황색", 10, "materials/sprites/orangeglow1", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("노란색", 10, "materials/sprites/yellowglow1", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("초록색", 10, "materials/sprites/greenglow1", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파란색", 10, "materials/sprites/blueglow1", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("하얀색", 10, "materials/sprites/light_glow01", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("커서", 10, "materials/sprites/arrow", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("불빛", 11, "fire_medium_01_glow", DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("불꽃", 11, "burning_wood_01b", DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("불잔상", 11, "embers_small_01", DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("물 파동", 11, "water_trail_medium", DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("물 거품", 11, "water_splash_02_froth2", DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("물 튀김", 11, "water_splash_02_vertical", DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("타이틀1", 12, "materials/sprites/strider_blackball", DEFAULT_COLOR, 100, 1, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("돌덩이", 13, "models/weapons/rabi/#_rock", DEFAULT_COLOR, 100, 6, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("악마 마우스", 14, "models/hats/deadmau5/deadmau5", DEFAULT_COLOR, 100, 4, {0, 1, 3}, {-9, -87, -104}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("개발팀", 14, "models/hats/devteamhat/devteamhat", DEFAULT_COLOR, 100, 4, {0, 0, 6}, {0, -98, -88}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("멧돼지 마스크", 14, "models/hats/adept/adept", DEFAULT_COLOR, 100, 4, {2, 0, -7}, {-6, -89, 87}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("아메리칸", 14, "models/hats/americahat/americahat", DEFAULT_COLOR, 100, 4, {0, 0, 6}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("사슴뿔", 14, "models/hats/antlers/antlers", DEFAULT_COLOR, 100, 4, {3, 0, 7}, {2, 95, 2}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("우주복 헬멧", 14, "models/hats/astronauthelmet/astronauthelmet", DEFAULT_COLOR, 100, 4, {-2, -1, -4}, {4, 100, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("맥주", 14, "models/hats/beerhat/beerhat", DEFAULT_COLOR, 100, 4, {-1, 0, 7}, {1, -88, 1}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("토끼 머리띠", 14, "models/hats/bunnyears/bunnyears", DEFAULT_COLOR, 100, 4, {0, 0, 9}, {2, -95, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("케이크", 14, "models/hats/cakehat/cakehat", DEFAULT_COLOR, 100, 4, {1, 0, 6}, {1, 95, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("선장", 14, "models/hats/captainshat/captainshat", DEFAULT_COLOR, 100, 4, {-1, 0, 6}, {2, -29, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("치즈", 14, "models/hats/CheeseHat/cheesehat", DEFAULT_COLOR, 100, 4, {-3, 0, 10}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("삐애로 가면", 14, "models/hats/clownmask/clownmask", DEFAULT_COLOR, 100, 4, {0, 1, -8}, {0, 180, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("용의 투구", 14, "models/hats/dragonscale/dragonscale", DEFAULT_COLOR, 100, 4, {-1, 0, 12}, {0, -82, 65}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("소다 드링크", 14, "models/hats/drinkcap/drinkcap", DEFAULT_COLOR, 100, 4, {-1, 0, 7}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("꼬깔", 14, "models/hats/duncehat/duncehat", DEFAULT_COLOR, 100, 4, {-1, 0, 5}, {0, 90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("눈깔", 14, "models/hats/eyebothelm/eyebothelm", DEFAULT_COLOR, 100, 4, {-3, 0, -5}, {0, 180, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("종이가방", 14, "models/hats/paperbag/paperbag", DEFAULT_COLOR, 100, 4, {1, 0, -3}, {0, -90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("젤리", 14, "models/hats/flan/flan", DEFAULT_COLOR, 100, 4, {-3, 0, 1}, {10, 0, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("오징어", 14, "models/hats/squid/squid", DEFAULT_COLOR, 100, 4, {2, 0, 0}, {0, 90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("마나피", 14, "models/hats/manaphy/manaphy", DEFAULT_COLOR, 100, 4, {1, 0, 11}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("헤드크랩", 14, "models/hats/headcrab/w_headcrab", DEFAULT_COLOR, 100, 4, {-2, 0, 0}, {80, 180, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("농장", 14, "models/hats/farmhat/farmhat", DEFAULT_COLOR, 100, 4, {-2, 0, 8}, {0, -1, -6}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("게이 경찰", 14, "models/hats/gaypolicehat/gaypolicehat", DEFAULT_COLOR, 100, 4, {-1, 0, 7}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("풀", 14, "models/hats/glass/glass", DEFAULT_COLOR, 100, 4, {0, 0, 3}, {0, 96, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("GTA 바이크 헬멧", 14, "models/hats/gtaiv/gtaiv", DEFAULT_COLOR, 100, 4, {-2, 0, 4}, {0, -90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("천사링", 14, "models/hats/Halo/halo", DEFAULT_COLOR, 100, 4, {-1, 0, 11}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("로봇 헬멧", 14, "models/hats/helmet2/helmet2", DEFAULT_COLOR, 100, 4, {0, 0, 3}, {0, -90, 90}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("영국 신사", 14, "models/hats/highhat/highhat", DEFAULT_COLOR, 100, 4, {-1, 0, 7}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("성기사 투구", 14, "models/hats/imperial/imperial", DEFAULT_COLOR, 100, 4, {-1, 0, 3}, {0, -90, 90}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("야만인 가면", 14, "models/hats/indoril/indoril", DEFAULT_COLOR, 100, 4, {3, 0, 3}, {-10, -90, 90}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("KFC", 14, "models/hats/kfchat/kfchat", DEFAULT_COLOR, 100, 4, {-2, 0, 9}, {90, 0, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("카우보이", 14, "models/hats/lucassimmshat/lucassimmshat", DEFAULT_COLOR, 100, 4, {-2, 0, 2}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("군인", 14, "models/hats/M1Helmet/M1Helmet", DEFAULT_COLOR, 100, 4, {-2, 0, 7}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("마조라 마스크", 14, "models/hats/majoramask/majoramask", DEFAULT_COLOR, 100, 4, {-1, 0, 4}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("마리오", 14, "models/hats/mariohat/mariohat", DEFAULT_COLOR, 100, 4, {-1, 0, 6}, {0, -90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("달", 14, "models/hats/Mmoon2head/Mmoon2head", DEFAULT_COLOR, 100, 4, {-1, 0, 6}, {-6, 89, -41}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("버섯", 14, "models/hats/mushroom/mushroom", DEFAULT_COLOR, 100, 4, {-2, 0, 5}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("노르딕", 14, "models/hats/nordic/nordic", DEFAULT_COLOR, 100, 4, {-3, 0, 5}, {0, -90, 90}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("사무라이", 14, "models/hats/orcish/orcish", DEFAULT_COLOR, 100, 4, {0, 0, 5}, {0, -90, 90}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파티", 14, "models/hats/partyhat/partyhat", DEFAULT_COLOR, 100, 4, {-1, 0, 8}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파티2", 14, "models/hats/partyhat2/partyhat2", DEFAULT_COLOR, 100, 4, {-1, 0, 8}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("독일군", 14, "models/hats/pickelhaube/pickelhaube", DEFAULT_COLOR, 100, 4, {-3, 0, 7}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("해적 선장", 14, "models/hats/piratehat/piratehat", DEFAULT_COLOR, 100, 4, {-1, 0, 4}, {0, -75, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("경찰", 14, "models/hats/policehat/policehat", DEFAULT_COLOR, 100, 4, {-2, 0, 7}, {0, -90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("프로펠러", 14, "models/hats/propellerhat/propellerhat", DEFAULT_COLOR, 100, 4, {-2, 0, 8}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("할로윈", 14, "models/hats/pumpkin/pumpkin", DEFAULT_COLOR, 100, 4, {-2, -1, -2}, {0, 0, -10}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("밀집", 14, "models/hats/salesmanhat/salesmanhat", DEFAULT_COLOR, 100, 4, {-1, 0, 7}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("산타", 14, "models/hats/santahat/santahat", DEFAULT_COLOR, 100, 4, {-1, 0, 6}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("썬켑", 14, "models/hats/solarthing/solarthing", DEFAULT_COLOR, 100, 4, {1, 0, 5}, {0, -90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("멕시코", 14, "models/hats/sombrero/sombrero", DEFAULT_COLOR, 100, 4, {-2, 0, 7}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("학사모", 14, "models/hats/studenthat/studenthat", DEFAULT_COLOR, 100, 4, {-1, 0, 8}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("기사 투구", 14, "models/hats/templar/templar", DEFAULT_COLOR, 100, 4, {-1, 0, 3}, {0, -90, 90}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("피카츄", 14, "models/hats/ttg_max/ttg_max", DEFAULT_COLOR, 100, 4, {-6, 0, -69}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("바이킹", 14, "models/hats/vikinghelmet/vikinghelmet", DEFAULT_COLOR, 100, 4, {-1, 0, 7}, {0, -90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("파나마", 14, "models/hats/viroshat/viroshat", DEFAULT_COLOR, 100, 4, {-1, 0, 8}, {6, 0, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("날개달린 투구", 14, "models/hats/wingedhelmet/wingedhelmet", DEFAULT_COLOR, 100, 4, {2, 0, -69}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("WTF", 14, "models/hats/wtf/wtf", DEFAULT_COLOR, 100, 4, {-1, 0, 5}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("자쿠", 14, "models/hats/zaku/zaku", DEFAULT_COLOR, 100, 4, {-2, 1, 0}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("저커", 14, "models/hats/zerker/zerker", DEFAULT_COLOR, 100, 4, {-1, 0, -7}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("천사의 날개", 15, "models/player/konata/wing/wing", DEFAULT_COLOR, 100, 4, {0, 0, -100}, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	DDS_SetGlobalItemList("미니 날개", 15, "models/player/konata/wing/nestwing", DEFAULT_COLOR, 100, 4, {0, 0, -65}, {0, 90, 0}, DEFAULT_SPECIAL, DEFAULT_TIME, DEFAULT_OPTION, DEFAULT_USE);
	
	DDS_SetGlobalItemList("갈매기", 16, "models/seagull", DEFAULT_COLOR, 100, 4, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, 2, "Fly", DEFAULT_USE);
	DDS_SetGlobalItemList("비둘기", 16, "models/pigeon", DEFAULT_COLOR, 100, 4, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, "Fly01", DEFAULT_USE);
	DDS_SetGlobalItemList("까마귀", 16, "models/crow", DEFAULT_COLOR, 100, 4, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, DEFAULT_TIME, "Fly01", DEFAULT_USE);
	
	DDS_SetGlobalItemList("마법의 복권", 17, DEFAULT_ADDRESS, DEFAULT_COLOR, 100, DEFAULT_PROCESS, DEFAULT_POS, DEFAULT_ANG, DEFAULT_SPECIAL, -1, DEFAULT_OPTION, DEFAULT_USE);
	
	// 데이터베이스 칼럼 체크 및 동기화
	DDS_UpdateDatabase();
}