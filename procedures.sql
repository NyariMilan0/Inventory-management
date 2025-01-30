-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Gép: localhost:3306
-- Létrehozás ideje: 2025. Jan 30. 16:12
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
-- Adatbázis: raktarproject
--

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
WHERE `is_deleted` IS NULL$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `usernameIN` VARCHAR(100) CHARSET utf8mb4, IN `passwordIN` VARCHAR(100) CHARSET utf8mb4)   SELECT * FROM `users` WHERE `username` = usernameIN AND `password` = passwordIN
-- Ez a login$$

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

    INSERT INTO `inventorymovement` (
        `movementDate`, `actionType`, `storageFrom`, `storageTo`, 
        `fromShelf`, `toShelf`, `palletSKU`, `byUser`
    )
    VALUES (NOW(), "move", fromStorageIdIn, toStorageIdIn, fromShelfIdIn, toShelfIdIn, palletSKU, userIdIn);

    SET @inventoryMovementId = LAST_INSERT_ID();

    INSERT INTO `inventorymovement_x_pallets` (`inventory_id`, `pallet_id`, `action_type`) 
    VALUES (@inventoryMovementId, palletIdIn, 'move');

    UPDATE `shelfs`
    SET `current_capacity` = currentFromCapacity - 1, 
        `isFull` = CASE 
            WHEN currentFromCapacity - 1 = 0 THEN 1  -- Ha eléri a 0-t, akkor legyen teljesen üres
            ELSE 0 
        END
    WHERE `id` = fromShelfIdIn;

    UPDATE `shelfs`
    SET `current_capacity` = currentToCapacity + 1, 
        `isFull` = CASE 
            WHEN currentToCapacity + 1 >= maxToCapacity THEN 1  -- Ha eléri a max kapacitást, akkor legyen tele
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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
