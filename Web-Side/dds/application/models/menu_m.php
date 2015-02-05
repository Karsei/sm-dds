<?php

class Menu_m extends CI_Model {
	
	function __construct()
	{
		parent::__construct();
	}

	function GetMenu()
	{
		$menuList = array(
			array("홈", "home", "fa-home", 0),
			array("내 정보", "myinfo", "fa-user", 0),
			array("아이템 구매", "buy", "fa-shopping-cart", 0),
			array("관리", "admin", "fa-cog", 1),
			array("로그아웃", "auth/logout", "fa-user-times", 0)
		);

		return $menuList;
	}

	function CreateMenu($focus)
	{
		$rval = '';
		for ($i = 0; $i < count($this->GetMenu()); $i++) {
			// 관리자용은 일단 패스
			//if ($this->GetMenu()[$i][2] == 1)	continue;

			// 클래스 처리
			$classSet = '';

			// 현재 있는 페이지 포커스
			if (strcmp($this->GetMenu()[$i][0], $focus) == 0) {
				$classSet .= 'focus';
			}

			// 적용
			if ($classSet) {
				$rval .= '<li class="' . $classSet . '">';
			} else {
				$rval .= '<li>';
			}
			$rval .= '<a href="' . base_url() . $this->GetMenu()[$i][1] . '"><i class="fa ' . $this->GetMenu()[$i][2] . ' fa-fw"></i>&nbsp; ' . $this->GetMenu()[$i][0] . '</a></li>';
		}

		return $rval;
	}

	function GetIcon($focus)
	{
		$rval = '';
		for ($i = 0; $i < count($this->GetMenu()); $i++) {
			// 구하고자 하는 페이지가 아니면 패스
			if (strcmp($this->GetMenu()[$i][0], $focus) != 0)	continue;

			// 추출
			$rval = $this->GetMenu()[$i][2];
		}
		return $rval;
	}
}

?>