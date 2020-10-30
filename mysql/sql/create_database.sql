-- Adminer 4.2.4 MySQL dump

CREATE DATABASE IF NOT EXISTS BTCPOOL_CKB;
USE BTCPOOL_CKB;

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `found_blocks`;
CREATE TABLE `found_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `puid` int(11) NOT NULL,
  `worker_id` bigint(20) NOT NULL,
  `worker_full_name` varchar(50) NOT NULL,
  `height` int(11) NOT NULL,
  `is_orphaned` tinyint(4) NOT NULL DEFAULT '0',
  `is_uncle` tinyint(4) NOT NULL DEFAULT '0',
  `ref_uncles` varchar(255) NOT NULL DEFAULT '',
  `hash` char(66) NOT NULL DEFAULT '',
  `hash_no_nonce` char(66) NOT NULL,
  `nonce` char(66) NOT NULL,
  `rewards` decimal(35,0) DEFAULT NULL,
  `size` int(11) NOT NULL DEFAULT '0',
  `prev_hash` char(66) NOT NULL DEFAULT '',
  `network_diff` bigint(20) unsigned NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `rpc_error` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `hash` (`hash`),
  KEY `height` (`height`),
  UNIQUE KEY `unique_block`(`hash_no_nonce`,`nonce`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `mining_workers`;
CREATE TABLE `mining_workers` (
  `worker_id` bigint(20) NOT NULL,
  `puid` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `worker_name` varchar(50) DEFAULT NULL,
  `accept_1m` bigint(20) NOT NULL DEFAULT '0',
  `accept_5m` bigint(20) NOT NULL DEFAULT '0',
  `accept_15m` bigint(20) NOT NULL DEFAULT '0',
  `stale_15m` bigint(20) NOT NULL DEFAULT '0',
  `reject_15m` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail_15m` varchar(255) NOT NULL DEFAULT '',
  `accept_1h` bigint(20) NOT NULL DEFAULT '0',
  `stale_1h` bigint(20) NOT NULL DEFAULT '0',
  `reject_1h` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail_1h` varchar(255) NOT NULL DEFAULT '',
  `accept_count` int(11) NOT NULL DEFAULT '0',
  `last_share_ip` char(16) NOT NULL DEFAULT '0.0.0.0',
  `last_share_time` timestamp NOT NULL DEFAULT '1970-01-01 00:00:01',
  `miner_agent` varchar(30) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `puid_worker_id` (`puid`,`worker_id`),
  KEY `puid_group_id` (`puid`,`group_id`),
  KEY `puid_worker_name` (`puid`,`worker_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `stats_pool_day`;
CREATE TABLE `stats_pool_day` (
  `day` int(11) NOT NULL,
  `share_accept` bigint(20) NOT NULL DEFAULT '0',
  `share_stale` bigint(20) NOT NULL DEFAULT '0',
  `share_reject` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail` varchar(255) NOT NULL DEFAULT '',
  `reject_rate` double NOT NULL DEFAULT '0',
  `score` decimal(35,25) NOT NULL DEFAULT '0.0000000000000000000000000',
  `earn` decimal(35,0) NOT NULL DEFAULT '0',
  `lucky` double NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `day` (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `stats_pool_hour`;
CREATE TABLE `stats_pool_hour` (
  `hour` int(11) NOT NULL,
  `share_accept` bigint(20) NOT NULL DEFAULT '0',
  `share_stale` bigint(20) NOT NULL DEFAULT '0',
  `share_reject` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail` varchar(255) NOT NULL DEFAULT '',
  `reject_rate` double NOT NULL DEFAULT '0',
  `score` decimal(35,25) NOT NULL DEFAULT '0.0000000000000000000000000',
  `earn` decimal(35,0) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `hour` (`hour`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `stats_users_day`;
CREATE TABLE `stats_users_day` (
  `puid` int(11) NOT NULL,
  `day` int(11) NOT NULL,
  `share_accept` bigint(20) NOT NULL DEFAULT '0',
  `share_stale` bigint(20) NOT NULL DEFAULT '0',
  `share_reject` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail` varchar(255) NOT NULL DEFAULT '',
  `reject_rate` double NOT NULL DEFAULT '0',
  `score` decimal(35,25) NOT NULL DEFAULT '0.0000000000000000000000000',
  `earn` decimal(35,0) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `puid_day` (`puid`,`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `stats_users_hour`;
CREATE TABLE `stats_users_hour` (
  `puid` int(11) NOT NULL,
  `hour` int(11) NOT NULL,
  `share_accept` bigint(20) NOT NULL DEFAULT '0',
  `share_stale` bigint(20) NOT NULL DEFAULT '0',
  `share_reject` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail` varchar(255) NOT NULL DEFAULT '',
  `reject_rate` double NOT NULL DEFAULT '0',
  `score` decimal(35,25) NOT NULL DEFAULT '0.0000000000000000000000000',
  `earn` decimal(35,0) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `puid_hour` (`puid`,`hour`),
  KEY `hour` (`hour`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `stats_workers_day`;
CREATE TABLE `stats_workers_day` (
  `puid` int(11) NOT NULL,
  `worker_id` bigint(20) NOT NULL,
  `day` int(11) NOT NULL,
  `share_accept` bigint(20) NOT NULL DEFAULT '0',
  `share_stale` bigint(20) NOT NULL DEFAULT '0',
  `share_reject` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail` varchar(255) NOT NULL DEFAULT '',
  `reject_rate` double NOT NULL DEFAULT '0',
  `score` decimal(35,25) NOT NULL DEFAULT '0.0000000000000000000000000',
  `earn` decimal(35,0) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `puid_worker_id_day` (`puid`,`worker_id`,`day`),
  KEY `day` (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `stats_workers_hour`;
CREATE TABLE `stats_workers_hour` (
  `puid` int(11) NOT NULL,
  `worker_id` bigint(20) NOT NULL,
  `hour` int(11) NOT NULL,
  `share_accept` bigint(20) NOT NULL DEFAULT '0',
  `share_stale` bigint(20) NOT NULL DEFAULT '0',
  `share_reject` bigint(20) NOT NULL DEFAULT '0',
  `reject_detail` varchar(255) NOT NULL DEFAULT '',
  `reject_rate` double NOT NULL DEFAULT '0',
  `score` decimal(35,25) NOT NULL DEFAULT '0.0000000000000000000000000',
  `earn` decimal(35,0) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `puid_worker_id_hour` (`puid`,`worker_id`,`hour`),
  KEY `hour` (`hour`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 2017-04-25 12:17:40
