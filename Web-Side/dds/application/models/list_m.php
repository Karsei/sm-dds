<?php

class List_m extends CI_Model {
	
	function __construct()
	{
		parent::__construct();
	}

	function GetList($type, $limitc, $limitidx, $authid, $numcheck = false)
	{
		if (strcmp($type, 'inven') == 0)
		{
			/*********************************************
			 * [내 정보 - 인벤토리 목록]
			 * 후에 총 6개 필드
			**********************************************/
			/*
			SELECT dds_user_item.idx, dds_item_list.icidx, dds_item_category.gloname AS icname, dds_item_list.gloname AS ilname, dds_user_item.buydate, dds_user_item.aplied
			FROM `dds_user_item` 
			LEFT JOIN `dds_item_list` ON `dds_user_item`.`ilidx` = `dds_item_list`.`ilidx` 
			LEFT JOIN `dds_item_category` ON `dds_item_category`.`icidx` = `dds_item_list`.`icidx` 
			WHERE `dds_item_category`.`status` = '1' 
			ORDER BY `dds_user_item`.`ilidx` ASC;
			*/
			$this->db->select('dds_user_item.idx, dds_item_list.icidx, dds_item_category.gloname AS icname, dds_item_list.gloname AS ilname, dds_user_item.buydate, dds_user_item.aplied');
			$this->db->join('dds_item_list', 'dds_user_item.ilidx = dds_item_list.ilidx', 'left');
			$this->db->join('dds_item_category', 'dds_item_category.icidx = dds_item_list.icidx', 'left');
			$this->db->where(array('dds_item_category.status' => '1', 'dds_user_item.authid' => $authid));
			$this->db->order_by('dds_user_item.idx', 'ASC');
			// Limit 거꾸로임 ㄱ-
			if (!$numcheck)	$this->db->limit($limitidx, $limitc);
			$q = $this->db->get('dds_user_item');

			// 갯수 파악 또는 결과
			if ($numcheck)
				return $q->num_rows();
			else
				return $q->result_array();
		}
		else if (strcmp($type, 'buy') == 0)
		{
			/*********************************************
			 * [아이템 구입 - 목록]
			 * 후에 총 6개 필드
			**********************************************/
			/*
			SELECT dds_item_category.gloname AS icname, dds_item_list.ilidx, dds_item_list.gloname AS itname, dds_item_list.money, dds_item_list.havtime 
			FROM `dds_item_category` 
			LEFT JOIN `dds_item_list` ON `dds_item_category`.`icidx` = `dds_item_list`.`icidx` 
			WHERE `dds_item_list`.`status` = '1' AND `dds_item_category`.`status` = '1' 
			ORDER BY `dds_item_list`.`ilidx` ASC;
			*/
			$this->db->select('dds_item_category.gloname AS icname, dds_item_list.ilidx, dds_item_list.gloname AS itname, dds_item_list.money, dds_item_list.havtime');
			$this->db->join('dds_item_list', 'dds_item_category.icidx = dds_item_list.icidx', 'left');
			$this->db->where(array('dds_item_list.status' => '1', 'dds_item_category.status' => '1'));
			$this->db->order_by('dds_item_list.ilidx', 'ASC');
			// Limit 거꾸로임 ㄱ-
			if (!$numcheck)	$this->db->limit($limitidx, $limitc);
			$q = $this->db->get('dds_item_category');

			// 갯수 파악 또는 결과
			if ($numcheck)
				return $q->num_rows();
			else
				return $q->result_array();
		}
		else if (strcmp($type, 'usrlist') == 0)
		{
			/*********************************************
			 * [유저 관리 - 목록]
			 * 후에 총 5개 필드
			**********************************************/
			/*
			SELECT * 
			FROM `dds_user_profile` 
			ORDER BY `idx` DESC;
			*/
			$this->db->order_by('idx', 'DESC');
			// Limit 거꾸로임 ㄱ-
			if (!$numcheck)	$this->db->limit($limitidx, $limitc);
			$q = $this->db->get('dds_user_profile');

			// 갯수 파악 또는 결과
			if ($numcheck)
				return $q->num_rows();
			else
				return $q->result_array();
		}
		else if (strcmp($type, 'itemlist') == 0)
		{
			/*********************************************
			 * [아이템 관리 - 목록]
			 * 후에 총 7개 필드
			**********************************************/
			$this->db->select('dds_item_list.ilidx, dds_item_list.icidx, dds_item_category.gloname AS icname, dds_item_list.gloname AS itname, dds_item_list.money, dds_item_list.havtime, dds_item_list.env, dds_item_list.status');
			$this->db->join('dds_item_category', 'dds_item_category.icidx = dds_item_list.icidx', 'left');
			$this->db->order_by('ilidx', 'DESC');
			// Limit 거꾸로임 ㄱ-
			if (!$numcheck)	$this->db->limit($limitidx, $limitc);
			$q = $this->db->get('dds_item_list');

			// 갯수 파악 또는 결과
			if ($numcheck)
				return $q->num_rows();
			else
				return $q->result_array();
		}
		else if (strcmp($type, 'itemcglist') == 0)
		{
			/*********************************************
			 * [아이템 종류 관리 - 목록]
			 * 후에 총 5개 필드
			**********************************************/
			/*
			SELECT * 
			FROM `dds_item_category` 
			ORDER BY `icidx` DESC;
			*/
			$this->db->order_by('icidx', 'DESC');
			// Limit 거꾸로임 ㄱ-
			if (!$numcheck)	$this->db->limit($limitidx, $limitc);
			$q = $this->db->get('dds_item_category');

			// 갯수 파악 또는 결과
			if ($numcheck)
				return $q->num_rows();
			else
				return $q->result_array();
		}
		else if (strcmp($type, 'dataloglist') == 0)
		{
			/*********************************************
			 * [데이터 로그 관리 - 목록]
			 * 후에 총 6개 필드
			**********************************************/
			/*
			SELECT * 
			FROM `dds_log_data` 
			ORDER BY `idx` DESC;
			*/
			$this->db->order_by('idx', 'DESC');
			// Limit 거꾸로임 ㄱ-
			if (!$numcheck)	$this->db->limit($limitidx, $limitc);
			$q = $this->db->get('dds_log_data');

			// 갯수 파악 또는 결과
			if ($numcheck)
				return $q->num_rows();
			else
				return $q->result_array();
		}
	}

	function SetList($type, $oidx, $tidx, $authid)
	{
		// 유저 프로필 로드
		$this->db->where('dds_user_profile.authid', $authid);
		$q = $this->db->get('dds_user_profile');
		$usrProfile = $q->result_array();

		$usr_Money = intval($usrProfile[0]['money']);
		$usr_pInGame = intval($usrProfile[0]['ingame']);

		// 게임 내에 있으면 동작 못하게 처리
		if ($usr_pInGame == 1)
		{
			return json_encode(array('result' => false, 'title' => 'msg_title_notice', 'msg' => 'msg_results_nogame'));
		}

		// 행동 구분
		if (strcmp($type, 'item-apply') == 0)
		{
			// 우선 해당 아이템과 같은 종류의 장착 아이템을 모두 장착 해제 시킨다.
			$qready = "UPDATE `dds_user_item` LEFT JOIN `dds_item_list` ON `dds_user_item`.`ilidx` = `dds_item_list`.`ilidx` SET `dds_user_item`.`aplied` = '0' WHERE `dds_user_item`.`authid` = '" . $authid . "' AND `dds_item_list`.`icidx` = '" . $tidx . "' AND `dds_user_item`.`aplied` = '1'";
			$this->db->query($qready);

			// 그리고 장착 처리
			$qready = "UPDATE `dds_user_item` SET `dds_user_item`.`aplied` = '1' WHERE `dds_user_item`.`authid` = '" . $authid . "' AND `dds_user_item`.`idx` = '" . $oidx . "'";
			$this->db->query($qready);
		}
		else if (strcmp($type, 'item-applycancel') == 0)
		{
			// 그리고 장착해제 처리
			$qready = "UPDATE `dds_user_item` SET `dds_user_item`.`aplied` = '0' WHERE `dds_user_item`.`authid` = '" . $authid . "' AND `dds_user_item`.`idx` = '" . $oidx . "'";
			$this->db->query($qready);
		}
		else if (strcmp($type, 'item-drop') == 0)
		{
			$setdata = array(
				'dds_user_item.authid' => $authid,
				'dds_user_item.idx' => $oidx // 아이템 번호가 아닌 데이터베이스 번호(간.소.화)
			);
			$this->db->where($setdata);
			$this->db->delete('dds_user_item');
		}
		else if (strcmp($type, 'item-buy') == 0)
		{
			// 우선 아이템 금액 확인 후 금액 조건 확인
			$this->db->select('dds_item_list.ilidx, dds_item_list.money, dds_item_list.gloname AS ilname');
			$this->db->where('dds_item_list.ilidx', $oidx);
			$sq = $this->db->get('dds_item_list');
			$sqc = $sq->result_array();
			if (intval($sqc[0]['money']) > $usr_Money)
			{
				return json_encode(array('result' => false, 'title' => 'msg_title_notice', 'msg' => 'msg_results_moneymore'));
			}

			// 금액 감산 처리
			$qready = "UPDATE `dds_user_profile` SET `dds_user_profile`.`money` = `dds_user_profile`.`money` - " . $sqc[0]['money'] . " WHERE `dds_user_profile`.`authid` = '" . $authid . "'";
			$this->db->query($qready);

			// 조건이 된다면 구매 처리
			$setdata = array(
				'dds_user_item.authid' => $authid,
				'dds_user_item.ilidx' => $oidx,
				'dds_user_item.buydate' => time()
			);
			$this->db->set($setdata);
			$this->db->insert('dds_user_item');
		}
		else if (strcmp($type, 'admin-usrmodify') == 0)
		{
			$qready = "UPDATE `dds_user_profile` SET `dds_user_profile`.`money` = '" . $tidx . "' WHERE `dds_user_profile`.`idx` = '" . $oidx . "'";
			$this->db->query($qready);
		}
		else if (strcmp($type, 'admin-itemdelete') == 0)
		{
			$setdata = array(
				'dds_item_list.ilidx' => $oidx
			);
			$this->db->where($setdata);
			$this->db->delete('dds_item_list');
		}
		else if (strcmp($type, 'admin-itemcgdelete') == 0)
		{
			$setdata = array(
				'dds_item_category.icidx' => $oidx
			);
			$this->db->where($setdata);
			$this->db->delete('dds_item_category');
		}
		return json_encode(array('result' => true, 'title' => 'msg_title_notice', 'msg' => 'msg_results_success'));
	}

	function SetDetInfo($type, $data)
	{
		if (strcmp($type, 'additem') == 0)
		{
			$il_code = $data[0];
			$il_name = $data[1];
			$il_money = $data[2];
			$il_havtime = $data[3];
			$il_env = $data[4];
			$il_status = $data[5];

			$setdata = array(
				'dds_item_list.gloname' => $il_name,
				'dds_item_list.icidx' => $il_code,
				'dds_item_list.money' => $il_money,
				'dds_item_list.havtime' => $il_havtime,
				'dds_item_list.env' => $il_env,
				'dds_item_list.status' => $il_status
			);
			$this->db->set($setdata);
			$this->db->insert('dds_item_list');
		}
		else if (strcmp($type, 'additemcg') == 0)
		{
			$ic_name = $data[0];
			$ic_orderidx = $data[1];
			$ic_env = $data[2];
			$ic_status = $data[3];

			$setdata = array(
				'dds_item_category.gloname' => $ic_name,
				'dds_item_category.orderidx' => $ic_orderidx,
				'dds_item_category.env' => $ic_env,
				'dds_item_category.status' => $ic_status
			);
			$this->db->set($setdata);
			$this->db->insert('dds_item_category');
		}

		return json_encode(array('result' => true, 'title' => 'msg_title_notice', 'msg' => 'msg_results_success'));
	}

	function GetProfile($authid)
	{
		// 유저 프로필 로드
		$this->db->where('dds_user_profile.authid', $authid);
		$q = $this->db->get('dds_user_profile');
		
		return $q->result_array();
	}
}

?>