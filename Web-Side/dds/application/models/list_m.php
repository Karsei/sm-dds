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
			SELECT dds_user_item.idx, dds_item_category.gloname AS icname, dds_item_list.gloname AS ilname, dds_user_item.buydate, dds_user_item.aplied
			FROM `dds_user_item` 
			LEFT JOIN `dds_item_list` ON `dds_user_item`.`ilidx` = `dds_item_list`.`ilidx` 
			LEFT JOIN `dds_item_category` ON `dds_item_category`.`icidx` = `dds_item_list`.`icidx` 
			WHERE `dds_item_category`.`status` = '1' 
			ORDER BY `dds_user_item`.`ilidx` DESC;
			*/
			$this->db->select('dds_user_item.idx, dds_item_category.gloname AS icname, dds_item_list.gloname AS ilname, dds_user_item.buydate, dds_user_item.aplied');
			$this->db->join('dds_item_list', 'dds_user_item.ilidx = dds_item_list.ilidx', 'left');
			$this->db->join('dds_item_category', 'dds_item_category.icidx = dds_item_list.icidx', 'left');
			$this->db->where(array('dds_item_category.status' => '1'));
			$this->db->order_by('dds_user_item.ilidx', 'DESC');
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
	}

	function SetList($type, $itemidx, $authid)
	{
		if (strcmp($type, 'item-buy') == 0)
		{
			$setdata = array(
				'authid' => $authid,
				'ilidx' => $itemidx,
				'buydate' => time()
			);
			$this->db->set($setdata);
			$this->db->insert('dds_user_item');
		}
	}
}

?>