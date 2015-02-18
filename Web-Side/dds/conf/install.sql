/**********************************************************
 * --------------------------------------------------------
 * Dynamic Dollar Shop
 * --------------------------------------------------------
 *
 * Author By. Karsei
 * http://karsei.pe.kr
 *
***********************************************************/
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/***********************
 * [Game Nid Databases]
************************/
CREATE TABLE IF NOT EXISTS `dds_user_profile` (
	`idx` INT(16) UNSIGNED NOT NULL AUTO_INCREMENT,
	`authid` VARCHAR(20) NOT NULL,
	`money` INT(16) UNSIGNED NOT NULL DEFAULT '0',
	`ingame` TINYINT(4) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`idx`),
	UNIQUE KEY `authid` (`authid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dds_user_item` (
	`idx` INT(16) UNSIGNED NOT NULL AUTO_INCREMENT,
	`authid` VARCHAR(20) NOT NULL,
	`ilidx` INT(8) UNSIGNED NOT NULL,
	`aplied` TINYINT(4) UNSIGNED NOT NULL DEFAULT '0',
	`buydate` VARCHAR(20) NOT NULL DEFAULT '0',
	PRIMARY KEY (`idx`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dds_user_setting` (
	`idx` INT(16) UNSIGNED NOT NULL AUTO_INCREMENT,
	`authid` VARCHAR(20) NOT NULL,
	`onecate` VARCHAR(20) NOT NULL,
	`twocate` INT(8) UNSIGNED NOT NULL,
	`setvalue` VARCHAR(32) NOT NULL DEFAULT '',
	PRIMARY KEY (`idx`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dds_item_category` (
	`icidx` INT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
	`gloname` VARCHAR(300) NOT NULL DEFAULT '',
	`orderidx` INT(8) UNSIGNED NOT NULL DEFAULT '0',
	`env` VARCHAR(512) NOT NULL DEFAULT '',
	`status` TINYINT(4) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`icidx`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dds_item_list` (
	`ilidx` INT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
	`gloname` VARCHAR(300) NOT NULL DEFAULT '',
	`icidx` INT(8) UNSIGNED NOT NULL DEFAULT '0',
	`money` INT(16) UNSIGNED NOT NULL DEFAULT '0',
	`havtime` INT(16) NOT NULL DEFAULT '0',
	`env` VARCHAR(512) NOT NULL DEFAULT '',
	`status` TINYINT(4) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`ilidx`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dds_log_data` (
	`idx` INT(32) UNSIGNED NOT NULL AUTO_INCREMENT,
	`authid` VARCHAR(20) NOT NULL,
	`action` VARCHAR(25) NOT NULL,
	`setdata` VARCHAR(128) NOT NULL DEFAULT '',
	`thisdate` VARCHAR(20) NOT NULL DEFAULT '0',
	`usrip` VARCHAR(20) NOT NULL,
	PRIMARY KEY (`idx`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dds_env_list` (
	`idx` INT(32) UNSIGNED NOT NULL AUTO_INCREMENT,
	`onecate` VARCHAR(20) NOT NULL,
	`twocate` VARCHAR(64) NOT NULL,
	`setdata` VARCHAR(256) NOT NULL DEFAULT '',
	PRIMARY KEY (`idx`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


/***********************
 * [Nid Table Records to Game Databases]
************************/
/** ENV LIST **/
INSERT INTO `dds_env_list` (`idx`, `onecate`, `twocate`, `setdata`) VALUES (NULL, 'item', 'ENV_DDS_SYS_GAME', 'cstrike');
INSERT INTO `dds_env_list` (`idx`, `onecate`, `twocate`, `setdata`) VALUES (NULL, 'item', 'ENV_DDS_PROPERTY_ADRS', '');
INSERT INTO `dds_env_list` (`idx`, `onecate`, `twocate`, `setdata`) VALUES (NULL, 'item', 'ENV_DDS_PROPERTY_POS', '0 0 0');
INSERT INTO `dds_env_list` (`idx`, `onecate`, `twocate`, `setdata`) VALUES (NULL, 'item', 'ENV_DDS_PROPERTY_ANG', '0 0 0');
INSERT INTO `dds_env_list` (`idx`, `onecate`, `twocate`, `setdata`) VALUES (NULL, 'item', 'ENV_DDS_PROPERTY_COLOR', '0 0 0 0');

INSERT INTO `dds_env_list` (`idx`, `onecate`, `twocate`, `setdata`) VALUES (NULL, 'itemcategory', 'ENV_DDS_SYS_GAME', 'cstrike');
INSERT INTO `dds_env_list` (`idx`, `onecate`, `twocate`, `setdata`) VALUES (NULL, 'itemcategory', 'ENV_DDS_ACCESS_CLASS', 'all');
INSERT INTO `dds_env_list` (`idx`, `onecate`, `twocate`, `setdata`) VALUES (NULL, 'itemcategory', 'ENV_DDS_USE_MONEY', '1');


/** Apply Env List to Item and Item Category **/


/** ITEM LIST **/
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Big Star||ko:큰별', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Rainbow||ko:무지개', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Mario||ko:마리오', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Luigi||ko:루이지', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Goomba||ko:굼바', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Money||ko:돈', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Mushroom||ko:버섯', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Burger||ko:햄버거', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Coffee||ko:커피', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Stars||ko:별들', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:LOL||ko:LOL', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Angry Face||ko:화난 얼굴', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:AOL||ko:졸라맨', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Apple||ko:사과', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Arrow||ko:화살표', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Awesome Face||ko:웃는 얼굴', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Bubbles||ko:거품', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Care Bear||ko:분홍색곰', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Chimaira||ko:키마이라', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Chrome||ko:크롬', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:FireFox||ko:파이어폭스', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:HL2||ko:하프라이프2', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:CSS||ko:CSS', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:DODS||ko:DODS', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Dots||ko:점들', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Easter Egg||ko:부활절 달걀', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:FireBird||ko:파이어버드', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Footprint||ko:발자국', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Handy||ko:장애인 표시', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Happy||ko:스마일', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Suzumiya Haruhi||ko:스즈미야 하루히', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Konata||ko:코나타', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Linux||ko:리눅스', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Love||ko:하트', '1', '100', '0', '', '1');
INSERT INTO `dds_item_list` (`ilidx`, `gloname`, `icidx`, `money`, `havtime`, `env`, `status`) VALUES (NULL, 'en:Pikachu||ko:피카츄', '1', '100', '0', '', '1');


/***********************
 * [CodeIgniter]
************************/
CREATE TABLE IF NOT EXISTS  `dds_sessions` (
	`session_id` VARCHAR(40) NOT NULL DEFAULT '0',
	`ip_address` VARCHAR(16) NOT NULL DEFAULT '0',
	`user_agent` VARCHAR(120) NOT NULL,
	`last_activity` INT(10) UNSIGNED NOT NULL DEFAULT 0,
	`user_data` TEXT NOT NULL,
	PRIMARY KEY (`session_id`),
	KEY `last_activity_idx` (`last_activity`)
);