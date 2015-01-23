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