-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 08, 2024 at 04:10 PM
-- Server version: 5.7.24
-- PHP Version: 8.0.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `raktarproject`
--
CREATE DATABASE IF NOT EXISTS `raktarproject` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `raktarproject`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addItems` (IN `skuIn` VARCHAR(100) CHARSET utf8mb4, IN `typeIn` ENUM('Metal','Wood','Titanium','Plastic') CHARSET utf8mb4, IN `nameIn` VARCHAR(100) CHARSET utf8mb4, IN `amountIn` INT(11), IN `priceIn` DOUBLE, IN `itemStateIn` ENUM('inportItem','exportItem') CHARSET utf8mb4, IN `weightIn` DOUBLE, IN `sizeIn` DOUBLE, IN `descriptionIn` TEXT CHARSET utf8mb4, IN `shelfidIn` INT(11))   BEGIN
INSERT INTO `items` (`sku`, `type`, `name`, `amount`, `price`, `itemState`, `weight`, `size`, `description`)
    VALUES (
        skuIn,
        typeIn,
        nameIn,
        amountIn,
        priceIn,
        itemStateIn,
        weightIn,
        sizeIn,
        descriptionIn
    );

    SET @lastItem = LAST_INSERT_ID();

    INSERT INTO `items_x_shelfs` (`item_id`, `shelf_id`)
    VALUES (@lastItem, shelfidIn);
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addShelf` (IN `nameIn` VARCHAR(255) CHARSET utf8mb4, IN `capacityIn` INT, IN `locationInStorageIn` VARCHAR(255) CHARSET utf8mb4, IN `storageIdIn` INT)   BEGIN
    INSERT INTO `shelfs` (`name`, `capacity`, `locationInStorage`)
    VALUES (nameIn, capacityIn, locationInStorageIn);

    SET @lastshelfid = LAST_INSERT_ID();

    INSERT INTO `shelfs_x_storage` (`shelf_id`, `storage_id`)
    VALUES (@lastshelfid, storageIdIn);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addStorage` (IN `nameIn` VARCHAR(255) CHARSET utf8mb4, IN `capacityIn` VARCHAR(255) CHARSET utf8mb4, IN `locationIn` VARCHAR(255) CHARSET utf8mb4)   INSERT INTO `storage`(`storage`.`name`, `storage`.`capacity`, `storage`.`location`)
VALUES (
	nameIn,
	capacityIn,
    locationIn
)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteUser` (IN `idIn` INT(11))   UPDATE `users`
SET `users`.`is_deleted` = 1,
`users`.`deletedAt` = NOW()
WHERE `users`.`id` = idIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAdmins` ()   SELECT `users`.*
FROM `users`
WHERE `users`.`isAdmin` = 1 AND `users`.`is_deleted` = 0
ORDER BY `users`.`firstName` ASC, `users`.`lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllNonAdmins` ()   SELECT `users`.*
FROM `users`
WHERE `users`.`isAdmin` = 0 AND `users`.`is_deleted` = 0
ORDER BY `users`.`firstName` ASC, 
`users`.`lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllShelfsItems` ()   BEGIN
    SELECT
        ix.shelf_id,                    
        s.name AS shelf_name,            
        i.id AS item_id,                 
        i.name AS item_name,              
        ix.amount AS amount_on_shelf    
    FROM
        items i
    JOIN
        items_x_shelfs ix ON i.id = ix.item_id 
    JOIN
        shelfs s ON ix.shelf_id = s.id         
    ORDER BY
        ix.shelf_id, i.name;                      
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllUsers` ()   SELECT `users`.*
FROM `users`
WHERE `users`.`is_deleted` = 0
ORDER BY `users`.`firstName` ASC, `users`.`lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDeletedUserByName` (IN `firstNameIn` VARCHAR(100) CHARSET utf8mb4, IN `lastNameIn` VARCHAR(100) CHARSET utf8mb4)   SELECT `users`.*
FROM `users`
WHERE `firstName` = firstNameIn OR `lastName` = lastNameIn AND `users`.`is_deleted` = 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDeletedUsers` ()   SELECT `users`.*
FROM `users`
WHERE `users`.`is_deleted` = 1
ORDER BY `users`.`firstName` ASC, `users`.`lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getGetItemsByStorageId` (IN `storageIdIN` INT(11))   SELECT items.*
    FROM `items`
    JOIN `items_x_shelfs` ON `items`.id = `items_x_shelfs`.`item_id`
    JOIN `shelfs` ON `items_x_shelfs`.`shelf_id` = `shelfs`.`id`
    JOIN `shelfs_x_storage` ON `shelfs`.id = `shelfs_x_storage`.`shelf_id`
    JOIN `storage` ON `shelfs_x_storage`.`storage_id` = `storage`.`id`
    WHERE `storage`.`id` = storageIdIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemAmount` ()   SELECT `items`.`name`, `items`.`sku`, `items`.`amount`
FROM `items`
WHERE `items`.`amount` IS NOT NULL$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemByName` (IN `nameIn` VARCHAR(100) CHARSET utf8)   SELECT `items`.*
FROM `items`
WHERE `items`.`name` = nameIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemBySizeAsc` ()   SELECT *
FROM `items`
ORDER BY `items`.`size` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemBySizeDesc` ()   SELECT *
FROM `items`
ORDER BY `items`.`size` DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemByWeightAsc` ()   SELECT *
FROM `items`
ORDER BY `items`.`weight` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemByWeightDesc` ()   SELECT *
FROM `items`
ORDER BY `items`.`weight` Desc$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsBySKU` (IN `skuIn` VARCHAR(100) CHARSET utf8mb4)   SELECT `items`.*
FROM `items`
WHERE skuIn = `items`.`sku`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsByType` (IN `typeIn` ENUM('Metal','Wood','Titanium','Plastic'))   SELECT `items`.*
FROM `items`
WHERE `items`.`type` = typeIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsOnShelfsByShelfId` (IN `shelfIdIn` INT)   BEGIN
    
    SELECT
        i.id AS item_id,             
        i.name AS item_name,          
        ix.amount AS amount_on_shelf   
    FROM
        items i
    JOIN
        items_x_shelfs ix ON i.id = ix.item_id  
    WHERE
        ix.shelf_id = shelfIdIn;        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getShelfsByStorageId` (IN `storageIdIN` INT(100))   SELECT `shelfs`.*
FROM `shelfs` 
JOIN `shelfs_x_storage` ON `shelfs`.`id` = `shelfs_x_storage`.`shelf_id`
JOIN `storage` ON `shelfs_x_storage`.`storage_id` = `storage`.`id`
WHERE `storage`.`id` = storageIdIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getStoragesUsers` (IN `storageIdIN` INT)   SELECT users.*
FROM `users` JOIN `user_x_storage` ON `users`.`id` = `user_x_storage`.`user_id`
JOIN `storage` ON `user_x_storage`.`storage_id` = `storage`.`id`
WHERE `storage`.`id` = storageIdIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserById` (IN `userIdIn` INT(11))   SELECT * FROM `users` WHERE `users`.`id`=userIdIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserByName` (IN `firstNameIn` VARCHAR(255) CHARSET utf8mb4, IN `lastNameIN` VARCHAR(255) CHARSET utf8mb4)   SELECT `users`.*
FROM `users`
WHERE `firstName` = firstNameIn OR `lastName` = lastNameIN AND `users`.`is_deleted` = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `groupbyItemCategory` (IN `typeIn` ENUM('Metal','Wood','Titanium','Plastic') CHARSET utf8mb4)   SELECT `items`.*
FROM `items`
WHERE `items`.`type` = typeIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `isUserExist` (IN `emailIN` VARCHAR(100), OUT `resultOUT` BOOLEAN)   SELECT COUNT(*) 
INTO resultOUT
FROM users
WHERE users.email = emailIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `usernameIN` VARCHAR(100) CHARSET utf8mb4, IN `passwordIN` VARCHAR(100) CHARSET utf8mb4)   SELECT `users`.*
FROM `users`
WHERE `users`.username = usernameIN 
  AND `users`.password = passwordIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moveItems` (IN `itemIdIn` INT, IN `fromStorageIdIn` INT, IN `toStorageIdIn` INT, IN `amountIn` INT, IN `userIdIn` INT)   BEGIN
    DECLARE exit handler for sqlexception
    BEGIN
        -- Ha hiba történik, visszavonjuk a tranzakciót és kiíratjuk a hibát
        ROLLBACK;
        SELECT 'Hiba történt az áthelyezés során. A tranzakció visszavonásra került.' AS result;
    END;

    START TRANSACTION;

    -- 1. A forrás tárolóból levonjuk a mennyiséget
    UPDATE items
    SET amount = amount - amountIn
    WHERE id = itemIdIn;

    -- 2. Hozzáadjuk a mennyiséget a cél tárolóhoz
    INSERT INTO items_x_shelfs (item_id, shelf_id, amount)
    SELECT itemIdIn, shelfs_x_storage.shelf_id, amountIn
    FROM shelfs_x_storage
    WHERE shelfs_x_storage.storage_id = toStorageIdIn
    LIMIT 1
    ON DUPLICATE KEY UPDATE amount = amount + amountIn;

    -- 3. Létrehozzuk az inventorymovement rekordot és eltároljuk az ID-t
    INSERT INTO inventorymovement (movementDate, amount, storageFrom, storageTo, byUser)
    VALUES (NOW(), amountIn, fromStorageIdIn, toStorageIdIn, userIdIn);
    
    -- Eltároljuk az inventorymovement id-t
    SET @inventoryMovementId = LAST_INSERT_ID();

    -- 4. Létrehozzuk az inventorymovement_x_storage rekordot
    INSERT INTO inventorymovement_x_storage (inventory_id, fromStorage_id, toStorage_id)
    VALUES (@inventoryMovementId, fromStorageIdIn, toStorageIdIn);

    -- 5. Létrehozzuk az inventorymovement_x_items rekordot
    INSERT INTO inventorymovement_x_items (inventory_id, item_id)
    VALUES (@inventoryMovementId, itemIdIn);

    COMMIT;

    -- 6. Visszajelzés
    SELECT 'Áthelyezés sikeres' AS result;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerAdmin` (IN `emailIn` VARCHAR(255) CHARSET utf8mb4, IN `firstNameIn` VARCHAR(255) CHARSET utf8mb4, IN `lastNameIn` VARCHAR(255) CHARSET utf8mb4, IN `userNameIn` VARCHAR(255) CHARSET utf8mb4, IN `pictureIn` TEXT CHARSET utf8mb4, IN `passwordIn` VARCHAR(255) CHARSET utf8mb4)   INSERT INTO users (users.email, users.firstName, users.lastName, users.userName, users.picture, users.password, users.isAdmin)
VALUES(
       emailIn,
       firstNameIn,
       lastNameIn,
       userNameIn,
       pictureIn,
       passwordIn,
       1

)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerUser` (IN `emailIn` VARCHAR(255), IN `firstNameIn` VARCHAR(255), IN `lastNameIn` VARCHAR(255), IN `userNameIn` VARCHAR(255), IN `pictureIn` TEXT, IN `passwordIn` VARCHAR(255))   INSERT INTO `users` (`users`.`email`, `users`.`firstName`, `users`.`lastName`, `users`.`userName`, `users`.`picture`, `users`.`password`, `users`.`isAdmin`)
VALUES(
	   emailIn,
	   firstNameIn,
	   lastNameIn,
	   userNameIn,
	   pictureIn,
	   passwordIn,
       0
)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sortItemPriceASC` ()   SELECT `items`.*
FROM `items`
ORDER BY `items`.`price` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sortItemPriceDesc` ()   SELECT `items`.*
FROM `items`
ORDER BY `items`.`price` DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateItem` (IN `skuIn` VARCHAR(255) CHARSET utf8mb4, IN `typeIn` ENUM('Metal','Wood','Titanium','Plastic') CHARSET utf8mb4, IN `nameIn` VARCHAR(255) CHARSET utf8mb4, IN `amountIn` INT(11), IN `priceIn` DOUBLE, IN `itemState` ENUM('inportItem','exportItem') CHARSET utf8mb4, IN `weightIn` DOUBLE, IN `sizeIn` DOUBLE, IN `descriptionIn` TEXT CHARSET utf8mb4, IN `idIn` INT(11))   UPDATE `items`
SET
`items`.`sku` = skuIn,
`items`.`type` = typeIn,
`items`.`name` = nameIn,
`items`.`amount` = amountIn,
`items`.`price` = priceIn,
`items`.`itemState` = itemState,
`items`.`weight` = weightIn,
`items`.`size` = sizeIn,
`items`.`description` = descriptionIn
WHERE `items`.`id` = idIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUser` (IN `emailIn` VARCHAR(255), IN `firstNameIn` VARCHAR(255), IN `lastNameIn` VARCHAR(255), IN `userNameIn` VARCHAR(255), IN `pictureIn` TEXT, IN `passwordIn` VARCHAR(255), IN `isAdminIn` TINYINT(1), IN `idIn` INT(11))   UPDATE `users` SET `users`.`email` = emailIn,
`users`.`firstName` = firstNameIn,
`users`.`lastName`= lastNameIn,
`users`.`userName`= userNameIn,
`users`.`picture` = pictureIn,
`users`.`password` = passwordIn,
`users`.`isAdmin` = isAdminIn
WHERE `users`.`id` = idIn$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `inventorymovement`
--

CREATE TABLE IF NOT EXISTS `inventorymovement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `movementDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `amount` int(11) DEFAULT NULL,
  `storageFrom` int(11) DEFAULT NULL,
  `storageTo` int(11) DEFAULT NULL,
  `byUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `inventorymovement`
--

INSERT INTO `inventorymovement` (`id`, `movementDate`, `amount`, `storageFrom`, `storageTo`, `byUser`) VALUES
(14, '2024-11-23 13:54:58', 5, 6, 25, 12),
(15, '2024-11-23 13:56:11', 25, 5, 6, 12),
(16, '2024-11-23 13:57:16', 200, 5, 6, 12);

-- --------------------------------------------------------

--
-- Table structure for table `inventorymovement_x_items`
--

CREATE TABLE IF NOT EXISTS `inventorymovement_x_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `inventory_id` (`inventory_id`),
  KEY `item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `inventorymovement_x_items`
--

INSERT INTO `inventorymovement_x_items` (`id`, `inventory_id`, `item_id`) VALUES
(12, 15, 26),
(13, 16, 26);

-- --------------------------------------------------------

--
-- Table structure for table `inventorymovement_x_storage`
--

CREATE TABLE IF NOT EXISTS `inventorymovement_x_storage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fromStorage_id` int(11) DEFAULT NULL,
  `toStorage_id` int(11) DEFAULT NULL,
  `inventory_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `inventory_id` (`inventory_id`),
  KEY `fromStorage_id` (`fromStorage_id`),
  KEY `toStorage_id` (`toStorage_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `inventorymovement_x_storage`
--

INSERT INTO `inventorymovement_x_storage` (`id`, `fromStorage_id`, `toStorage_id`, `inventory_id`) VALUES
(11, 5, 6, 14),
(12, 5, 6, 15),
(13, 5, 6, 16);

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE IF NOT EXISTS `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sku` varchar(255) DEFAULT NULL,
  `type` enum('Metal','Wood','Titanium','Plastic') DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `price` double DEFAULT NULL,
  `itemState` enum('inportItem','exportItem') DEFAULT NULL,
  `transactionTimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `weight` double DEFAULT NULL,
  `size` double DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`id`, `sku`, `type`, `name`, `amount`, `price`, `itemState`, `transactionTimestamp`, `weight`, `size`, `description`) VALUES
(26, 'SKU001', 'Metal', 'Flange nut', 475, 3000, 'inportItem', '2024-11-23 12:19:10', 500, 400, 'A flange nut is a type of nut that has a wide flange at one end, which serves as an integrated washer.');

-- --------------------------------------------------------

--
-- Table structure for table `items_x_shelfs`
--

CREATE TABLE IF NOT EXISTS `items_x_shelfs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) DEFAULT NULL,
  `shelf_id` int(11) DEFAULT NULL,
  `amount` int(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `item_shelf_unique` (`item_id`,`shelf_id`),
  KEY `item_id` (`item_id`),
  KEY `shelf_id` (`shelf_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `items_x_shelfs`
--

INSERT INTO `items_x_shelfs` (`id`, `item_id`, `shelf_id`, `amount`) VALUES
(16, 26, 8, 525);

-- --------------------------------------------------------

--
-- Table structure for table `shelfs`
--

CREATE TABLE IF NOT EXISTS `shelfs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `capacity` text,
  `locationInStorage` varchar(255) DEFAULT NULL,
  `isFull` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `shelfs`
--

INSERT INTO `shelfs` (`id`, `name`, `capacity`, `locationInStorage`, `isFull`) VALUES
(7, 'Shelf A', '200', 'Section 1', NULL),
(8, 'Shelf A', '3000', 'Section 1', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `shelfs_x_storage`
--

CREATE TABLE IF NOT EXISTS `shelfs_x_storage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shelf_id` int(11) DEFAULT NULL,
  `storage_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `storage_id` (`storage_id`),
  KEY `shelf_id` (`shelf_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `shelfs_x_storage`
--

INSERT INTO `shelfs_x_storage` (`id`, `shelf_id`, `storage_id`) VALUES
(7, 7, 5),
(8, 8, 6);

-- --------------------------------------------------------

--
-- Table structure for table `storage`
--

CREATE TABLE IF NOT EXISTS `storage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `capacity` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `isFull` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `storage`
--

INSERT INTO `storage` (`id`, `name`, `capacity`, `location`, `isFull`) VALUES
(5, 'Ware House A', '5000', 'Left Wing', 0),
(6, 'Storage B', '5000', 'East Wing', 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `userName` varchar(255) DEFAULT NULL,
  `picture` text,
  `password` varchar(255) DEFAULT NULL,
  `isAdmin` tinyint(1) DEFAULT '0',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) DEFAULT '0',
  `deletedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `firstName`, `lastName`, `userName`, `picture`, `password`, `isAdmin`, `createdAt`, `is_deleted`, `deletedAt`) VALUES
(10, 'zoltannagy@gmail.com', 'Nagy', 'Zoltán', 'ZoltanNagy12', 'https://img.com/zoli', 'Asd123', 0, '2024-11-23 13:20:11', 1, '2024-11-23 13:26:28'),
(12, 'meszarosgeza@gmail.com', 'Mészáros', 'Géza', 'Gezuka11', 'https://img.com/gezameszaros', 'meszarosgizu1', 0, '2024-11-23 13:22:57', 0, NULL),
(13, 'totharpad55@hotmail.com', 'Tóth', 'Árpád', 'TothArpi09', 'https://img.com/totharpad', 'AdminArpad898', 1, '2024-11-23 13:23:50', 0, NULL),
(14, 'user@gmail.com', 'Jhon', 'Doe', 'JDoe', 'asdhjasgdhgsad', 'Asd123!', 0, '2024-12-05 17:15:39', 0, NULL),
(16, 'admin@gmail.com', 'Jhon', 'Admin', 'AdminJoe', 'asdasdasd', 'Asd123!', 1, '2024-12-05 17:22:56', 0, NULL),
(17, 'testuser@example.com', 'John', 'Doe', 'profile.jpg', 'johndoe', 'securePassword123!', 0, '2024-12-06 11:25:40', 0, NULL),
(18, 'testAdmin@example.com', 'John', 'Admin', 'profile.jpg', 'AdminJoe', 'securePassword123!', 0, '2024-12-06 11:26:36', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_x_storage`
--

CREATE TABLE IF NOT EXISTS `user_x_storage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `storage_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `inventorymovement_x_items`
--
ALTER TABLE `inventorymovement_x_items`
  ADD CONSTRAINT `inventorymovement_x_items_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `inventorymovement` (`id`),
  ADD CONSTRAINT `inventorymovement_x_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`);

--
-- Constraints for table `inventorymovement_x_storage`
--
ALTER TABLE `inventorymovement_x_storage`
  ADD CONSTRAINT `inventorymovement_x_storage_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `inventorymovement` (`id`),
  ADD CONSTRAINT `inventorymovement_x_storage_ibfk_2` FOREIGN KEY (`fromStorage_id`) REFERENCES `storage` (`id`),
  ADD CONSTRAINT `inventorymovement_x_storage_ibfk_3` FOREIGN KEY (`toStorage_id`) REFERENCES `storage` (`id`);

--
-- Constraints for table `items_x_shelfs`
--
ALTER TABLE `items_x_shelfs`
  ADD CONSTRAINT `items_x_shelfs_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`),
  ADD CONSTRAINT `items_x_shelfs_ibfk_2` FOREIGN KEY (`shelf_id`) REFERENCES `shelfs` (`id`);

--
-- Constraints for table `shelfs_x_storage`
--
ALTER TABLE `shelfs_x_storage`
  ADD CONSTRAINT `shelfs_x_storage_ibfk_1` FOREIGN KEY (`storage_id`) REFERENCES `storage` (`id`),
  ADD CONSTRAINT `shelfs_x_storage_ibfk_2` FOREIGN KEY (`shelf_id`) REFERENCES `shelfs` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
