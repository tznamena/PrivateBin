-- PrivateBin MySQL Database Initialization for Production
-- This script initializes the database tables required for PrivateBin

-- Create tables for PrivateBin (production schema)
CREATE TABLE IF NOT EXISTS `pb_paste` (
  `dataid` varchar(64) NOT NULL,
  `data` mediumblob,
  `postdate` int(10) unsigned NOT NULL,
  `expiredate` int(10) unsigned NOT NULL,
  `opendiscussion` tinyint(1) NOT NULL,
  `burnafterreading` tinyint(1) NOT NULL,
  `meta` text,
  `attachment` mediumblob,
  `attachmentname` blob,
  PRIMARY KEY (`dataid`),
  KEY `expiredate` (`expiredate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS `pb_comment` (
  `dataid` varchar(64) NOT NULL,
  `pasteid` varchar(64) NOT NULL,
  `parentid` varchar(64) NOT NULL,
  `data` blob,
  `nickname` blob,
  `vizhash` blob,
  `postdate` int(10) unsigned NOT NULL,
  PRIMARY KEY (`dataid`),
  KEY `pasteid` (`pasteid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE IF NOT EXISTS `pb_config` (
  `id` varchar(64) NOT NULL,
  `value` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Insert production configuration
INSERT IGNORE INTO `pb_config` (`id`, `value`) VALUES
('VERSION', '2.0.0'),
('SCHEMA_VERSION', '100');

-- Set proper permissions for production user
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'privatebin'@'%';
FLUSH PRIVILEGES;