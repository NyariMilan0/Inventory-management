-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Gép: localhost:3306
-- Létrehozás ideje: 2025. Feb 22. 11:38
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `addPalletToShelf` (IN `skuCodeIn` VARCHAR(255) CHARSET utf8mb4, IN `shelfId` INT(11), IN `heightIn` INT(11))   BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `completeMovementRequest` (IN `movementRequestIdIn` INT, IN `userIdIn` INT)   BEGIN
    DECLARE `actionTypeIn` VARCHAR(50);
    DECLARE `palletIdIn` INT;
    DECLARE `fromShelfIdIn` INT;
    DECLARE `toShelfIdIn` INT;
    DECLARE `storageFromIn` INT;
    DECLARE `storageToIn` INT;
    DECLARE `skuIn` VARCHAR(255);

    UPDATE `movement_requests`
    SET `status` = 'completed'
    WHERE `id` = movementRequestIdIn;

    SELECT 
        `actionType`, 
        `pallet_id`, 
        `fromShelfId`, 
        `toShelfId`
    INTO 
        actionTypeIn, 
        palletIdIn, 
        fromShelfIdIn, 
        toShelfIdIn
    FROM `movement_requests`
    WHERE `id` = movementRequestIdIn;

    SELECT `storage_id` INTO storageFromIn
    FROM `shelfs_x_storage`
    WHERE `shelf_id` = fromShelfIdIn
    LIMIT 1;

    SELECT `storage_id` INTO storageToIn
    FROM `shelfs_x_storage`
    WHERE `shelf_id` = toShelfIdIn
    LIMIT 1;

    SELECT `items`.`sku` INTO skuIn
    FROM `pallets_x_items`
    JOIN `items` ON `pallets_x_items`.`item_id` = `items`.`id`
    WHERE `pallets_x_items`.`pallet_id` = palletIdIn
    LIMIT 1;

    INSERT INTO `inventorymovement` (
        `movementDate`, 
        `actionType`, 
        `storageFrom`, 
        `storageTo`, 
        `fromShelf`, 
        `toShelf`, 
        `palletSKU`, 
        `byUser`
    )
    VALUES (
        NOW(),
        actionTypeIn,
        storageFromIn,
        storageToIn,
        fromShelfIdIn,
        toShelfIdIn,
        skuIn,
        userIdIn
    );

    SET @inventoryId = LAST_INSERT_ID();
    INSERT INTO `inventorymovement_x_pallets` (
        `inventory_id`, 
        `pallet_id`, 
        `action_type`
    )
    VALUES (
        @inventoryId, 
        palletIdIn, 
        actionTypeIn
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createAddMovementRequest` (IN `adminIdIn` INT, IN `palletIdIn` INT, IN `toShelfIdIn` INT, IN `timeLimitIn` DATETIME)   BEGIN
    DECLARE `movementRequestId` INT;

    INSERT INTO `movement_requests` 
        (`adminId`, `pallet_id`, `fromShelfId`, `toShelfId`, `actionType`, `timeLimit`)
    VALUES 
        (`adminIdIn`, `palletIdIn`, NULL, `toShelfIdIn`, 'add', `timeLimitIn`);

    SET `movementRequestId` = LAST_INSERT_ID();

    INSERT INTO `movement_requests_x_pallets` 
        (`movement_requests_id`, `pallet_id`)
    VALUES 
        (`movementRequestId`, `palletIdIn`);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createMoveMovementRequest` (IN `adminIdIn` INT, IN `palletIdIn` INT, IN `fromShelfIdIn` INT, IN `toShelfIdIn` INT, IN `timeLimitIn` DATETIME)   BEGIN
    DECLARE `movementRequestId` INT;

    INSERT INTO `movement_requests` 
        (`adminId`, `pallet_id`, `fromShelfId`, `toShelfId`, `actionType`, `timeLimit`)
    VALUES 
        (`adminIdIn`, `palletIdIn`, `fromShelfIdIn`, `toShelfIdIn`, 'move', `timeLimitIn`);

    SET `movementRequestId` = LAST_INSERT_ID();

    INSERT INTO `movement_requests_x_pallets` 
        (`movement_requests_id`, `pallet_id`)
    VALUES 
        (`movementRequestId`, `palletIdIn`);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createRemoveMovementRequest` (IN `adminIdIn` INT, IN `palletIdIn` INT, IN `fromShelfIdIn` INT, IN `timeLimitIn` DATETIME)   BEGIN
    DECLARE `movementRequestId` INT;

    INSERT INTO `movement_requests` 
        (`adminId`, `pallet_id`, `fromShelfId`, `toShelfId`, `actionType`, `timeLimit`)
    VALUES 
        (`adminIdIn`, `palletIdIn`, `fromShelfIdIn`, NULL, 'remove', `timeLimitIn`);

    SET `movementRequestId` = LAST_INSERT_ID();

    INSERT INTO `movement_requests_x_pallets` 
        (`movement_requests_id`, `pallet_id`)
    VALUES 
        (`movementRequestId`, `palletIdIn`);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deletePalletById` (IN `palletId` INT)   BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteShelfFromStorage` (IN `shelfIdIn` INT, IN `storageIdIn` INT)   BEGIN
    DECLARE `storageCurrentCapacity` INT;


    DELETE FROM `shelfs_x_storage`
    WHERE `shelf_id` = `shelfIdIn` AND `storage_id` = `storageIdIn`;


    DELETE FROM `shelfs`
    WHERE `id` = `shelfIdIn`;


    SELECT `current_capacity`
    INTO `storageCurrentCapacity`
    FROM `storage`
    WHERE `id` = `storageIdIn`;

    UPDATE `storage`
    SET `current_capacity` = `storageCurrentCapacity` + 1
    WHERE `id` = `storageIdIn`;

    IF `storageCurrentCapacity` + 1 > 0 THEN
        UPDATE `storage`
        SET `isFull` = 0
        WHERE `id` = `storageIdIn`;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteUser` (IN `idIn` INT(11))   UPDATE `users`
SET `is_deleted` = 1, `deletedAt` = NOW()
WHERE `id` = idIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAdmins` ()   SELECT `users`.*
FROM `users`
WHERE `users`.`isAdmin` = 1 AND `users`.`is_deleted` IS NULL$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllNonAdmins` ()   SELECT `users`.*
FROM `users`
WHERE `isAdmin` = 0 AND `is_deleted` IS NULL$$

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
WHERE `is_deleted` = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCapacityByShelfUsage` ()   SELECT SUM(`shelfs`.`current_capacity`) AS `currentFreeSpaces`, SUM(`shelfs`.`max_capacity`) AS `maxCapacity`
FROM `shelfs`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCapacityForStorageUsage` ()   SELECT SUM(`storage`.`current_capacity`) AS `freeSpaces`, SUM(`storage`.`max_capacity`) AS `maxUsableSpace`
FROM `storage`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDeletedUserByName` (IN `firstNameIn` VARCHAR(100) CHARSET utf8mb4, IN `lastNameIn` VARCHAR(100) CHARSET utf8mb4)   SELECT `users`.*
FROM `users`
WHERE `firstName` = firstNameIn OR `lastName` = lastNameIn 
AND `is_deleted` = 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getDeletedUsers` ()   SELECT `users`.*
FROM `users`
WHERE `is_deleted` = 1
ORDER BY `firstName` ASC, `lastName` ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFullShelfs` ()   SELECT `shelfs`.*
FROM `shelfs`
WHERE `shelfs`.`isFull` = 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getItemList` ()   SELECT `items`.*
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getPalletsWithShelfs` ()   BEGIN
    SELECT 
        `pallets`.`id` AS `pallet_id`,
        `pallets`.`name` AS `pallet_name`,
        `shelfs`.`id` AS `shelf_id`,
        `shelfs`.`name` AS `shelf_name`,
        `shelfs`.`locationInStorage` AS `shelf_location`
    FROM 
        `pallets`
    JOIN 
        `pallets_x_shelfs` ON `pallets`.`id` = `pallets_x_shelfs`.`pallet_id`
    JOIN 
        `shelfs` ON `pallets_x_shelfs`.`shelf_id` = `shelfs`.`id`;
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

    -- Forrás polc adatai
    SELECT `current_capacity`, `max_capacity`
    INTO currentFromCapacity, maxFromCapacity
    FROM `shelfs`
    WHERE `id` = fromShelfIdIn;

    -- A célpolc adatai
    SELECT `current_capacity`, `max_capacity`
    INTO currentToCapacity, maxToCapacity
    FROM `shelfs`
    WHERE `id` = toShelfIdIn;

    -- Raklap áthelyezés
    UPDATE `pallets_x_shelfs`
    SET `shelf_id` = toShelfIdIn
    WHERE `pallet_id` = palletIdIn;

    -- Raklap SKU lekérdezés
    SELECT `items`.`sku` 
    INTO palletSKU
    FROM `pallets_x_items`
    JOIN `items` ON `pallets_x_items`.`item_id` = `items`.`id`
    WHERE `pallets_x_items`.`pallet_id` = palletIdIn
    LIMIT 1;

    -- Inventory mozgás rögzítése
    INSERT INTO `inventorymovement` (
        `movementDate`, `actionType`, `storageFrom`, `storageTo`, 
        `fromShelf`, `toShelf`, `palletSKU`, `byUser`
    )
    VALUES (NOW(), 'move', fromStorageIdIn, toStorageIdIn, fromShelfIdIn, toShelfIdIn, palletSKU, userIdIn);

    SET @inventoryMovementId = LAST_INSERT_ID();


    INSERT INTO `inventorymovement_x_pallets` (`inventory_id`, `pallet_id`, `action_type`) 
    VALUES (@inventoryMovementId, palletIdIn, 'move');
    UPDATE `shelfs`
    SET 
        `current_capacity` = currentFromCapacity + 1,
        `isFull` = CASE 
            WHEN (currentFromCapacity + 1) >= maxFromCapacity THEN 0
            ELSE `isFull` 
        END
    WHERE `id` = fromShelfIdIn;

-- IsFull kezelés
    UPDATE `shelfs`
    SET 
        `current_capacity` = currentToCapacity - 1,
        `isFull` = CASE 
            WHEN (currentToCapacity - 1) <= 0 THEN 1  
            ELSE 0
        END
    WHERE `id` = toShelfIdIn;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `movePalletBetweenShelfsNew` (IN `palletIdIn` INT, IN `fromShelfIdIn` INT, IN `toShelfIdIn` INT, IN `userIdIn` INT)   BEGIN
    DECLARE currentFromCapacity INT;
    DECLARE maxFromCapacity INT;
    DECLARE currentToCapacity INT;
    DECLARE maxToCapacity INT;
    DECLARE palletSKU VARCHAR(255);
    DECLARE storageFromIn INT;
    DECLARE storageToIn INT;

    START TRANSACTION;

    -- Tárolók lekérdezése a polcok alapján
    SELECT `storage_id` INTO storageFromIn FROM `shelfs_x_storage` WHERE `shelf_id` = fromShelfIdIn LIMIT 1;
    SELECT `storage_id` INTO storageToIn FROM `shelfs_x_storage` WHERE `shelf_id` = toShelfIdIn LIMIT 1;

    -- Forrás polc kapacitás adatok
    SELECT `current_capacity`, `max_capacity`
    INTO currentFromCapacity, maxFromCapacity
    FROM `shelfs`
    WHERE `id` = fromShelfIdIn;

    -- Cél polc kapacitás adatok
    SELECT `current_capacity`, `max_capacity`
    INTO currentToCapacity, maxToCapacity
    FROM `shelfs`
    WHERE `id` = toShelfIdIn;

    -- Raklap áthelyezése a célpolcra
    UPDATE `pallets_x_shelfs`
    SET `shelf_id` = toShelfIdIn
    WHERE `pallet_id` = palletIdIn;

    -- Raklap SKU lekérése
    SELECT `items`.`sku` INTO palletSKU
    FROM `pallets_x_items`
    JOIN `items` ON `pallets_x_items`.`item_id` = `items`.`id`
    WHERE `pallets_x_items`.`pallet_id` = palletIdIn
    LIMIT 1;

    -- Készletmozgás rögzítése
    INSERT INTO `inventorymovement` (
        `movementDate`, `actionType`, `storageFrom`, `storageTo`, 
        `fromShelf`, `toShelf`, `palletSKU`, `byUser`
    ) VALUES (
        NOW(), 'move', storageFromIn, storageToIn, 
        fromShelfIdIn, toShelfIdIn, palletSKU, userIdIn
    );

    SET @inventoryMovementId = LAST_INSERT_ID();

    -- Kapcsolat létrehozása a készletmozgás és a raklap között
    INSERT INTO `inventorymovement_x_pallets` 
        (`inventory_id`, `pallet_id`, `action_type`) 
    VALUES 
        (@inventoryMovementId, palletIdIn, 'move');

    -- Forrás polc kapacitás frissítése (palett eltávolítása)
    UPDATE `shelfs`
    SET 
        `current_capacity` = currentFromCapacity + 1,
        `isFull` = CASE 
            WHEN (currentFromCapacity + 1) > 0 THEN 0  -- Ha van hely, nem teli
            ELSE 1  -- Egyébként teli
        END
    WHERE `id` = fromShelfIdIn;

    -- Cél polc kapacitás frissítése (palett hozzáadása)
    UPDATE `shelfs`
    SET 
        `current_capacity` = currentToCapacity - 1,
        `isFull` = CASE 
            WHEN (currentToCapacity - 1) <= 0 THEN 1  -- Ha nincs hely, teli
            ELSE 0  -- Egyébként nem teli
        END
    WHERE `id` = toShelfIdIn;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `passwordChangeByUserId` (IN `idIn` INT(11), IN `newPassword` VARCHAR(100) CHARSET utf8mb4)   UPDATE `users`
SET `users`.`password` = newPassword
WHERE `users`.`id` = idIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerAdmin` (IN `emailIn` VARCHAR(255) CHARSET utf8mb4, IN `firstNameIn` VARCHAR(255) CHARSET utf8mb4, IN `lastNameIn` VARCHAR(255) CHARSET utf8mb4, IN `userNameIn` VARCHAR(255) CHARSET utf8mb4, IN `pictureIn` TEXT CHARSET utf8mb4, IN `passwordIn` VARCHAR(255) CHARSET utf8mb4)   INSERT INTO `users` (`email`, `firstName`, `lastName`, `userName`, `picture`, `password`, `isAdmin`)
VALUES (emailIn, firstNameIn, lastNameIn, userNameIn, pictureIn, passwordIn, 1)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerUser` (IN `emailIn` VARCHAR(255) CHARSET utf8mb4, IN `firstNameIn` VARCHAR(255) CHARSET utf8mb4, IN `lastNameIn` VARCHAR(255) CHARSET utf8mb4, IN `userNameIn` VARCHAR(255) CHARSET utf8mb4, IN `pictureIn` TEXT CHARSET utf8mb4, IN `passwordIn` VARCHAR(255) CHARSET utf8mb4)   INSERT INTO `users` (`email`, `firstName`, `lastName`, `userName`, `picture`, `password`, `isAdmin`)
VALUES (emailIn, firstNameIn, lastNameIn, userNameIn, pictureIn, passwordIn, 0)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateItem` (IN `itemIdIn` INT(11), IN `skuIn` VARCHAR(100), IN `typeIn` VARCHAR(100), IN `nameIn` VARCHAR(100), IN `amountIn` INT(100), IN `priceIn` DECIMAL(65), IN `weightIn` DECIMAL(65), IN `sizeIn` DECIMAL(65), IN `descriptionIn` TEXT)   UPDATE `items`
SET `items`.`sku` = skuIn, `items`.`type` = typeIn ,
`items`.`name` = nameIn, `items`.`amount` = amountIn, `items`.`price`= priceIn , `items`.`weight` = weightIn , `items`.`size` = sizeIn, `items`.`description` = descriptionIn
WHERE `items`.`id` = itemIdIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateMovementRequest` (IN `idIn` INT(11), IN `adminIdIn` INT(11), IN `pallet_idIn` INT(11), IN `fromShelfIdIn` INT(11), IN `toShelfIdIn` INT(11), IN `actionTypeIn` VARCHAR(100), IN `statusIn` VARCHAR(11), IN `timeLimitIn` DATETIME)   UPDATE `movement_requests`
SET `movement_requests`.`adminId` = adminIdIn,
`movement_requests`.`pallet_id` = pallet_idIn,
`movement_requests`.`fromShelfId` = fromShelfIdIn, `movement_requests`.`toShelfId` = toShelfIdIn,
`movement_requests`.`actionType` = actionTypeIn,
`movement_requests`.`status` = statusIn,
`movement_requests`.`timeLimit` = timeLimitIn
WHERE `movement_requests`.`id` = idIn$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `usernameChangeByUserId` (IN `idIn` INT(11), IN `usernameIn` VARCHAR(100) CHARSET utf8mb4)   BEGIN

UPDATE `users`
SET `users`.`userName` = usernameIn
WHERE `users`.`id` = idIn;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `userUpdate` (IN `idIn` INT(11), IN `emailIn` VARCHAR(255), IN `firstNameIn` VARCHAR(255), IN `lastNameIn` VARCHAR(255), IN `userNameIn` VARCHAR(255), IN `pictureIn` TEXT, IN `passwordIn` VARCHAR(255), IN `isAdminIn` TINYINT(1))   BEGIN
    UPDATE `users`
    SET 
        `email` = `emailIn`,
        `firstName` = `firstNameIn`,
        `lastName` = `lastNameIn`,
        `userName` = `userNameIn`,
        `picture` = `pictureIn`,
        `password` = `passwordIn`,
        `isAdmin` = `isAdminIn`
    WHERE 
        `id` = `idIn`;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `inventorymovement`
--

CREATE TABLE `inventorymovement` (
  `id` int(11) NOT NULL,
  `movementDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `actionType` varchar(11) DEFAULT NULL,
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

INSERT INTO `inventorymovement` (`id`, `movementDate`, `actionType`, `storageFrom`, `storageTo`, `fromShelf`, `toShelf`, `palletSKU`, `byUser`) VALUES
(1, '2025-01-30 14:33:32', 'add', NULL, 1, NULL, 1, NULL, 1),
(2, '2025-01-30 14:35:08', 'add', NULL, 1, NULL, 2, 'SKU001', 1),
(3, '2025-01-30 14:37:27', 'move', 1, 1, 1, 2, 'SKU001', 5),
(4, '2025-01-30 14:37:49', 'move', 1, 1, 1, 2, 'SKU001', 5),
(5, '2025-01-30 14:46:09', 'move', 1, 1, 2, 1, NULL, 2),
(6, '2025-01-30 16:11:49', 'move', 1, 1, 1, 1, NULL, 1),
(7, '2025-01-30 21:13:16', 'move', 1, 1, 1, 2, 'SKU001', 2),
(8, '2025-02-06 09:11:27', 'move', 1, 1, 1, 2, 'SKU001', 1);

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
(2, 2, 2, 'add'),
(3, 3, 2, 'move'),
(4, 4, 2, 'move'),
(5, 5, 2, 'move'),
(6, 6, 1, 'move'),
(7, 7, 5, 'move'),
(8, 8, 6, 'move');

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
(21, 'asd', 'Wood', 'asd', 1, 1, 1, 1, 'asd'),
(22, 'SKU002', 'Wood', 'Wooden Chair', 25, 79.99, 5.5, 45, 'Comfortable wooden chair with cushioned seat.'),
(23, 'SKU003', 'Wood', 'Bookshelf', 15, 149.99, 20, 180, 'Large wooden bookshelf with 5 shelves.'),
(24, 'SKU004', 'Wood', 'Coffee Table', 20, 89.99, 10, 90, 'Stylish wooden coffee table for living rooms.'),
(25, 'SKU005', 'Wood', 'Wooden Bed Frame', 8, 299.99, 30, 200, 'Durable king-size wooden bed frame.'),
(26, 'SKU006', 'Metal', 'Metal Cabinet', 12, 249.99, 25, 160, 'Secure metal storage cabinet with lock.'),
(27, 'SKU007', 'Metal', 'Steel Chair', 30, 59.99, 6, 50, 'Modern steel chair with ergonomic design.'),
(28, 'SKU008', 'Metal', 'Metal Shelf', 18, 199.99, 18, 150, 'Heavy-duty metal shelf for storage.'),
(29, 'SKU009', 'Metal', 'Iron Table', 10, 179.99, 20, 110, 'Industrial-style iron dining table.'),
(30, 'SKU010', 'Metal', 'Metal Bed Frame', 7, 279.99, 28, 190, 'Strong and sturdy metal bed frame.'),
(31, 'SKU011', 'Plastic', 'Plastic Chair', 40, 29.99, 2.5, 45, 'Lightweight and durable plastic chair.'),
(32, 'SKU012', 'Plastic', 'Plastic Storage Box', 50, 19.99, 3, 40, 'Transparent plastic storage box with lid.'),
(33, 'SKU013', 'Plastic', 'Kids Toy Set', 60, 24.99, 1.2, 30, 'Colorful plastic toy set for children.'),
(34, 'SKU014', 'Plastic', 'Plastic Table', 22, 69.99, 5, 80, 'Easy-to-clean plastic table for outdoor use.'),
(35, 'SKU015', 'Plastic', 'Water Bottle', 100, 9.99, 0.8, 25, 'Reusable BPA-free plastic water bottle.'),
(36, 'SKU016', '', 'Aluminum Ladder', 15, 129.99, 10.5, 150, 'Lightweight and durable aluminum ladder.'),
(37, 'SKU017', '', 'Aluminum Suitcase', 20, 199.99, 8, 70, 'Scratch-resistant aluminum travel suitcase.'),
(38, 'SKU018', '', 'Aluminum Laptop Stand', 30, 39.99, 1.5, 35, 'Ergonomic aluminum stand for laptops.'),
(39, 'SKU019', '', 'Aluminum Bicycle', 10, 499.99, 12, 160, 'Lightweight aluminum frame mountain bike.'),
(40, 'SKU020', '', 'Aluminum Frying Pan', 25, 59.99, 2, 30, 'Non-stick aluminum frying pan for cooking.');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `movement_requests`
--

CREATE TABLE `movement_requests` (
  `id` int(11) NOT NULL,
  `adminId` int(11) NOT NULL,
  `pallet_id` int(11) NOT NULL,
  `fromShelfId` int(11) DEFAULT NULL,
  `toShelfId` int(11) DEFAULT NULL,
  `actionType` varchar(100) NOT NULL,
  `status` varchar(11) NOT NULL DEFAULT 'pending',
  `timeLimit` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `movement_requests`
--

INSERT INTO `movement_requests` (`id`, `adminId`, `pallet_id`, `fromShelfId`, `toShelfId`, `actionType`, `status`, `timeLimit`) VALUES
(2, 3, 3, 3, 3, 'move', 'pending', '2008-11-11 13:23:44'),
(3, 3, 3, NULL, 3, 'add', 'pending', '2008-11-11 13:23:44'),
(4, 4, 4, NULL, 4, 'add', 'pending', '2025-01-31 13:23:44'),
(5, 1, 2, 1, 2, 'move', 'completed', '2025-01-31 13:23:44');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `movement_requests_x_pallets`
--

CREATE TABLE `movement_requests_x_pallets` (
  `id` int(11) NOT NULL,
  `movement_requests_id` int(11) NOT NULL,
  `pallet_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `movement_requests_x_pallets`
--

INSERT INTO `movement_requests_x_pallets` (`id`, `movement_requests_id`, `pallet_id`) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 2);

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
(5, 'Wooden Table', '2025-01-30 22:08:11', 80, 120, 80),
(6, 'Wooden Table', '2025-02-06 10:11:00', 80, 120, 80),
(7, 'Plastic Storage Box', '2025-02-21 09:27:47', 80, 120, 80),
(8, 'Plastic Chair', '2025-02-21 09:27:47', 80, 120, 80),
(9, 'Metal Bed Frame', '2025-02-21 09:27:47', 80, 120, 80),
(10, 'Iron Table', '2025-02-21 09:27:47', 80, 120, 80),
(11, 'Plastic Storage Box', '2025-02-21 09:27:47', 80, 120, 80),
(12, 'Plastic Chair', '2025-02-21 09:27:47', 80, 120, 80),
(13, 'Metal Bed Frame', '2025-02-21 09:27:47', 80, 120, 80),
(14, 'Iron Table', '2025-02-21 09:27:47', 80, 120, 80),
(15, 'Plastic Storage Box', '2025-02-21 09:27:47', 80, 120, 80),
(16, 'Plastic Chair', '2025-02-21 09:27:47', 80, 120, 80),
(17, 'Metal Bed Frame', '2025-02-21 09:27:47', 80, 120, 80),
(18, 'Iron Table', '2025-02-21 09:27:47', 80, 120, 80),
(19, 'Plastic Storage Box', '2025-02-21 09:27:47', 80, 120, 80),
(20, 'Plastic Chair', '2025-02-21 09:27:47', 80, 120, 80),
(21, 'Metal Bed Frame', '2025-02-21 09:27:47', 80, 120, 80),
(22, 'Iron Table', '2025-02-21 09:27:47', 80, 120, 80),
(23, 'Plastic Storage Box', '2025-02-21 09:27:47', 80, 120, 80),
(24, 'Plastic Chair', '2025-02-21 09:27:47', 80, 120, 80),
(25, 'Metal Bed Frame', '2025-02-21 09:27:47', 80, 120, 80),
(26, 'Iron Table', '2025-02-21 09:27:47', 80, 120, 80),
(27, 'Plastic Storage Box', '2025-02-21 09:27:47', 80, 120, 80),
(28, 'Plastic Storage Box', '2025-02-21 09:28:00', 80, 120, 80);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `pallets_x_items`
--

CREATE TABLE `pallets_x_items` (
  `id` int(11) NOT NULL,
  `pallet_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `pallets_x_items`
--

INSERT INTO `pallets_x_items` (`id`, `pallet_id`, `item_id`) VALUES
(2, 5, 21),
(3, 6, 21),
(4, 7, 32),
(5, 8, 31),
(6, 9, 30),
(7, 10, 29),
(8, 11, 32),
(9, 12, 31),
(10, 13, 30),
(11, 14, 29),
(12, 15, 32),
(13, 16, 31),
(14, 17, 30),
(15, 18, 29),
(16, 19, 32),
(17, 20, 31),
(18, 21, 30),
(19, 22, 29),
(20, 23, 32),
(21, 24, 31),
(22, 25, 30),
(23, 26, 29),
(24, 27, 32),
(25, 28, 32);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `pallets_x_shelfs`
--

CREATE TABLE `pallets_x_shelfs` (
  `id` int(11) NOT NULL,
  `pallet_id` int(11) DEFAULT NULL,
  `shelf_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `pallets_x_shelfs`
--

INSERT INTO `pallets_x_shelfs` (`id`, `pallet_id`, `shelf_id`) VALUES
(2, 5, 2),
(3, 6, 2),
(4, 7, 2),
(5, 8, 2),
(6, 9, 2),
(7, 10, 2),
(8, 11, 2),
(9, 12, 2),
(10, 13, 2),
(11, 14, 2),
(12, 15, 2),
(13, 16, 2),
(14, 17, 2),
(15, 18, 2),
(16, 19, 2),
(17, 20, 2),
(18, 21, 2),
(19, 22, 2),
(20, 23, 2),
(21, 24, 2),
(22, 25, 2),
(23, 26, 2),
(24, 27, 2),
(25, 28, 2);

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
(1, 'Shelf a', 'Isle A', 24, 24, 400, 720, 80, 4, 0),
(2, 'Shelf B', 'Isle B', 24, 0, 400, 720, 80, 4, 1),
(3, 'Shelf A', 'Isle A', 24, 24, 400, 720, 80, 4, 0),
(4, 'Shelf B', 'Isle B', 24, 24, 400, 720, 80, 4, 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `shelfs_x_storage`
--

CREATE TABLE `shelfs_x_storage` (
  `id` int(11) NOT NULL,
  `shelf_id` int(11) DEFAULT NULL,
  `storage_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `shelfs_x_storage`
--

INSERT INTO `shelfs_x_storage` (`id`, `shelf_id`, `storage_id`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 2),
(4, 4, 2);

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
(1, 'Storage A', 'Left Wing', 54, 52, 0),
(2, 'Storage B', 'East Wing', 54, 52, 0);

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
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) DEFAULT '0',
  `deletedAt` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `users`
--

INSERT INTO `users` (`id`, `email`, `firstName`, `lastName`, `userName`, `picture`, `password`, `isAdmin`, `createdAt`, `is_deleted`, `deletedAt`) VALUES
(1, 'user1@example.com', 'John', 'Doe', 'ujFelhasznalonev', 'profile1.jpg', 'ujASDas@1dasd', 0, '2025-01-30 16:36:34', 1, '2025-01-31 10:56:52'),
(2, 'user2@example.com', 'Jane', 'Smith', 'smityjhonny2', 'profile2.jpg', 'password123', 0, '2025-01-30 16:36:34', 0, NULL),
(3, 'user3@example.com', 'Michael', 'Brown', 'smityjhonny3', 'profile3.jpg', 'password123', 0, '2025-01-30 16:36:34', 0, NULL),
(4, 'user4@example.com', 'Emily', 'Davis', 'smityjhonny4', 'profile4.jpg', 'password123', 1, '2025-01-30 16:36:34', 1, '2025-01-30 14:38:07'),
(5, 'user5@example.com', 'Chris', 'Wilson', 'smityjhonny5', 'profile5.jpg', 'password123', 0, '2025-01-30 16:36:34', 1, '2025-01-30 20:56:34'),
(6, 'user6@example.com', 'Sarah', 'Miller', 'smityjhonny6', 'profile6.jpg', 'password123', 0, '2025-01-30 16:36:34', 0, NULL),
(7, 'user7@example.com', 'David', 'Anderson', 'smityjhonny7', 'profile7.jpg', 'password123', 0, '2025-01-30 16:36:34', 0, NULL),
(8, 'user8@example.com', 'Laura', 'Martinez', 'smityjhonny8', 'profile8.jpg', 'password123', 0, '2025-01-30 16:36:34', 0, NULL),
(9, 'user9@example.com', 'James', 'Taylor', 'smityjhonny9', 'profile9.jpg', 'password123', 0, '2025-01-30 16:36:34', 0, NULL),
(10, 'user10@example.com', 'Olivia', 'Harris', 'smityjhonny10', 'profile10.jpg', 'password123', 0, '2025-01-30 16:36:34', 0, NULL),
(11, 'admin1@example.com', 'Alice', 'Johnson', 'smityjhonny11', 'admin1.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(12, 'admin2@example.com', 'Bob', 'Williams', 'smityjhonny12', 'admin2.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(13, 'admin3@example.com', 'Charlie', 'Martinez', 'smityjhonny13', 'admin3.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(14, 'admin4@example.com', 'Diana', 'Rodriguez', 'smityjhonny14', 'admin4.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(15, 'admin5@example.com', 'Ethan', 'Hernandez', 'smityjhonny15', 'admin5.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(16, 'admin6@example.com', 'Fiona', 'Lopez', 'smityjhonny16', 'admin6.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(17, 'admin7@example.com', 'George', 'Gonzalez', 'smityjhonny17', 'admin7.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(18, 'admin8@example.com', 'Hannah', 'Wilson', 'smityjhonny18', 'admin8.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(19, 'admin9@example.com', 'Ian', 'Anderson', 'smityjhonny19', 'admin9.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(20, 'admin10@example.com', 'Julia', 'Thomas', 'smityjhonny20', 'admin10.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', 0, NULL),
(21, 'asd@asd.com', 'asd', 'asd', 'asd', 'asd', 'asd', 1, '2025-01-30 17:04:06', 0, NULL),
(22, 'testtest@gmail.com', 'Jónás', 'Kiszacskos', 'smityjhonny22', 'csicskaszatyor1445', 'Asdasd123@', 0, '2025-01-30 22:52:27', 0, NULL),
(23, 'adminadmin@gmail.com', 'Josephinio', 'Murányi', 'smityjhonny23', 'répaszeletelo', 'Asdasdasd123@', 0, '2025-01-30 22:55:12', 0, NULL),
(24, 'testemail@gmail.com', 'Testes', 'Kismargo', 'smityjhonny24', 'Testesikismargit', 'A@assword3211', 0, '2025-01-31 11:50:47', 0, NULL),
(25, 'testadminaa@gmail.com', 'adminka', 'kalocsai', 'smityjhonny25', 'kalocsaiadminka', 'Admin@12ij5', 0, '2025-01-31 11:53:15', 0, NULL),
(26, 'testemadil@gmail.com', 'Testes', 'Kismargo', 'https//:margitka', 'Testesikismargit', 'A@assword3211', 0, '2025-02-20 18:56:55', 0, NULL),
(27, 'fisimasi@gmail.com', 'Firstnameeee', 'Lastnameeee', 'https://www.w3schools.com/howto/img_avatar.png', 'CSiruszfiam', 'ASDasd@123', 0, '2025-02-20 18:58:56', 0, NULL),
(28, 'Admintest@gmail.com', 'Admintest', 'Admintest', 'https://www.w3schools.com/howto/img_avatar.png', 'Admintest', 'Admintest123@@', 0, '2025-02-20 18:59:53', 0, NULL),
(29, 'testadminaaa@gmail.com', 'adminka', 'kalocsai', 'https//:adminka', 'kalocsaiadminka', 'Admin@12ij5', 0, '2025-02-20 19:00:16', 0, NULL),
(30, 'asasasasasn@gmail.com', 'asd', 'asd', 'GASGSAAGSSAGSAGASGSAGASGGSA', 'asd', 'ASD123@', 1, '2025-02-20 19:00:53', 0, NULL),
(31, 'tesasgaa@gmail.com', 'adminka', 'kalocsai', 'https//:adminka', 'kalocsaiadminka', 'Admin@12ij5', 0, '2025-02-20 19:04:20', 0, NULL),
(32, 'agsgaags@gmail.com', 'adminka', 'kalocsai', 'https//:adminka', 'kalocsaiadminka', 'Admin@12ij5', 0, '2025-02-20 19:07:57', 0, NULL),
(33, 'gecags@gmail.com', 'adminka', 'kalocsai', 'https//:adminka', 'kalocsaiadminka', 'Admin@12ij5', 0, '2025-02-20 19:12:42', 0, NULL),
(34, 'gfaszg@gmail.com', 'adminka', 'kalocsai', 'https//:adminka', 'kalocsaiadminka', 'Admin@12ij5', 0, '2025-02-20 19:20:10', 0, NULL),
(35, 'fisimasnnkhhggi@gmail.com', 'asdsdf', 'asdsdf', 'https://www.w3schools.com/howto/img_avatar.png', 'asdn', 'Faszom@123asd', 0, '2025-02-20 19:45:00', 0, NULL),
(36, 'asgasg@gmail.com', 'agsasggasgsaasg', 'gaagsgsasg', 'https://www.w3schools.com/howto/img_avatar.png', 'CSiruszfiam', 'ASDasd123@@@', 0, '2025-02-21 10:08:00', 0, NULL),
(38, 'asghfgasg@gmail.com', 'agsgasasggasgsaasg', 'gaagsgsasg', 'CSiruszfiam', 'https://www.w3schools.com/howto/img_avatar.png', 'ASDasd123@@@', 0, '2025-02-21 10:25:16', 0, NULL),
(39, 'ahdhddhhdsgasg@gmail.com', 'agsasggasgsaasg', 'gaagsgsasg', 'CSiruszfiam', 'https://www.w3schools.com/howto/img_avatar.png', 'ASDasd123@@@', 0, '2025-02-21 10:27:00', 0, NULL),
(40, 'admiasasafsasfn@gmail.com', 'aasdasgfas', 'gasgasg', 'asgasgasgsa', 'https://img.com/pasd', 'asdasdaSAs@@~234125', 1, '2025-02-21 10:36:27', 0, NULL),
(41, 'gfahfdszg@gmail.com', 'adminka', 'kalocsai', 'https//:adminka', 'kalocsaiadminka', 'Admin@12ij5', 0, '2025-02-21 10:36:47', 0, NULL),
(42, 'teshdftemasdil@gmail.com', 'Testes', 'Kismargo', 'https//:margitka', 'Testesikismargit', 'A@assword3211', 0, '2025-02-21 10:37:11', 0, NULL);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user_x_storage`
--

CREATE TABLE `user_x_storage` (
  `1` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `storage_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `user_x_storage`
--

INSERT INTO `user_x_storage` (`1`, `user_id`, `storage_id`) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 2),
(6, 6, 2),
(7, 7, 2),
(8, 8, 2);

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
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sku` (`sku`);

--
-- A tábla indexei `movement_requests`
--
ALTER TABLE `movement_requests`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `movement_requests_x_pallets`
--
ALTER TABLE `movement_requests_x_pallets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `movement_requests_id` (`movement_requests_id`),
  ADD KEY `pallet_id` (`pallet_id`);

--
-- A tábla indexei `pallets`
--
ALTER TABLE `pallets`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `pallets_x_items`
--
ALTER TABLE `pallets_x_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pallet_id` (`pallet_id`),
  ADD KEY `item_id` (`item_id`);

--
-- A tábla indexei `pallets_x_shelfs`
--
ALTER TABLE `pallets_x_shelfs`
  ADD PRIMARY KEY (`id`),
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
  ADD PRIMARY KEY (`id`),
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
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- A tábla indexei `user_x_storage`
--
ALTER TABLE `user_x_storage`
  ADD PRIMARY KEY (`1`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `storage_id` (`storage_id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `inventorymovement`
--
ALTER TABLE `inventorymovement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT a táblához `inventorymovement_x_pallets`
--
ALTER TABLE `inventorymovement_x_pallets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT a táblához `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT a táblához `movement_requests`
--
ALTER TABLE `movement_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `movement_requests_x_pallets`
--
ALTER TABLE `movement_requests_x_pallets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `pallets`
--
ALTER TABLE `pallets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT a táblához `pallets_x_items`
--
ALTER TABLE `pallets_x_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT a táblához `pallets_x_shelfs`
--
ALTER TABLE `pallets_x_shelfs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT a táblához `shelfs`
--
ALTER TABLE `shelfs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT a táblához `shelfs_x_storage`
--
ALTER TABLE `shelfs_x_storage`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT a táblához `storage`
--
ALTER TABLE `storage`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT a táblához `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT a táblához `user_x_storage`
--
ALTER TABLE `user_x_storage`
  MODIFY `1` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

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
  ADD CONSTRAINT `inventorymovement_x_pallets_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `inventorymovement` (`id`);

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
