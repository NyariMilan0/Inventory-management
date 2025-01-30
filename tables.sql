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
-- Adatbázis: `raktarproject`
--

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
(6, '2025-01-30 16:11:49', 'move', 1, 1, 1, 1, NULL, 1);

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
(6, 6, 1, 'move');

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
(21, 'SKU001', 'Wood', 'Wooden Table', 10, 199.99, 15, 120, 'High-quality oak wood dining table.'),
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
(2, 2, 2, NULL, 2, 'add', 'completed', '2025-01-31 13:23:44'),
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
(4, 'Bookshelf', '2025-01-30 15:50:53', 80, 120, 80);

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
(1, 4, 23);

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
(1, 4, 2);

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
(1, 'Shelf a', 'Isle A', 24, 26, 400, 720, 80, 4, 1),
(2, 'Shelf B', 'Isle B', 24, 21, 400, 720, 80, 4, 0),
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
  `is_deleted` tinyint(1) DEFAULT NULL,
  `deletedAt` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- A tábla adatainak kiíratása `users`
--

INSERT INTO `users` (`id`, `email`, `firstName`, `lastName`, `userName`, `picture`, `password`, `isAdmin`, `createdAt`, `is_deleted`, `deletedAt`) VALUES
(1, 'user1@example.com', 'John', 'Doe', 'johndoe', 'profile1.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(2, 'user2@example.com', 'Jane', 'Smith', 'janesmith', 'profile2.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(3, 'user3@example.com', 'Michael', 'Brown', 'michaelbrown', 'profile3.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(4, 'user4@example.com', 'Emily', 'Davis', 'emilydavis', 'profile4.jpg', 'password123', 0, '2025-01-30 16:36:34', 1, '2025-01-30 14:38:07'),
(5, 'user5@example.com', 'Chris', 'Wilson', 'chriswilson', 'profile5.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(6, 'user6@example.com', 'Sarah', 'Miller', 'sarahmiller', 'profile6.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(7, 'user7@example.com', 'David', 'Anderson', 'davidanderson', 'profile7.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(8, 'user8@example.com', 'Laura', 'Martinez', 'lauramartinez', 'profile8.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(9, 'user9@example.com', 'James', 'Taylor', 'jamestaylor', 'profile9.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(10, 'user10@example.com', 'Olivia', 'Harris', 'oliviaharris', 'profile10.jpg', 'password123', 0, '2025-01-30 16:36:34', NULL, NULL),
(11, 'admin1@example.com', 'Alice', 'Johnson', 'alicejohnson', 'admin1.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(12, 'admin2@example.com', 'Bob', 'Williams', 'bobwilliams', 'admin2.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(13, 'admin3@example.com', 'Charlie', 'Martinez', 'charliemartinez', 'admin3.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(14, 'admin4@example.com', 'Diana', 'Rodriguez', 'dianarodriguez', 'admin4.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(15, 'admin5@example.com', 'Ethan', 'Hernandez', 'ethanhernandez', 'admin5.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(16, 'admin6@example.com', 'Fiona', 'Lopez', 'fionalopez', 'admin6.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(17, 'admin7@example.com', 'George', 'Gonzalez', 'georgegonzalez', 'admin7.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(18, 'admin8@example.com', 'Hannah', 'Wilson', 'hannahwilson', 'admin8.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(19, 'admin9@example.com', 'Ian', 'Anderson', 'iananderson', 'admin9.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(20, 'admin10@example.com', 'Julia', 'Thomas', 'juliathomas', 'admin10.jpg', 'adminpass123', 1, '2025-01-30 16:36:34', NULL, NULL),
(21, 'asd@asd.com', 'asd', 'asd', 'asd', 'asd', 'asd', 0, '2025-01-30 17:04:06', NULL, NULL);

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
  ADD PRIMARY KEY (`id`);

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
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT a táblához `inventorymovement_x_pallets`
--
ALTER TABLE `inventorymovement_x_pallets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT a táblához `pallets_x_items`
--
ALTER TABLE `pallets_x_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT a táblához `pallets_x_shelfs`
--
ALTER TABLE `pallets_x_shelfs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

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
