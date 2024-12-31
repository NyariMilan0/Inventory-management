-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Gép: localhost:3306
-- Létrehozás ideje: 2024. Dec 31. 08:51
-- Kiszolgáló verziója: 5.7.24
-- PHP verzió: 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `raktarproject`
--
CREATE DATABASE IF NOT EXISTS `raktarproject` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `raktarproject`;

DELIMITER $$
--
-- Eljárások
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addItem` (IN `skuIn` VARCHAR(255) CHARSET utf8mb4, IN `typeIn` VARCHAR(50) CHARSET utf8mb4, IN `nameIn` VARCHAR(255) CHARSET utf8mb4, IN `amountIn` INT(11), IN `priceIn` DECIMAL(10,2), IN `weightIn` DECIMAL(10,2), IN `sizeIn` DECIMAL(10,2), IN `descriptionIn` TEXT CHARSET utf8mb4)   BEGIN
    INSERT INTO `items` (
        `sku`, `type`, `name`, `amount`, `price`, `weight`, `size`, `description`
    ) 
    VALUES (
        skuIn, typeIn, nameIn, amountIn, priceIn, weightIn, sizeIn, descriptionIn
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addPalletWithItems` (IN `skuCodeIn` VARCHAR(255) CHARSET utf8mb4, IN `shelfId` INT(11), IN `heightIn` INT(11))   BEGIN
DECLARE `newPalletId` INT;
DECLARE `palletName` VARCHAR(255);
DECLARE `maxCapacity` INT;
DECLARE `currentCapacity` INT;

SELECT `items`.`name`
INTO `palletName`
FROM `items`
WHERE `items`.`sku` = `skuCodeIn`
LIMIT 1;

INSERT INTO `pallets` (`name`, `height`) 
VALUES (`palletName`, `heightIn`);

SET `newPalletId` = LAST_INSERT_ID();

INSERT INTO `pallets_x_items` (`pallet_id`, `item_id`)
SELECT `newPalletId`, `items`.`id`
FROM `items`
WHERE `items`.`sku` = `skuCodeIn`;

INSERT INTO `pallets_x_shelfs` (`pallet_id`, `shelf_id`)
VALUES (`newPalletId`, `shelfId`);

SELECT `current_capacity`, `max_capacity`
INTO `currentCapacity`, `maxCapacity`
FROM `shelfs`
WHERE `id` = `shelfId`;

UPDATE `shelfs`
SET `current_capacity` = `currentCapacity` - 1
WHERE `id` = `shelfId`;

IF `currentCapacity` - 1 <= 0 THEN

UPDATE `shelfs`
SET `isFull` = 1
WHERE `id` = `shelfId`;

ELSE
UPDATE `shelfs`
SET `isFull` = 0
WHERE `id` = `shelfId`;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addShelfToStorage` (IN `storageIdIn` INT, IN `shelfNameIn` VARCHAR(255), IN `locationIn` VARCHAR(255))   BEGIN
DECLARE `storageCurrentCapacity` INT;

INSERT INTO `shelfs` (`name`, `locationInStorage`)
VALUES (`shelfNameIn`, `locationIn`);

SELECT `current_capacity`
INTO `storageCurrentCapacity`
FROM `storage`
WHERE `id` = `storageIdIn`;

UPDATE `storage`
SET `current_capacity` = `storageCurrentCapacity` - 1
WHERE `id` = `storageIdIn`;

IF `storageCurrentCapacity` - 1 <= 0 THEN

UPDATE `storage`
SET `isFull` = 1
WHERE `id` = `storageIdIn`;

END IF;

INSERT INTO `shelfs_x_storage` (`shelf_id`, `storage_id`)
VALUES (LAST_INSERT_ID(), `storageIdIn`);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addStorage` (IN `storageNameIn` VARCHAR(255) CHARSET utf8mb4, IN `locationIn` VARCHAR(255) CHARSET utf8mb4)   INSERT INTO `storage` (`name`, `location`, `isFull`)
VALUES (storageNameIn, locationIn, 0)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `assignUserToStorage` (IN `userId` INT, IN `storageId` INT)   INSERT INTO `user_x_storage` (user_id, storage_id)
VALUES (userId, storageId)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deletePallet` (IN `palletId` INT)   BEGIN
DECLARE shelfId INT;

SELECT `shelf_id`
INTO shelfId
FROM `pallets_x_shelfs`
WHERE `pallets_x_shelfs`.`pallet_id` = `palletId`
LIMIT 1;

DELETE FROM `pallets_x_items` WHERE `pallet_id` = `palletId`;

DELETE FROM `pallets_x_shelfs` WHERE `pallet_id` = `palletId`;

DELETE FROM `pallets` WHERE `id` = `palletId`;
UPDATE `shelfs`
SET `current_capacity` = `current_capacity` + 1
WHERE `shelfs`.`id` = shelfId;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteUser` (IN `idIn` INT(11))   UPDATE `users`
SET `is_deleted` = 1, `deletedAt` = NOW()
WHERE `id` = idIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAdmins` ()   SELECT `users`.*
FROM `users`
WHERE `isAdmin` = 1 AND `is_deleted` = 0
ORDER BY `firstName` ASC, `lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllNonAdmins` ()   SELECT `users`.*
FROM `users`
WHERE `isAdmin` = 0 AND `is_deleted` = 0
ORDER BY `firstName` ASC, `lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllPallets` ()   BEGIN
SELECT
`pallets`.`id` AS `palletId`,
`pallets`.`name` AS `palletName`,
`pallets`.`height` AS `palletHeight`,
`pallets`.`width` AS `palletWidth`,
`pallets`.`created_at` AS `palletCreated_at`,
`shelfs`.`id` AS `shelfId`,
`shelfs`.`name` AS `shelfName`,
`shelfs`.`locationInStorage` AS `shelfLocation`,
`items`.`id` AS `itemId`,
`items`.`sku` AS `itemSku`,
`items`.`name` AS `itemName`

FROM `pallets`
LEFT JOIN `pallets_x_shelfs` ON `pallets`.`id` = `pallets_x_shelfs`.`pallet_id`

LEFT JOIN `shelfs` ON `pallets_x_shelfs`.`shelf_id` = `shelfs`.`id`

LEFT JOIN `pallets_x_items` ON `pallets`.`id` = `pallets_x_items`.`pallet_id`

LEFT JOIN `items` ON `pallets_x_items`.`item_id` = `items`.`id`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllShelfsItems` ()   SELECT 
`shelfs`.`id` AS `shelf_id`,
`shelfs`.`name` AS `shelf_name`,
`shelfs`.`locationInStorage` AS`shelf_location`,
`items`.`id` AS `item_id`,
`items`.`name` AS `item_name`,
`items`.`type` AS `item_type`,
`pallets`.`name` AS `pallet_name`

FROM `shelfs` JOIN `pallets_x_shelfs`
ON `shelfs`.`id` = `pallets_x_shelfs`.`shelf_id`
JOIN `pallets` ON `pallets_x_shelfs`.`pallet_id` = `pallets`.`id`
JOIN `pallets_x_items` ON `pallets`.`id` = `pallets_x_items`.`pallet_id`
JOIN `items` ON `pallets_x_items`.`item_id` = `items`.`id`
ORDER BY `pallets_x_shelfs`.`shelf_id`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllUsers` ()   SELECT `users`.*
FROM `users`
WHERE `is_deleted` = 0
ORDER BY `firstName` ASC, `lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDeletedUserByName` (IN `firstNameIn` VARCHAR(100) CHARSET utf8mb4, IN `lastNameIn` VARCHAR(100) CHARSET utf8mb4)   SELECT `users`.*
FROM `users`
WHERE `firstName` = firstNameIn OR `lastName` = lastNameIn 
AND `is_deleted` = 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDeletedUsers` ()   SELECT `users`.*
FROM `users`
WHERE `is_deleted` = 1
ORDER BY `firstName` ASC, `lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemList` ()   SELECT `items`.`name`, `items`.`sku`, `items`.`amount`
FROM `items`
WHERE `items`.`amount` IS NOT NULL$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsByShelfId` (IN `shelfIdIn` INT)   SELECT `items`.*
FROM  `pallets_x_items` JOIN  `items`
ON `pallets_x_items`.`item_id` = `items`.`id` 
JOIN  `pallets_x_shelfs`
ON `pallets_x_items`.`pallet_id` = `pallets_x_shelfs`.`pallet_id`
WHERE  `pallets_x_shelfs`.`shelf_id` = shelfIdIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsBySKU` (IN `skuIn` VARCHAR(100) CHARSET utf8mb4)   SELECT `items`.*
FROM `items`
WHERE `items`.`sku` = skuIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsBySkuInStorage` (IN `skuCode` VARCHAR(255), IN `storageId` INT)   SELECT 
`items`.`id` AS `itemId`,
`items`.`sku` AS `itemSku`,
`items`.`name` AS `itemName`,
`items`.`type` AS `itemType`,
`items`.`amount` AS `itemAmount`,
`items`.`price` AS `itemPrice`,
`items`.`weight` AS `itemWeight`,
`items`.`size` AS `itemSize`

FROM `items` 
JOIN `pallets_x_items` 
ON `items`.`id` = `pallets_x_items`.`item_id`
JOIN `pallets` 
ON `pallets_x_items`.`pallet_id` = `pallets`.`id`
JOIN `pallets_x_shelfs` 
ON `pallets`.`id` = `pallets_x_shelfs`.`pallet_id`
JOIN `shelfs_x_storage` 
ON `pallets_x_shelfs`.`shelf_id` = `shelfs_x_storage`.`shelf_id`

WHERE `items`.`sku` = `skuCode`
AND `shelfs_x_storage`.`storage_id` = `storageId`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsByStorageId` (IN `storageId` INT)   BEGIN
SELECT 
`items`.`id` AS `itemId`,
`items`.`sku` AS `itemSku`,
`items`.`name` AS `itemName`,
`items`.`type` AS `itemType`,
`items`.`amount` AS `itemAmount`,
`items`.`price` AS `itemPrice`,
`items`.`weight` AS `itemWeight`,
`items`.`size` AS `itemSize`

FROM `items`
JOIN `pallets_x_items` ON `items`.`id` = `pallets_x_items`.`item_id`

JOIN `pallets` ON `pallets_x_items`.`pallet_id` = `pallets`.`id`

JOIN `pallets_x_shelfs` ON `pallets`.`id` = `pallets_x_shelfs`.`pallet_id` #Raklapok és polcok kapcsolata

JOIN `shelfs_x_storage` ON `pallets_x_shelfs`.`shelf_id` = `shelfs_x_storage`.`shelf_id` #Polcok és tárolók kapcsolata

WHERE `shelfs_x_storage`.`storage_id` = `storageId`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsByType` (IN `typeIn` VARCHAR(255))   SELECT `items`.*
FROM `items`
WHERE `items`.`type` = `typeIn`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemsSorted` (IN `sortBy` VARCHAR(255), IN `sortOrder` VARCHAR(4))   BEGIN
SET @sql = CONCAT(
'SELECT ',
'`items`.`id` AS `item_id`, ',
'`items`.`sku` AS `item_sku`, ',
'`items`.`name` AS `item_name`, ',
'`items`.`type` AS `item_type`, ',
'`items`.`amount` AS `item_amount`, ',
'`items`.`price` AS `item_price`, ',
'`items`.`weight` AS `item_weight`, ',
'`items`.`size` AS `item_size` ',
'FROM `items` ',
'ORDER BY ', sortBy, ' ', sortOrder);

PREPARE stmt FROM @sql;
EXECUTE stmt;

DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getPalletByShelfId` (IN `shelfIdIn` INT)   BEGIN
SELECT 
    `pallets`.`id` AS `palletId`, 
    `pallets`.`name` AS `palletName`, 
    `pallets`.`height` AS `palletHeight`, 
    `pallets`.`length` AS `palletLength`, 
    `pallets`.`width` AS `palletWidth`
    
FROM `pallets`
JOIN `pallets_x_shelfs` ON `pallets`.`id` = `pallets_x_shelfs`.`pallet_id`
WHERE `pallets_x_shelfs`.`shelf_id` = `shelfIdIn`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getPalletsByStorageId` (IN `storageIdIn` INT)   BEGIN
SELECT 
`pallets`.`id` AS `palletId`,
`pallets`.`name` AS `palletName`,
`shelfs`.`id` AS `shelfId`,
`shelfs`.`name` AS `shelfName`,
`shelfs`.`locationInStorage` AS `shelfLocation`

FROM 
`pallets`
JOIN `pallets_x_shelfs` ON `pallets`.`id` = `pallets_x_shelfs`.`pallet_id`

JOIN `shelfs` ON `pallets_x_shelfs`.`shelf_id` = `shelfs`.`id`

JOIN `shelfs_x_storage` ON `shelfs`.`id` = `shelfs_x_storage`.`shelf_id`

WHERE `shelfs_x_storage`.`storage_id` = storageIdIn;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getShelfsByStorageId` (IN `storageId` INT)   BEGIN
SELECT 
`shelfs`.`id` AS `shelf_id`,
`shelfs`.`name` AS `shelf_name`,
`shelfs`.`locationInStorage` AS `shelf_location`,
`shelfs`.`max_capacity` AS `shelf_max_capacity`,
`shelfs`.`isFull` AS `shelf_is_full`

FROM `shelfs`
JOIN `shelfs_x_storage` ON `shelfs`.`id` = `shelfs_x_storage`.`shelf_id`

WHERE 
    `shelfs_x_storage`.`storage_id` = `storageId`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getStoragesUsers` (IN `storageIdIN` INT)   SELECT `users`.*
FROM `users` 
JOIN `user_x_storage` ON `users`.`id` = `user_x_storage`.`user_id`
JOIN `storage` ON `user_x_storage`.`storage_id` = `storage`.`id`
WHERE `storage`.`id` = storageIdIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserById` (IN `userIdIn` INT(11))   SELECT * FROM `users` WHERE `id` = userIdIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserByName` (IN `firstNameIn` VARCHAR(255) CHARSET utf8mb4, IN `lastNameIN` VARCHAR(255) CHARSET utf8mb4)   SELECT `users`.*
FROM `users`
WHERE `firstName` = firstNameIn OR `lastName` = lastNameIN 
AND `is_deleted` = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `isUserExist` (IN `emailIN` VARCHAR(100), OUT `resultOUT` BOOLEAN)   SELECT COUNT(*) 
INTO resultOUT
FROM `users`
WHERE `email` = emailIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listAllUsersWithStorageId` ()   BEGIN
    SELECT 
        `users`.`userName` AS username, 
        `users`.`firstName` AS first_name, 
        `users`.`lastName` AS last_name, 
        `users`.`email` AS email, 
        `user_x_storage`.`storage_id` AS worksInStorageId
    FROM 
        users
    LEFT JOIN 
        `user_x_storage` ON `users`.`id` = `user_x_storage`.`user_id`
    ORDER BY `user_x_storage`.`storage_id`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `usernameIN` VARCHAR(100) CHARSET utf8mb4, IN `passwordIN` VARCHAR(100) CHARSET utf8mb4)   SELECT * FROM `users` WHERE `username` = usernameIN AND `password` = passwordIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `movePalletBetweenShelfs` (IN `palletIdIn` INT, IN `fromStorageIdIn` INT, IN `fromShelfIdIn` INT, IN `toStorageIdIn` INT, IN `toShelfIdIn` INT, IN `userIdIn` INT)   BEGIN
DECLARE currentFromCapacity INT;
DECLARE maxFromCapacity INT;
DECLARE currentToCapacity INT;
DECLARE maxToCapacity INT;
DECLARE palletSKU VARCHAR(255);

START TRANSACTION;
SELECT `current_capacity`, `max_capacity`
INTO currentFromCapacity, maxFromCapacity
FROM `shelfs`
WHERE `id` = fromShelfIdIn;

SELECT `current_capacity`, `max_capacity`
INTO currentToCapacity, maxToCapacity
FROM `shelfs`
WHERE `id` = toShelfIdIn;

UPDATE `pallets_x_shelfs`
SET `shelf_id` = toShelfIdIn
WHERE `pallet_id` = palletIdIn;

SELECT `items`.`sku` 
INTO palletSKU
FROM `pallets_x_items`
JOIN `items` ON `pallets_x_items`.`item_id` = `items`.`id`
WHERE `pallets_x_items`.`pallet_id` = palletIdIn
LIMIT 1;

INSERT INTO `inventorymovement` (`movementDate`, `storageFrom`, `storageTo`, `fromShelf`, `toShelf`, `palletSKU`, `byUser`
    )
VALUES (NOW(), fromStorageIdIn, toStorageIdIn, fromShelfIdIn, toShelfIdIn, palletSKU, userIdIn);

SET @inventoryMovementId = LAST_INSERT_ID();

INSERT INTO `inventorymovement_x_pallets` (`inventory_id`, `pallet_id`, `action_type`) 
VALUES (@inventoryMovementId, palletIdIn, 'move');

UPDATE `shelfs`
SET `current_capacity` = currentFromCapacity + 1,`isFull` = CASE 
WHEN currentFromCapacity + 1 >= maxFromCapacity 
THEN 1
ELSE 0 
END

WHERE `id` = fromShelfIdIn;
UPDATE `shelfs`
SET `current_capacity` = currentToCapacity - 1,
`isFull` = CASE 
WHEN currentToCapacity - 1 <= 0 THEN 1
ELSE 0
END

 WHERE `id` = toShelfIdIn;
 COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerAdmin` (IN `emailIn` VARCHAR(255) CHARSET utf8mb4, IN `firstNameIn` VARCHAR(255) CHARSET utf8mb4, IN `lastNameIn` VARCHAR(255) CHARSET utf8mb4, IN `userNameIn` VARCHAR(255) CHARSET utf8mb4, IN `pictureIn` TEXT CHARSET utf8mb4, IN `passwordIn` VARCHAR(255) CHARSET utf8mb4)   INSERT INTO `users` (`email`, `firstName`, `lastName`, `userName`, `picture`, `password`, `isAdmin`)
VALUES (emailIn, firstNameIn, lastNameIn, userNameIn, pictureIn, passwordIn, 1)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerUser` (IN `emailIn` VARCHAR(255) CHARSET utf8mb4, IN `firstNameIn` VARCHAR(255) CHARSET utf8mb4, IN `lastNameIn` VARCHAR(255) CHARSET utf8mb4, IN `userNameIn` VARCHAR(255) CHARSET utf8mb4, IN `pictureIn` TEXT CHARSET utf8mb4, IN `passwordIn` VARCHAR(255) CHARSET utf8mb4)   INSERT INTO `users` (`email`, `firstName`, `lastName`, `userName`, `picture`, `password`, `isAdmin`)
VALUES (emailIn, firstNameIn, lastNameIn, userNameIn, pictureIn, passwordIn, 0)$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `inventorymovement`
--

CREATE TABLE `inventorymovement` (
  `id` int(11) NOT NULL,
  `movementDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `storageFrom` int(11) DEFAULT NULL,
  `storageTo` int(11) DEFAULT NULL,
  `fromShelf` int(11) DEFAULT NULL,
  `toShelf` int(11) DEFAULT NULL,
  `palletSKU` varchar(50) DEFAULT NULL,
  `byUser` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `inventorymovement`
--

INSERT INTO `inventorymovement` (`id`, `movementDate`, `storageFrom`, `storageTo`, `fromShelf`, `toShelf`, `palletSKU`, `byUser`) VALUES
(2, '2024-12-29 15:21:46', 1, 1, 1, 2, 'SKU002', 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `inventorymovement_x_pallets`
--

CREATE TABLE `inventorymovement_x_pallets` (
  `id` int(11) NOT NULL,
  `inventory_id` int(11) DEFAULT NULL,
  `pallet_id` int(11) DEFAULT NULL,
  `action_type` enum('add','remove','move') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `inventorymovement_x_pallets`
--

INSERT INTO `inventorymovement_x_pallets` (`id`, `inventory_id`, `pallet_id`, `action_type`) VALUES
(4, 2, 4, 'move');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `type` enum('Metal','Wood','Titanium','Plastic') DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `price` double DEFAULT NULL,
  `weight` double DEFAULT NULL,
  `size` double DEFAULT NULL,
  `description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `items`
--

INSERT INTO `items` (`id`, `sku`, `type`, `name`, `amount`, `price`, `weight`, `size`, `description`) VALUES
(1, 'SKU001', 'Metal', 'Steel Plate', 50, 500, 200.5, 100.2, 'A flat plate made of steel, used in construction and manufacturing.'),
(2, 'SKU002', 'Wood', 'Wooden Beam', 75, 150, 150, 120.5, 'A long wooden beam used in carpentry and construction.'),
(3, 'SKU003', 'Titanium', 'Titanium Rod', 60, 2000, 450, 30, 'A high-strength titanium rod used in aerospace.'),
(4, 'SKU004', 'Plastic', 'PVC Pipe', 100, 100, 50, 30, 'PVC pipes for plumbing systems.'),
(5, 'SKU005', 'Wood', 'Oak Plank', 45, 120, 80, 40, 'High-quality oak wood planks for furniture.'),
(6, 'SKU006', 'Metal', 'Iron Nails', 2000, 20, 1.2, 10, 'Pack of iron nails for construction use.'),
(7, 'SKU007', 'Plastic', 'Plastic Bags', 150, 50, 5, 15, 'Environmentally friendly plastic bags for various uses.'),
(8, 'SKU008', 'Titanium', 'Titanium Sheet', 20, 5000, 800, 200, 'High-strength titanium sheet used for industrial applications.'),
(9, 'SKU009', 'Metal', 'Copper Wire', 300, 350, 250, 150, 'Copper wire for electrical wiring systems.'),
(10, 'SKU010', 'Plastic', 'Plastic Sheeting', 100, 200, 120, 60, 'Durable plastic sheeting used for construction sites.'),
(11, 'SKU011', 'Wood', 'Pine Log', 120, 300, 500, 200, 'Pine logs used for woodcrafts and furniture making.'),
(12, 'SKU012', 'Titanium', 'Titanium Plate', 30, 4000, 1000, 200, 'Large titanium plate used in aerospace technology.'),
(13, 'SKU013', 'Plastic', 'Nylon Rope', 50, 80, 100, 20, 'Strong nylon rope used in maritime applications.'),
(14, 'SKU014', 'Wood', 'Cherry Wood Slabs', 25, 350, 150, 45, 'Premium cherry wood slabs for high-end furniture.'),
(15, 'SKU015', 'Metal', 'Aluminum Sheet', 75, 600, 200, 120, 'Thin aluminum sheets for manufacturing.'),
(16, 'SKU016', 'Titanium', 'Titanium Wire', 40, 2500, 200, 75, 'High-performance titanium wire used in medical devices.'),
(17, 'SKU017', 'Plastic', 'ABS Plastic Sheet', 60, 180, 120, 30, 'ABS plastic sheet commonly used in automotive industries.'),
(18, 'SKU018', 'Metal', 'Brass Rod', 50, 800, 400, 120, 'Brass rods used in machining and manufacturing.'),
(19, 'SKU019', 'Wood', 'Bamboo Plank', 150, 180, 60, 35, 'Bamboo planks for eco-friendly flooring options.'),
(20, 'SKU020', 'Titanium', 'Titanium Bolts', 500, 10000, 50, 10, 'Titanium bolts used in engineering and structural work.'),
(21, 'SKU001245', 'Metal', 'Flange nut', 123, 525, 500, 25, 'A flange nut is a type of nut that has a wide flange at one end, which serves as an integrated washer.');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `pallets`
--

CREATE TABLE `pallets` (
  `id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `height` int(11) DEFAULT NULL,
  `length` int(11) DEFAULT '120',
  `width` int(11) DEFAULT '80'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `pallets`
--

INSERT INTO `pallets` (`id`, `name`, `created_at`, `height`, `length`, `width`) VALUES
(4, 'Wooden Beam', '2024-12-29 16:11:01', 80, 120, 80),
(5, 'Titanium Rod', '2024-12-30 22:27:28', 80, 120, 80),
(6, 'Titanium Rod', '2024-12-30 22:27:34', 180, 120, 80),
(7, 'Titanium Rod', '2024-12-30 22:27:40', 180, 120, 80),
(8, 'Titanium Rod', '2024-12-30 22:27:49', 80, 120, 80),
(9, 'Titanium Rod', '2024-12-30 22:28:04', 80, 120, 80),
(10, 'Steel Plate', '2024-12-30 22:28:09', 80, 120, 80),
(11, 'Titanium Rod', '2024-12-30 22:29:22', 80, 120, 80);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `pallets_x_items`
--

CREATE TABLE `pallets_x_items` (
  `pallet_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `pallets_x_items`
--

INSERT INTO `pallets_x_items` (`pallet_id`, `item_id`) VALUES
(4, 2),
(5, 3),
(6, 3),
(7, 3),
(8, 3),
(9, 3),
(10, 1),
(11, 3);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `pallets_x_shelfs`
--

CREATE TABLE `pallets_x_shelfs` (
  `pallet_id` int(11) DEFAULT NULL,
  `shelf_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `pallets_x_shelfs`
--

INSERT INTO `pallets_x_shelfs` (`pallet_id`, `shelf_id`) VALUES
(4, 2),
(5, 2),
(6, 2),
(7, 2),
(8, 2),
(9, 2),
(10, 2),
(11, 2);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `shelfs`
--

CREATE TABLE `shelfs` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `locationInStorage` varchar(255) DEFAULT NULL,
  `max_capacity` int(11) DEFAULT '24',
  `current_capacity` int(11) DEFAULT '24',
  `height` int(11) DEFAULT '400',
  `length` int(11) DEFAULT '720',
  `width` int(11) DEFAULT '80',
  `levels` int(11) DEFAULT '4',
  `isFull` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `shelfs`
--

INSERT INTO `shelfs` (`id`, `name`, `locationInStorage`, `max_capacity`, `current_capacity`, `height`, `length`, `width`, `levels`, `isFull`) VALUES
(1, 'Shelf A', 'Section 1', 24, 24, 400, 720, 80, 4, 1),
(2, 'Shelf B', 'Section 2', 24, 16, 400, 720, 80, 4, 0),
(3, 'Shelf C', 'Section 3', 24, 24, 400, 720, 80, 4, 0),
(4, 'Shelf A', 'Section 1', 24, 24, 400, 720, 80, 4, 0),
(5, 'Shelf B', 'Section 2', 24, 24, 400, 720, 80, 4, 0),
(6, 'Shelf C', 'Section 3', 24, 24, 400, 720, 80, 4, 0),
(7, 'Shelf J', 'Section 5', 24, 24, 400, 720, 80, 4, 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `shelfs_x_storage`
--

CREATE TABLE `shelfs_x_storage` (
  `shelf_id` int(11) DEFAULT NULL,
  `storage_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `shelfs_x_storage`
--

INSERT INTO `shelfs_x_storage` (`shelf_id`, `storage_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 2),
(6, 2),
(7, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `storage`
--

CREATE TABLE `storage` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `max_capacity` int(11) DEFAULT '54',
  `current_capacity` int(11) DEFAULT '54',
  `isFull` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `storage`
--

INSERT INTO `storage` (`id`, `name`, `location`, `max_capacity`, `current_capacity`, `isFull`) VALUES
(1, 'Storage A', 'South Wing', 54, 53, 0),
(2, 'Storage B', 'Left Wing', 54, 54, 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `firstName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `userName` varchar(255) DEFAULT NULL,
  `picture` text,
  `password` varchar(255) DEFAULT NULL,
  `isAdmin` tinyint(1) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `deletedAt` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `users`
--

INSERT INTO `users` (`id`, `email`, `firstName`, `lastName`, `userName`, `picture`, `password`, `isAdmin`, `is_deleted`, `deletedAt`) VALUES
(1, 'admin@gmail.com', 'Tóth', 'Bober', 'Johnbober1', 'https://img.com/potpont', 'ASD123@', 0, NULL, NULL),
(2, 'admi1n@gmail.com', 'Asd', 'asd', 'Postpone123', 'https://img.com/gezameszaros', 'test123', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user_x_storage`
--

CREATE TABLE `user_x_storage` (
  `user_id` int(11) DEFAULT NULL,
  `storage_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `inventorymovement`
--
ALTER TABLE `inventorymovement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `storageFrom` (`storageFrom`),
  ADD KEY `storageTo` (`storageTo`),
  ADD KEY `fromShelf` (`fromShelf`),
  ADD KEY `toShelf` (`toShelf`),
  ADD KEY `byUser` (`byUser`);

--
-- A tábla indexei `inventorymovement_x_pallets`
--
ALTER TABLE `inventorymovement_x_pallets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `inventory_id` (`inventory_id`),
  ADD KEY `pallet_id` (`pallet_id`);

--
-- A tábla indexei `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `pallets`
--
ALTER TABLE `pallets`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `pallets_x_items`
--
ALTER TABLE `pallets_x_items`
  ADD KEY `pallet_id` (`pallet_id`),
  ADD KEY `item_id` (`item_id`);

--
-- A tábla indexei `pallets_x_shelfs`
--
ALTER TABLE `pallets_x_shelfs`
  ADD KEY `pallet_id` (`pallet_id`),
  ADD KEY `shelf_id` (`shelf_id`);

--
-- A tábla indexei `shelfs`
--
ALTER TABLE `shelfs`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `shelfs_x_storage`
--
ALTER TABLE `shelfs_x_storage`
  ADD KEY `shelf_id` (`shelf_id`),
  ADD KEY `storage_id` (`storage_id`);

--
-- A tábla indexei `storage`
--
ALTER TABLE `storage`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `user_x_storage`
--
ALTER TABLE `user_x_storage`
  ADD KEY `user_id` (`user_id`),
  ADD KEY `storage_id` (`storage_id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `inventorymovement`
--
ALTER TABLE `inventorymovement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT a táblához `inventorymovement_x_pallets`
--
ALTER TABLE `inventorymovement_x_pallets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT a táblához `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT a táblához `pallets`
--
ALTER TABLE `pallets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT a táblához `shelfs`
--
ALTER TABLE `shelfs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT a táblához `storage`
--
ALTER TABLE `storage`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT a táblához `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `inventorymovement`
--
ALTER TABLE `inventorymovement`
  ADD CONSTRAINT `inventorymovement_ibfk_1` FOREIGN KEY (`storageFrom`) REFERENCES `storage` (`id`),
  ADD CONSTRAINT `inventorymovement_ibfk_2` FOREIGN KEY (`storageTo`) REFERENCES `storage` (`id`),
  ADD CONSTRAINT `inventorymovement_ibfk_3` FOREIGN KEY (`fromShelf`) REFERENCES `shelfs` (`id`),
  ADD CONSTRAINT `inventorymovement_ibfk_4` FOREIGN KEY (`toShelf`) REFERENCES `shelfs` (`id`),
  ADD CONSTRAINT `inventorymovement_ibfk_5` FOREIGN KEY (`byUser`) REFERENCES `users` (`id`);

--
-- Megkötések a táblához `inventorymovement_x_pallets`
--
ALTER TABLE `inventorymovement_x_pallets`
  ADD CONSTRAINT `inventorymovement_x_pallets_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `inventorymovement` (`id`),
  ADD CONSTRAINT `inventorymovement_x_pallets_ibfk_2` FOREIGN KEY (`pallet_id`) REFERENCES `pallets` (`id`);

--
-- Megkötések a táblához `pallets_x_items`
--
ALTER TABLE `pallets_x_items`
  ADD CONSTRAINT `pallets_x_items_ibfk_1` FOREIGN KEY (`pallet_id`) REFERENCES `pallets` (`id`),
  ADD CONSTRAINT `pallets_x_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`);

--
-- Megkötések a táblához `pallets_x_shelfs`
--
ALTER TABLE `pallets_x_shelfs`
  ADD CONSTRAINT `pallets_x_shelfs_ibfk_1` FOREIGN KEY (`pallet_id`) REFERENCES `pallets` (`id`),
  ADD CONSTRAINT `pallets_x_shelfs_ibfk_2` FOREIGN KEY (`shelf_id`) REFERENCES `shelfs` (`id`);

--
-- Megkötések a táblához `shelfs_x_storage`
--
ALTER TABLE `shelfs_x_storage`
  ADD CONSTRAINT `shelfs_x_storage_ibfk_1` FOREIGN KEY (`shelf_id`) REFERENCES `shelfs` (`id`),
  ADD CONSTRAINT `shelfs_x_storage_ibfk_2` FOREIGN KEY (`storage_id`) REFERENCES `storage` (`id`);

--
-- Megkötések a táblához `user_x_storage`
--
ALTER TABLE `user_x_storage`
  ADD CONSTRAINT `user_x_storage_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `user_x_storage_ibfk_2` FOREIGN KEY (`storage_id`) REFERENCES `storage` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
