CREATE DATABASE IF NOT EXISTS petclinic;

USE petclinic;

-- Create tables that have no dependencies first
DROP TABLE IF EXISTS `specialties`;
CREATE TABLE `specialties` (
  `id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

DROP TABLE IF EXISTS `types`;
CREATE TABLE `types` (
  `id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

DROP TABLE IF EXISTS `owners`;
CREATE TABLE `owners` (
  `id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(30) DEFAULT NULL,
  `last_name` varchar(30) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(80) DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `last_name` (`last_name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

DROP TABLE IF EXISTS `vets`;
CREATE TABLE `vets` (
  `id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(30) DEFAULT NULL,
  `last_name` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `last_name` (`last_name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Create tables that depend on the above tables
DROP TABLE IF EXISTS `pets`;
CREATE TABLE `pets` (
  `id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `type_id` int(4) unsigned NOT NULL,
  `owner_id` int(4) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `owner_id` (`owner_id`),
  KEY `type_id` (`type_id`),
  CONSTRAINT `pets_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `owners` (`id`),
  CONSTRAINT `pets_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

DROP TABLE IF EXISTS `vet_specialties`;
CREATE TABLE `vet_specialties` (
  `vet_id` int(4) unsigned NOT NULL,
  `specialty_id` int(4) unsigned NOT NULL,
  UNIQUE KEY `vet_id` (`vet_id`,`specialty_id`),
  KEY `specialty_id` (`specialty_id`),
  CONSTRAINT `vet_specialties_ibfk_1` FOREIGN KEY (`vet_id`) REFERENCES `vets` (`id`),
  CONSTRAINT `vet_specialties_ibfk_2` FOREIGN KEY (`specialty_id`) REFERENCES `specialties` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

DROP TABLE IF EXISTS `visits`;
CREATE TABLE `visits` (
  `id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `pet_id` int(4) unsigned NOT NULL,
  `visit_date` date DEFAULT NULL,
  `description` varchar(8192) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pet_id` (`pet_id`),
  CONSTRAINT `visits_ibfk_1` FOREIGN KEY (`pet_id`) REFERENCES `pets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Insert data in the same order as table creation
LOCK TABLES `specialties` WRITE;
INSERT INTO `specialties` VALUES
(3,'dentistry'),
(1,'radiology'),
(2,'surgery');
UNLOCK TABLES;

LOCK TABLES `types` WRITE;
INSERT INTO `types` VALUES
(5,'bird'),
(1,'cat'),
(2,'dog'),
(6,'hamster'),
(3,'lizard'),
(4,'snake');
UNLOCK TABLES;

LOCK TABLES `owners` WRITE;
INSERT INTO `owners` VALUES
(1,'George','Franklin','110 W. Liberty St.','Madison','6085551023'),
(2,'Betty','Davis','638 Cardinal Ave.','Sun Prairie','6085551749'),
(3,'Eduardo','Rodriquez','2693 Commerce St.','McFarland','6085558763'),
(4,'Harold','Davis','563 Friendly St.','Windsor','6085553198'),
(5,'Peter','McTavish','2387 S. Fair Way','Madison','6085552765'),
(6,'Jean','Coleman','105 N. Lake St.','Monona','6085552654'),
(7,'Jeff','Black','1450 Oak Blvd.','Monona','6085555387'),
(8,'Maria','Escobito','345 Maple St.','Madison','6085557683'),
(9,'David','Schroeder','2749 Blackhawk Trail','Madison','6085559435'),
(10,'Carlos','Estaban','2335 Independence La.','Waunakee','6085555487');
UNLOCK TABLES;

LOCK TABLES `vets` WRITE;
INSERT INTO `vets` VALUES
(1,'James','Carter'),
(2,'Helen','Leary'),
(3,'Linda','Douglas'),
(4,'Rafael','Ortega'),
(5,'Henry','Stevens'),
(6,'Sharon','Jenkins');
UNLOCK TABLES;

LOCK TABLES `pets` WRITE;
INSERT INTO `pets` VALUES
(1,'Leo','2000-09-07',1,1),
(2,'Basil','2002-08-06',6,2),
(3,'Rosy','2001-04-17',2,3),
(4,'Jewel','2000-03-07',2,3),
(5,'Iggy','2000-11-30',3,4),
(6,'George','2000-01-20',4,5),
(7,'Samantha','1995-09-04',1,6),
(8,'Max','1995-09-04',1,6),
(9,'Lucky','1999-08-06',5,7),
(10,'Mulligan','1997-02-24',2,8),
(11,'Freddy','2000-03-09',5,9),
(12,'Lucky','2000-06-24',2,10),
(13,'Sly','2002-06-08',1,10);
UNLOCK TABLES;

LOCK TABLES `vet_specialties` WRITE;
INSERT INTO `vet_specialties` VALUES
(2,1),
(5,1),
(3,2),
(4,2),
(3,3);
UNLOCK TABLES;

LOCK TABLES `visits` WRITE;
INSERT INTO `visits` VALUES
(1,7,'2010-03-04','rabies shot'),
(2,8,'2011-03-04','rabies shot'),
(3,8,'2009-06-04','neutered'),
(4,7,'2008-09-04','spayed');
UNLOCK TABLES;
