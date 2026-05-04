-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 04, 2026 at 04:19 AM
-- Server version: 10.4.32-MariaDB-log
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cinemaclick`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_seats` ()   BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE v_screen_id VARCHAR(10);
  DECLARE v_total INT;
  DECLARE v_seat_id VARCHAR(15);
  DECLARE seat_num INT;
  DECLARE row_letter CHAR(1);
  DECLARE col_num INT;
  DECLARE seat_counter INT DEFAULT 1;

  DECLARE cur CURSOR FOR SELECT screen_id, total_seats FROM screens;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_screen_id, v_total;
    IF done THEN LEAVE read_loop; END IF;

    -- Only generate if no seats exist yet
    IF (SELECT COUNT(*) FROM seats WHERE screen_id = v_screen_id) = 0 THEN
      SET seat_num = 1;
      WHILE seat_num <= v_total DO
        SET row_letter = CHAR(64 + CEIL(seat_num / 10));
        SET col_num    = seat_num - ((CEIL(seat_num / 10) - 1) * 10);
        SET v_seat_id  = CONCAT(v_screen_id, '-S', LPAD(seat_num, 3, '0'));
        INSERT IGNORE INTO seats (seat_id, screen_id, seat_number, seat_type, status)
        VALUES (v_seat_id, v_screen_id, CONCAT(row_letter, col_num), 'Standard', 'Available');
        SET seat_num = seat_num + 1;
      END WHILE;
    END IF;
  END LOOP;
  CLOSE cur;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `admin_id` varchar(10) NOT NULL,
  `name` varchar(100) NOT NULL,
  `first_name` varchar(50) NOT NULL DEFAULT '',
  `last_name` varchar(50) NOT NULL DEFAULT '',
  `email` varchar(100) NOT NULL DEFAULT '',
  `phone_number` varchar(20) NOT NULL DEFAULT '',
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`admin_id`, `name`, `first_name`, `last_name`, `email`, `phone_number`, `username`, `password`, `created_at`) VALUES
('ADM001', 'Catriona Gray', 'Catriona', 'Gray', 'catrionagray@cinema.ph', '09378357738', 'admin', '$2y$10$WM6ful0zNdI8fmjiQOuPG.ozBSjlkqa2Vjsj1Gy/IGfFyrASsMYyy', '2026-05-02 19:47:32'),
('ADM002', 'Eumee Sodusta', 'Eumee', 'Sodusta', 'eumeeadmin@cinema.ph', '09482753886', 'admin1', '$2y$10$q6GxywRD15Bv1Y/itNv7gOjQsydmAaxNmgrLXuy2nXvwLv/i027QG', '2026-05-02 19:47:32');

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `log_id` int(11) NOT NULL,
  `operation` enum('INSERT','UPDATE','DELETE') NOT NULL,
  `table_name` varchar(100) NOT NULL,
  `record_id` varchar(20) DEFAULT NULL,
  `old_data` text DEFAULT NULL,
  `new_data` text DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `changed_by` varchar(100) DEFAULT 'system'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_log`
--

INSERT INTO `audit_log` (`log_id`, `operation`, `table_name`, `record_id`, `old_data`, `new_data`, `changed_at`, `changed_by`) VALUES
(1, 'INSERT', 'cinemas', 'CIN001', NULL, 'cinema_name=SM Cinema Cebu, location=SM City Cebu, North Reclamation Area, contact=(032) 231-0001', '2026-04-25 11:44:42', 'system'),
(2, 'INSERT', 'cinemas', 'CIN002', NULL, 'cinema_name=Ayala Cinemas, location=Ayala Center Cebu, Cebu City, contact=(032) 888-0002', '2026-04-25 11:44:42', 'system'),
(3, 'INSERT', 'cinemas', 'CIN003', NULL, 'cinema_name=Robinsons Movieworld, location=Robinsons Galleria Cebu, Cebu City, contact=(032) 777-0003', '2026-04-25 11:44:42', 'system'),
(4, 'INSERT', 'movies', 'MOV001', NULL, 'title=Avengers: Doomsday, genre=Action, duration=150min, rating=PG-13, release_date=2026-05-01', '2026-04-25 11:44:42', 'system'),
(5, 'INSERT', 'movies', 'MOV002', NULL, 'title=Inside Out 3, genre=Animation, duration=110min, rating=G, release_date=2026-04-15', '2026-04-25 11:44:42', 'system'),
(6, 'INSERT', 'movies', 'MOV003', NULL, 'title=A Quiet Place: Day One, genre=Horror, duration=120min, rating=R, release_date=2026-03-22', '2026-04-25 11:44:42', 'system'),
(7, 'INSERT', 'movies', 'MOV004', NULL, 'title=Deadpool & Wolverine, genre=Action, duration=128min, rating=R-18, release_date=2026-02-14', '2026-04-25 11:44:42', 'system'),
(8, 'INSERT', 'movies', 'MOV005', NULL, 'title=Kung Fu Panda 5, genre=Animation, duration=100min, rating=G, release_date=2026-04-10', '2026-04-25 11:44:42', 'system'),
(9, 'INSERT', 'customers', 'CUS001', NULL, 'first_name=Juan, last_name=Dela Cruz, email=juan@email.com, phone=09171234567, status=Active', '2026-04-25 11:44:42', 'system'),
(10, 'INSERT', 'customers', 'CUS002', NULL, 'first_name=Maria, last_name=Santos, email=maria@email.com, phone=09182345678, status=Active', '2026-04-25 11:44:42', 'system'),
(11, 'INSERT', 'customers', 'CUS003', NULL, 'first_name=Jose, last_name=Rizal, email=jose@email.com, phone=09193456789, status=Active', '2026-04-25 11:44:42', 'system'),
(12, 'INSERT', 'customers', 'CUS004', NULL, 'first_name=Ana, last_name=Reyes, email=ana@email.com, phone=09204567890, status=Inactive', '2026-04-25 11:44:42', 'system'),
(13, 'INSERT', 'customers', 'CUS005', NULL, 'first_name=Carlo, last_name=Mendoza, email=carlo@email.com, phone=09215678901, status=Active', '2026-04-25 11:44:42', 'system'),
(14, 'INSERT', 'bookings', 'BKG001', NULL, 'customer_id=CUS001, showtime_id=SHW001, customer_name=Juan Dela Cruz, total_amount=500.00, status=Confirmed', '2026-04-25 11:44:42', 'system'),
(15, 'INSERT', 'bookings', 'BKG002', NULL, 'customer_id=CUS002, showtime_id=SHW003, customer_name=Maria Santos, total_amount=200.00, status=Confirmed', '2026-04-25 11:44:42', 'system'),
(16, 'INSERT', 'bookings', 'BKG003', NULL, 'customer_id=CUS003, showtime_id=SHW004, customer_name=Jose Rizal, total_amount=300.00, status=Pending', '2026-04-25 11:44:42', 'system'),
(17, 'INSERT', 'bookings', 'BKG004', NULL, 'customer_id=CUS001, showtime_id=SHW005, customer_name=Juan Dela Cruz, total_amount=700.00, status=Cancelled', '2026-04-25 11:44:42', 'system'),
(18, 'INSERT', 'bookings', 'BKG005', NULL, 'customer_id=CUS005, showtime_id=SHW006, customer_name=Carlo Mendoza, total_amount=360.00, status=Confirmed', '2026-04-25 11:44:42', 'system'),
(19, 'INSERT', 'payments', 'PAY001', NULL, 'booking_id=BKG001, amount=500.00, method=GCash, status=Paid', '2026-04-25 11:44:42', 'system'),
(20, 'INSERT', 'payments', 'PAY002', NULL, 'booking_id=BKG002, amount=200.00, method=Cash, status=Paid', '2026-04-25 11:44:42', 'system'),
(21, 'INSERT', 'payments', 'PAY003', NULL, 'booking_id=BKG003, amount=300.00, method=Maya, status=Pending', '2026-04-25 11:44:42', 'system'),
(22, 'INSERT', 'payments', 'PAY004', NULL, 'booking_id=BKG005, amount=360.00, method=Credit Card, status=Paid', '2026-04-25 11:44:42', 'system'),
(23, 'INSERT', 'customers', 'CUS006', NULL, 'first_name=Raphaelle, last_name=Alabanzas, email=raph@gmail.com, phone=092334554534, status=Active', '2026-04-25 20:14:04', 'system'),
(24, 'DELETE', 'customers', 'CUS006', 'first_name=Raphaelle, last_name=Alabanzas, email=raph@gmail.com, status=Active', NULL, '2026-04-25 20:16:58', 'system'),
(25, 'INSERT', 'customers', 'CUS006', NULL, 'first_name=Gleih, last_name=Sayno, email=gleih@gmail.com, phone=0923345545, status=Active', '2026-04-26 00:57:52', 'system'),
(26, 'INSERT', 'bookings', 'BKG006', NULL, 'customer_id=CUS006, showtime_id=SHW005, customer_name=Gleih Sayno, total_amount=350.00, status=Confirmed', '2026-04-26 00:58:34', 'system'),
(27, 'UPDATE', 'bookings', 'BKG006', 'total_amount=350.00, status=Confirmed', 'total_amount=350.00, status=Cancelled', '2026-04-26 00:58:55', 'system'),
(28, 'UPDATE', 'movies', 'MOV002', 'title=Inside Out 3, genre=Animation, rating=G', 'title=Inside Out 3, genre=Animation, rating=G', '2026-04-26 01:11:14', 'system'),
(29, 'UPDATE', 'movies', 'MOV002', 'title=Inside Out 3, genre=Animation, rating=G', 'title=Inside Out 3, genre=Animation, rating=G', '2026-04-26 01:12:14', 'system'),
(30, 'INSERT', 'movies', 'MOV006', NULL, 'title=hatdpg, genre=Action, duration=90min, rating=G, release_date=2026-04-25', '2026-04-26 01:14:55', 'system'),
(31, 'DELETE', 'movies', 'MOV006', 'title=hatdpg, genre=Action, rating=G', NULL, '2026-04-26 01:15:01', 'system'),
(32, 'INSERT', 'movies', 'MOV006', NULL, 'title=hai, genre=Action, duration=90min, rating=G, release_date=2026-04-25', '2026-04-26 01:21:37', 'system'),
(33, 'INSERT', 'bookings', 'BKG007', NULL, 'customer_id=CUS006, showtime_id=SHW001, customer_name=Gleih Sayno, total_amount=250.00, status=Confirmed', '2026-04-26 01:25:25', 'system'),
(34, 'UPDATE', 'bookings', 'BKG007', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Pending', '2026-04-26 01:47:37', 'system'),
(35, 'INSERT', 'payments', 'PAY005', NULL, 'booking_id=BKG007, amount=250.00, method=Credit Card, status=Pending', '2026-04-26 01:50:58', 'system'),
(36, 'INSERT', 'tickets', 'TKT0001', NULL, 'booking_id=BKG002, seat_id=SCR004-S161, ticket_price=200.00', '2026-04-26 01:51:28', 'system'),
(37, 'INSERT', 'tickets', 'TKT0002', NULL, 'booking_id=BKG005, seat_id=SCR004-S006, ticket_price=180.00', '2026-04-26 01:52:15', 'system'),
(38, 'INSERT', 'tickets', 'TKT0003', NULL, 'booking_id=BKG003, seat_id=SCR004-S154, ticket_price=300.00', '2026-04-26 02:01:20', 'system'),
(39, 'INSERT', 'movies', 'MOV007', NULL, 'title=Avengers: Beyond The Genders, genre=Romance, duration=90min, rating=R-18, release_date=2026-04-26', '2026-04-26 17:24:01', 'system'),
(40, 'INSERT', 'bookings', 'BKG008', NULL, 'customer_id=CUS003, showtime_id=SHW007, customer_name=Jose Protacio Rizal Mercado Y Alonzo Realonda, total_amount=2500000.00, status=Confirmed', '2026-04-26 17:28:01', 'system'),
(41, 'INSERT', 'tickets', 'TKT0004', NULL, 'booking_id=BKG008, seat_id=SCR004-S001, ticket_price=2500000.00', '2026-04-26 17:28:51', 'system'),
(42, 'INSERT', 'payments', 'PAY006', NULL, 'booking_id=BKG008, amount=2500000.00, method=Cash, status=Paid', '2026-04-26 17:29:16', 'system'),
(43, 'UPDATE', 'bookings', 'BKG008', 'total_amount=2500000.00, status=Confirmed', 'total_amount=2500000.00, status=Confirmed', '2026-04-26 17:29:16', 'system'),
(44, 'UPDATE', 'movies', 'MOV002', 'title=Inside Out 3, genre=Animation, rating=G', 'title=Inside Out 3, genre=Animation, rating=G', '2026-04-27 00:31:34', 'system'),
(45, 'DELETE', 'movies', 'MOV002', 'title=Inside Out 3, genre=Animation, rating=G', NULL, '2026-04-27 00:31:39', 'system'),
(46, 'UPDATE', 'bookings', 'BKG008', 'total_amount=2500000.00, status=Confirmed', 'total_amount=2500000.00, status=Confirmed', '2026-04-27 00:53:19', 'system'),
(47, 'INSERT', 'customers', 'CUS007', NULL, 'first_name=Eumee, last_name=Sodusta, email=sodustaeumee@gmail.com, phone=09946108339, status=Active', '2026-04-27 00:59:37', 'system'),
(48, 'INSERT', 'customers', 'CUS008', NULL, 'first_name=Renz, last_name=Ramos, email=ramos@gmail.com, phone=09931386293, status=Active', '2026-04-27 01:17:03', 'system'),
(49, 'INSERT', 'customers', 'CUS009', NULL, 'first_name=Raphaelle, last_name=Alabanzas, email=alabanzas@gmail.com, phone=09281625349, status=Active', '2026-04-27 01:24:56', 'system'),
(50, 'DELETE', 'customers', 'CUS009', 'first_name=Raphaelle, last_name=Alabanzas, email=alabanzas@gmail.com, status=Active', NULL, '2026-04-27 01:25:07', 'system'),
(51, 'INSERT', 'customers', 'CUS009', NULL, 'first_name=Raphaelle, last_name=Alabanzas, email=alabanzas@gmail.com, phone=09281625349, status=Active', '2026-04-27 01:26:08', 'system'),
(52, 'DELETE', 'customers', 'CUS009', 'first_name=Raphaelle, last_name=Alabanzas, email=alabanzas@gmail.com, status=Active', NULL, '2026-04-27 01:26:45', 'system'),
(53, 'DELETE', 'customers', 'CUS008', 'first_name=Renz, last_name=Ramos, email=ramos@gmail.com, status=Active', NULL, '2026-04-27 01:31:36', 'system'),
(54, 'INSERT', 'customers', 'CUS008', NULL, 'first_name=Renz, last_name=Ramos, email=ramos@gmail.com, phone=09281625349, status=Active', '2026-04-27 01:32:27', 'system'),
(55, 'INSERT', 'customers', 'CUS009', NULL, 'first_name=Name, last_name=last, email=namelast@gmail.com, phone=09281625349, status=Active', '2026-04-27 01:58:16', 'system'),
(56, 'DELETE', 'customers', 'CUS009', 'first_name=Name, last_name=last, email=namelast@gmail.com, status=Active', NULL, '2026-04-27 02:18:31', 'system'),
(57, 'INSERT', 'customers', 'CUS009', NULL, 'first_name=Brad, last_name=Pitt, email=bradpitt@gmail.com, phone=09485102987, status=Active', '2026-04-27 02:19:16', 'system'),
(58, 'UPDATE', 'customers', 'CUS009', 'first_name=Brad, last_name=Pitt, email=bradpitt@gmail.com, status=Active', 'first_name=Brad, last_name=Pittt, email=bradpitt@gmail.com, status=Active', '2026-04-27 02:20:56', 'system'),
(59, 'DELETE', 'screens', 'SCR006', 'cinema_id=CIN003, screen_name=Screen 2, total_seats=100', NULL, '2026-04-27 02:36:56', 'system'),
(60, 'INSERT', 'screens', 'SCR006', NULL, 'cinema_id=CIN003, screen_name=Screen 2, total_seats=100', '2026-04-27 02:37:07', 'system'),
(61, 'INSERT', 'seats', 'SCR006-001', NULL, 'screen_id=SCR006, seat_number=A01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(62, 'INSERT', 'seats', 'SCR006-002', NULL, 'screen_id=SCR006, seat_number=A02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(63, 'INSERT', 'seats', 'SCR006-003', NULL, 'screen_id=SCR006, seat_number=A03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(64, 'INSERT', 'seats', 'SCR006-004', NULL, 'screen_id=SCR006, seat_number=A04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(65, 'INSERT', 'seats', 'SCR006-005', NULL, 'screen_id=SCR006, seat_number=A05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(66, 'INSERT', 'seats', 'SCR006-006', NULL, 'screen_id=SCR006, seat_number=A06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(67, 'INSERT', 'seats', 'SCR006-007', NULL, 'screen_id=SCR006, seat_number=A07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(68, 'INSERT', 'seats', 'SCR006-008', NULL, 'screen_id=SCR006, seat_number=A08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(69, 'INSERT', 'seats', 'SCR006-009', NULL, 'screen_id=SCR006, seat_number=A09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(70, 'INSERT', 'seats', 'SCR006-010', NULL, 'screen_id=SCR006, seat_number=A10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(71, 'INSERT', 'seats', 'SCR006-011', NULL, 'screen_id=SCR006, seat_number=B01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(72, 'INSERT', 'seats', 'SCR006-012', NULL, 'screen_id=SCR006, seat_number=B02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(73, 'INSERT', 'seats', 'SCR006-013', NULL, 'screen_id=SCR006, seat_number=B03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(74, 'INSERT', 'seats', 'SCR006-014', NULL, 'screen_id=SCR006, seat_number=B04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(75, 'INSERT', 'seats', 'SCR006-015', NULL, 'screen_id=SCR006, seat_number=B05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(76, 'INSERT', 'seats', 'SCR006-016', NULL, 'screen_id=SCR006, seat_number=B06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(77, 'INSERT', 'seats', 'SCR006-017', NULL, 'screen_id=SCR006, seat_number=B07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(78, 'INSERT', 'seats', 'SCR006-018', NULL, 'screen_id=SCR006, seat_number=B08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(79, 'INSERT', 'seats', 'SCR006-019', NULL, 'screen_id=SCR006, seat_number=B09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(80, 'INSERT', 'seats', 'SCR006-020', NULL, 'screen_id=SCR006, seat_number=B10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(81, 'INSERT', 'seats', 'SCR006-021', NULL, 'screen_id=SCR006, seat_number=C01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(82, 'INSERT', 'seats', 'SCR006-022', NULL, 'screen_id=SCR006, seat_number=C02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(83, 'INSERT', 'seats', 'SCR006-023', NULL, 'screen_id=SCR006, seat_number=C03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(84, 'INSERT', 'seats', 'SCR006-024', NULL, 'screen_id=SCR006, seat_number=C04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(85, 'INSERT', 'seats', 'SCR006-025', NULL, 'screen_id=SCR006, seat_number=C05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(86, 'INSERT', 'seats', 'SCR006-026', NULL, 'screen_id=SCR006, seat_number=C06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(87, 'INSERT', 'seats', 'SCR006-027', NULL, 'screen_id=SCR006, seat_number=C07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(88, 'INSERT', 'seats', 'SCR006-028', NULL, 'screen_id=SCR006, seat_number=C08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(89, 'INSERT', 'seats', 'SCR006-029', NULL, 'screen_id=SCR006, seat_number=C09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(90, 'INSERT', 'seats', 'SCR006-030', NULL, 'screen_id=SCR006, seat_number=C10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(91, 'INSERT', 'seats', 'SCR006-031', NULL, 'screen_id=SCR006, seat_number=D01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(92, 'INSERT', 'seats', 'SCR006-032', NULL, 'screen_id=SCR006, seat_number=D02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(93, 'INSERT', 'seats', 'SCR006-033', NULL, 'screen_id=SCR006, seat_number=D03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(94, 'INSERT', 'seats', 'SCR006-034', NULL, 'screen_id=SCR006, seat_number=D04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(95, 'INSERT', 'seats', 'SCR006-035', NULL, 'screen_id=SCR006, seat_number=D05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(96, 'INSERT', 'seats', 'SCR006-036', NULL, 'screen_id=SCR006, seat_number=D06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(97, 'INSERT', 'seats', 'SCR006-037', NULL, 'screen_id=SCR006, seat_number=D07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(98, 'INSERT', 'seats', 'SCR006-038', NULL, 'screen_id=SCR006, seat_number=D08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(99, 'INSERT', 'seats', 'SCR006-039', NULL, 'screen_id=SCR006, seat_number=D09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(100, 'INSERT', 'seats', 'SCR006-040', NULL, 'screen_id=SCR006, seat_number=D10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(101, 'INSERT', 'seats', 'SCR006-041', NULL, 'screen_id=SCR006, seat_number=E01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(102, 'INSERT', 'seats', 'SCR006-042', NULL, 'screen_id=SCR006, seat_number=E02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(103, 'INSERT', 'seats', 'SCR006-043', NULL, 'screen_id=SCR006, seat_number=E03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(104, 'INSERT', 'seats', 'SCR006-044', NULL, 'screen_id=SCR006, seat_number=E04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(105, 'INSERT', 'seats', 'SCR006-045', NULL, 'screen_id=SCR006, seat_number=E05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(106, 'INSERT', 'seats', 'SCR006-046', NULL, 'screen_id=SCR006, seat_number=E06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(107, 'INSERT', 'seats', 'SCR006-047', NULL, 'screen_id=SCR006, seat_number=E07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(108, 'INSERT', 'seats', 'SCR006-048', NULL, 'screen_id=SCR006, seat_number=E08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(109, 'INSERT', 'seats', 'SCR006-049', NULL, 'screen_id=SCR006, seat_number=E09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(110, 'INSERT', 'seats', 'SCR006-050', NULL, 'screen_id=SCR006, seat_number=E10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(111, 'INSERT', 'seats', 'SCR006-051', NULL, 'screen_id=SCR006, seat_number=F01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(112, 'INSERT', 'seats', 'SCR006-052', NULL, 'screen_id=SCR006, seat_number=F02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(113, 'INSERT', 'seats', 'SCR006-053', NULL, 'screen_id=SCR006, seat_number=F03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(114, 'INSERT', 'seats', 'SCR006-054', NULL, 'screen_id=SCR006, seat_number=F04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(115, 'INSERT', 'seats', 'SCR006-055', NULL, 'screen_id=SCR006, seat_number=F05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(116, 'INSERT', 'seats', 'SCR006-056', NULL, 'screen_id=SCR006, seat_number=F06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(117, 'INSERT', 'seats', 'SCR006-057', NULL, 'screen_id=SCR006, seat_number=F07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(118, 'INSERT', 'seats', 'SCR006-058', NULL, 'screen_id=SCR006, seat_number=F08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(119, 'INSERT', 'seats', 'SCR006-059', NULL, 'screen_id=SCR006, seat_number=F09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(120, 'INSERT', 'seats', 'SCR006-060', NULL, 'screen_id=SCR006, seat_number=F10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(121, 'INSERT', 'seats', 'SCR006-061', NULL, 'screen_id=SCR006, seat_number=G01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(122, 'INSERT', 'seats', 'SCR006-062', NULL, 'screen_id=SCR006, seat_number=G02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(123, 'INSERT', 'seats', 'SCR006-063', NULL, 'screen_id=SCR006, seat_number=G03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(124, 'INSERT', 'seats', 'SCR006-064', NULL, 'screen_id=SCR006, seat_number=G04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(125, 'INSERT', 'seats', 'SCR006-065', NULL, 'screen_id=SCR006, seat_number=G05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(126, 'INSERT', 'seats', 'SCR006-066', NULL, 'screen_id=SCR006, seat_number=G06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(127, 'INSERT', 'seats', 'SCR006-067', NULL, 'screen_id=SCR006, seat_number=G07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(128, 'INSERT', 'seats', 'SCR006-068', NULL, 'screen_id=SCR006, seat_number=G08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(129, 'INSERT', 'seats', 'SCR006-069', NULL, 'screen_id=SCR006, seat_number=G09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(130, 'INSERT', 'seats', 'SCR006-070', NULL, 'screen_id=SCR006, seat_number=G10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(131, 'INSERT', 'seats', 'SCR006-071', NULL, 'screen_id=SCR006, seat_number=H01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(132, 'INSERT', 'seats', 'SCR006-072', NULL, 'screen_id=SCR006, seat_number=H02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(133, 'INSERT', 'seats', 'SCR006-073', NULL, 'screen_id=SCR006, seat_number=H03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(134, 'INSERT', 'seats', 'SCR006-074', NULL, 'screen_id=SCR006, seat_number=H04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(135, 'INSERT', 'seats', 'SCR006-075', NULL, 'screen_id=SCR006, seat_number=H05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(136, 'INSERT', 'seats', 'SCR006-076', NULL, 'screen_id=SCR006, seat_number=H06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(137, 'INSERT', 'seats', 'SCR006-077', NULL, 'screen_id=SCR006, seat_number=H07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(138, 'INSERT', 'seats', 'SCR006-078', NULL, 'screen_id=SCR006, seat_number=H08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(139, 'INSERT', 'seats', 'SCR006-079', NULL, 'screen_id=SCR006, seat_number=H09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(140, 'INSERT', 'seats', 'SCR006-080', NULL, 'screen_id=SCR006, seat_number=H10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(141, 'INSERT', 'seats', 'SCR006-081', NULL, 'screen_id=SCR006, seat_number=I01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(142, 'INSERT', 'seats', 'SCR006-082', NULL, 'screen_id=SCR006, seat_number=I02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(143, 'INSERT', 'seats', 'SCR006-083', NULL, 'screen_id=SCR006, seat_number=I03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(144, 'INSERT', 'seats', 'SCR006-084', NULL, 'screen_id=SCR006, seat_number=I04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(145, 'INSERT', 'seats', 'SCR006-085', NULL, 'screen_id=SCR006, seat_number=I05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(146, 'INSERT', 'seats', 'SCR006-086', NULL, 'screen_id=SCR006, seat_number=I06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(147, 'INSERT', 'seats', 'SCR006-087', NULL, 'screen_id=SCR006, seat_number=I07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(148, 'INSERT', 'seats', 'SCR006-088', NULL, 'screen_id=SCR006, seat_number=I08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(149, 'INSERT', 'seats', 'SCR006-089', NULL, 'screen_id=SCR006, seat_number=I09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(150, 'INSERT', 'seats', 'SCR006-090', NULL, 'screen_id=SCR006, seat_number=I10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(151, 'INSERT', 'seats', 'SCR006-091', NULL, 'screen_id=SCR006, seat_number=J01, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(152, 'INSERT', 'seats', 'SCR006-092', NULL, 'screen_id=SCR006, seat_number=J02, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(153, 'INSERT', 'seats', 'SCR006-093', NULL, 'screen_id=SCR006, seat_number=J03, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(154, 'INSERT', 'seats', 'SCR006-094', NULL, 'screen_id=SCR006, seat_number=J04, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(155, 'INSERT', 'seats', 'SCR006-095', NULL, 'screen_id=SCR006, seat_number=J05, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(156, 'INSERT', 'seats', 'SCR006-096', NULL, 'screen_id=SCR006, seat_number=J06, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(157, 'INSERT', 'seats', 'SCR006-097', NULL, 'screen_id=SCR006, seat_number=J07, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(158, 'INSERT', 'seats', 'SCR006-098', NULL, 'screen_id=SCR006, seat_number=J08, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(159, 'INSERT', 'seats', 'SCR006-099', NULL, 'screen_id=SCR006, seat_number=J09, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(160, 'INSERT', 'seats', 'SCR006-100', NULL, 'screen_id=SCR006, seat_number=J10, seat_type=Standard, status=Available', '2026-04-27 02:37:07', 'system'),
(161, 'UPDATE', 'seats', 'SCR003-S064', 'screen_id=SCR003, seat_number=G4, status=Available', 'screen_id=SCR003, seat_number=G4, status=Taken', '2026-04-27 02:37:52', 'system'),
(162, 'DELETE', 'bookings', 'BKG008', 'customer_id=CUS003, showtime_id=SHW007, total_amount=2500000.00, status=Confirmed', NULL, '2026-04-27 02:48:33', 'system'),
(163, 'DELETE', 'movies', 'MOV007', 'title=Avengers: Beyond The Genders, genre=Romance, rating=R-18', NULL, '2026-04-27 03:08:13', 'system'),
(164, 'UPDATE', 'seats', 'SCR003-S110', 'screen_id=SCR003, seat_number=K10, status=Available', 'screen_id=SCR003, seat_number=K10, status=Taken', '2026-04-27 14:13:59', 'system'),
(165, 'DELETE', 'movies', 'MOV006', 'title=hai, genre=Action, rating=G', NULL, '2026-04-27 14:14:36', 'system'),
(166, 'INSERT', 'movies', 'MOV006', NULL, 'title=The Notebook, genre=Romance, duration=120min, rating=R, release_date=2026-04-27', '2026-04-27 14:18:22', 'system'),
(167, 'UPDATE', 'movies', 'MOV001', 'title=Avengers: Doomsday, genre=Action, rating=PG-13', 'title=Avengers: Doomsday, genre=Action, rating=PG-13', '2026-04-27 14:18:58', 'system'),
(168, 'INSERT', 'movies', 'MOV007', NULL, 'title=La La Land, genre=Romance, duration=120min, rating=PG-13, release_date=2026-04-27', '2026-04-27 14:21:27', 'system'),
(169, 'INSERT', 'movies', 'MOV008', NULL, 'title=IT, genre=Horror, duration=120min, rating=R, release_date=2026-04-27', '2026-04-27 14:25:43', 'system'),
(170, 'UPDATE', 'movies', 'MOV004', 'title=Deadpool & Wolverine, genre=Action, rating=R-18', 'title=Deadpool & Wolverine, genre=Action, rating=R-18', '2026-04-27 14:26:22', 'system'),
(171, 'UPDATE', 'movies', 'MOV003', 'title=A Quiet Place: Day One, genre=Horror, rating=R', 'title=A Quiet Place: Day One, genre=Horror, rating=R', '2026-04-27 14:27:26', 'system'),
(172, 'DELETE', 'movies', 'MOV005', 'title=Kung Fu Panda 5, genre=Animation, rating=G', NULL, '2026-04-27 14:27:31', 'system'),
(173, 'INSERT', 'movies', 'MOV009', NULL, 'title=Ne Zha, genre=Animation, duration=120min, rating=PG-13, release_date=2026-04-27', '2026-04-27 14:30:05', 'system'),
(174, 'INSERT', 'movies', 'MOV010', NULL, 'title=White Chicks, genre=Comedy, duration=120min, rating=PG-13, release_date=2026-04-27', '2026-04-27 14:34:39', 'system'),
(175, 'UPDATE', 'customers', 'CUS009', 'first_name=Brad, last_name=Pittt, email=bradpitt@gmail.com, status=Active', 'first_name=Brad, last_name=Pitt, email=bradpitt@gmail.com, status=Active', '2026-04-27 14:39:34', 'system'),
(176, 'DELETE', 'screens', 'SCR005', 'cinema_id=CIN001, screen_name=Screen 6, total_seats=150', NULL, '2026-04-27 14:40:55', 'system'),
(177, 'DELETE', 'screens', 'SCR006', 'cinema_id=CIN003, screen_name=Screen 2, total_seats=100', NULL, '2026-04-27 14:41:04', 'system'),
(178, 'INSERT', 'customers', 'CUS010', NULL, 'first_name=Nadine, last_name=Lustre, email=nadinelustre@gmail.com, phone=09347630012, status=Active', '2026-04-27 14:42:00', 'system'),
(179, 'INSERT', 'bookings', 'BKG008', NULL, 'customer_id=CUS010, showtime_id=SHW007, customer_name=Nadine Lustre, total_amount=250.00, status=Confirmed', '2026-04-27 14:43:02', 'system'),
(180, 'INSERT', 'payments', 'PAY006', NULL, 'booking_id=BKG008, amount=250.00, method=Cash, status=Paid', '2026-04-27 14:43:24', 'system'),
(181, 'UPDATE', 'bookings', 'BKG008', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-04-27 14:43:24', 'system'),
(182, 'INSERT', 'tickets', 'TKT0004', NULL, 'booking_id=BKG008, seat_id=SCR004-S010, ticket_price=250.00', '2026-04-27 14:44:16', 'system'),
(183, 'UPDATE', 'seats', 'SCR003-S010', 'screen_id=SCR003, seat_number=A10, status=Available', 'screen_id=SCR003, seat_number=A10, status=Taken', '2026-04-27 14:45:35', 'system'),
(184, 'UPDATE', 'seats', 'SCR003-S080', 'screen_id=SCR003, seat_number=H10, status=Available', 'screen_id=SCR003, seat_number=H10, status=Available', '2026-05-02 13:59:55', 'system'),
(185, 'INSERT', 'bookings', 'BKG009', NULL, 'customer_id=CUS007, showtime_id=SHW008, customer_name=Eumee Sodusta, total_amount=250.00, status=Confirmed', '2026-05-02 14:23:42', 'system'),
(186, 'INSERT', 'payments', 'PAY007', NULL, 'booking_id=BKG009, amount=250.00, method=Cash, status=Paid', '2026-05-02 14:24:08', 'system'),
(187, 'UPDATE', 'bookings', 'BKG009', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-05-02 14:24:08', 'system'),
(188, 'UPDATE', 'seats', 'SCR003-S132', 'screen_id=SCR003, seat_number=N2, status=Available', 'screen_id=SCR003, seat_number=N2, status=Available', '2026-05-02 14:27:47', 'system'),
(189, 'INSERT', 'tickets', 'TKT0005', NULL, 'booking_id=BKG009, seat_id=SCR003-S002, ticket_price=250.00', '2026-05-02 14:30:28', 'system'),
(190, 'INSERT', 'tickets', 'TKT0006', NULL, 'booking_id=BKG009, seat_id=SCR003-S024, ticket_price=250.00', '2026-05-02 14:30:52', 'system'),
(191, 'INSERT', 'bookings', 'BKG010', NULL, 'customer_id=CUS008, showtime_id=SHW009, customer_name=Renz Ramos, total_amount=250.00, status=Confirmed', '2026-05-02 14:32:57', 'system'),
(192, 'INSERT', 'payments', 'PAY008', NULL, 'booking_id=BKG010, amount=250.00, method=Cash, status=Paid', '2026-05-02 14:33:07', 'system'),
(193, 'UPDATE', 'bookings', 'BKG010', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-05-02 14:33:07', 'system'),
(194, 'INSERT', 'tickets', 'TKT0007', NULL, 'booking_id=BKG010, seat_id=SCR004-S004, ticket_price=250.00', '2026-05-02 14:33:24', 'system'),
(195, 'INSERT', 'tickets', 'TKT0008', NULL, 'booking_id=BKG010, seat_id=SCR004-S011, ticket_price=250.00', '2026-05-02 14:36:16', 'system'),
(196, 'UPDATE', 'seats', 'SCR004-S011', 'screen_id=SCR004, seat_number=B1, status=Available', 'screen_id=SCR004, seat_number=B1, status=Taken', '2026-05-02 14:36:16', 'system'),
(197, 'DELETE', 'tickets', 'TKT0002', 'booking_id=BKG005, seat_id=SCR004-S006, ticket_price=180.00', NULL, '2026-05-02 14:37:04', 'system'),
(198, 'UPDATE', 'seats', 'SCR004-S006', 'screen_id=SCR004, seat_number=A6, status=Available', 'screen_id=SCR004, seat_number=A6, status=Available', '2026-05-02 14:37:04', 'system'),
(199, 'DELETE', 'tickets', 'TKT0003', 'booking_id=BKG003, seat_id=SCR004-S154, ticket_price=300.00', NULL, '2026-05-02 14:37:07', 'system'),
(200, 'UPDATE', 'seats', 'SCR004-S154', 'screen_id=SCR004, seat_number=P4, status=Available', 'screen_id=SCR004, seat_number=P4, status=Available', '2026-05-02 14:37:07', 'system'),
(201, 'DELETE', 'tickets', 'TKT0004', 'booking_id=BKG008, seat_id=SCR004-S010, ticket_price=250.00', NULL, '2026-05-02 14:37:10', 'system'),
(202, 'UPDATE', 'seats', 'SCR004-S010', 'screen_id=SCR004, seat_number=A10, status=Available', 'screen_id=SCR004, seat_number=A10, status=Available', '2026-05-02 14:37:10', 'system'),
(203, 'DELETE', 'tickets', 'TKT0005', 'booking_id=BKG009, seat_id=SCR003-S002, ticket_price=250.00', NULL, '2026-05-02 14:37:13', 'system'),
(204, 'UPDATE', 'seats', 'SCR003-S002', 'screen_id=SCR003, seat_number=A2, status=Available', 'screen_id=SCR003, seat_number=A2, status=Available', '2026-05-02 14:37:13', 'system'),
(205, 'DELETE', 'tickets', 'TKT0006', 'booking_id=BKG009, seat_id=SCR003-S024, ticket_price=250.00', NULL, '2026-05-02 14:37:15', 'system'),
(206, 'UPDATE', 'seats', 'SCR003-S024', 'screen_id=SCR003, seat_number=C4, status=Available', 'screen_id=SCR003, seat_number=C4, status=Available', '2026-05-02 14:37:15', 'system'),
(207, 'DELETE', 'tickets', 'TKT0007', 'booking_id=BKG010, seat_id=SCR004-S004, ticket_price=250.00', NULL, '2026-05-02 14:37:17', 'system'),
(208, 'UPDATE', 'seats', 'SCR004-S004', 'screen_id=SCR004, seat_number=A4, status=Available', 'screen_id=SCR004, seat_number=A4, status=Available', '2026-05-02 14:37:17', 'system'),
(209, 'DELETE', 'tickets', 'TKT0008', 'booking_id=BKG010, seat_id=SCR004-S011, ticket_price=250.00', NULL, '2026-05-02 14:37:20', 'system'),
(210, 'UPDATE', 'seats', 'SCR004-S011', 'screen_id=SCR004, seat_number=B1, status=Taken', 'screen_id=SCR004, seat_number=B1, status=Available', '2026-05-02 14:37:20', 'system'),
(211, 'UPDATE', 'payments', 'PAY005', 'amount=250.00, method=Credit Card, status=Pending', 'amount=250.00, method=Credit Card, status=Paid', '2026-05-02 14:37:43', 'system'),
(212, 'UPDATE', 'bookings', 'BKG007', 'total_amount=250.00, status=Pending', 'total_amount=250.00, status=Confirmed', '2026-05-02 14:37:43', 'system'),
(213, 'DELETE', 'payments', 'PAY005', 'booking_id=BKG007, amount=250.00, method=Credit Card, status=Paid', NULL, '2026-05-02 14:37:48', 'system'),
(214, 'DELETE', 'payments', 'PAY004', 'booking_id=BKG005, amount=360.00, method=Credit Card, status=Paid', NULL, '2026-05-02 14:37:51', 'system'),
(215, 'DELETE', 'payments', 'PAY003', 'booking_id=BKG003, amount=300.00, method=Maya, status=Pending', NULL, '2026-05-02 14:37:53', 'system'),
(216, 'DELETE', 'payments', 'PAY001', 'booking_id=BKG001, amount=500.00, method=GCash, status=Paid', NULL, '2026-05-02 14:37:55', 'system'),
(217, 'DELETE', 'payments', 'PAY006', 'booking_id=BKG008, amount=250.00, method=Cash, status=Paid', NULL, '2026-05-02 14:37:57', 'system'),
(218, 'DELETE', 'payments', 'PAY008', 'booking_id=BKG010, amount=250.00, method=Cash, status=Paid', NULL, '2026-05-02 14:37:59', 'system'),
(219, 'DELETE', 'payments', 'PAY007', 'booking_id=BKG009, amount=250.00, method=Cash, status=Paid', NULL, '2026-05-02 14:38:02', 'system'),
(220, 'UPDATE', 'seats', 'SCR003-S110', 'screen_id=SCR003, seat_number=K10, status=Taken', 'screen_id=SCR003, seat_number=K10, status=Available', '2026-05-02 14:38:12', 'system'),
(221, 'UPDATE', 'seats', 'SCR003-S143', 'screen_id=SCR003, seat_number=O3, status=Taken', 'screen_id=SCR003, seat_number=O3, status=Available', '2026-05-02 14:38:15', 'system'),
(222, 'UPDATE', 'seats', 'SCR003-S064', 'screen_id=SCR003, seat_number=G4, status=Taken', 'screen_id=SCR003, seat_number=G4, status=Available', '2026-05-02 14:38:19', 'system'),
(223, 'UPDATE', 'seats', 'SCR003-S001', 'screen_id=SCR003, seat_number=A1, status=Taken', 'screen_id=SCR003, seat_number=A1, status=Available', '2026-05-02 14:38:22', 'system'),
(224, 'UPDATE', 'seats', 'SCR003-S010', 'screen_id=SCR003, seat_number=A10, status=Taken', 'screen_id=SCR003, seat_number=A10, status=Available', '2026-05-02 14:38:26', 'system'),
(225, 'DELETE', 'screens', 'SCR002', 'cinema_id=CIN001, screen_name=Screen B, total_seats=80', NULL, '2026-05-02 14:38:32', 'system'),
(226, 'DELETE', 'screens', 'SCR001', 'cinema_id=CIN001, screen_name=Screen A, total_seats=120', NULL, '2026-05-02 14:38:40', 'system'),
(227, 'DELETE', 'screens', 'SCR004', 'cinema_id=CIN003, screen_name=Main Hall, total_seats=200', NULL, '2026-05-02 14:38:42', 'system'),
(228, 'DELETE', 'screens', 'SCR003', 'cinema_id=CIN002, screen_name=Screen 1, total_seats=150', NULL, '2026-05-02 14:38:44', 'system'),
(229, 'INSERT', 'movies', 'MOV011', NULL, 'title=Don\'t Breathe, genre=Thriller, duration=90min, rating=R, release_date=2026-05-02', '2026-05-02 14:46:30', 'system'),
(230, 'INSERT', 'movies', 'MOV012', NULL, 'title=Girl, Boy, Bakla, Tomboy, genre=Comedy, duration=90min, rating=PG, release_date=2026-05-02', '2026-05-02 14:50:19', 'system'),
(231, 'UPDATE', 'cinemas', 'CIN001', 'cinema_name=SM Cinema Cebu, location=SM City Cebu, North Reclamation Area', 'cinema_name=SM Cinema Iloilo, location=SM City Iloilo, Senator Benigno Aquino Jr. Avenue', '2026-05-02 14:52:21', 'system'),
(232, 'UPDATE', 'cinemas', 'CIN003', 'cinema_name=Robinsons Movieworld, location=Robinsons Galleria Cebu, Cebu City', 'cinema_name=Robinsons Movieworld, location=Robinsons Galleria, Iloilo City', '2026-05-02 14:52:55', 'system'),
(233, 'UPDATE', 'cinemas', 'CIN002', 'cinema_name=Ayala Cinemas, location=Ayala Center Cebu, Cebu City', 'cinema_name=Festive Walk Cinemas, location=Festive Walk,  Mandurriao, Iloilo City', '2026-05-02 14:54:13', 'system'),
(234, 'INSERT', 'screens', 'SCR001', NULL, 'cinema_id=CIN002, screen_name=Screen 1, total_seats=120', '2026-05-02 14:54:31', 'system'),
(235, 'INSERT', 'seats', 'SCR001-001', NULL, 'screen_id=SCR001, seat_number=A01, seat_type=Standard, status=Available', '2026-05-02 14:54:31', 'system'),
(236, 'INSERT', 'seats', 'SCR001-002', NULL, 'screen_id=SCR001, seat_number=A02, seat_type=Standard, status=Available', '2026-05-02 14:54:31', 'system'),
(237, 'INSERT', 'seats', 'SCR001-003', NULL, 'screen_id=SCR001, seat_number=A03, seat_type=Standard, status=Available', '2026-05-02 14:54:31', 'system'),
(238, 'INSERT', 'seats', 'SCR001-004', NULL, 'screen_id=SCR001, seat_number=A04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(239, 'INSERT', 'seats', 'SCR001-005', NULL, 'screen_id=SCR001, seat_number=A05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(240, 'INSERT', 'seats', 'SCR001-006', NULL, 'screen_id=SCR001, seat_number=A06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(241, 'INSERT', 'seats', 'SCR001-007', NULL, 'screen_id=SCR001, seat_number=A07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(242, 'INSERT', 'seats', 'SCR001-008', NULL, 'screen_id=SCR001, seat_number=A08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(243, 'INSERT', 'seats', 'SCR001-009', NULL, 'screen_id=SCR001, seat_number=A09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(244, 'INSERT', 'seats', 'SCR001-010', NULL, 'screen_id=SCR001, seat_number=A10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(245, 'INSERT', 'seats', 'SCR001-011', NULL, 'screen_id=SCR001, seat_number=B01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(246, 'INSERT', 'seats', 'SCR001-012', NULL, 'screen_id=SCR001, seat_number=B02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(247, 'INSERT', 'seats', 'SCR001-013', NULL, 'screen_id=SCR001, seat_number=B03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(248, 'INSERT', 'seats', 'SCR001-014', NULL, 'screen_id=SCR001, seat_number=B04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(249, 'INSERT', 'seats', 'SCR001-015', NULL, 'screen_id=SCR001, seat_number=B05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(250, 'INSERT', 'seats', 'SCR001-016', NULL, 'screen_id=SCR001, seat_number=B06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(251, 'INSERT', 'seats', 'SCR001-017', NULL, 'screen_id=SCR001, seat_number=B07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(252, 'INSERT', 'seats', 'SCR001-018', NULL, 'screen_id=SCR001, seat_number=B08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(253, 'INSERT', 'seats', 'SCR001-019', NULL, 'screen_id=SCR001, seat_number=B09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(254, 'INSERT', 'seats', 'SCR001-020', NULL, 'screen_id=SCR001, seat_number=B10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(255, 'INSERT', 'seats', 'SCR001-021', NULL, 'screen_id=SCR001, seat_number=C01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(256, 'INSERT', 'seats', 'SCR001-022', NULL, 'screen_id=SCR001, seat_number=C02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(257, 'INSERT', 'seats', 'SCR001-023', NULL, 'screen_id=SCR001, seat_number=C03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(258, 'INSERT', 'seats', 'SCR001-024', NULL, 'screen_id=SCR001, seat_number=C04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(259, 'INSERT', 'seats', 'SCR001-025', NULL, 'screen_id=SCR001, seat_number=C05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(260, 'INSERT', 'seats', 'SCR001-026', NULL, 'screen_id=SCR001, seat_number=C06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(261, 'INSERT', 'seats', 'SCR001-027', NULL, 'screen_id=SCR001, seat_number=C07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(262, 'INSERT', 'seats', 'SCR001-028', NULL, 'screen_id=SCR001, seat_number=C08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(263, 'INSERT', 'seats', 'SCR001-029', NULL, 'screen_id=SCR001, seat_number=C09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(264, 'INSERT', 'seats', 'SCR001-030', NULL, 'screen_id=SCR001, seat_number=C10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(265, 'INSERT', 'seats', 'SCR001-031', NULL, 'screen_id=SCR001, seat_number=D01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(266, 'INSERT', 'seats', 'SCR001-032', NULL, 'screen_id=SCR001, seat_number=D02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(267, 'INSERT', 'seats', 'SCR001-033', NULL, 'screen_id=SCR001, seat_number=D03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(268, 'INSERT', 'seats', 'SCR001-034', NULL, 'screen_id=SCR001, seat_number=D04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(269, 'INSERT', 'seats', 'SCR001-035', NULL, 'screen_id=SCR001, seat_number=D05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(270, 'INSERT', 'seats', 'SCR001-036', NULL, 'screen_id=SCR001, seat_number=D06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(271, 'INSERT', 'seats', 'SCR001-037', NULL, 'screen_id=SCR001, seat_number=D07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(272, 'INSERT', 'seats', 'SCR001-038', NULL, 'screen_id=SCR001, seat_number=D08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(273, 'INSERT', 'seats', 'SCR001-039', NULL, 'screen_id=SCR001, seat_number=D09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(274, 'INSERT', 'seats', 'SCR001-040', NULL, 'screen_id=SCR001, seat_number=D10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(275, 'INSERT', 'seats', 'SCR001-041', NULL, 'screen_id=SCR001, seat_number=E01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(276, 'INSERT', 'seats', 'SCR001-042', NULL, 'screen_id=SCR001, seat_number=E02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(277, 'INSERT', 'seats', 'SCR001-043', NULL, 'screen_id=SCR001, seat_number=E03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(278, 'INSERT', 'seats', 'SCR001-044', NULL, 'screen_id=SCR001, seat_number=E04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(279, 'INSERT', 'seats', 'SCR001-045', NULL, 'screen_id=SCR001, seat_number=E05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(280, 'INSERT', 'seats', 'SCR001-046', NULL, 'screen_id=SCR001, seat_number=E06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(281, 'INSERT', 'seats', 'SCR001-047', NULL, 'screen_id=SCR001, seat_number=E07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(282, 'INSERT', 'seats', 'SCR001-048', NULL, 'screen_id=SCR001, seat_number=E08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(283, 'INSERT', 'seats', 'SCR001-049', NULL, 'screen_id=SCR001, seat_number=E09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(284, 'INSERT', 'seats', 'SCR001-050', NULL, 'screen_id=SCR001, seat_number=E10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(285, 'INSERT', 'seats', 'SCR001-051', NULL, 'screen_id=SCR001, seat_number=F01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(286, 'INSERT', 'seats', 'SCR001-052', NULL, 'screen_id=SCR001, seat_number=F02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(287, 'INSERT', 'seats', 'SCR001-053', NULL, 'screen_id=SCR001, seat_number=F03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(288, 'INSERT', 'seats', 'SCR001-054', NULL, 'screen_id=SCR001, seat_number=F04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(289, 'INSERT', 'seats', 'SCR001-055', NULL, 'screen_id=SCR001, seat_number=F05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(290, 'INSERT', 'seats', 'SCR001-056', NULL, 'screen_id=SCR001, seat_number=F06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(291, 'INSERT', 'seats', 'SCR001-057', NULL, 'screen_id=SCR001, seat_number=F07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(292, 'INSERT', 'seats', 'SCR001-058', NULL, 'screen_id=SCR001, seat_number=F08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(293, 'INSERT', 'seats', 'SCR001-059', NULL, 'screen_id=SCR001, seat_number=F09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(294, 'INSERT', 'seats', 'SCR001-060', NULL, 'screen_id=SCR001, seat_number=F10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(295, 'INSERT', 'seats', 'SCR001-061', NULL, 'screen_id=SCR001, seat_number=G01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(296, 'INSERT', 'seats', 'SCR001-062', NULL, 'screen_id=SCR001, seat_number=G02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(297, 'INSERT', 'seats', 'SCR001-063', NULL, 'screen_id=SCR001, seat_number=G03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(298, 'INSERT', 'seats', 'SCR001-064', NULL, 'screen_id=SCR001, seat_number=G04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(299, 'INSERT', 'seats', 'SCR001-065', NULL, 'screen_id=SCR001, seat_number=G05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(300, 'INSERT', 'seats', 'SCR001-066', NULL, 'screen_id=SCR001, seat_number=G06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(301, 'INSERT', 'seats', 'SCR001-067', NULL, 'screen_id=SCR001, seat_number=G07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(302, 'INSERT', 'seats', 'SCR001-068', NULL, 'screen_id=SCR001, seat_number=G08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(303, 'INSERT', 'seats', 'SCR001-069', NULL, 'screen_id=SCR001, seat_number=G09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(304, 'INSERT', 'seats', 'SCR001-070', NULL, 'screen_id=SCR001, seat_number=G10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(305, 'INSERT', 'seats', 'SCR001-071', NULL, 'screen_id=SCR001, seat_number=H01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(306, 'INSERT', 'seats', 'SCR001-072', NULL, 'screen_id=SCR001, seat_number=H02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(307, 'INSERT', 'seats', 'SCR001-073', NULL, 'screen_id=SCR001, seat_number=H03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(308, 'INSERT', 'seats', 'SCR001-074', NULL, 'screen_id=SCR001, seat_number=H04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(309, 'INSERT', 'seats', 'SCR001-075', NULL, 'screen_id=SCR001, seat_number=H05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(310, 'INSERT', 'seats', 'SCR001-076', NULL, 'screen_id=SCR001, seat_number=H06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(311, 'INSERT', 'seats', 'SCR001-077', NULL, 'screen_id=SCR001, seat_number=H07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(312, 'INSERT', 'seats', 'SCR001-078', NULL, 'screen_id=SCR001, seat_number=H08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(313, 'INSERT', 'seats', 'SCR001-079', NULL, 'screen_id=SCR001, seat_number=H09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(314, 'INSERT', 'seats', 'SCR001-080', NULL, 'screen_id=SCR001, seat_number=H10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(315, 'INSERT', 'seats', 'SCR001-081', NULL, 'screen_id=SCR001, seat_number=I01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(316, 'INSERT', 'seats', 'SCR001-082', NULL, 'screen_id=SCR001, seat_number=I02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(317, 'INSERT', 'seats', 'SCR001-083', NULL, 'screen_id=SCR001, seat_number=I03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(318, 'INSERT', 'seats', 'SCR001-084', NULL, 'screen_id=SCR001, seat_number=I04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(319, 'INSERT', 'seats', 'SCR001-085', NULL, 'screen_id=SCR001, seat_number=I05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system');
INSERT INTO `audit_log` (`log_id`, `operation`, `table_name`, `record_id`, `old_data`, `new_data`, `changed_at`, `changed_by`) VALUES
(320, 'INSERT', 'seats', 'SCR001-086', NULL, 'screen_id=SCR001, seat_number=I06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(321, 'INSERT', 'seats', 'SCR001-087', NULL, 'screen_id=SCR001, seat_number=I07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(322, 'INSERT', 'seats', 'SCR001-088', NULL, 'screen_id=SCR001, seat_number=I08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(323, 'INSERT', 'seats', 'SCR001-089', NULL, 'screen_id=SCR001, seat_number=I09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(324, 'INSERT', 'seats', 'SCR001-090', NULL, 'screen_id=SCR001, seat_number=I10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(325, 'INSERT', 'seats', 'SCR001-091', NULL, 'screen_id=SCR001, seat_number=J01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(326, 'INSERT', 'seats', 'SCR001-092', NULL, 'screen_id=SCR001, seat_number=J02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(327, 'INSERT', 'seats', 'SCR001-093', NULL, 'screen_id=SCR001, seat_number=J03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(328, 'INSERT', 'seats', 'SCR001-094', NULL, 'screen_id=SCR001, seat_number=J04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(329, 'INSERT', 'seats', 'SCR001-095', NULL, 'screen_id=SCR001, seat_number=J05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(330, 'INSERT', 'seats', 'SCR001-096', NULL, 'screen_id=SCR001, seat_number=J06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(331, 'INSERT', 'seats', 'SCR001-097', NULL, 'screen_id=SCR001, seat_number=J07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(332, 'INSERT', 'seats', 'SCR001-098', NULL, 'screen_id=SCR001, seat_number=J08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(333, 'INSERT', 'seats', 'SCR001-099', NULL, 'screen_id=SCR001, seat_number=J09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(334, 'INSERT', 'seats', 'SCR001-100', NULL, 'screen_id=SCR001, seat_number=J10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(335, 'INSERT', 'seats', 'SCR001-101', NULL, 'screen_id=SCR001, seat_number=K01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(336, 'INSERT', 'seats', 'SCR001-102', NULL, 'screen_id=SCR001, seat_number=K02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(337, 'INSERT', 'seats', 'SCR001-103', NULL, 'screen_id=SCR001, seat_number=K03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(338, 'INSERT', 'seats', 'SCR001-104', NULL, 'screen_id=SCR001, seat_number=K04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(339, 'INSERT', 'seats', 'SCR001-105', NULL, 'screen_id=SCR001, seat_number=K05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(340, 'INSERT', 'seats', 'SCR001-106', NULL, 'screen_id=SCR001, seat_number=K06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(341, 'INSERT', 'seats', 'SCR001-107', NULL, 'screen_id=SCR001, seat_number=K07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(342, 'INSERT', 'seats', 'SCR001-108', NULL, 'screen_id=SCR001, seat_number=K08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(343, 'INSERT', 'seats', 'SCR001-109', NULL, 'screen_id=SCR001, seat_number=K09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(344, 'INSERT', 'seats', 'SCR001-110', NULL, 'screen_id=SCR001, seat_number=K10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(345, 'INSERT', 'seats', 'SCR001-111', NULL, 'screen_id=SCR001, seat_number=L01, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(346, 'INSERT', 'seats', 'SCR001-112', NULL, 'screen_id=SCR001, seat_number=L02, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(347, 'INSERT', 'seats', 'SCR001-113', NULL, 'screen_id=SCR001, seat_number=L03, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(348, 'INSERT', 'seats', 'SCR001-114', NULL, 'screen_id=SCR001, seat_number=L04, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(349, 'INSERT', 'seats', 'SCR001-115', NULL, 'screen_id=SCR001, seat_number=L05, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(350, 'INSERT', 'seats', 'SCR001-116', NULL, 'screen_id=SCR001, seat_number=L06, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(351, 'INSERT', 'seats', 'SCR001-117', NULL, 'screen_id=SCR001, seat_number=L07, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(352, 'INSERT', 'seats', 'SCR001-118', NULL, 'screen_id=SCR001, seat_number=L08, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(353, 'INSERT', 'seats', 'SCR001-119', NULL, 'screen_id=SCR001, seat_number=L09, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(354, 'INSERT', 'seats', 'SCR001-120', NULL, 'screen_id=SCR001, seat_number=L10, seat_type=Standard, status=Available', '2026-05-02 14:54:32', 'system'),
(355, 'INSERT', 'screens', 'SCR002', NULL, 'cinema_id=CIN003, screen_name=Screen 1, total_seats=120', '2026-05-02 14:54:42', 'system'),
(356, 'INSERT', 'seats', 'SCR002-001', NULL, 'screen_id=SCR002, seat_number=A01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(357, 'INSERT', 'seats', 'SCR002-002', NULL, 'screen_id=SCR002, seat_number=A02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(358, 'INSERT', 'seats', 'SCR002-003', NULL, 'screen_id=SCR002, seat_number=A03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(359, 'INSERT', 'seats', 'SCR002-004', NULL, 'screen_id=SCR002, seat_number=A04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(360, 'INSERT', 'seats', 'SCR002-005', NULL, 'screen_id=SCR002, seat_number=A05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(361, 'INSERT', 'seats', 'SCR002-006', NULL, 'screen_id=SCR002, seat_number=A06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(362, 'INSERT', 'seats', 'SCR002-007', NULL, 'screen_id=SCR002, seat_number=A07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(363, 'INSERT', 'seats', 'SCR002-008', NULL, 'screen_id=SCR002, seat_number=A08, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(364, 'INSERT', 'seats', 'SCR002-009', NULL, 'screen_id=SCR002, seat_number=A09, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(365, 'INSERT', 'seats', 'SCR002-010', NULL, 'screen_id=SCR002, seat_number=A10, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(366, 'INSERT', 'seats', 'SCR002-011', NULL, 'screen_id=SCR002, seat_number=B01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(367, 'INSERT', 'seats', 'SCR002-012', NULL, 'screen_id=SCR002, seat_number=B02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(368, 'INSERT', 'seats', 'SCR002-013', NULL, 'screen_id=SCR002, seat_number=B03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(369, 'INSERT', 'seats', 'SCR002-014', NULL, 'screen_id=SCR002, seat_number=B04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(370, 'INSERT', 'seats', 'SCR002-015', NULL, 'screen_id=SCR002, seat_number=B05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(371, 'INSERT', 'seats', 'SCR002-016', NULL, 'screen_id=SCR002, seat_number=B06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(372, 'INSERT', 'seats', 'SCR002-017', NULL, 'screen_id=SCR002, seat_number=B07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(373, 'INSERT', 'seats', 'SCR002-018', NULL, 'screen_id=SCR002, seat_number=B08, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(374, 'INSERT', 'seats', 'SCR002-019', NULL, 'screen_id=SCR002, seat_number=B09, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(375, 'INSERT', 'seats', 'SCR002-020', NULL, 'screen_id=SCR002, seat_number=B10, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(376, 'INSERT', 'seats', 'SCR002-021', NULL, 'screen_id=SCR002, seat_number=C01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(377, 'INSERT', 'seats', 'SCR002-022', NULL, 'screen_id=SCR002, seat_number=C02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(378, 'INSERT', 'seats', 'SCR002-023', NULL, 'screen_id=SCR002, seat_number=C03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(379, 'INSERT', 'seats', 'SCR002-024', NULL, 'screen_id=SCR002, seat_number=C04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(380, 'INSERT', 'seats', 'SCR002-025', NULL, 'screen_id=SCR002, seat_number=C05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(381, 'INSERT', 'seats', 'SCR002-026', NULL, 'screen_id=SCR002, seat_number=C06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(382, 'INSERT', 'seats', 'SCR002-027', NULL, 'screen_id=SCR002, seat_number=C07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(383, 'INSERT', 'seats', 'SCR002-028', NULL, 'screen_id=SCR002, seat_number=C08, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(384, 'INSERT', 'seats', 'SCR002-029', NULL, 'screen_id=SCR002, seat_number=C09, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(385, 'INSERT', 'seats', 'SCR002-030', NULL, 'screen_id=SCR002, seat_number=C10, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(386, 'INSERT', 'seats', 'SCR002-031', NULL, 'screen_id=SCR002, seat_number=D01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(387, 'INSERT', 'seats', 'SCR002-032', NULL, 'screen_id=SCR002, seat_number=D02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(388, 'INSERT', 'seats', 'SCR002-033', NULL, 'screen_id=SCR002, seat_number=D03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(389, 'INSERT', 'seats', 'SCR002-034', NULL, 'screen_id=SCR002, seat_number=D04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(390, 'INSERT', 'seats', 'SCR002-035', NULL, 'screen_id=SCR002, seat_number=D05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(391, 'INSERT', 'seats', 'SCR002-036', NULL, 'screen_id=SCR002, seat_number=D06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(392, 'INSERT', 'seats', 'SCR002-037', NULL, 'screen_id=SCR002, seat_number=D07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(393, 'INSERT', 'seats', 'SCR002-038', NULL, 'screen_id=SCR002, seat_number=D08, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(394, 'INSERT', 'seats', 'SCR002-039', NULL, 'screen_id=SCR002, seat_number=D09, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(395, 'INSERT', 'seats', 'SCR002-040', NULL, 'screen_id=SCR002, seat_number=D10, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(396, 'INSERT', 'seats', 'SCR002-041', NULL, 'screen_id=SCR002, seat_number=E01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(397, 'INSERT', 'seats', 'SCR002-042', NULL, 'screen_id=SCR002, seat_number=E02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(398, 'INSERT', 'seats', 'SCR002-043', NULL, 'screen_id=SCR002, seat_number=E03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(399, 'INSERT', 'seats', 'SCR002-044', NULL, 'screen_id=SCR002, seat_number=E04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(400, 'INSERT', 'seats', 'SCR002-045', NULL, 'screen_id=SCR002, seat_number=E05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(401, 'INSERT', 'seats', 'SCR002-046', NULL, 'screen_id=SCR002, seat_number=E06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(402, 'INSERT', 'seats', 'SCR002-047', NULL, 'screen_id=SCR002, seat_number=E07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(403, 'INSERT', 'seats', 'SCR002-048', NULL, 'screen_id=SCR002, seat_number=E08, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(404, 'INSERT', 'seats', 'SCR002-049', NULL, 'screen_id=SCR002, seat_number=E09, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(405, 'INSERT', 'seats', 'SCR002-050', NULL, 'screen_id=SCR002, seat_number=E10, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(406, 'INSERT', 'seats', 'SCR002-051', NULL, 'screen_id=SCR002, seat_number=F01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(407, 'INSERT', 'seats', 'SCR002-052', NULL, 'screen_id=SCR002, seat_number=F02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(408, 'INSERT', 'seats', 'SCR002-053', NULL, 'screen_id=SCR002, seat_number=F03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(409, 'INSERT', 'seats', 'SCR002-054', NULL, 'screen_id=SCR002, seat_number=F04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(410, 'INSERT', 'seats', 'SCR002-055', NULL, 'screen_id=SCR002, seat_number=F05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(411, 'INSERT', 'seats', 'SCR002-056', NULL, 'screen_id=SCR002, seat_number=F06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(412, 'INSERT', 'seats', 'SCR002-057', NULL, 'screen_id=SCR002, seat_number=F07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(413, 'INSERT', 'seats', 'SCR002-058', NULL, 'screen_id=SCR002, seat_number=F08, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(414, 'INSERT', 'seats', 'SCR002-059', NULL, 'screen_id=SCR002, seat_number=F09, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(415, 'INSERT', 'seats', 'SCR002-060', NULL, 'screen_id=SCR002, seat_number=F10, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(416, 'INSERT', 'seats', 'SCR002-061', NULL, 'screen_id=SCR002, seat_number=G01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(417, 'INSERT', 'seats', 'SCR002-062', NULL, 'screen_id=SCR002, seat_number=G02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(418, 'INSERT', 'seats', 'SCR002-063', NULL, 'screen_id=SCR002, seat_number=G03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(419, 'INSERT', 'seats', 'SCR002-064', NULL, 'screen_id=SCR002, seat_number=G04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(420, 'INSERT', 'seats', 'SCR002-065', NULL, 'screen_id=SCR002, seat_number=G05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(421, 'INSERT', 'seats', 'SCR002-066', NULL, 'screen_id=SCR002, seat_number=G06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(422, 'INSERT', 'seats', 'SCR002-067', NULL, 'screen_id=SCR002, seat_number=G07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(423, 'INSERT', 'seats', 'SCR002-068', NULL, 'screen_id=SCR002, seat_number=G08, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(424, 'INSERT', 'seats', 'SCR002-069', NULL, 'screen_id=SCR002, seat_number=G09, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(425, 'INSERT', 'seats', 'SCR002-070', NULL, 'screen_id=SCR002, seat_number=G10, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(426, 'INSERT', 'seats', 'SCR002-071', NULL, 'screen_id=SCR002, seat_number=H01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(427, 'INSERT', 'seats', 'SCR002-072', NULL, 'screen_id=SCR002, seat_number=H02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(428, 'INSERT', 'seats', 'SCR002-073', NULL, 'screen_id=SCR002, seat_number=H03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(429, 'INSERT', 'seats', 'SCR002-074', NULL, 'screen_id=SCR002, seat_number=H04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(430, 'INSERT', 'seats', 'SCR002-075', NULL, 'screen_id=SCR002, seat_number=H05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(431, 'INSERT', 'seats', 'SCR002-076', NULL, 'screen_id=SCR002, seat_number=H06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(432, 'INSERT', 'seats', 'SCR002-077', NULL, 'screen_id=SCR002, seat_number=H07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(433, 'INSERT', 'seats', 'SCR002-078', NULL, 'screen_id=SCR002, seat_number=H08, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(434, 'INSERT', 'seats', 'SCR002-079', NULL, 'screen_id=SCR002, seat_number=H09, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(435, 'INSERT', 'seats', 'SCR002-080', NULL, 'screen_id=SCR002, seat_number=H10, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(436, 'INSERT', 'seats', 'SCR002-081', NULL, 'screen_id=SCR002, seat_number=I01, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(437, 'INSERT', 'seats', 'SCR002-082', NULL, 'screen_id=SCR002, seat_number=I02, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(438, 'INSERT', 'seats', 'SCR002-083', NULL, 'screen_id=SCR002, seat_number=I03, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(439, 'INSERT', 'seats', 'SCR002-084', NULL, 'screen_id=SCR002, seat_number=I04, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(440, 'INSERT', 'seats', 'SCR002-085', NULL, 'screen_id=SCR002, seat_number=I05, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(441, 'INSERT', 'seats', 'SCR002-086', NULL, 'screen_id=SCR002, seat_number=I06, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(442, 'INSERT', 'seats', 'SCR002-087', NULL, 'screen_id=SCR002, seat_number=I07, seat_type=Standard, status=Available', '2026-05-02 14:54:42', 'system'),
(443, 'INSERT', 'seats', 'SCR002-088', NULL, 'screen_id=SCR002, seat_number=I08, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(444, 'INSERT', 'seats', 'SCR002-089', NULL, 'screen_id=SCR002, seat_number=I09, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(445, 'INSERT', 'seats', 'SCR002-090', NULL, 'screen_id=SCR002, seat_number=I10, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(446, 'INSERT', 'seats', 'SCR002-091', NULL, 'screen_id=SCR002, seat_number=J01, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(447, 'INSERT', 'seats', 'SCR002-092', NULL, 'screen_id=SCR002, seat_number=J02, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(448, 'INSERT', 'seats', 'SCR002-093', NULL, 'screen_id=SCR002, seat_number=J03, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(449, 'INSERT', 'seats', 'SCR002-094', NULL, 'screen_id=SCR002, seat_number=J04, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(450, 'INSERT', 'seats', 'SCR002-095', NULL, 'screen_id=SCR002, seat_number=J05, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(451, 'INSERT', 'seats', 'SCR002-096', NULL, 'screen_id=SCR002, seat_number=J06, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(452, 'INSERT', 'seats', 'SCR002-097', NULL, 'screen_id=SCR002, seat_number=J07, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(453, 'INSERT', 'seats', 'SCR002-098', NULL, 'screen_id=SCR002, seat_number=J08, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(454, 'INSERT', 'seats', 'SCR002-099', NULL, 'screen_id=SCR002, seat_number=J09, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(455, 'INSERT', 'seats', 'SCR002-100', NULL, 'screen_id=SCR002, seat_number=J10, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(456, 'INSERT', 'seats', 'SCR002-101', NULL, 'screen_id=SCR002, seat_number=K01, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(457, 'INSERT', 'seats', 'SCR002-102', NULL, 'screen_id=SCR002, seat_number=K02, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(458, 'INSERT', 'seats', 'SCR002-103', NULL, 'screen_id=SCR002, seat_number=K03, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(459, 'INSERT', 'seats', 'SCR002-104', NULL, 'screen_id=SCR002, seat_number=K04, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(460, 'INSERT', 'seats', 'SCR002-105', NULL, 'screen_id=SCR002, seat_number=K05, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(461, 'INSERT', 'seats', 'SCR002-106', NULL, 'screen_id=SCR002, seat_number=K06, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(462, 'INSERT', 'seats', 'SCR002-107', NULL, 'screen_id=SCR002, seat_number=K07, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(463, 'INSERT', 'seats', 'SCR002-108', NULL, 'screen_id=SCR002, seat_number=K08, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(464, 'INSERT', 'seats', 'SCR002-109', NULL, 'screen_id=SCR002, seat_number=K09, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(465, 'INSERT', 'seats', 'SCR002-110', NULL, 'screen_id=SCR002, seat_number=K10, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(466, 'INSERT', 'seats', 'SCR002-111', NULL, 'screen_id=SCR002, seat_number=L01, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(467, 'INSERT', 'seats', 'SCR002-112', NULL, 'screen_id=SCR002, seat_number=L02, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(468, 'INSERT', 'seats', 'SCR002-113', NULL, 'screen_id=SCR002, seat_number=L03, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(469, 'INSERT', 'seats', 'SCR002-114', NULL, 'screen_id=SCR002, seat_number=L04, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(470, 'INSERT', 'seats', 'SCR002-115', NULL, 'screen_id=SCR002, seat_number=L05, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(471, 'INSERT', 'seats', 'SCR002-116', NULL, 'screen_id=SCR002, seat_number=L06, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(472, 'INSERT', 'seats', 'SCR002-117', NULL, 'screen_id=SCR002, seat_number=L07, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(473, 'INSERT', 'seats', 'SCR002-118', NULL, 'screen_id=SCR002, seat_number=L08, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(474, 'INSERT', 'seats', 'SCR002-119', NULL, 'screen_id=SCR002, seat_number=L09, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(475, 'INSERT', 'seats', 'SCR002-120', NULL, 'screen_id=SCR002, seat_number=L10, seat_type=Standard, status=Available', '2026-05-02 14:54:43', 'system'),
(476, 'INSERT', 'screens', 'SCR003', NULL, 'cinema_id=CIN001, screen_name=Screen 1, total_seats=150', '2026-05-02 14:55:21', 'system'),
(477, 'INSERT', 'seats', 'SCR003-001', NULL, 'screen_id=SCR003, seat_number=A01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(478, 'INSERT', 'seats', 'SCR003-002', NULL, 'screen_id=SCR003, seat_number=A02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(479, 'INSERT', 'seats', 'SCR003-003', NULL, 'screen_id=SCR003, seat_number=A03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(480, 'INSERT', 'seats', 'SCR003-004', NULL, 'screen_id=SCR003, seat_number=A04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(481, 'INSERT', 'seats', 'SCR003-005', NULL, 'screen_id=SCR003, seat_number=A05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(482, 'INSERT', 'seats', 'SCR003-006', NULL, 'screen_id=SCR003, seat_number=A06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(483, 'INSERT', 'seats', 'SCR003-007', NULL, 'screen_id=SCR003, seat_number=A07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(484, 'INSERT', 'seats', 'SCR003-008', NULL, 'screen_id=SCR003, seat_number=A08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(485, 'INSERT', 'seats', 'SCR003-009', NULL, 'screen_id=SCR003, seat_number=A09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(486, 'INSERT', 'seats', 'SCR003-010', NULL, 'screen_id=SCR003, seat_number=A10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(487, 'INSERT', 'seats', 'SCR003-011', NULL, 'screen_id=SCR003, seat_number=B01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(488, 'INSERT', 'seats', 'SCR003-012', NULL, 'screen_id=SCR003, seat_number=B02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(489, 'INSERT', 'seats', 'SCR003-013', NULL, 'screen_id=SCR003, seat_number=B03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(490, 'INSERT', 'seats', 'SCR003-014', NULL, 'screen_id=SCR003, seat_number=B04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(491, 'INSERT', 'seats', 'SCR003-015', NULL, 'screen_id=SCR003, seat_number=B05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(492, 'INSERT', 'seats', 'SCR003-016', NULL, 'screen_id=SCR003, seat_number=B06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(493, 'INSERT', 'seats', 'SCR003-017', NULL, 'screen_id=SCR003, seat_number=B07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(494, 'INSERT', 'seats', 'SCR003-018', NULL, 'screen_id=SCR003, seat_number=B08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(495, 'INSERT', 'seats', 'SCR003-019', NULL, 'screen_id=SCR003, seat_number=B09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(496, 'INSERT', 'seats', 'SCR003-020', NULL, 'screen_id=SCR003, seat_number=B10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(497, 'INSERT', 'seats', 'SCR003-021', NULL, 'screen_id=SCR003, seat_number=C01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(498, 'INSERT', 'seats', 'SCR003-022', NULL, 'screen_id=SCR003, seat_number=C02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(499, 'INSERT', 'seats', 'SCR003-023', NULL, 'screen_id=SCR003, seat_number=C03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(500, 'INSERT', 'seats', 'SCR003-024', NULL, 'screen_id=SCR003, seat_number=C04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(501, 'INSERT', 'seats', 'SCR003-025', NULL, 'screen_id=SCR003, seat_number=C05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(502, 'INSERT', 'seats', 'SCR003-026', NULL, 'screen_id=SCR003, seat_number=C06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(503, 'INSERT', 'seats', 'SCR003-027', NULL, 'screen_id=SCR003, seat_number=C07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(504, 'INSERT', 'seats', 'SCR003-028', NULL, 'screen_id=SCR003, seat_number=C08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(505, 'INSERT', 'seats', 'SCR003-029', NULL, 'screen_id=SCR003, seat_number=C09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(506, 'INSERT', 'seats', 'SCR003-030', NULL, 'screen_id=SCR003, seat_number=C10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(507, 'INSERT', 'seats', 'SCR003-031', NULL, 'screen_id=SCR003, seat_number=D01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(508, 'INSERT', 'seats', 'SCR003-032', NULL, 'screen_id=SCR003, seat_number=D02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(509, 'INSERT', 'seats', 'SCR003-033', NULL, 'screen_id=SCR003, seat_number=D03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(510, 'INSERT', 'seats', 'SCR003-034', NULL, 'screen_id=SCR003, seat_number=D04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(511, 'INSERT', 'seats', 'SCR003-035', NULL, 'screen_id=SCR003, seat_number=D05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(512, 'INSERT', 'seats', 'SCR003-036', NULL, 'screen_id=SCR003, seat_number=D06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(513, 'INSERT', 'seats', 'SCR003-037', NULL, 'screen_id=SCR003, seat_number=D07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(514, 'INSERT', 'seats', 'SCR003-038', NULL, 'screen_id=SCR003, seat_number=D08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(515, 'INSERT', 'seats', 'SCR003-039', NULL, 'screen_id=SCR003, seat_number=D09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(516, 'INSERT', 'seats', 'SCR003-040', NULL, 'screen_id=SCR003, seat_number=D10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(517, 'INSERT', 'seats', 'SCR003-041', NULL, 'screen_id=SCR003, seat_number=E01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(518, 'INSERT', 'seats', 'SCR003-042', NULL, 'screen_id=SCR003, seat_number=E02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(519, 'INSERT', 'seats', 'SCR003-043', NULL, 'screen_id=SCR003, seat_number=E03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(520, 'INSERT', 'seats', 'SCR003-044', NULL, 'screen_id=SCR003, seat_number=E04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(521, 'INSERT', 'seats', 'SCR003-045', NULL, 'screen_id=SCR003, seat_number=E05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(522, 'INSERT', 'seats', 'SCR003-046', NULL, 'screen_id=SCR003, seat_number=E06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(523, 'INSERT', 'seats', 'SCR003-047', NULL, 'screen_id=SCR003, seat_number=E07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(524, 'INSERT', 'seats', 'SCR003-048', NULL, 'screen_id=SCR003, seat_number=E08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(525, 'INSERT', 'seats', 'SCR003-049', NULL, 'screen_id=SCR003, seat_number=E09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(526, 'INSERT', 'seats', 'SCR003-050', NULL, 'screen_id=SCR003, seat_number=E10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(527, 'INSERT', 'seats', 'SCR003-051', NULL, 'screen_id=SCR003, seat_number=F01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(528, 'INSERT', 'seats', 'SCR003-052', NULL, 'screen_id=SCR003, seat_number=F02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(529, 'INSERT', 'seats', 'SCR003-053', NULL, 'screen_id=SCR003, seat_number=F03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(530, 'INSERT', 'seats', 'SCR003-054', NULL, 'screen_id=SCR003, seat_number=F04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(531, 'INSERT', 'seats', 'SCR003-055', NULL, 'screen_id=SCR003, seat_number=F05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(532, 'INSERT', 'seats', 'SCR003-056', NULL, 'screen_id=SCR003, seat_number=F06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(533, 'INSERT', 'seats', 'SCR003-057', NULL, 'screen_id=SCR003, seat_number=F07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(534, 'INSERT', 'seats', 'SCR003-058', NULL, 'screen_id=SCR003, seat_number=F08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(535, 'INSERT', 'seats', 'SCR003-059', NULL, 'screen_id=SCR003, seat_number=F09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(536, 'INSERT', 'seats', 'SCR003-060', NULL, 'screen_id=SCR003, seat_number=F10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(537, 'INSERT', 'seats', 'SCR003-061', NULL, 'screen_id=SCR003, seat_number=G01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(538, 'INSERT', 'seats', 'SCR003-062', NULL, 'screen_id=SCR003, seat_number=G02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(539, 'INSERT', 'seats', 'SCR003-063', NULL, 'screen_id=SCR003, seat_number=G03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(540, 'INSERT', 'seats', 'SCR003-064', NULL, 'screen_id=SCR003, seat_number=G04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(541, 'INSERT', 'seats', 'SCR003-065', NULL, 'screen_id=SCR003, seat_number=G05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(542, 'INSERT', 'seats', 'SCR003-066', NULL, 'screen_id=SCR003, seat_number=G06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(543, 'INSERT', 'seats', 'SCR003-067', NULL, 'screen_id=SCR003, seat_number=G07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(544, 'INSERT', 'seats', 'SCR003-068', NULL, 'screen_id=SCR003, seat_number=G08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(545, 'INSERT', 'seats', 'SCR003-069', NULL, 'screen_id=SCR003, seat_number=G09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(546, 'INSERT', 'seats', 'SCR003-070', NULL, 'screen_id=SCR003, seat_number=G10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(547, 'INSERT', 'seats', 'SCR003-071', NULL, 'screen_id=SCR003, seat_number=H01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(548, 'INSERT', 'seats', 'SCR003-072', NULL, 'screen_id=SCR003, seat_number=H02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(549, 'INSERT', 'seats', 'SCR003-073', NULL, 'screen_id=SCR003, seat_number=H03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(550, 'INSERT', 'seats', 'SCR003-074', NULL, 'screen_id=SCR003, seat_number=H04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(551, 'INSERT', 'seats', 'SCR003-075', NULL, 'screen_id=SCR003, seat_number=H05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(552, 'INSERT', 'seats', 'SCR003-076', NULL, 'screen_id=SCR003, seat_number=H06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(553, 'INSERT', 'seats', 'SCR003-077', NULL, 'screen_id=SCR003, seat_number=H07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(554, 'INSERT', 'seats', 'SCR003-078', NULL, 'screen_id=SCR003, seat_number=H08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(555, 'INSERT', 'seats', 'SCR003-079', NULL, 'screen_id=SCR003, seat_number=H09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(556, 'INSERT', 'seats', 'SCR003-080', NULL, 'screen_id=SCR003, seat_number=H10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(557, 'INSERT', 'seats', 'SCR003-081', NULL, 'screen_id=SCR003, seat_number=I01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(558, 'INSERT', 'seats', 'SCR003-082', NULL, 'screen_id=SCR003, seat_number=I02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(559, 'INSERT', 'seats', 'SCR003-083', NULL, 'screen_id=SCR003, seat_number=I03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(560, 'INSERT', 'seats', 'SCR003-084', NULL, 'screen_id=SCR003, seat_number=I04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(561, 'INSERT', 'seats', 'SCR003-085', NULL, 'screen_id=SCR003, seat_number=I05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(562, 'INSERT', 'seats', 'SCR003-086', NULL, 'screen_id=SCR003, seat_number=I06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(563, 'INSERT', 'seats', 'SCR003-087', NULL, 'screen_id=SCR003, seat_number=I07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(564, 'INSERT', 'seats', 'SCR003-088', NULL, 'screen_id=SCR003, seat_number=I08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(565, 'INSERT', 'seats', 'SCR003-089', NULL, 'screen_id=SCR003, seat_number=I09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(566, 'INSERT', 'seats', 'SCR003-090', NULL, 'screen_id=SCR003, seat_number=I10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(567, 'INSERT', 'seats', 'SCR003-091', NULL, 'screen_id=SCR003, seat_number=J01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(568, 'INSERT', 'seats', 'SCR003-092', NULL, 'screen_id=SCR003, seat_number=J02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(569, 'INSERT', 'seats', 'SCR003-093', NULL, 'screen_id=SCR003, seat_number=J03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(570, 'INSERT', 'seats', 'SCR003-094', NULL, 'screen_id=SCR003, seat_number=J04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(571, 'INSERT', 'seats', 'SCR003-095', NULL, 'screen_id=SCR003, seat_number=J05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(572, 'INSERT', 'seats', 'SCR003-096', NULL, 'screen_id=SCR003, seat_number=J06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(573, 'INSERT', 'seats', 'SCR003-097', NULL, 'screen_id=SCR003, seat_number=J07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(574, 'INSERT', 'seats', 'SCR003-098', NULL, 'screen_id=SCR003, seat_number=J08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(575, 'INSERT', 'seats', 'SCR003-099', NULL, 'screen_id=SCR003, seat_number=J09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(576, 'INSERT', 'seats', 'SCR003-100', NULL, 'screen_id=SCR003, seat_number=J10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(577, 'INSERT', 'seats', 'SCR003-101', NULL, 'screen_id=SCR003, seat_number=K01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(578, 'INSERT', 'seats', 'SCR003-102', NULL, 'screen_id=SCR003, seat_number=K02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(579, 'INSERT', 'seats', 'SCR003-103', NULL, 'screen_id=SCR003, seat_number=K03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(580, 'INSERT', 'seats', 'SCR003-104', NULL, 'screen_id=SCR003, seat_number=K04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(581, 'INSERT', 'seats', 'SCR003-105', NULL, 'screen_id=SCR003, seat_number=K05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(582, 'INSERT', 'seats', 'SCR003-106', NULL, 'screen_id=SCR003, seat_number=K06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(583, 'INSERT', 'seats', 'SCR003-107', NULL, 'screen_id=SCR003, seat_number=K07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(584, 'INSERT', 'seats', 'SCR003-108', NULL, 'screen_id=SCR003, seat_number=K08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(585, 'INSERT', 'seats', 'SCR003-109', NULL, 'screen_id=SCR003, seat_number=K09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(586, 'INSERT', 'seats', 'SCR003-110', NULL, 'screen_id=SCR003, seat_number=K10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(587, 'INSERT', 'seats', 'SCR003-111', NULL, 'screen_id=SCR003, seat_number=L01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(588, 'INSERT', 'seats', 'SCR003-112', NULL, 'screen_id=SCR003, seat_number=L02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(589, 'INSERT', 'seats', 'SCR003-113', NULL, 'screen_id=SCR003, seat_number=L03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(590, 'INSERT', 'seats', 'SCR003-114', NULL, 'screen_id=SCR003, seat_number=L04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(591, 'INSERT', 'seats', 'SCR003-115', NULL, 'screen_id=SCR003, seat_number=L05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(592, 'INSERT', 'seats', 'SCR003-116', NULL, 'screen_id=SCR003, seat_number=L06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(593, 'INSERT', 'seats', 'SCR003-117', NULL, 'screen_id=SCR003, seat_number=L07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(594, 'INSERT', 'seats', 'SCR003-118', NULL, 'screen_id=SCR003, seat_number=L08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(595, 'INSERT', 'seats', 'SCR003-119', NULL, 'screen_id=SCR003, seat_number=L09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(596, 'INSERT', 'seats', 'SCR003-120', NULL, 'screen_id=SCR003, seat_number=L10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(597, 'INSERT', 'seats', 'SCR003-121', NULL, 'screen_id=SCR003, seat_number=M01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(598, 'INSERT', 'seats', 'SCR003-122', NULL, 'screen_id=SCR003, seat_number=M02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(599, 'INSERT', 'seats', 'SCR003-123', NULL, 'screen_id=SCR003, seat_number=M03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(600, 'INSERT', 'seats', 'SCR003-124', NULL, 'screen_id=SCR003, seat_number=M04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(601, 'INSERT', 'seats', 'SCR003-125', NULL, 'screen_id=SCR003, seat_number=M05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(602, 'INSERT', 'seats', 'SCR003-126', NULL, 'screen_id=SCR003, seat_number=M06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(603, 'INSERT', 'seats', 'SCR003-127', NULL, 'screen_id=SCR003, seat_number=M07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(604, 'INSERT', 'seats', 'SCR003-128', NULL, 'screen_id=SCR003, seat_number=M08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(605, 'INSERT', 'seats', 'SCR003-129', NULL, 'screen_id=SCR003, seat_number=M09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(606, 'INSERT', 'seats', 'SCR003-130', NULL, 'screen_id=SCR003, seat_number=M10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(607, 'INSERT', 'seats', 'SCR003-131', NULL, 'screen_id=SCR003, seat_number=N01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(608, 'INSERT', 'seats', 'SCR003-132', NULL, 'screen_id=SCR003, seat_number=N02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(609, 'INSERT', 'seats', 'SCR003-133', NULL, 'screen_id=SCR003, seat_number=N03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(610, 'INSERT', 'seats', 'SCR003-134', NULL, 'screen_id=SCR003, seat_number=N04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(611, 'INSERT', 'seats', 'SCR003-135', NULL, 'screen_id=SCR003, seat_number=N05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(612, 'INSERT', 'seats', 'SCR003-136', NULL, 'screen_id=SCR003, seat_number=N06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(613, 'INSERT', 'seats', 'SCR003-137', NULL, 'screen_id=SCR003, seat_number=N07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(614, 'INSERT', 'seats', 'SCR003-138', NULL, 'screen_id=SCR003, seat_number=N08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(615, 'INSERT', 'seats', 'SCR003-139', NULL, 'screen_id=SCR003, seat_number=N09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(616, 'INSERT', 'seats', 'SCR003-140', NULL, 'screen_id=SCR003, seat_number=N10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(617, 'INSERT', 'seats', 'SCR003-141', NULL, 'screen_id=SCR003, seat_number=O01, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(618, 'INSERT', 'seats', 'SCR003-142', NULL, 'screen_id=SCR003, seat_number=O02, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(619, 'INSERT', 'seats', 'SCR003-143', NULL, 'screen_id=SCR003, seat_number=O03, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(620, 'INSERT', 'seats', 'SCR003-144', NULL, 'screen_id=SCR003, seat_number=O04, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(621, 'INSERT', 'seats', 'SCR003-145', NULL, 'screen_id=SCR003, seat_number=O05, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(622, 'INSERT', 'seats', 'SCR003-146', NULL, 'screen_id=SCR003, seat_number=O06, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(623, 'INSERT', 'seats', 'SCR003-147', NULL, 'screen_id=SCR003, seat_number=O07, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(624, 'INSERT', 'seats', 'SCR003-148', NULL, 'screen_id=SCR003, seat_number=O08, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(625, 'INSERT', 'seats', 'SCR003-149', NULL, 'screen_id=SCR003, seat_number=O09, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(626, 'INSERT', 'seats', 'SCR003-150', NULL, 'screen_id=SCR003, seat_number=O10, seat_type=Standard, status=Available', '2026-05-02 14:55:21', 'system'),
(627, 'INSERT', 'screens', 'SCR004', NULL, 'cinema_id=CIN001, screen_name=Screen 2, total_seats=150', '2026-05-02 14:55:36', 'system'),
(628, 'INSERT', 'seats', 'SCR004-001', NULL, 'screen_id=SCR004, seat_number=A01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(629, 'INSERT', 'seats', 'SCR004-002', NULL, 'screen_id=SCR004, seat_number=A02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(630, 'INSERT', 'seats', 'SCR004-003', NULL, 'screen_id=SCR004, seat_number=A03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(631, 'INSERT', 'seats', 'SCR004-004', NULL, 'screen_id=SCR004, seat_number=A04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(632, 'INSERT', 'seats', 'SCR004-005', NULL, 'screen_id=SCR004, seat_number=A05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(633, 'INSERT', 'seats', 'SCR004-006', NULL, 'screen_id=SCR004, seat_number=A06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(634, 'INSERT', 'seats', 'SCR004-007', NULL, 'screen_id=SCR004, seat_number=A07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(635, 'INSERT', 'seats', 'SCR004-008', NULL, 'screen_id=SCR004, seat_number=A08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(636, 'INSERT', 'seats', 'SCR004-009', NULL, 'screen_id=SCR004, seat_number=A09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(637, 'INSERT', 'seats', 'SCR004-010', NULL, 'screen_id=SCR004, seat_number=A10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(638, 'INSERT', 'seats', 'SCR004-011', NULL, 'screen_id=SCR004, seat_number=B01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(639, 'INSERT', 'seats', 'SCR004-012', NULL, 'screen_id=SCR004, seat_number=B02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(640, 'INSERT', 'seats', 'SCR004-013', NULL, 'screen_id=SCR004, seat_number=B03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(641, 'INSERT', 'seats', 'SCR004-014', NULL, 'screen_id=SCR004, seat_number=B04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(642, 'INSERT', 'seats', 'SCR004-015', NULL, 'screen_id=SCR004, seat_number=B05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(643, 'INSERT', 'seats', 'SCR004-016', NULL, 'screen_id=SCR004, seat_number=B06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(644, 'INSERT', 'seats', 'SCR004-017', NULL, 'screen_id=SCR004, seat_number=B07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(645, 'INSERT', 'seats', 'SCR004-018', NULL, 'screen_id=SCR004, seat_number=B08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(646, 'INSERT', 'seats', 'SCR004-019', NULL, 'screen_id=SCR004, seat_number=B09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(647, 'INSERT', 'seats', 'SCR004-020', NULL, 'screen_id=SCR004, seat_number=B10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system');
INSERT INTO `audit_log` (`log_id`, `operation`, `table_name`, `record_id`, `old_data`, `new_data`, `changed_at`, `changed_by`) VALUES
(648, 'INSERT', 'seats', 'SCR004-021', NULL, 'screen_id=SCR004, seat_number=C01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(649, 'INSERT', 'seats', 'SCR004-022', NULL, 'screen_id=SCR004, seat_number=C02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(650, 'INSERT', 'seats', 'SCR004-023', NULL, 'screen_id=SCR004, seat_number=C03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(651, 'INSERT', 'seats', 'SCR004-024', NULL, 'screen_id=SCR004, seat_number=C04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(652, 'INSERT', 'seats', 'SCR004-025', NULL, 'screen_id=SCR004, seat_number=C05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(653, 'INSERT', 'seats', 'SCR004-026', NULL, 'screen_id=SCR004, seat_number=C06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(654, 'INSERT', 'seats', 'SCR004-027', NULL, 'screen_id=SCR004, seat_number=C07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(655, 'INSERT', 'seats', 'SCR004-028', NULL, 'screen_id=SCR004, seat_number=C08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(656, 'INSERT', 'seats', 'SCR004-029', NULL, 'screen_id=SCR004, seat_number=C09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(657, 'INSERT', 'seats', 'SCR004-030', NULL, 'screen_id=SCR004, seat_number=C10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(658, 'INSERT', 'seats', 'SCR004-031', NULL, 'screen_id=SCR004, seat_number=D01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(659, 'INSERT', 'seats', 'SCR004-032', NULL, 'screen_id=SCR004, seat_number=D02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(660, 'INSERT', 'seats', 'SCR004-033', NULL, 'screen_id=SCR004, seat_number=D03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(661, 'INSERT', 'seats', 'SCR004-034', NULL, 'screen_id=SCR004, seat_number=D04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(662, 'INSERT', 'seats', 'SCR004-035', NULL, 'screen_id=SCR004, seat_number=D05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(663, 'INSERT', 'seats', 'SCR004-036', NULL, 'screen_id=SCR004, seat_number=D06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(664, 'INSERT', 'seats', 'SCR004-037', NULL, 'screen_id=SCR004, seat_number=D07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(665, 'INSERT', 'seats', 'SCR004-038', NULL, 'screen_id=SCR004, seat_number=D08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(666, 'INSERT', 'seats', 'SCR004-039', NULL, 'screen_id=SCR004, seat_number=D09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(667, 'INSERT', 'seats', 'SCR004-040', NULL, 'screen_id=SCR004, seat_number=D10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(668, 'INSERT', 'seats', 'SCR004-041', NULL, 'screen_id=SCR004, seat_number=E01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(669, 'INSERT', 'seats', 'SCR004-042', NULL, 'screen_id=SCR004, seat_number=E02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(670, 'INSERT', 'seats', 'SCR004-043', NULL, 'screen_id=SCR004, seat_number=E03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(671, 'INSERT', 'seats', 'SCR004-044', NULL, 'screen_id=SCR004, seat_number=E04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(672, 'INSERT', 'seats', 'SCR004-045', NULL, 'screen_id=SCR004, seat_number=E05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(673, 'INSERT', 'seats', 'SCR004-046', NULL, 'screen_id=SCR004, seat_number=E06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(674, 'INSERT', 'seats', 'SCR004-047', NULL, 'screen_id=SCR004, seat_number=E07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(675, 'INSERT', 'seats', 'SCR004-048', NULL, 'screen_id=SCR004, seat_number=E08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(676, 'INSERT', 'seats', 'SCR004-049', NULL, 'screen_id=SCR004, seat_number=E09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(677, 'INSERT', 'seats', 'SCR004-050', NULL, 'screen_id=SCR004, seat_number=E10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(678, 'INSERT', 'seats', 'SCR004-051', NULL, 'screen_id=SCR004, seat_number=F01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(679, 'INSERT', 'seats', 'SCR004-052', NULL, 'screen_id=SCR004, seat_number=F02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(680, 'INSERT', 'seats', 'SCR004-053', NULL, 'screen_id=SCR004, seat_number=F03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(681, 'INSERT', 'seats', 'SCR004-054', NULL, 'screen_id=SCR004, seat_number=F04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(682, 'INSERT', 'seats', 'SCR004-055', NULL, 'screen_id=SCR004, seat_number=F05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(683, 'INSERT', 'seats', 'SCR004-056', NULL, 'screen_id=SCR004, seat_number=F06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(684, 'INSERT', 'seats', 'SCR004-057', NULL, 'screen_id=SCR004, seat_number=F07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(685, 'INSERT', 'seats', 'SCR004-058', NULL, 'screen_id=SCR004, seat_number=F08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(686, 'INSERT', 'seats', 'SCR004-059', NULL, 'screen_id=SCR004, seat_number=F09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(687, 'INSERT', 'seats', 'SCR004-060', NULL, 'screen_id=SCR004, seat_number=F10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(688, 'INSERT', 'seats', 'SCR004-061', NULL, 'screen_id=SCR004, seat_number=G01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(689, 'INSERT', 'seats', 'SCR004-062', NULL, 'screen_id=SCR004, seat_number=G02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(690, 'INSERT', 'seats', 'SCR004-063', NULL, 'screen_id=SCR004, seat_number=G03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(691, 'INSERT', 'seats', 'SCR004-064', NULL, 'screen_id=SCR004, seat_number=G04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(692, 'INSERT', 'seats', 'SCR004-065', NULL, 'screen_id=SCR004, seat_number=G05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(693, 'INSERT', 'seats', 'SCR004-066', NULL, 'screen_id=SCR004, seat_number=G06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(694, 'INSERT', 'seats', 'SCR004-067', NULL, 'screen_id=SCR004, seat_number=G07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(695, 'INSERT', 'seats', 'SCR004-068', NULL, 'screen_id=SCR004, seat_number=G08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(696, 'INSERT', 'seats', 'SCR004-069', NULL, 'screen_id=SCR004, seat_number=G09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(697, 'INSERT', 'seats', 'SCR004-070', NULL, 'screen_id=SCR004, seat_number=G10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(698, 'INSERT', 'seats', 'SCR004-071', NULL, 'screen_id=SCR004, seat_number=H01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(699, 'INSERT', 'seats', 'SCR004-072', NULL, 'screen_id=SCR004, seat_number=H02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(700, 'INSERT', 'seats', 'SCR004-073', NULL, 'screen_id=SCR004, seat_number=H03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(701, 'INSERT', 'seats', 'SCR004-074', NULL, 'screen_id=SCR004, seat_number=H04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(702, 'INSERT', 'seats', 'SCR004-075', NULL, 'screen_id=SCR004, seat_number=H05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(703, 'INSERT', 'seats', 'SCR004-076', NULL, 'screen_id=SCR004, seat_number=H06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(704, 'INSERT', 'seats', 'SCR004-077', NULL, 'screen_id=SCR004, seat_number=H07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(705, 'INSERT', 'seats', 'SCR004-078', NULL, 'screen_id=SCR004, seat_number=H08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(706, 'INSERT', 'seats', 'SCR004-079', NULL, 'screen_id=SCR004, seat_number=H09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(707, 'INSERT', 'seats', 'SCR004-080', NULL, 'screen_id=SCR004, seat_number=H10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(708, 'INSERT', 'seats', 'SCR004-081', NULL, 'screen_id=SCR004, seat_number=I01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(709, 'INSERT', 'seats', 'SCR004-082', NULL, 'screen_id=SCR004, seat_number=I02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(710, 'INSERT', 'seats', 'SCR004-083', NULL, 'screen_id=SCR004, seat_number=I03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(711, 'INSERT', 'seats', 'SCR004-084', NULL, 'screen_id=SCR004, seat_number=I04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(712, 'INSERT', 'seats', 'SCR004-085', NULL, 'screen_id=SCR004, seat_number=I05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(713, 'INSERT', 'seats', 'SCR004-086', NULL, 'screen_id=SCR004, seat_number=I06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(714, 'INSERT', 'seats', 'SCR004-087', NULL, 'screen_id=SCR004, seat_number=I07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(715, 'INSERT', 'seats', 'SCR004-088', NULL, 'screen_id=SCR004, seat_number=I08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(716, 'INSERT', 'seats', 'SCR004-089', NULL, 'screen_id=SCR004, seat_number=I09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(717, 'INSERT', 'seats', 'SCR004-090', NULL, 'screen_id=SCR004, seat_number=I10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(718, 'INSERT', 'seats', 'SCR004-091', NULL, 'screen_id=SCR004, seat_number=J01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(719, 'INSERT', 'seats', 'SCR004-092', NULL, 'screen_id=SCR004, seat_number=J02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(720, 'INSERT', 'seats', 'SCR004-093', NULL, 'screen_id=SCR004, seat_number=J03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(721, 'INSERT', 'seats', 'SCR004-094', NULL, 'screen_id=SCR004, seat_number=J04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(722, 'INSERT', 'seats', 'SCR004-095', NULL, 'screen_id=SCR004, seat_number=J05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(723, 'INSERT', 'seats', 'SCR004-096', NULL, 'screen_id=SCR004, seat_number=J06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(724, 'INSERT', 'seats', 'SCR004-097', NULL, 'screen_id=SCR004, seat_number=J07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(725, 'INSERT', 'seats', 'SCR004-098', NULL, 'screen_id=SCR004, seat_number=J08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(726, 'INSERT', 'seats', 'SCR004-099', NULL, 'screen_id=SCR004, seat_number=J09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(727, 'INSERT', 'seats', 'SCR004-100', NULL, 'screen_id=SCR004, seat_number=J10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(728, 'INSERT', 'seats', 'SCR004-101', NULL, 'screen_id=SCR004, seat_number=K01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(729, 'INSERT', 'seats', 'SCR004-102', NULL, 'screen_id=SCR004, seat_number=K02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(730, 'INSERT', 'seats', 'SCR004-103', NULL, 'screen_id=SCR004, seat_number=K03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(731, 'INSERT', 'seats', 'SCR004-104', NULL, 'screen_id=SCR004, seat_number=K04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(732, 'INSERT', 'seats', 'SCR004-105', NULL, 'screen_id=SCR004, seat_number=K05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(733, 'INSERT', 'seats', 'SCR004-106', NULL, 'screen_id=SCR004, seat_number=K06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(734, 'INSERT', 'seats', 'SCR004-107', NULL, 'screen_id=SCR004, seat_number=K07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(735, 'INSERT', 'seats', 'SCR004-108', NULL, 'screen_id=SCR004, seat_number=K08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(736, 'INSERT', 'seats', 'SCR004-109', NULL, 'screen_id=SCR004, seat_number=K09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(737, 'INSERT', 'seats', 'SCR004-110', NULL, 'screen_id=SCR004, seat_number=K10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(738, 'INSERT', 'seats', 'SCR004-111', NULL, 'screen_id=SCR004, seat_number=L01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(739, 'INSERT', 'seats', 'SCR004-112', NULL, 'screen_id=SCR004, seat_number=L02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(740, 'INSERT', 'seats', 'SCR004-113', NULL, 'screen_id=SCR004, seat_number=L03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(741, 'INSERT', 'seats', 'SCR004-114', NULL, 'screen_id=SCR004, seat_number=L04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(742, 'INSERT', 'seats', 'SCR004-115', NULL, 'screen_id=SCR004, seat_number=L05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(743, 'INSERT', 'seats', 'SCR004-116', NULL, 'screen_id=SCR004, seat_number=L06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(744, 'INSERT', 'seats', 'SCR004-117', NULL, 'screen_id=SCR004, seat_number=L07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(745, 'INSERT', 'seats', 'SCR004-118', NULL, 'screen_id=SCR004, seat_number=L08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(746, 'INSERT', 'seats', 'SCR004-119', NULL, 'screen_id=SCR004, seat_number=L09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(747, 'INSERT', 'seats', 'SCR004-120', NULL, 'screen_id=SCR004, seat_number=L10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(748, 'INSERT', 'seats', 'SCR004-121', NULL, 'screen_id=SCR004, seat_number=M01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(749, 'INSERT', 'seats', 'SCR004-122', NULL, 'screen_id=SCR004, seat_number=M02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(750, 'INSERT', 'seats', 'SCR004-123', NULL, 'screen_id=SCR004, seat_number=M03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(751, 'INSERT', 'seats', 'SCR004-124', NULL, 'screen_id=SCR004, seat_number=M04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(752, 'INSERT', 'seats', 'SCR004-125', NULL, 'screen_id=SCR004, seat_number=M05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(753, 'INSERT', 'seats', 'SCR004-126', NULL, 'screen_id=SCR004, seat_number=M06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(754, 'INSERT', 'seats', 'SCR004-127', NULL, 'screen_id=SCR004, seat_number=M07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(755, 'INSERT', 'seats', 'SCR004-128', NULL, 'screen_id=SCR004, seat_number=M08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(756, 'INSERT', 'seats', 'SCR004-129', NULL, 'screen_id=SCR004, seat_number=M09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(757, 'INSERT', 'seats', 'SCR004-130', NULL, 'screen_id=SCR004, seat_number=M10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(758, 'INSERT', 'seats', 'SCR004-131', NULL, 'screen_id=SCR004, seat_number=N01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(759, 'INSERT', 'seats', 'SCR004-132', NULL, 'screen_id=SCR004, seat_number=N02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(760, 'INSERT', 'seats', 'SCR004-133', NULL, 'screen_id=SCR004, seat_number=N03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(761, 'INSERT', 'seats', 'SCR004-134', NULL, 'screen_id=SCR004, seat_number=N04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(762, 'INSERT', 'seats', 'SCR004-135', NULL, 'screen_id=SCR004, seat_number=N05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(763, 'INSERT', 'seats', 'SCR004-136', NULL, 'screen_id=SCR004, seat_number=N06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(764, 'INSERT', 'seats', 'SCR004-137', NULL, 'screen_id=SCR004, seat_number=N07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(765, 'INSERT', 'seats', 'SCR004-138', NULL, 'screen_id=SCR004, seat_number=N08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(766, 'INSERT', 'seats', 'SCR004-139', NULL, 'screen_id=SCR004, seat_number=N09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(767, 'INSERT', 'seats', 'SCR004-140', NULL, 'screen_id=SCR004, seat_number=N10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(768, 'INSERT', 'seats', 'SCR004-141', NULL, 'screen_id=SCR004, seat_number=O01, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(769, 'INSERT', 'seats', 'SCR004-142', NULL, 'screen_id=SCR004, seat_number=O02, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(770, 'INSERT', 'seats', 'SCR004-143', NULL, 'screen_id=SCR004, seat_number=O03, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(771, 'INSERT', 'seats', 'SCR004-144', NULL, 'screen_id=SCR004, seat_number=O04, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(772, 'INSERT', 'seats', 'SCR004-145', NULL, 'screen_id=SCR004, seat_number=O05, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(773, 'INSERT', 'seats', 'SCR004-146', NULL, 'screen_id=SCR004, seat_number=O06, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(774, 'INSERT', 'seats', 'SCR004-147', NULL, 'screen_id=SCR004, seat_number=O07, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(775, 'INSERT', 'seats', 'SCR004-148', NULL, 'screen_id=SCR004, seat_number=O08, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(776, 'INSERT', 'seats', 'SCR004-149', NULL, 'screen_id=SCR004, seat_number=O09, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(777, 'INSERT', 'seats', 'SCR004-150', NULL, 'screen_id=SCR004, seat_number=O10, seat_type=Standard, status=Available', '2026-05-02 14:55:36', 'system'),
(778, 'INSERT', 'bookings', 'BKG001', NULL, 'customer_id=CUS001, showtime_id=SHW002, customer_name=Juan Dela Cruz, total_amount=250.00, status=Confirmed', '2026-05-02 14:57:43', 'system'),
(779, 'INSERT', 'payments', 'PAY001', NULL, 'booking_id=BKG001, amount=250.00, method=GCash, status=Paid', '2026-05-02 14:58:17', 'system'),
(780, 'UPDATE', 'bookings', 'BKG001', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-05-02 14:58:17', 'system'),
(781, 'INSERT', 'tickets', 'TKT0001', NULL, 'booking_id=BKG001, seat_id=SCR004-001, ticket_price=250.00', '2026-05-02 14:58:38', 'system'),
(782, 'UPDATE', 'seats', 'SCR004-001', 'screen_id=SCR004, seat_number=A01, status=Available', 'screen_id=SCR004, seat_number=A01, status=Taken', '2026-05-02 14:58:38', 'system'),
(783, 'UPDATE', 'payments', 'PAY001', 'amount=250.00, method=GCash, status=Paid', 'amount=500.00, method=GCash, status=Paid', '2026-05-02 14:58:54', 'system'),
(784, 'UPDATE', 'bookings', 'BKG001', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-05-02 14:58:54', 'system'),
(785, 'UPDATE', 'payments', 'PAY001', 'amount=500.00, method=GCash, status=Paid', 'amount=250.00, method=GCash, status=Paid', '2026-05-02 14:59:10', 'system'),
(786, 'UPDATE', 'bookings', 'BKG001', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-05-02 14:59:10', 'system'),
(787, 'INSERT', 'bookings', 'BKG002', NULL, 'customer_id=CUS007, showtime_id=SHW001, customer_name=Eumee Sodusta, total_amount=250.00, status=Confirmed', '2026-05-02 14:59:39', 'system'),
(788, 'INSERT', 'tickets', 'TKT0002', NULL, 'booking_id=BKG002, seat_id=SCR003-033, ticket_price=250.00', '2026-05-02 14:59:57', 'system'),
(789, 'UPDATE', 'seats', 'SCR003-033', 'screen_id=SCR003, seat_number=D03, status=Available', 'screen_id=SCR003, seat_number=D03, status=Taken', '2026-05-02 14:59:57', 'system'),
(790, 'INSERT', 'payments', 'PAY002', NULL, 'booking_id=BKG002, amount=250.00, method=GCash, status=Paid', '2026-05-02 15:00:09', 'system'),
(791, 'UPDATE', 'bookings', 'BKG002', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-05-02 15:00:09', 'system'),
(792, 'INSERT', 'bookings', 'BKG003', NULL, 'customer_id=CUS008, showtime_id=SHW002, customer_name=Renz Ramos, total_amount=250.00, status=Confirmed', '2026-05-02 15:00:50', 'system'),
(793, 'INSERT', 'tickets', 'TKT0003', NULL, 'booking_id=BKG003, seat_id=SCR004-011, ticket_price=250.00', '2026-05-02 15:01:04', 'system'),
(794, 'UPDATE', 'seats', 'SCR004-011', 'screen_id=SCR004, seat_number=B01, status=Available', 'screen_id=SCR004, seat_number=B01, status=Taken', '2026-05-02 15:01:04', 'system'),
(795, 'INSERT', 'payments', 'PAY003', NULL, 'booking_id=BKG003, amount=250.00, method=Cash, status=Paid', '2026-05-02 15:01:31', 'system'),
(796, 'UPDATE', 'bookings', 'BKG003', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-05-02 15:01:31', 'system'),
(797, 'UPDATE', 'showtimes', 'SHW002', 'movie_id=MOV012, screen_id=SCR004, show_date=2026-05-02, start_time=10:00:00, end_time=12:00:00, price=250.00', 'movie_id=MOV012, screen_id=SCR004, show_date=2026-05-02, start_time=10:00:00, end_time=12:00:00, price=200.00', '2026-05-02 17:22:01', 'system'),
(798, 'UPDATE', 'showtimes', 'SHW002', 'movie_id=MOV012, screen_id=SCR004, show_date=2026-05-02, start_time=10:00:00, end_time=12:00:00, price=200.00', 'movie_id=MOV012, screen_id=SCR004, show_date=2026-05-02, start_time=10:00:00, end_time=12:00:00, price=250.00', '2026-05-02 17:22:59', 'system'),
(799, 'DELETE', 'customers', 'CUS001', 'first_name=Juan, last_name=Dela Cruz, email=juan@email.com, status=Active', NULL, '2026-05-02 21:13:19', 'system'),
(800, 'INSERT', 'showtimes', 'SHW003', NULL, 'movie_id=MOV004, screen_id=SCR001, show_date=2026-05-03, start_time=10:00:00, end_time=12:00:00, price=250.00', '2026-05-03 12:49:46', 'system'),
(801, 'INSERT', 'bookings', 'BKG004', NULL, 'customer_id=CUS002, showtime_id=SHW003, customer_name=Maria Santos, total_amount=250.00, status=Confirmed', '2026-05-03 12:50:43', 'system'),
(802, 'INSERT', 'tickets', 'TKT0004', NULL, 'booking_id=BKG004, seat_id=SCR001-015, ticket_price=250.00', '2026-05-03 12:50:58', 'system'),
(803, 'UPDATE', 'seats', 'SCR001-015', 'screen_id=SCR001, seat_number=B05, status=Available', 'screen_id=SCR001, seat_number=B05, status=Taken', '2026-05-03 12:50:58', 'system'),
(804, 'INSERT', 'payments', 'PAY004', NULL, 'booking_id=BKG004, amount=250.00, method=Cash, status=Paid', '2026-05-03 12:51:18', 'system'),
(805, 'UPDATE', 'bookings', 'BKG004', 'total_amount=250.00, status=Confirmed', 'total_amount=250.00, status=Confirmed', '2026-05-03 12:51:18', 'system'),
(806, 'UPDATE', 'payments', 'PAY004', 'amount=250.00, method=Cash, status=Paid', 'amount=250.00, method=Cash, status=Failed', '2026-05-03 12:51:40', 'system'),
(807, 'DELETE', 'tickets', 'TKT0004', 'booking_id=BKG004, seat_id=SCR001-015, ticket_price=250.00', NULL, '2026-05-03 12:51:53', 'system'),
(808, 'UPDATE', 'seats', 'SCR001-015', 'screen_id=SCR001, seat_number=B05, status=Taken', 'screen_id=SCR001, seat_number=B05, status=Available', '2026-05-03 12:51:53', 'system'),
(809, 'UPDATE', 'showtimes', 'SHW003', 'movie_id=MOV004, screen_id=SCR001, show_date=2026-05-03, start_time=10:00:00, end_time=12:00:00, price=250.00', 'movie_id=MOV004, screen_id=SCR001, show_date=2026-05-03, start_time=06:00:00, end_time=18:15:00, price=250.00', '2026-05-03 12:53:34', 'system'),
(810, 'DELETE', 'tickets', 'TKT0003', 'booking_id=BKG003, seat_id=SCR004-011, ticket_price=250.00', NULL, '2026-05-03 12:54:24', 'system'),
(811, 'UPDATE', 'seats', 'SCR004-011', 'screen_id=SCR004, seat_number=B01, status=Taken', 'screen_id=SCR004, seat_number=B01, status=Available', '2026-05-03 12:54:24', 'system'),
(812, 'DELETE', 'tickets', 'TKT0002', 'booking_id=BKG002, seat_id=SCR003-033, ticket_price=250.00', NULL, '2026-05-03 12:54:34', 'system'),
(813, 'UPDATE', 'seats', 'SCR003-033', 'screen_id=SCR003, seat_number=D03, status=Taken', 'screen_id=SCR003, seat_number=D03, status=Available', '2026-05-03 12:54:34', 'system'),
(814, 'UPDATE', 'seats', 'SCR004-001', 'screen_id=SCR004, seat_number=A01, status=Taken', 'screen_id=SCR004, seat_number=A01, status=Available', '2026-05-03 12:54:43', 'system'),
(815, 'INSERT', 'bookings', 'BKG005', NULL, 'customer_id=CUS005, showtime_id=SHW003, customer_name=Carlo Mendoza, total_amount=200.00, status=Pending', '2026-05-03 12:58:44', 'system'),
(816, 'UPDATE', 'seats', 'SCR001-035', 'screen_id=SCR001, seat_number=D05, status=Available', 'screen_id=SCR001, seat_number=D05, status=Taken', '2026-05-03 13:19:35', 'system'),
(817, 'UPDATE', 'seats', 'SCR001-035', 'screen_id=SCR001, seat_number=D05, status=Taken', 'screen_id=SCR001, seat_number=D05, status=Available', '2026-05-03 13:19:44', 'system'),
(818, 'INSERT', 'bookings', 'BKG006', NULL, 'customer_id=CUS010, showtime_id=SHW003, customer_name=Nadine Lustre, total_amount=0.00, status=Pending', '2026-05-03 13:21:28', 'system'),
(819, 'INSERT', 'tickets', 'TKT0001', NULL, 'booking_id=BKG006, seat_id=SCR001-001, ticket_price=250.00', '2026-05-03 13:26:37', 'system'),
(820, 'UPDATE', 'seats', 'SCR001-001', 'screen_id=SCR001, seat_number=A01, status=Available', 'screen_id=SCR001, seat_number=A01, status=Taken', '2026-05-03 13:26:37', 'system'),
(821, 'UPDATE', 'bookings', 'BKG006', 'total_amount=0.00, status=Pending', 'total_amount=0.00, status=Cancelled', '2026-05-03 13:27:37', 'system'),
(822, 'DELETE', 'tickets', 'TKT0001', 'booking_id=BKG006, seat_id=SCR001-001, ticket_price=250.00', NULL, '2026-05-03 13:27:54', 'system'),
(823, 'UPDATE', 'seats', 'SCR001-001', 'screen_id=SCR001, seat_number=A01, status=Taken', 'screen_id=SCR001, seat_number=A01, status=Available', '2026-05-03 13:27:54', 'system'),
(824, 'INSERT', 'bookings', 'BKG007', NULL, 'customer_id=CUS007, showtime_id=SHW003, customer_name=Renz, total_amount=0.00, status=Pending', '2026-05-03 13:32:16', 'system'),
(825, 'INSERT', 'bookings', 'BKG008', NULL, 'customer_id=CUS009, showtime_id=SHW003, customer_name=Gleih, total_amount=0.00, status=Pending', '2026-05-03 13:32:27', 'system'),
(826, 'DELETE', 'bookings', 'BKG007', 'customer_id=CUS007, showtime_id=SHW003, total_amount=0.00, status=Pending', NULL, '2026-05-03 13:32:32', 'system'),
(827, 'DELETE', 'bookings', 'BKG008', 'customer_id=CUS009, showtime_id=SHW003, total_amount=0.00, status=Pending', NULL, '2026-05-03 13:32:35', 'system'),
(828, 'INSERT', 'bookings', 'BKG007', NULL, 'customer_id=CUS007, showtime_id=SHW003, customer_name=Eumee Sodusta, total_amount=250.00, status=Pending', '2026-05-03 16:10:51', 'system'),
(829, 'INSERT', 'tickets', 'TKT0001', NULL, 'booking_id=BKG007, seat_id=SCR001-001, ticket_price=250.00', '2026-05-03 16:11:23', 'system'),
(830, 'UPDATE', 'seats', 'SCR001-001', 'screen_id=SCR001, seat_number=A01, status=Available', 'screen_id=SCR001, seat_number=A01, status=Taken', '2026-05-03 16:11:23', 'system'),
(831, 'INSERT', 'payments', 'PAY005', NULL, 'booking_id=BKG007, amount=250.00, method=Cash, status=Paid', '2026-05-03 16:11:51', 'system'),
(832, 'UPDATE', 'bookings', 'BKG007', 'total_amount=250.00, status=Pending', 'total_amount=250.00, status=Confirmed', '2026-05-03 16:11:51', 'system');

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` varchar(15) NOT NULL,
  `customer_id` varchar(10) NOT NULL,
  `showtime_id` varchar(10) NOT NULL,
  `customer_name` varchar(160) NOT NULL,
  `booking_date` date NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `booking_status` enum('Confirmed','Pending','Cancelled') NOT NULL DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `customer_id`, `showtime_id`, `customer_name`, `booking_date`, `total_amount`, `booking_status`) VALUES
('BKG002', 'CUS007', 'SHW001', 'Eumee Sodusta', '2026-05-02', 250.00, 'Confirmed'),
('BKG003', 'CUS008', 'SHW002', 'Renz Ramos', '2026-05-02', 250.00, 'Confirmed'),
('BKG004', 'CUS002', 'SHW003', 'Maria Santos', '2026-05-03', 250.00, 'Confirmed'),
('BKG005', 'CUS005', 'SHW003', 'Carlo Mendoza', '2026-05-03', 200.00, 'Pending'),
('BKG006', 'CUS010', 'SHW003', 'Nadine Lustre', '2026-05-03', 0.00, 'Cancelled'),
('BKG007', 'CUS007', 'SHW003', 'Eumee Sodusta', '2026-05-03', 250.00, 'Confirmed');

--
-- Triggers `bookings`
--
DELIMITER $$
CREATE TRIGGER `trg_bookings_after_delete` AFTER DELETE ON `bookings` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'bookings', OLD.booking_id,
    CONCAT('customer_id=', OLD.customer_id, ', showtime_id=', OLD.showtime_id,
           ', total_amount=', OLD.total_amount, ', status=', OLD.booking_status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_bookings_after_insert` AFTER INSERT ON `bookings` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'bookings', NEW.booking_id,
    CONCAT('customer_id=', NEW.customer_id, ', showtime_id=', NEW.showtime_id,
           ', customer_name=', NEW.customer_name, ', total_amount=', NEW.total_amount,
           ', status=', NEW.booking_status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_bookings_after_update` AFTER UPDATE ON `bookings` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'bookings', NEW.booking_id,
    CONCAT('total_amount=', OLD.total_amount, ', status=', OLD.booking_status),
    CONCAT('total_amount=', NEW.total_amount, ', status=', NEW.booking_status));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cinemas`
--

CREATE TABLE `cinemas` (
  `cinema_id` varchar(10) NOT NULL,
  `cinema_name` varchar(150) NOT NULL,
  `location` varchar(255) NOT NULL,
  `contact_number` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cinemas`
--

INSERT INTO `cinemas` (`cinema_id`, `cinema_name`, `location`, `contact_number`) VALUES
('CIN001', 'SM Cinema Iloilo', 'SM City Iloilo, Senator Benigno Aquino Jr. Avenue', '(032) 231-0001'),
('CIN002', 'Festive Walk Cinemas', 'Festive Walk,  Mandurriao, Iloilo City', '(032) 888-0002'),
('CIN003', 'Robinsons Movieworld', 'Robinsons Galleria, Iloilo City', '(032) 777-0003');

--
-- Triggers `cinemas`
--
DELIMITER $$
CREATE TRIGGER `trg_cinemas_after_delete` AFTER DELETE ON `cinemas` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'cinemas', OLD.cinema_id,
    CONCAT('cinema_name=', OLD.cinema_name, ', location=', OLD.location));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cinemas_after_insert` AFTER INSERT ON `cinemas` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'cinemas', NEW.cinema_id,
    CONCAT('cinema_name=', NEW.cinema_name, ', location=', NEW.location,
           ', contact=', NEW.contact_number));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cinemas_after_update` AFTER UPDATE ON `cinemas` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'cinemas', NEW.cinema_id,
    CONCAT('cinema_name=', OLD.cinema_name, ', location=', OLD.location),
    CONCAT('cinema_name=', NEW.cinema_name, ', location=', NEW.location));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `customer_id` varchar(10) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `status` enum('Active','Inactive','Suspended') NOT NULL DEFAULT 'Active',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`customer_id`, `first_name`, `last_name`, `email`, `phone_number`, `password`, `status`, `created_at`) VALUES
('CUS002', 'Maria', 'Santos', 'maria@email.com', '09182345678', 'hashed_pw', 'Active', '2026-04-25 11:44:42'),
('CUS003', 'Jose', 'Rizal', 'jose@email.com', '09193456789', 'hashed_pw', 'Active', '2026-04-25 11:44:42'),
('CUS004', 'Ana', 'Reyes', 'ana@email.com', '09204567890', 'hashed_pw', 'Inactive', '2026-04-25 11:44:42'),
('CUS005', 'Carlo', 'Mendoza', 'carlo@email.com', '09215678901', 'hashed_pw', 'Active', '2026-04-25 11:44:42'),
('CUS006', 'Gleih', 'Sayno', 'gleih@gmail.com', '0923345545', '$2y$10$1RpqtHRqHkg7qR6HVbFxROsXqZeMnRGS1IQ32Ow2f5tZ//4foLqxq', 'Active', '2026-04-26 00:57:52'),
('CUS007', 'Eumee', 'Sodusta', 'sodustaeumee@gmail.com', '09946108339', '$2y$10$1zR3z/yRFv1tFgUsf2J/g.VvWo2Vbg9IB6XwJ/i8JmDd/N1wV7DsO', 'Active', '2026-04-27 00:59:37'),
('CUS008', 'Renz', 'Ramos', 'ramos@gmail.com', '09281625349', '$2y$10$Tqk9wxRMRiZCHJ4wdN6pze7ToHX89jq3JVcIJuxwqUD6lUMfhU97S', 'Active', '2026-04-27 01:32:27'),
('CUS009', 'Brad', 'Pitt', 'bradpitt@gmail.com', '09485102987', '$2y$10$aZwy4q1gr5UdC1b712fczuWTCrY.qlpkIpRNtha2RrtGTqp.LOLaC', 'Active', '2026-04-27 02:19:16'),
('CUS010', 'Nadine', 'Lustre', 'nadinelustre@gmail.com', '09347630012', '$2y$10$37tCQfgXkvrf3/B/iSxg3uNGErjR4zTizC0srkWH.ZNHopO.iOV8C', 'Active', '2026-04-27 14:42:00');

--
-- Triggers `customers`
--
DELIMITER $$
CREATE TRIGGER `trg_customers_after_delete` AFTER DELETE ON `customers` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'customers', OLD.customer_id,
    CONCAT('first_name=', OLD.first_name, ', last_name=', OLD.last_name,
           ', email=', OLD.email, ', status=', OLD.status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_customers_after_insert` AFTER INSERT ON `customers` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'customers', NEW.customer_id,
    CONCAT('first_name=', NEW.first_name,
           ', last_name=',  NEW.last_name,
           ', email=',      NEW.email,
           ', phone=',      IFNULL(NEW.phone_number,'NULL'),
           ', status=',     NEW.status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_customers_after_update` AFTER UPDATE ON `customers` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'customers', NEW.customer_id,
    CONCAT('first_name=', OLD.first_name, ', last_name=', OLD.last_name,
           ', email=', OLD.email, ', status=', OLD.status),
    CONCAT('first_name=', NEW.first_name, ', last_name=', NEW.last_name,
           ', email=', NEW.email, ', status=', NEW.status));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `movies`
--

CREATE TABLE `movies` (
  `movie_id` varchar(10) NOT NULL,
  `title` varchar(200) NOT NULL,
  `genre` enum('Action','Adventure','Animation','Comedy','Drama','Horror','Romance','Sci-Fi','Thriller') NOT NULL,
  `duration_minutes` int(10) UNSIGNED NOT NULL,
  `rating` enum('G','PG','PG-13','R','R-18') NOT NULL,
  `release_date` date NOT NULL,
  `description` text DEFAULT NULL,
  `poster_url` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movies`
--

INSERT INTO `movies` (`movie_id`, `title`, `genre`, `duration_minutes`, `rating`, `release_date`, `description`, `poster_url`) VALUES
('MOV001', 'Avengers: Doomsday', 'Action', 150, 'PG-13', '2026-05-01', 'Earth\'s mightiest heroes unite once more.', 'uploads/posters/MOV001.jpg'),
('MOV003', 'A Quiet Place: Day One', 'Horror', 120, 'R', '2026-03-22', 'The origin of silence.', 'uploads/posters/MOV003.jpg'),
('MOV004', 'Deadpool & Wolverine', 'Action', 128, 'R-18', '2026-02-14', 'Two legends. One adventure.', 'uploads/posters/MOV004.jpg'),
('MOV006', 'The Notebook', 'Romance', 120, 'R', '2026-04-27', 'In the 1940s South Carolina, mill worker Noah Calhoun (Ryan Gosling) and rich girl Allie (Rachel McAdams) are desperately in love. But her parents don\'t approve. When Noah goes off to serve in World War II, it seems to mark the end of their love affair. In the interim, Allie becomes involved with another man (James Marsden). But when Noah returns to their small town years later, on the cusp of Allie\'s marriage, it soon becomes clear that their romance is anything but over.', 'uploads/posters/MOV006.jpg'),
('MOV007', 'La La Land', 'Romance', 120, 'PG-13', '2026-04-27', 'Sebastian (Ryan Gosling) and Mia (Emma Stone) are drawn together by their common desire to do what they love. But as success mounts they are faced with decisions that begin to fray the fragile fabric of their love affair, and the dreams they worked so hard to maintain in each other threaten to rip them apart.', 'uploads/posters/MOV007.png'),
('MOV008', 'IT', 'Horror', 120, 'R', '2026-04-27', 'Seven young outcasts in Derry, Maine, are about to face their worst nightmare -- an ancient, shape-shifting evil that emerges from the sewer every 27 years to prey on the town\'s children. Banding together over the course of one horrifying summer, the friends must overcome their own personal fears to battle the murderous, bloodthirsty clown known as Pennywise.', 'uploads/posters/MOV008.jpg'),
('MOV009', 'Ne Zha', 'Animation', 120, 'PG-13', '2026-04-27', 'The Primus extracts a Mixed Yuan Bead into a spirit bead and a demon bead. The spirit bead can be reincarnated in humans to help King Zhou establish a new dynasty, the demon bead will create a devil and harm humans. Ne Zha is the one who should be spirit bead hero, but he becomes a devil incarnate, because the spirit bead and the demon bead are switched.', 'uploads/posters/MOV009.jpg'),
('MOV010', 'White Chicks', 'Comedy', 120, 'PG-13', '2026-04-27', 'Two FBI agent brothers, Marcus (Marlon Wayans) and Kevin Copeland (Shawn Wayans), accidentally foil a drug bust. As punishment, they are forced to escort a pair of socialites (Anne Dudek, Rochelle Aytes) to the Hamptons, where they\'re going to be used as bait for a kidnapper. But when the girls realize the FBI\'s plan, they refuse to go. Left without options, Marcus and Kevin decide to pose as the sisters, transforming themselves from African-American men into a pair of blonde, white women.', 'uploads/posters/MOV010.jpg'),
('MOV011', 'Don\'t Breathe', 'Thriller', 90, 'R', '2026-05-02', 'Rocky (Jane Levy), Alex and Money are three Detroit thieves who get their kicks by breaking into the houses of wealthy people. Money gets word about a blind veteran who won a major cash settlement following the death of his only child. Figuring he\'s an easy target, the trio invades the man\'s secluded home in an abandoned neighborhood. Finding themselves trapped inside, the young intruders must fight for their lives after making a shocking discovery about their supposedly helpless victim.', 'uploads/posters/MOV011.jpg'),
('MOV012', 'Girl, Boy, Bakla, Tomboy', 'Comedy', 90, 'PG', '2026-05-02', 'Quadruplets are split into pairs and raised apart by their parents. They meet as adults by accident and have a tough choice to make when one needs a liver transplant.', 'uploads/posters/MOV012.jpg');

--
-- Triggers `movies`
--
DELIMITER $$
CREATE TRIGGER `trg_movies_after_delete` AFTER DELETE ON `movies` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'movies', OLD.movie_id,
    CONCAT('title=', OLD.title, ', genre=', OLD.genre, ', rating=', OLD.rating));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_movies_after_insert` AFTER INSERT ON `movies` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'movies', NEW.movie_id,
    CONCAT('title=', NEW.title, ', genre=', NEW.genre,
           ', duration=', NEW.duration_minutes, 'min, rating=', NEW.rating,
           ', release_date=', NEW.release_date));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_movies_after_update` AFTER UPDATE ON `movies` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'movies', NEW.movie_id,
    CONCAT('title=', OLD.title, ', genre=', OLD.genre, ', rating=', OLD.rating),
    CONCAT('title=', NEW.title, ', genre=', NEW.genre, ', rating=', NEW.rating));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` varchar(15) NOT NULL,
  `booking_id` varchar(15) NOT NULL,
  `payment_date` date NOT NULL,
  `payment_method` enum('Cash','GCash','Maya','Credit Card','Debit Card') NOT NULL,
  `payment_status` enum('Paid','Pending','Failed','Refunded') NOT NULL DEFAULT 'Pending',
  `amount` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`payment_id`, `booking_id`, `payment_date`, `payment_method`, `payment_status`, `amount`) VALUES
('PAY002', 'BKG002', '2026-05-02', 'GCash', 'Paid', 250.00),
('PAY003', 'BKG003', '2026-05-02', 'Cash', 'Paid', 250.00),
('PAY004', 'BKG004', '2026-05-03', 'Cash', 'Failed', 250.00),
('PAY005', 'BKG007', '2026-05-03', 'Cash', 'Paid', 250.00);

--
-- Triggers `payments`
--
DELIMITER $$
CREATE TRIGGER `trg_payments_after_delete` AFTER DELETE ON `payments` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'payments', OLD.payment_id,
    CONCAT('booking_id=', OLD.booking_id, ', amount=', OLD.amount,
           ', method=', OLD.payment_method, ', status=', OLD.payment_status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_payments_after_insert` AFTER INSERT ON `payments` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'payments', NEW.payment_id,
    CONCAT('booking_id=', NEW.booking_id, ', amount=', NEW.amount,
           ', method=', NEW.payment_method, ', status=', NEW.payment_status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_payments_after_update` AFTER UPDATE ON `payments` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'payments', NEW.payment_id,
    CONCAT('amount=', OLD.amount, ', method=', OLD.payment_method, ', status=', OLD.payment_status),
    CONCAT('amount=', NEW.amount, ', method=', NEW.payment_method, ', status=', NEW.payment_status));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `screens`
--

CREATE TABLE `screens` (
  `screen_id` varchar(10) NOT NULL,
  `cinema_id` varchar(10) NOT NULL,
  `screen_name` varchar(60) NOT NULL,
  `total_seats` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `screens`
--

INSERT INTO `screens` (`screen_id`, `cinema_id`, `screen_name`, `total_seats`) VALUES
('SCR001', 'CIN002', 'Screen 1', 120),
('SCR002', 'CIN003', 'Screen 1', 120),
('SCR003', 'CIN001', 'Screen 1', 150),
('SCR004', 'CIN001', 'Screen 2', 150);

--
-- Triggers `screens`
--
DELIMITER $$
CREATE TRIGGER `trg_screens_after_delete` AFTER DELETE ON `screens` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'screens', OLD.screen_id,
    CONCAT('cinema_id=', OLD.cinema_id,
           ', screen_name=', OLD.screen_name,
           ', total_seats=', OLD.total_seats));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_screens_after_insert` AFTER INSERT ON `screens` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'screens', NEW.screen_id,
    CONCAT('cinema_id=', NEW.cinema_id,
           ', screen_name=', NEW.screen_name,
           ', total_seats=', NEW.total_seats));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_screens_after_update` AFTER UPDATE ON `screens` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'screens', NEW.screen_id,
    CONCAT('cinema_id=', OLD.cinema_id,
           ', screen_name=', OLD.screen_name,
           ', total_seats=', OLD.total_seats),
    CONCAT('cinema_id=', NEW.cinema_id,
           ', screen_name=', NEW.screen_name,
           ', total_seats=', NEW.total_seats));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `seats`
--

CREATE TABLE `seats` (
  `seat_id` varchar(15) NOT NULL,
  `screen_id` varchar(10) NOT NULL,
  `seat_number` varchar(10) NOT NULL,
  `seat_type` enum('Standard') NOT NULL DEFAULT 'Standard',
  `status` enum('Available','Taken','Maintenance') NOT NULL DEFAULT 'Available'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `seats`
--

INSERT INTO `seats` (`seat_id`, `screen_id`, `seat_number`, `seat_type`, `status`) VALUES
('SCR001-001', 'SCR001', 'A01', 'Standard', 'Taken'),
('SCR001-002', 'SCR001', 'A02', 'Standard', 'Available'),
('SCR001-003', 'SCR001', 'A03', 'Standard', 'Available'),
('SCR001-004', 'SCR001', 'A04', 'Standard', 'Available'),
('SCR001-005', 'SCR001', 'A05', 'Standard', 'Available'),
('SCR001-006', 'SCR001', 'A06', 'Standard', 'Available'),
('SCR001-007', 'SCR001', 'A07', 'Standard', 'Available'),
('SCR001-008', 'SCR001', 'A08', 'Standard', 'Available'),
('SCR001-009', 'SCR001', 'A09', 'Standard', 'Available'),
('SCR001-010', 'SCR001', 'A10', 'Standard', 'Available'),
('SCR001-011', 'SCR001', 'B01', 'Standard', 'Available'),
('SCR001-012', 'SCR001', 'B02', 'Standard', 'Available'),
('SCR001-013', 'SCR001', 'B03', 'Standard', 'Available'),
('SCR001-014', 'SCR001', 'B04', 'Standard', 'Available'),
('SCR001-015', 'SCR001', 'B05', 'Standard', 'Available'),
('SCR001-016', 'SCR001', 'B06', 'Standard', 'Available'),
('SCR001-017', 'SCR001', 'B07', 'Standard', 'Available'),
('SCR001-018', 'SCR001', 'B08', 'Standard', 'Available'),
('SCR001-019', 'SCR001', 'B09', 'Standard', 'Available'),
('SCR001-020', 'SCR001', 'B10', 'Standard', 'Available'),
('SCR001-021', 'SCR001', 'C01', 'Standard', 'Available'),
('SCR001-022', 'SCR001', 'C02', 'Standard', 'Available'),
('SCR001-023', 'SCR001', 'C03', 'Standard', 'Available'),
('SCR001-024', 'SCR001', 'C04', 'Standard', 'Available'),
('SCR001-025', 'SCR001', 'C05', 'Standard', 'Available'),
('SCR001-026', 'SCR001', 'C06', 'Standard', 'Available'),
('SCR001-027', 'SCR001', 'C07', 'Standard', 'Available'),
('SCR001-028', 'SCR001', 'C08', 'Standard', 'Available'),
('SCR001-029', 'SCR001', 'C09', 'Standard', 'Available'),
('SCR001-030', 'SCR001', 'C10', 'Standard', 'Available'),
('SCR001-031', 'SCR001', 'D01', 'Standard', 'Available'),
('SCR001-032', 'SCR001', 'D02', 'Standard', 'Available'),
('SCR001-033', 'SCR001', 'D03', 'Standard', 'Available'),
('SCR001-034', 'SCR001', 'D04', 'Standard', 'Available'),
('SCR001-035', 'SCR001', 'D05', 'Standard', 'Available'),
('SCR001-036', 'SCR001', 'D06', 'Standard', 'Available'),
('SCR001-037', 'SCR001', 'D07', 'Standard', 'Available'),
('SCR001-038', 'SCR001', 'D08', 'Standard', 'Available'),
('SCR001-039', 'SCR001', 'D09', 'Standard', 'Available'),
('SCR001-040', 'SCR001', 'D10', 'Standard', 'Available'),
('SCR001-041', 'SCR001', 'E01', 'Standard', 'Available'),
('SCR001-042', 'SCR001', 'E02', 'Standard', 'Available'),
('SCR001-043', 'SCR001', 'E03', 'Standard', 'Available'),
('SCR001-044', 'SCR001', 'E04', 'Standard', 'Available'),
('SCR001-045', 'SCR001', 'E05', 'Standard', 'Available'),
('SCR001-046', 'SCR001', 'E06', 'Standard', 'Available'),
('SCR001-047', 'SCR001', 'E07', 'Standard', 'Available'),
('SCR001-048', 'SCR001', 'E08', 'Standard', 'Available'),
('SCR001-049', 'SCR001', 'E09', 'Standard', 'Available'),
('SCR001-050', 'SCR001', 'E10', 'Standard', 'Available'),
('SCR001-051', 'SCR001', 'F01', 'Standard', 'Available'),
('SCR001-052', 'SCR001', 'F02', 'Standard', 'Available'),
('SCR001-053', 'SCR001', 'F03', 'Standard', 'Available'),
('SCR001-054', 'SCR001', 'F04', 'Standard', 'Available'),
('SCR001-055', 'SCR001', 'F05', 'Standard', 'Available'),
('SCR001-056', 'SCR001', 'F06', 'Standard', 'Available'),
('SCR001-057', 'SCR001', 'F07', 'Standard', 'Available'),
('SCR001-058', 'SCR001', 'F08', 'Standard', 'Available'),
('SCR001-059', 'SCR001', 'F09', 'Standard', 'Available'),
('SCR001-060', 'SCR001', 'F10', 'Standard', 'Available'),
('SCR001-061', 'SCR001', 'G01', 'Standard', 'Available'),
('SCR001-062', 'SCR001', 'G02', 'Standard', 'Available'),
('SCR001-063', 'SCR001', 'G03', 'Standard', 'Available'),
('SCR001-064', 'SCR001', 'G04', 'Standard', 'Available'),
('SCR001-065', 'SCR001', 'G05', 'Standard', 'Available'),
('SCR001-066', 'SCR001', 'G06', 'Standard', 'Available'),
('SCR001-067', 'SCR001', 'G07', 'Standard', 'Available'),
('SCR001-068', 'SCR001', 'G08', 'Standard', 'Available'),
('SCR001-069', 'SCR001', 'G09', 'Standard', 'Available'),
('SCR001-070', 'SCR001', 'G10', 'Standard', 'Available'),
('SCR001-071', 'SCR001', 'H01', 'Standard', 'Available'),
('SCR001-072', 'SCR001', 'H02', 'Standard', 'Available'),
('SCR001-073', 'SCR001', 'H03', 'Standard', 'Available'),
('SCR001-074', 'SCR001', 'H04', 'Standard', 'Available'),
('SCR001-075', 'SCR001', 'H05', 'Standard', 'Available'),
('SCR001-076', 'SCR001', 'H06', 'Standard', 'Available'),
('SCR001-077', 'SCR001', 'H07', 'Standard', 'Available'),
('SCR001-078', 'SCR001', 'H08', 'Standard', 'Available'),
('SCR001-079', 'SCR001', 'H09', 'Standard', 'Available'),
('SCR001-080', 'SCR001', 'H10', 'Standard', 'Available'),
('SCR001-081', 'SCR001', 'I01', 'Standard', 'Available'),
('SCR001-082', 'SCR001', 'I02', 'Standard', 'Available'),
('SCR001-083', 'SCR001', 'I03', 'Standard', 'Available'),
('SCR001-084', 'SCR001', 'I04', 'Standard', 'Available'),
('SCR001-085', 'SCR001', 'I05', 'Standard', 'Available'),
('SCR001-086', 'SCR001', 'I06', 'Standard', 'Available'),
('SCR001-087', 'SCR001', 'I07', 'Standard', 'Available'),
('SCR001-088', 'SCR001', 'I08', 'Standard', 'Available'),
('SCR001-089', 'SCR001', 'I09', 'Standard', 'Available'),
('SCR001-090', 'SCR001', 'I10', 'Standard', 'Available'),
('SCR001-091', 'SCR001', 'J01', 'Standard', 'Available'),
('SCR001-092', 'SCR001', 'J02', 'Standard', 'Available'),
('SCR001-093', 'SCR001', 'J03', 'Standard', 'Available'),
('SCR001-094', 'SCR001', 'J04', 'Standard', 'Available'),
('SCR001-095', 'SCR001', 'J05', 'Standard', 'Available'),
('SCR001-096', 'SCR001', 'J06', 'Standard', 'Available'),
('SCR001-097', 'SCR001', 'J07', 'Standard', 'Available'),
('SCR001-098', 'SCR001', 'J08', 'Standard', 'Available'),
('SCR001-099', 'SCR001', 'J09', 'Standard', 'Available'),
('SCR001-100', 'SCR001', 'J10', 'Standard', 'Available'),
('SCR001-101', 'SCR001', 'K01', 'Standard', 'Available'),
('SCR001-102', 'SCR001', 'K02', 'Standard', 'Available'),
('SCR001-103', 'SCR001', 'K03', 'Standard', 'Available'),
('SCR001-104', 'SCR001', 'K04', 'Standard', 'Available'),
('SCR001-105', 'SCR001', 'K05', 'Standard', 'Available'),
('SCR001-106', 'SCR001', 'K06', 'Standard', 'Available'),
('SCR001-107', 'SCR001', 'K07', 'Standard', 'Available'),
('SCR001-108', 'SCR001', 'K08', 'Standard', 'Available'),
('SCR001-109', 'SCR001', 'K09', 'Standard', 'Available'),
('SCR001-110', 'SCR001', 'K10', 'Standard', 'Available'),
('SCR001-111', 'SCR001', 'L01', 'Standard', 'Available'),
('SCR001-112', 'SCR001', 'L02', 'Standard', 'Available'),
('SCR001-113', 'SCR001', 'L03', 'Standard', 'Available'),
('SCR001-114', 'SCR001', 'L04', 'Standard', 'Available'),
('SCR001-115', 'SCR001', 'L05', 'Standard', 'Available'),
('SCR001-116', 'SCR001', 'L06', 'Standard', 'Available'),
('SCR001-117', 'SCR001', 'L07', 'Standard', 'Available'),
('SCR001-118', 'SCR001', 'L08', 'Standard', 'Available'),
('SCR001-119', 'SCR001', 'L09', 'Standard', 'Available'),
('SCR001-120', 'SCR001', 'L10', 'Standard', 'Available'),
('SCR002-001', 'SCR002', 'A01', 'Standard', 'Available'),
('SCR002-002', 'SCR002', 'A02', 'Standard', 'Available'),
('SCR002-003', 'SCR002', 'A03', 'Standard', 'Available'),
('SCR002-004', 'SCR002', 'A04', 'Standard', 'Available'),
('SCR002-005', 'SCR002', 'A05', 'Standard', 'Available'),
('SCR002-006', 'SCR002', 'A06', 'Standard', 'Available'),
('SCR002-007', 'SCR002', 'A07', 'Standard', 'Available'),
('SCR002-008', 'SCR002', 'A08', 'Standard', 'Available'),
('SCR002-009', 'SCR002', 'A09', 'Standard', 'Available'),
('SCR002-010', 'SCR002', 'A10', 'Standard', 'Available'),
('SCR002-011', 'SCR002', 'B01', 'Standard', 'Available'),
('SCR002-012', 'SCR002', 'B02', 'Standard', 'Available'),
('SCR002-013', 'SCR002', 'B03', 'Standard', 'Available'),
('SCR002-014', 'SCR002', 'B04', 'Standard', 'Available'),
('SCR002-015', 'SCR002', 'B05', 'Standard', 'Available'),
('SCR002-016', 'SCR002', 'B06', 'Standard', 'Available'),
('SCR002-017', 'SCR002', 'B07', 'Standard', 'Available'),
('SCR002-018', 'SCR002', 'B08', 'Standard', 'Available'),
('SCR002-019', 'SCR002', 'B09', 'Standard', 'Available'),
('SCR002-020', 'SCR002', 'B10', 'Standard', 'Available'),
('SCR002-021', 'SCR002', 'C01', 'Standard', 'Available'),
('SCR002-022', 'SCR002', 'C02', 'Standard', 'Available'),
('SCR002-023', 'SCR002', 'C03', 'Standard', 'Available'),
('SCR002-024', 'SCR002', 'C04', 'Standard', 'Available'),
('SCR002-025', 'SCR002', 'C05', 'Standard', 'Available'),
('SCR002-026', 'SCR002', 'C06', 'Standard', 'Available'),
('SCR002-027', 'SCR002', 'C07', 'Standard', 'Available'),
('SCR002-028', 'SCR002', 'C08', 'Standard', 'Available'),
('SCR002-029', 'SCR002', 'C09', 'Standard', 'Available'),
('SCR002-030', 'SCR002', 'C10', 'Standard', 'Available'),
('SCR002-031', 'SCR002', 'D01', 'Standard', 'Available'),
('SCR002-032', 'SCR002', 'D02', 'Standard', 'Available'),
('SCR002-033', 'SCR002', 'D03', 'Standard', 'Available'),
('SCR002-034', 'SCR002', 'D04', 'Standard', 'Available'),
('SCR002-035', 'SCR002', 'D05', 'Standard', 'Available'),
('SCR002-036', 'SCR002', 'D06', 'Standard', 'Available'),
('SCR002-037', 'SCR002', 'D07', 'Standard', 'Available'),
('SCR002-038', 'SCR002', 'D08', 'Standard', 'Available'),
('SCR002-039', 'SCR002', 'D09', 'Standard', 'Available'),
('SCR002-040', 'SCR002', 'D10', 'Standard', 'Available'),
('SCR002-041', 'SCR002', 'E01', 'Standard', 'Available'),
('SCR002-042', 'SCR002', 'E02', 'Standard', 'Available'),
('SCR002-043', 'SCR002', 'E03', 'Standard', 'Available'),
('SCR002-044', 'SCR002', 'E04', 'Standard', 'Available'),
('SCR002-045', 'SCR002', 'E05', 'Standard', 'Available'),
('SCR002-046', 'SCR002', 'E06', 'Standard', 'Available'),
('SCR002-047', 'SCR002', 'E07', 'Standard', 'Available'),
('SCR002-048', 'SCR002', 'E08', 'Standard', 'Available'),
('SCR002-049', 'SCR002', 'E09', 'Standard', 'Available'),
('SCR002-050', 'SCR002', 'E10', 'Standard', 'Available'),
('SCR002-051', 'SCR002', 'F01', 'Standard', 'Available'),
('SCR002-052', 'SCR002', 'F02', 'Standard', 'Available'),
('SCR002-053', 'SCR002', 'F03', 'Standard', 'Available'),
('SCR002-054', 'SCR002', 'F04', 'Standard', 'Available'),
('SCR002-055', 'SCR002', 'F05', 'Standard', 'Available'),
('SCR002-056', 'SCR002', 'F06', 'Standard', 'Available'),
('SCR002-057', 'SCR002', 'F07', 'Standard', 'Available'),
('SCR002-058', 'SCR002', 'F08', 'Standard', 'Available'),
('SCR002-059', 'SCR002', 'F09', 'Standard', 'Available'),
('SCR002-060', 'SCR002', 'F10', 'Standard', 'Available'),
('SCR002-061', 'SCR002', 'G01', 'Standard', 'Available'),
('SCR002-062', 'SCR002', 'G02', 'Standard', 'Available'),
('SCR002-063', 'SCR002', 'G03', 'Standard', 'Available'),
('SCR002-064', 'SCR002', 'G04', 'Standard', 'Available'),
('SCR002-065', 'SCR002', 'G05', 'Standard', 'Available'),
('SCR002-066', 'SCR002', 'G06', 'Standard', 'Available'),
('SCR002-067', 'SCR002', 'G07', 'Standard', 'Available'),
('SCR002-068', 'SCR002', 'G08', 'Standard', 'Available'),
('SCR002-069', 'SCR002', 'G09', 'Standard', 'Available'),
('SCR002-070', 'SCR002', 'G10', 'Standard', 'Available'),
('SCR002-071', 'SCR002', 'H01', 'Standard', 'Available'),
('SCR002-072', 'SCR002', 'H02', 'Standard', 'Available'),
('SCR002-073', 'SCR002', 'H03', 'Standard', 'Available'),
('SCR002-074', 'SCR002', 'H04', 'Standard', 'Available'),
('SCR002-075', 'SCR002', 'H05', 'Standard', 'Available'),
('SCR002-076', 'SCR002', 'H06', 'Standard', 'Available'),
('SCR002-077', 'SCR002', 'H07', 'Standard', 'Available'),
('SCR002-078', 'SCR002', 'H08', 'Standard', 'Available'),
('SCR002-079', 'SCR002', 'H09', 'Standard', 'Available'),
('SCR002-080', 'SCR002', 'H10', 'Standard', 'Available'),
('SCR002-081', 'SCR002', 'I01', 'Standard', 'Available'),
('SCR002-082', 'SCR002', 'I02', 'Standard', 'Available'),
('SCR002-083', 'SCR002', 'I03', 'Standard', 'Available'),
('SCR002-084', 'SCR002', 'I04', 'Standard', 'Available'),
('SCR002-085', 'SCR002', 'I05', 'Standard', 'Available'),
('SCR002-086', 'SCR002', 'I06', 'Standard', 'Available'),
('SCR002-087', 'SCR002', 'I07', 'Standard', 'Available'),
('SCR002-088', 'SCR002', 'I08', 'Standard', 'Available'),
('SCR002-089', 'SCR002', 'I09', 'Standard', 'Available'),
('SCR002-090', 'SCR002', 'I10', 'Standard', 'Available'),
('SCR002-091', 'SCR002', 'J01', 'Standard', 'Available'),
('SCR002-092', 'SCR002', 'J02', 'Standard', 'Available'),
('SCR002-093', 'SCR002', 'J03', 'Standard', 'Available'),
('SCR002-094', 'SCR002', 'J04', 'Standard', 'Available'),
('SCR002-095', 'SCR002', 'J05', 'Standard', 'Available'),
('SCR002-096', 'SCR002', 'J06', 'Standard', 'Available'),
('SCR002-097', 'SCR002', 'J07', 'Standard', 'Available'),
('SCR002-098', 'SCR002', 'J08', 'Standard', 'Available'),
('SCR002-099', 'SCR002', 'J09', 'Standard', 'Available'),
('SCR002-100', 'SCR002', 'J10', 'Standard', 'Available'),
('SCR002-101', 'SCR002', 'K01', 'Standard', 'Available'),
('SCR002-102', 'SCR002', 'K02', 'Standard', 'Available'),
('SCR002-103', 'SCR002', 'K03', 'Standard', 'Available'),
('SCR002-104', 'SCR002', 'K04', 'Standard', 'Available'),
('SCR002-105', 'SCR002', 'K05', 'Standard', 'Available'),
('SCR002-106', 'SCR002', 'K06', 'Standard', 'Available'),
('SCR002-107', 'SCR002', 'K07', 'Standard', 'Available'),
('SCR002-108', 'SCR002', 'K08', 'Standard', 'Available'),
('SCR002-109', 'SCR002', 'K09', 'Standard', 'Available'),
('SCR002-110', 'SCR002', 'K10', 'Standard', 'Available'),
('SCR002-111', 'SCR002', 'L01', 'Standard', 'Available'),
('SCR002-112', 'SCR002', 'L02', 'Standard', 'Available'),
('SCR002-113', 'SCR002', 'L03', 'Standard', 'Available'),
('SCR002-114', 'SCR002', 'L04', 'Standard', 'Available'),
('SCR002-115', 'SCR002', 'L05', 'Standard', 'Available'),
('SCR002-116', 'SCR002', 'L06', 'Standard', 'Available'),
('SCR002-117', 'SCR002', 'L07', 'Standard', 'Available'),
('SCR002-118', 'SCR002', 'L08', 'Standard', 'Available'),
('SCR002-119', 'SCR002', 'L09', 'Standard', 'Available'),
('SCR002-120', 'SCR002', 'L10', 'Standard', 'Available'),
('SCR003-001', 'SCR003', 'A01', 'Standard', 'Available'),
('SCR003-002', 'SCR003', 'A02', 'Standard', 'Available'),
('SCR003-003', 'SCR003', 'A03', 'Standard', 'Available'),
('SCR003-004', 'SCR003', 'A04', 'Standard', 'Available'),
('SCR003-005', 'SCR003', 'A05', 'Standard', 'Available'),
('SCR003-006', 'SCR003', 'A06', 'Standard', 'Available'),
('SCR003-007', 'SCR003', 'A07', 'Standard', 'Available'),
('SCR003-008', 'SCR003', 'A08', 'Standard', 'Available'),
('SCR003-009', 'SCR003', 'A09', 'Standard', 'Available'),
('SCR003-010', 'SCR003', 'A10', 'Standard', 'Available'),
('SCR003-011', 'SCR003', 'B01', 'Standard', 'Available'),
('SCR003-012', 'SCR003', 'B02', 'Standard', 'Available'),
('SCR003-013', 'SCR003', 'B03', 'Standard', 'Available'),
('SCR003-014', 'SCR003', 'B04', 'Standard', 'Available'),
('SCR003-015', 'SCR003', 'B05', 'Standard', 'Available'),
('SCR003-016', 'SCR003', 'B06', 'Standard', 'Available'),
('SCR003-017', 'SCR003', 'B07', 'Standard', 'Available'),
('SCR003-018', 'SCR003', 'B08', 'Standard', 'Available'),
('SCR003-019', 'SCR003', 'B09', 'Standard', 'Available'),
('SCR003-020', 'SCR003', 'B10', 'Standard', 'Available'),
('SCR003-021', 'SCR003', 'C01', 'Standard', 'Available'),
('SCR003-022', 'SCR003', 'C02', 'Standard', 'Available'),
('SCR003-023', 'SCR003', 'C03', 'Standard', 'Available'),
('SCR003-024', 'SCR003', 'C04', 'Standard', 'Available'),
('SCR003-025', 'SCR003', 'C05', 'Standard', 'Available'),
('SCR003-026', 'SCR003', 'C06', 'Standard', 'Available'),
('SCR003-027', 'SCR003', 'C07', 'Standard', 'Available'),
('SCR003-028', 'SCR003', 'C08', 'Standard', 'Available'),
('SCR003-029', 'SCR003', 'C09', 'Standard', 'Available'),
('SCR003-030', 'SCR003', 'C10', 'Standard', 'Available'),
('SCR003-031', 'SCR003', 'D01', 'Standard', 'Available'),
('SCR003-032', 'SCR003', 'D02', 'Standard', 'Available'),
('SCR003-033', 'SCR003', 'D03', 'Standard', 'Available'),
('SCR003-034', 'SCR003', 'D04', 'Standard', 'Available'),
('SCR003-035', 'SCR003', 'D05', 'Standard', 'Available'),
('SCR003-036', 'SCR003', 'D06', 'Standard', 'Available'),
('SCR003-037', 'SCR003', 'D07', 'Standard', 'Available'),
('SCR003-038', 'SCR003', 'D08', 'Standard', 'Available'),
('SCR003-039', 'SCR003', 'D09', 'Standard', 'Available'),
('SCR003-040', 'SCR003', 'D10', 'Standard', 'Available'),
('SCR003-041', 'SCR003', 'E01', 'Standard', 'Available'),
('SCR003-042', 'SCR003', 'E02', 'Standard', 'Available'),
('SCR003-043', 'SCR003', 'E03', 'Standard', 'Available'),
('SCR003-044', 'SCR003', 'E04', 'Standard', 'Available'),
('SCR003-045', 'SCR003', 'E05', 'Standard', 'Available'),
('SCR003-046', 'SCR003', 'E06', 'Standard', 'Available'),
('SCR003-047', 'SCR003', 'E07', 'Standard', 'Available'),
('SCR003-048', 'SCR003', 'E08', 'Standard', 'Available'),
('SCR003-049', 'SCR003', 'E09', 'Standard', 'Available'),
('SCR003-050', 'SCR003', 'E10', 'Standard', 'Available'),
('SCR003-051', 'SCR003', 'F01', 'Standard', 'Available'),
('SCR003-052', 'SCR003', 'F02', 'Standard', 'Available'),
('SCR003-053', 'SCR003', 'F03', 'Standard', 'Available'),
('SCR003-054', 'SCR003', 'F04', 'Standard', 'Available'),
('SCR003-055', 'SCR003', 'F05', 'Standard', 'Available'),
('SCR003-056', 'SCR003', 'F06', 'Standard', 'Available'),
('SCR003-057', 'SCR003', 'F07', 'Standard', 'Available'),
('SCR003-058', 'SCR003', 'F08', 'Standard', 'Available'),
('SCR003-059', 'SCR003', 'F09', 'Standard', 'Available'),
('SCR003-060', 'SCR003', 'F10', 'Standard', 'Available'),
('SCR003-061', 'SCR003', 'G01', 'Standard', 'Available'),
('SCR003-062', 'SCR003', 'G02', 'Standard', 'Available'),
('SCR003-063', 'SCR003', 'G03', 'Standard', 'Available'),
('SCR003-064', 'SCR003', 'G04', 'Standard', 'Available'),
('SCR003-065', 'SCR003', 'G05', 'Standard', 'Available'),
('SCR003-066', 'SCR003', 'G06', 'Standard', 'Available'),
('SCR003-067', 'SCR003', 'G07', 'Standard', 'Available'),
('SCR003-068', 'SCR003', 'G08', 'Standard', 'Available'),
('SCR003-069', 'SCR003', 'G09', 'Standard', 'Available'),
('SCR003-070', 'SCR003', 'G10', 'Standard', 'Available'),
('SCR003-071', 'SCR003', 'H01', 'Standard', 'Available'),
('SCR003-072', 'SCR003', 'H02', 'Standard', 'Available'),
('SCR003-073', 'SCR003', 'H03', 'Standard', 'Available'),
('SCR003-074', 'SCR003', 'H04', 'Standard', 'Available'),
('SCR003-075', 'SCR003', 'H05', 'Standard', 'Available'),
('SCR003-076', 'SCR003', 'H06', 'Standard', 'Available'),
('SCR003-077', 'SCR003', 'H07', 'Standard', 'Available'),
('SCR003-078', 'SCR003', 'H08', 'Standard', 'Available'),
('SCR003-079', 'SCR003', 'H09', 'Standard', 'Available'),
('SCR003-080', 'SCR003', 'H10', 'Standard', 'Available'),
('SCR003-081', 'SCR003', 'I01', 'Standard', 'Available'),
('SCR003-082', 'SCR003', 'I02', 'Standard', 'Available'),
('SCR003-083', 'SCR003', 'I03', 'Standard', 'Available'),
('SCR003-084', 'SCR003', 'I04', 'Standard', 'Available'),
('SCR003-085', 'SCR003', 'I05', 'Standard', 'Available'),
('SCR003-086', 'SCR003', 'I06', 'Standard', 'Available'),
('SCR003-087', 'SCR003', 'I07', 'Standard', 'Available'),
('SCR003-088', 'SCR003', 'I08', 'Standard', 'Available'),
('SCR003-089', 'SCR003', 'I09', 'Standard', 'Available'),
('SCR003-090', 'SCR003', 'I10', 'Standard', 'Available'),
('SCR003-091', 'SCR003', 'J01', 'Standard', 'Available'),
('SCR003-092', 'SCR003', 'J02', 'Standard', 'Available'),
('SCR003-093', 'SCR003', 'J03', 'Standard', 'Available'),
('SCR003-094', 'SCR003', 'J04', 'Standard', 'Available'),
('SCR003-095', 'SCR003', 'J05', 'Standard', 'Available'),
('SCR003-096', 'SCR003', 'J06', 'Standard', 'Available'),
('SCR003-097', 'SCR003', 'J07', 'Standard', 'Available'),
('SCR003-098', 'SCR003', 'J08', 'Standard', 'Available'),
('SCR003-099', 'SCR003', 'J09', 'Standard', 'Available'),
('SCR003-100', 'SCR003', 'J10', 'Standard', 'Available'),
('SCR003-101', 'SCR003', 'K01', 'Standard', 'Available'),
('SCR003-102', 'SCR003', 'K02', 'Standard', 'Available'),
('SCR003-103', 'SCR003', 'K03', 'Standard', 'Available'),
('SCR003-104', 'SCR003', 'K04', 'Standard', 'Available'),
('SCR003-105', 'SCR003', 'K05', 'Standard', 'Available'),
('SCR003-106', 'SCR003', 'K06', 'Standard', 'Available'),
('SCR003-107', 'SCR003', 'K07', 'Standard', 'Available'),
('SCR003-108', 'SCR003', 'K08', 'Standard', 'Available'),
('SCR003-109', 'SCR003', 'K09', 'Standard', 'Available'),
('SCR003-110', 'SCR003', 'K10', 'Standard', 'Available'),
('SCR003-111', 'SCR003', 'L01', 'Standard', 'Available'),
('SCR003-112', 'SCR003', 'L02', 'Standard', 'Available'),
('SCR003-113', 'SCR003', 'L03', 'Standard', 'Available'),
('SCR003-114', 'SCR003', 'L04', 'Standard', 'Available'),
('SCR003-115', 'SCR003', 'L05', 'Standard', 'Available'),
('SCR003-116', 'SCR003', 'L06', 'Standard', 'Available'),
('SCR003-117', 'SCR003', 'L07', 'Standard', 'Available'),
('SCR003-118', 'SCR003', 'L08', 'Standard', 'Available'),
('SCR003-119', 'SCR003', 'L09', 'Standard', 'Available'),
('SCR003-120', 'SCR003', 'L10', 'Standard', 'Available'),
('SCR003-121', 'SCR003', 'M01', 'Standard', 'Available'),
('SCR003-122', 'SCR003', 'M02', 'Standard', 'Available'),
('SCR003-123', 'SCR003', 'M03', 'Standard', 'Available'),
('SCR003-124', 'SCR003', 'M04', 'Standard', 'Available'),
('SCR003-125', 'SCR003', 'M05', 'Standard', 'Available'),
('SCR003-126', 'SCR003', 'M06', 'Standard', 'Available'),
('SCR003-127', 'SCR003', 'M07', 'Standard', 'Available'),
('SCR003-128', 'SCR003', 'M08', 'Standard', 'Available'),
('SCR003-129', 'SCR003', 'M09', 'Standard', 'Available'),
('SCR003-130', 'SCR003', 'M10', 'Standard', 'Available'),
('SCR003-131', 'SCR003', 'N01', 'Standard', 'Available'),
('SCR003-132', 'SCR003', 'N02', 'Standard', 'Available'),
('SCR003-133', 'SCR003', 'N03', 'Standard', 'Available'),
('SCR003-134', 'SCR003', 'N04', 'Standard', 'Available'),
('SCR003-135', 'SCR003', 'N05', 'Standard', 'Available'),
('SCR003-136', 'SCR003', 'N06', 'Standard', 'Available'),
('SCR003-137', 'SCR003', 'N07', 'Standard', 'Available'),
('SCR003-138', 'SCR003', 'N08', 'Standard', 'Available'),
('SCR003-139', 'SCR003', 'N09', 'Standard', 'Available'),
('SCR003-140', 'SCR003', 'N10', 'Standard', 'Available'),
('SCR003-141', 'SCR003', 'O01', 'Standard', 'Available'),
('SCR003-142', 'SCR003', 'O02', 'Standard', 'Available'),
('SCR003-143', 'SCR003', 'O03', 'Standard', 'Available'),
('SCR003-144', 'SCR003', 'O04', 'Standard', 'Available'),
('SCR003-145', 'SCR003', 'O05', 'Standard', 'Available'),
('SCR003-146', 'SCR003', 'O06', 'Standard', 'Available'),
('SCR003-147', 'SCR003', 'O07', 'Standard', 'Available'),
('SCR003-148', 'SCR003', 'O08', 'Standard', 'Available'),
('SCR003-149', 'SCR003', 'O09', 'Standard', 'Available'),
('SCR003-150', 'SCR003', 'O10', 'Standard', 'Available'),
('SCR004-001', 'SCR004', 'A01', 'Standard', 'Available'),
('SCR004-002', 'SCR004', 'A02', 'Standard', 'Available'),
('SCR004-003', 'SCR004', 'A03', 'Standard', 'Available'),
('SCR004-004', 'SCR004', 'A04', 'Standard', 'Available'),
('SCR004-005', 'SCR004', 'A05', 'Standard', 'Available'),
('SCR004-006', 'SCR004', 'A06', 'Standard', 'Available'),
('SCR004-007', 'SCR004', 'A07', 'Standard', 'Available'),
('SCR004-008', 'SCR004', 'A08', 'Standard', 'Available'),
('SCR004-009', 'SCR004', 'A09', 'Standard', 'Available'),
('SCR004-010', 'SCR004', 'A10', 'Standard', 'Available'),
('SCR004-011', 'SCR004', 'B01', 'Standard', 'Available'),
('SCR004-012', 'SCR004', 'B02', 'Standard', 'Available'),
('SCR004-013', 'SCR004', 'B03', 'Standard', 'Available'),
('SCR004-014', 'SCR004', 'B04', 'Standard', 'Available'),
('SCR004-015', 'SCR004', 'B05', 'Standard', 'Available'),
('SCR004-016', 'SCR004', 'B06', 'Standard', 'Available'),
('SCR004-017', 'SCR004', 'B07', 'Standard', 'Available'),
('SCR004-018', 'SCR004', 'B08', 'Standard', 'Available'),
('SCR004-019', 'SCR004', 'B09', 'Standard', 'Available'),
('SCR004-020', 'SCR004', 'B10', 'Standard', 'Available'),
('SCR004-021', 'SCR004', 'C01', 'Standard', 'Available'),
('SCR004-022', 'SCR004', 'C02', 'Standard', 'Available'),
('SCR004-023', 'SCR004', 'C03', 'Standard', 'Available'),
('SCR004-024', 'SCR004', 'C04', 'Standard', 'Available'),
('SCR004-025', 'SCR004', 'C05', 'Standard', 'Available'),
('SCR004-026', 'SCR004', 'C06', 'Standard', 'Available'),
('SCR004-027', 'SCR004', 'C07', 'Standard', 'Available'),
('SCR004-028', 'SCR004', 'C08', 'Standard', 'Available'),
('SCR004-029', 'SCR004', 'C09', 'Standard', 'Available'),
('SCR004-030', 'SCR004', 'C10', 'Standard', 'Available'),
('SCR004-031', 'SCR004', 'D01', 'Standard', 'Available'),
('SCR004-032', 'SCR004', 'D02', 'Standard', 'Available'),
('SCR004-033', 'SCR004', 'D03', 'Standard', 'Available'),
('SCR004-034', 'SCR004', 'D04', 'Standard', 'Available'),
('SCR004-035', 'SCR004', 'D05', 'Standard', 'Available'),
('SCR004-036', 'SCR004', 'D06', 'Standard', 'Available'),
('SCR004-037', 'SCR004', 'D07', 'Standard', 'Available'),
('SCR004-038', 'SCR004', 'D08', 'Standard', 'Available'),
('SCR004-039', 'SCR004', 'D09', 'Standard', 'Available'),
('SCR004-040', 'SCR004', 'D10', 'Standard', 'Available'),
('SCR004-041', 'SCR004', 'E01', 'Standard', 'Available'),
('SCR004-042', 'SCR004', 'E02', 'Standard', 'Available'),
('SCR004-043', 'SCR004', 'E03', 'Standard', 'Available'),
('SCR004-044', 'SCR004', 'E04', 'Standard', 'Available'),
('SCR004-045', 'SCR004', 'E05', 'Standard', 'Available'),
('SCR004-046', 'SCR004', 'E06', 'Standard', 'Available'),
('SCR004-047', 'SCR004', 'E07', 'Standard', 'Available'),
('SCR004-048', 'SCR004', 'E08', 'Standard', 'Available'),
('SCR004-049', 'SCR004', 'E09', 'Standard', 'Available'),
('SCR004-050', 'SCR004', 'E10', 'Standard', 'Available'),
('SCR004-051', 'SCR004', 'F01', 'Standard', 'Available'),
('SCR004-052', 'SCR004', 'F02', 'Standard', 'Available'),
('SCR004-053', 'SCR004', 'F03', 'Standard', 'Available'),
('SCR004-054', 'SCR004', 'F04', 'Standard', 'Available'),
('SCR004-055', 'SCR004', 'F05', 'Standard', 'Available'),
('SCR004-056', 'SCR004', 'F06', 'Standard', 'Available'),
('SCR004-057', 'SCR004', 'F07', 'Standard', 'Available'),
('SCR004-058', 'SCR004', 'F08', 'Standard', 'Available'),
('SCR004-059', 'SCR004', 'F09', 'Standard', 'Available'),
('SCR004-060', 'SCR004', 'F10', 'Standard', 'Available'),
('SCR004-061', 'SCR004', 'G01', 'Standard', 'Available'),
('SCR004-062', 'SCR004', 'G02', 'Standard', 'Available'),
('SCR004-063', 'SCR004', 'G03', 'Standard', 'Available'),
('SCR004-064', 'SCR004', 'G04', 'Standard', 'Available'),
('SCR004-065', 'SCR004', 'G05', 'Standard', 'Available'),
('SCR004-066', 'SCR004', 'G06', 'Standard', 'Available'),
('SCR004-067', 'SCR004', 'G07', 'Standard', 'Available'),
('SCR004-068', 'SCR004', 'G08', 'Standard', 'Available'),
('SCR004-069', 'SCR004', 'G09', 'Standard', 'Available'),
('SCR004-070', 'SCR004', 'G10', 'Standard', 'Available'),
('SCR004-071', 'SCR004', 'H01', 'Standard', 'Available'),
('SCR004-072', 'SCR004', 'H02', 'Standard', 'Available'),
('SCR004-073', 'SCR004', 'H03', 'Standard', 'Available'),
('SCR004-074', 'SCR004', 'H04', 'Standard', 'Available'),
('SCR004-075', 'SCR004', 'H05', 'Standard', 'Available'),
('SCR004-076', 'SCR004', 'H06', 'Standard', 'Available'),
('SCR004-077', 'SCR004', 'H07', 'Standard', 'Available'),
('SCR004-078', 'SCR004', 'H08', 'Standard', 'Available'),
('SCR004-079', 'SCR004', 'H09', 'Standard', 'Available'),
('SCR004-080', 'SCR004', 'H10', 'Standard', 'Available'),
('SCR004-081', 'SCR004', 'I01', 'Standard', 'Available'),
('SCR004-082', 'SCR004', 'I02', 'Standard', 'Available'),
('SCR004-083', 'SCR004', 'I03', 'Standard', 'Available'),
('SCR004-084', 'SCR004', 'I04', 'Standard', 'Available'),
('SCR004-085', 'SCR004', 'I05', 'Standard', 'Available'),
('SCR004-086', 'SCR004', 'I06', 'Standard', 'Available'),
('SCR004-087', 'SCR004', 'I07', 'Standard', 'Available'),
('SCR004-088', 'SCR004', 'I08', 'Standard', 'Available'),
('SCR004-089', 'SCR004', 'I09', 'Standard', 'Available'),
('SCR004-090', 'SCR004', 'I10', 'Standard', 'Available'),
('SCR004-091', 'SCR004', 'J01', 'Standard', 'Available'),
('SCR004-092', 'SCR004', 'J02', 'Standard', 'Available'),
('SCR004-093', 'SCR004', 'J03', 'Standard', 'Available'),
('SCR004-094', 'SCR004', 'J04', 'Standard', 'Available'),
('SCR004-095', 'SCR004', 'J05', 'Standard', 'Available'),
('SCR004-096', 'SCR004', 'J06', 'Standard', 'Available'),
('SCR004-097', 'SCR004', 'J07', 'Standard', 'Available'),
('SCR004-098', 'SCR004', 'J08', 'Standard', 'Available'),
('SCR004-099', 'SCR004', 'J09', 'Standard', 'Available'),
('SCR004-100', 'SCR004', 'J10', 'Standard', 'Available'),
('SCR004-101', 'SCR004', 'K01', 'Standard', 'Available'),
('SCR004-102', 'SCR004', 'K02', 'Standard', 'Available'),
('SCR004-103', 'SCR004', 'K03', 'Standard', 'Available'),
('SCR004-104', 'SCR004', 'K04', 'Standard', 'Available'),
('SCR004-105', 'SCR004', 'K05', 'Standard', 'Available'),
('SCR004-106', 'SCR004', 'K06', 'Standard', 'Available'),
('SCR004-107', 'SCR004', 'K07', 'Standard', 'Available'),
('SCR004-108', 'SCR004', 'K08', 'Standard', 'Available'),
('SCR004-109', 'SCR004', 'K09', 'Standard', 'Available'),
('SCR004-110', 'SCR004', 'K10', 'Standard', 'Available'),
('SCR004-111', 'SCR004', 'L01', 'Standard', 'Available'),
('SCR004-112', 'SCR004', 'L02', 'Standard', 'Available'),
('SCR004-113', 'SCR004', 'L03', 'Standard', 'Available'),
('SCR004-114', 'SCR004', 'L04', 'Standard', 'Available'),
('SCR004-115', 'SCR004', 'L05', 'Standard', 'Available'),
('SCR004-116', 'SCR004', 'L06', 'Standard', 'Available'),
('SCR004-117', 'SCR004', 'L07', 'Standard', 'Available'),
('SCR004-118', 'SCR004', 'L08', 'Standard', 'Available'),
('SCR004-119', 'SCR004', 'L09', 'Standard', 'Available'),
('SCR004-120', 'SCR004', 'L10', 'Standard', 'Available'),
('SCR004-121', 'SCR004', 'M01', 'Standard', 'Available'),
('SCR004-122', 'SCR004', 'M02', 'Standard', 'Available'),
('SCR004-123', 'SCR004', 'M03', 'Standard', 'Available'),
('SCR004-124', 'SCR004', 'M04', 'Standard', 'Available'),
('SCR004-125', 'SCR004', 'M05', 'Standard', 'Available'),
('SCR004-126', 'SCR004', 'M06', 'Standard', 'Available'),
('SCR004-127', 'SCR004', 'M07', 'Standard', 'Available'),
('SCR004-128', 'SCR004', 'M08', 'Standard', 'Available'),
('SCR004-129', 'SCR004', 'M09', 'Standard', 'Available'),
('SCR004-130', 'SCR004', 'M10', 'Standard', 'Available'),
('SCR004-131', 'SCR004', 'N01', 'Standard', 'Available'),
('SCR004-132', 'SCR004', 'N02', 'Standard', 'Available'),
('SCR004-133', 'SCR004', 'N03', 'Standard', 'Available'),
('SCR004-134', 'SCR004', 'N04', 'Standard', 'Available'),
('SCR004-135', 'SCR004', 'N05', 'Standard', 'Available'),
('SCR004-136', 'SCR004', 'N06', 'Standard', 'Available'),
('SCR004-137', 'SCR004', 'N07', 'Standard', 'Available'),
('SCR004-138', 'SCR004', 'N08', 'Standard', 'Available'),
('SCR004-139', 'SCR004', 'N09', 'Standard', 'Available'),
('SCR004-140', 'SCR004', 'N10', 'Standard', 'Available'),
('SCR004-141', 'SCR004', 'O01', 'Standard', 'Available'),
('SCR004-142', 'SCR004', 'O02', 'Standard', 'Available'),
('SCR004-143', 'SCR004', 'O03', 'Standard', 'Available'),
('SCR004-144', 'SCR004', 'O04', 'Standard', 'Available'),
('SCR004-145', 'SCR004', 'O05', 'Standard', 'Available'),
('SCR004-146', 'SCR004', 'O06', 'Standard', 'Available'),
('SCR004-147', 'SCR004', 'O07', 'Standard', 'Available'),
('SCR004-148', 'SCR004', 'O08', 'Standard', 'Available'),
('SCR004-149', 'SCR004', 'O09', 'Standard', 'Available'),
('SCR004-150', 'SCR004', 'O10', 'Standard', 'Available');

--
-- Triggers `seats`
--
DELIMITER $$
CREATE TRIGGER `trg_seats_after_delete` AFTER DELETE ON `seats` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'seats', OLD.seat_id,
    CONCAT('screen_id=', OLD.screen_id,
           ', seat_number=', OLD.seat_number,
           ', status=',      OLD.status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_seats_after_insert` AFTER INSERT ON `seats` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'seats', NEW.seat_id,
    CONCAT('screen_id=', NEW.screen_id,
           ', seat_number=', NEW.seat_number,
           ', seat_type=',   NEW.seat_type,
           ', status=',      NEW.status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_seats_after_update` AFTER UPDATE ON `seats` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'seats', NEW.seat_id,
    CONCAT('screen_id=', OLD.screen_id,
           ', seat_number=', OLD.seat_number,
           ', status=',      OLD.status),
    CONCAT('screen_id=', NEW.screen_id,
           ', seat_number=', NEW.seat_number,
           ', status=',      NEW.status));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `showtimes`
--

CREATE TABLE `showtimes` (
  `showtime_id` varchar(10) NOT NULL,
  `movie_id` varchar(10) NOT NULL,
  `screen_id` varchar(10) NOT NULL,
  `show_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `showtimes`
--

INSERT INTO `showtimes` (`showtime_id`, `movie_id`, `screen_id`, `show_date`, `start_time`, `end_time`, `price`) VALUES
('SHW001', 'MOV008', 'SCR003', '2026-05-02', '10:00:00', '12:00:00', 250.00),
('SHW002', 'MOV012', 'SCR004', '2026-05-02', '10:00:00', '12:00:00', 250.00),
('SHW003', 'MOV004', 'SCR001', '2026-05-03', '06:00:00', '18:15:00', 250.00);

--
-- Triggers `showtimes`
--
DELIMITER $$
CREATE TRIGGER `trg_showtimes_after_delete` AFTER DELETE ON `showtimes` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'showtimes', OLD.showtime_id,
    CONCAT('movie_id=', OLD.movie_id,
           ', screen_id=', OLD.screen_id,
           ', show_date=', OLD.show_date,
           ', start_time=', OLD.start_time,
           ', end_time=', OLD.end_time,
           ', price=', OLD.price));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_showtimes_after_insert` AFTER INSERT ON `showtimes` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'showtimes', NEW.showtime_id,
    CONCAT('movie_id=', NEW.movie_id,
           ', screen_id=', NEW.screen_id,
           ', show_date=', NEW.show_date,
           ', start_time=', NEW.start_time,
           ', end_time=', NEW.end_time,
           ', price=', NEW.price));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_showtimes_after_update` AFTER UPDATE ON `showtimes` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'showtimes', NEW.showtime_id,
    CONCAT('movie_id=', OLD.movie_id,
           ', screen_id=', OLD.screen_id,
           ', show_date=', OLD.show_date,
           ', start_time=', OLD.start_time,
           ', end_time=', OLD.end_time,
           ', price=', OLD.price),
    CONCAT('movie_id=', NEW.movie_id,
           ', screen_id=', NEW.screen_id,
           ', show_date=', NEW.show_date,
           ', start_time=', NEW.start_time,
           ', end_time=', NEW.end_time,
           ', price=', NEW.price));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `ticket_id` varchar(15) NOT NULL,
  `booking_id` varchar(15) NOT NULL,
  `seat_id` varchar(15) NOT NULL,
  `ticket_price` decimal(10,2) NOT NULL,
  `issued_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tickets`
--

INSERT INTO `tickets` (`ticket_id`, `booking_id`, `seat_id`, `ticket_price`, `issued_at`) VALUES
('TKT0001', 'BKG007', 'SCR001-001', 250.00, '2026-05-03 16:11:23');

--
-- Triggers `tickets`
--
DELIMITER $$
CREATE TRIGGER `trg_tickets_after_delete` AFTER DELETE ON `tickets` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'tickets', OLD.ticket_id,
    CONCAT('booking_id=', OLD.booking_id, ', seat_id=', OLD.seat_id,
           ', ticket_price=', OLD.ticket_price));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_tickets_after_insert` AFTER INSERT ON `tickets` FOR EACH ROW BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'tickets', NEW.ticket_id,
    CONCAT('booking_id=', NEW.booking_id, ', seat_id=', NEW.seat_id,
           ', ticket_price=', NEW.ticket_price));
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `showtime_id` (`showtime_id`);

--
-- Indexes for table `cinemas`
--
ALTER TABLE `cinemas`
  ADD PRIMARY KEY (`cinema_id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`customer_id`),
  ADD UNIQUE KEY `uq_email` (`email`);

--
-- Indexes for table `movies`
--
ALTER TABLE `movies`
  ADD PRIMARY KEY (`movie_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `screens`
--
ALTER TABLE `screens`
  ADD PRIMARY KEY (`screen_id`),
  ADD KEY `cinema_id` (`cinema_id`);

--
-- Indexes for table `seats`
--
ALTER TABLE `seats`
  ADD PRIMARY KEY (`seat_id`),
  ADD KEY `screen_id` (`screen_id`);

--
-- Indexes for table `showtimes`
--
ALTER TABLE `showtimes`
  ADD PRIMARY KEY (`showtime_id`),
  ADD KEY `movie_id` (`movie_id`),
  ADD KEY `screen_id` (`screen_id`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `seat_id` (`seat_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=833;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`showtime_id`) REFERENCES `showtimes` (`showtime_id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE;

--
-- Constraints for table `screens`
--
ALTER TABLE `screens`
  ADD CONSTRAINT `screens_ibfk_1` FOREIGN KEY (`cinema_id`) REFERENCES `cinemas` (`cinema_id`) ON DELETE CASCADE;

--
-- Constraints for table `seats`
--
ALTER TABLE `seats`
  ADD CONSTRAINT `seats_ibfk_1` FOREIGN KEY (`screen_id`) REFERENCES `screens` (`screen_id`) ON DELETE CASCADE;

--
-- Constraints for table `showtimes`
--
ALTER TABLE `showtimes`
  ADD CONSTRAINT `showtimes_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `showtimes_ibfk_2` FOREIGN KEY (`screen_id`) REFERENCES `screens` (`screen_id`) ON DELETE CASCADE;

--
-- Constraints for table `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tickets_ibfk_2` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`seat_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
