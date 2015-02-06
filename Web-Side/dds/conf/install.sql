/**
 * Author By. KARSEI
 *
 * http://karsei.pe.kr
 */
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

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
	`gloname` VARCHAR(64) NOT NULL DEFAULT '',
	`orderidx` INT(8) UNSIGNED NOT NULL DEFAULT '0',
	`env` VARCHAR(256) NOT NULL DEFAULT '',
	`status` TINYINT(4) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`icidx`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dds_item_list` (
	`ilidx` INT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
	`gloname` VARCHAR(64) NOT NULL DEFAULT '',
	`icidx` INT(8) UNSIGNED NOT NULL DEFAULT '0',
	`money` INT(16) UNSIGNED NOT NULL DEFAULT '0',
	`havtime` INT(16) NOT NULL DEFAULT '0',
	`env` VARCHAR(256) NOT NULL DEFAULT '',
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


/**
 * Codeigniter
 */
CREATE TABLE IF NOT EXISTS  `dds_sessions` (
	`session_id` VARCHAR(40) NOT NULL DEFAULT '0',
	`ip_address` VARCHAR(16) NOT NULL DEFAULT '0',
	`user_agent` VARCHAR(120) NOT NULL,
	`last_activity` INT(10) UNSIGNED NOT NULL DEFAULT 0,
	`user_data` TEXT NOT NULL,
	PRIMARY KEY (`session_id`),
	KEY `last_activity_idx` (`last_activity`)
);