<?php

class Buy_m extends CI_Model {
	
	function __construct()
	{
		parent::__construct();
	}

	function LoadList($limitc, $limitidx)
	{
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
		$this->db->limit($limitidx, $limitc);
		$q = $this->db->get('dds_item_category');

		return $q->result();
	}

	function MakeRecord($data)
	{
		$rval = '';
		foreach ($data as $row)
		{
			$rval .= '<tr>';
			$rval .= '<td>' . $row->ilidx . '</td>';
			$rval .= '<td>' . $row->icname . '</td>';
			$rval .= '<td>' . $row->itname . '</td>';
			$rval .= '<td>' . $row->money . '</td>';
			$rval .= '<td>' . $row->havtime . '</td>';
			$rval .= '<td>구입 / 선물</td>';
			$rval .= '</tr>';
		}
		return $rval;
	}
}

?>