-- ============================================================
--  database_setup.sql  —  CinemaClick
--  Run ONLY on the MASTER (port 3306).
--  Replication will push every change to the SLAVE (port 3308).
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS `cinemaclick`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `cinemaclick`;

-- ============================================================
--  CORE TABLES  (exact schema from the exported SQL)
-- ============================================================

CREATE TABLE IF NOT EXISTS `cinemas` (
  `cinema_id`      varchar(10)  NOT NULL,
  `cinema_name`    varchar(150) NOT NULL,
  `location`       varchar(255) NOT NULL,
  `contact_number` varchar(30)  NOT NULL,
  PRIMARY KEY (`cinema_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `movies` (
  `movie_id`         varchar(10)  NOT NULL,
  `title`            varchar(200) NOT NULL,
  `genre`            enum('Action','Adventure','Animation','Comedy','Drama','Horror','Romance','Sci-Fi','Thriller') NOT NULL,
  `duration_minutes` int(10) UNSIGNED NOT NULL,
  `rating`           enum('G','PG','PG-13','R','R-18') NOT NULL,
  `release_date`     date         NOT NULL,
  `description`      text         DEFAULT NULL,
  `poster_url`       longtext     DEFAULT NULL,
  PRIMARY KEY (`movie_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `customers` (
  `customer_id`  varchar(10)  NOT NULL,
  `first_name`   varchar(80)  NOT NULL,
  `last_name`    varchar(80)  NOT NULL,
  `email`        varchar(150) NOT NULL,
  `phone_number` varchar(20)  DEFAULT NULL,
  `password`     varchar(255) DEFAULT NULL,
  `status`       enum('Active','Inactive','Suspended') NOT NULL DEFAULT 'Active',
  `created_at`   datetime     DEFAULT current_timestamp(),
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `uq_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `screens` (
  `screen_id`   varchar(10) NOT NULL,
  `cinema_id`   varchar(10) NOT NULL,
  `screen_name` varchar(60) NOT NULL,
  `total_seats` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`screen_id`),
  KEY `cinema_id` (`cinema_id`),
  CONSTRAINT `screens_ibfk_1` FOREIGN KEY (`cinema_id`) REFERENCES `cinemas` (`cinema_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `seats` (
  `seat_id`     varchar(15) NOT NULL,
  `screen_id`   varchar(10) NOT NULL,
  `seat_number` varchar(10) NOT NULL,
  `seat_type`   enum('Standard') NOT NULL DEFAULT 'Standard',
  `status`      enum('Available','Taken','Maintenance') NOT NULL DEFAULT 'Available',
  PRIMARY KEY (`seat_id`),
  KEY `screen_id` (`screen_id`),
  CONSTRAINT `seats_ibfk_1` FOREIGN KEY (`screen_id`) REFERENCES `screens` (`screen_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `showtimes` (
  `showtime_id` varchar(10)    NOT NULL,
  `movie_id`    varchar(10)    NOT NULL,
  `screen_id`   varchar(10)    NOT NULL,
  `show_date`   date           NOT NULL,
  `start_time`  time           NOT NULL,
  `end_time`    time           NOT NULL,
  `price`       decimal(10,2)  NOT NULL,
  PRIMARY KEY (`showtime_id`),
  KEY `movie_id`  (`movie_id`),
  KEY `screen_id` (`screen_id`),
  CONSTRAINT `showtimes_ibfk_1` FOREIGN KEY (`movie_id`)  REFERENCES `movies`  (`movie_id`)  ON DELETE CASCADE,
  CONSTRAINT `showtimes_ibfk_2` FOREIGN KEY (`screen_id`) REFERENCES `screens` (`screen_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `bookings` (
  `booking_id`     varchar(15)    NOT NULL,
  `customer_id`    varchar(10)    NOT NULL,
  `showtime_id`    varchar(10)    NOT NULL,
  `customer_name`  varchar(160)   NOT NULL,
  `booking_date`   date           NOT NULL,
  `total_amount`   decimal(10,2)  NOT NULL,
  `booking_status` enum('Confirmed','Pending','Cancelled') NOT NULL DEFAULT 'Pending',
  PRIMARY KEY (`booking_id`),
  KEY `customer_id` (`customer_id`),
  KEY `showtime_id` (`showtime_id`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers`  (`customer_id`) ON DELETE CASCADE,
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`showtime_id`) REFERENCES `showtimes` (`showtime_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `payments` (
  `payment_id`     varchar(15)    NOT NULL,
  `booking_id`     varchar(15)    NOT NULL,
  `payment_date`   date           NOT NULL,
  `payment_method` enum('Cash','GCash','Maya','Credit Card','Debit Card') NOT NULL,
  `payment_status` enum('Paid','Pending','Failed','Refunded') NOT NULL DEFAULT 'Pending',
  `amount`         decimal(10,2)  NOT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
--  AUDIT LOG TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `audit_log` (
  `log_id`      int(11)       AUTO_INCREMENT PRIMARY KEY,
  `operation`   enum('INSERT','UPDATE','DELETE') NOT NULL,
  `table_name`  varchar(100)  NOT NULL,
  `record_id`   varchar(20)   DEFAULT NULL,
  `old_data`    text          DEFAULT NULL,
  `new_data`    text          DEFAULT NULL,
  `changed_at`  datetime      DEFAULT current_timestamp(),
  `changed_by`  varchar(100)  DEFAULT 'system'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
--  TRIGGERS — customers
-- ============================================================
DROP TRIGGER IF EXISTS `trg_customers_after_insert`;
DELIMITER $$
CREATE TRIGGER `trg_customers_after_insert`
AFTER INSERT ON `customers` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'customers', NEW.customer_id,
    CONCAT('first_name=', NEW.first_name,
           ', last_name=',  NEW.last_name,
           ', email=',      NEW.email,
           ', phone=',      IFNULL(NEW.phone_number,'NULL'),
           ', status=',     NEW.status));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_customers_after_update`;
DELIMITER $$
CREATE TRIGGER `trg_customers_after_update`
AFTER UPDATE ON `customers` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'customers', NEW.customer_id,
    CONCAT('first_name=', OLD.first_name, ', last_name=', OLD.last_name,
           ', email=', OLD.email, ', status=', OLD.status),
    CONCAT('first_name=', NEW.first_name, ', last_name=', NEW.last_name,
           ', email=', NEW.email, ', status=', NEW.status));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_customers_after_delete`;
DELIMITER $$
CREATE TRIGGER `trg_customers_after_delete`
AFTER DELETE ON `customers` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'customers', OLD.customer_id,
    CONCAT('first_name=', OLD.first_name, ', last_name=', OLD.last_name,
           ', email=', OLD.email, ', status=', OLD.status));
END$$
DELIMITER ;

-- ============================================================
--  TRIGGERS — movies
-- ============================================================
DROP TRIGGER IF EXISTS `trg_movies_after_insert`;
DELIMITER $$
CREATE TRIGGER `trg_movies_after_insert`
AFTER INSERT ON `movies` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'movies', NEW.movie_id,
    CONCAT('title=', NEW.title, ', genre=', NEW.genre,
           ', duration=', NEW.duration_minutes, 'min, rating=', NEW.rating,
           ', release_date=', NEW.release_date));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_movies_after_update`;
DELIMITER $$
CREATE TRIGGER `trg_movies_after_update`
AFTER UPDATE ON `movies` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'movies', NEW.movie_id,
    CONCAT('title=', OLD.title, ', genre=', OLD.genre, ', rating=', OLD.rating),
    CONCAT('title=', NEW.title, ', genre=', NEW.genre, ', rating=', NEW.rating));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_movies_after_delete`;
DELIMITER $$
CREATE TRIGGER `trg_movies_after_delete`
AFTER DELETE ON `movies` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'movies', OLD.movie_id,
    CONCAT('title=', OLD.title, ', genre=', OLD.genre, ', rating=', OLD.rating));
END$$
DELIMITER ;

-- ============================================================
--  TRIGGERS — bookings
-- ============================================================
DROP TRIGGER IF EXISTS `trg_bookings_after_insert`;
DELIMITER $$
CREATE TRIGGER `trg_bookings_after_insert`
AFTER INSERT ON `bookings` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'bookings', NEW.booking_id,
    CONCAT('customer_id=', NEW.customer_id, ', showtime_id=', NEW.showtime_id,
           ', customer_name=', NEW.customer_name, ', total_amount=', NEW.total_amount,
           ', status=', NEW.booking_status));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_bookings_after_update`;
DELIMITER $$
CREATE TRIGGER `trg_bookings_after_update`
AFTER UPDATE ON `bookings` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'bookings', NEW.booking_id,
    CONCAT('total_amount=', OLD.total_amount, ', status=', OLD.booking_status),
    CONCAT('total_amount=', NEW.total_amount, ', status=', NEW.booking_status));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_bookings_after_delete`;
DELIMITER $$
CREATE TRIGGER `trg_bookings_after_delete`
AFTER DELETE ON `bookings` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'bookings', OLD.booking_id,
    CONCAT('customer_id=', OLD.customer_id, ', showtime_id=', OLD.showtime_id,
           ', total_amount=', OLD.total_amount, ', status=', OLD.booking_status));
END$$
DELIMITER ;

-- ============================================================
--  TRIGGERS — payments
-- ============================================================
DROP TRIGGER IF EXISTS `trg_payments_after_insert`;
DELIMITER $$
CREATE TRIGGER `trg_payments_after_insert`
AFTER INSERT ON `payments` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'payments', NEW.payment_id,
    CONCAT('booking_id=', NEW.booking_id, ', amount=', NEW.amount,
           ', method=', NEW.payment_method, ', status=', NEW.payment_status));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_payments_after_update`;
DELIMITER $$
CREATE TRIGGER `trg_payments_after_update`
AFTER UPDATE ON `payments` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'payments', NEW.payment_id,
    CONCAT('amount=', OLD.amount, ', method=', OLD.payment_method, ', status=', OLD.payment_status),
    CONCAT('amount=', NEW.amount, ', method=', NEW.payment_method, ', status=', NEW.payment_status));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_payments_after_delete`;
DELIMITER $$
CREATE TRIGGER `trg_payments_after_delete`
AFTER DELETE ON `payments` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'payments', OLD.payment_id,
    CONCAT('booking_id=', OLD.booking_id, ', amount=', OLD.amount,
           ', method=', OLD.payment_method, ', status=', OLD.payment_status));
END$$
DELIMITER ;

-- ============================================================
--  TRIGGERS — cinemas
-- ============================================================
DROP TRIGGER IF EXISTS `trg_cinemas_after_insert`;
DELIMITER $$
CREATE TRIGGER `trg_cinemas_after_insert`
AFTER INSERT ON `cinemas` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'cinemas', NEW.cinema_id,
    CONCAT('cinema_name=', NEW.cinema_name, ', location=', NEW.location,
           ', contact=', NEW.contact_number));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_cinemas_after_update`;
DELIMITER $$
CREATE TRIGGER `trg_cinemas_after_update`
AFTER UPDATE ON `cinemas` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data, new_data)
  VALUES ('UPDATE', 'cinemas', NEW.cinema_id,
    CONCAT('cinema_name=', OLD.cinema_name, ', location=', OLD.location),
    CONCAT('cinema_name=', NEW.cinema_name, ', location=', NEW.location));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_cinemas_after_delete`;
DELIMITER $$
CREATE TRIGGER `trg_cinemas_after_delete`
AFTER DELETE ON `cinemas` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'cinemas', OLD.cinema_id,
    CONCAT('cinema_name=', OLD.cinema_name, ', location=', OLD.location));
END$$
DELIMITER ;

-- ============================================================
--  SAMPLE DATA
-- ============================================================
INSERT IGNORE INTO `cinemas` VALUES
  ('CIN001','SM Cinema Cebu','SM City Cebu, North Reclamation Area','(032) 231-0001'),
  ('CIN002','Ayala Cinemas','Ayala Center Cebu, Cebu City','(032) 888-0002'),
  ('CIN003','Robinsons Movieworld','Robinsons Galleria Cebu, Cebu City','(032) 777-0003');

INSERT IGNORE INTO `movies` VALUES
  ('MOV001','Avengers: Doomsday','Action',150,'PG-13','2026-05-01','Earth\'s mightiest heroes unite once more.',''),
  ('MOV002','Inside Out 3','Animation',110,'G','2026-04-15','New emotions, new adventures.',''),
  ('MOV003','A Quiet Place: Day One','Horror',120,'R','2026-03-22','The origin of silence.',''),
  ('MOV004','Deadpool & Wolverine','Action',128,'R-18','2026-02-14','Two legends. One adventure.',''),
  ('MOV005','Kung Fu Panda 5','Animation',100,'G','2026-04-10','Po is back!','');

INSERT IGNORE INTO `screens` VALUES
  ('SCR001','CIN001','Screen A',120),
  ('SCR002','CIN001','Screen B',80),
  ('SCR003','CIN002','Screen 1',150),
  ('SCR004','CIN003','Main Hall',200);

INSERT IGNORE INTO `showtimes` VALUES
  ('SHW001','MOV001','SCR001','2026-04-26','10:00:00','12:30:00',250.00),
  ('SHW002','MOV001','SCR001','2026-04-26','14:00:00','16:30:00',250.00),
  ('SHW003','MOV002','SCR002','2026-04-26','11:00:00','12:50:00',200.00),
  ('SHW004','MOV003','SCR003','2026-04-27','19:00:00','21:00:00',300.00),
  ('SHW005','MOV004','SCR004','2026-04-27','20:00:00','22:08:00',350.00),
  ('SHW006','MOV005','SCR001','2026-04-28','09:00:00','10:40:00',180.00);

INSERT IGNORE INTO `customers` VALUES
  ('CUS001','Juan','Dela Cruz','juan@email.com','09171234567','hashed_pw','Active',NOW()),
  ('CUS002','Maria','Santos','maria@email.com','09182345678','hashed_pw','Active',NOW()),
  ('CUS003','Jose','Rizal','jose@email.com','09193456789','hashed_pw','Active',NOW()),
  ('CUS004','Ana','Reyes','ana@email.com','09204567890','hashed_pw','Inactive',NOW()),
  ('CUS005','Carlo','Mendoza','carlo@email.com','09215678901','hashed_pw','Active',NOW());

INSERT IGNORE INTO `bookings` VALUES
  ('BKG001','CUS001','SHW001','Juan Dela Cruz','2026-04-25',500.00,'Confirmed'),
  ('BKG002','CUS002','SHW003','Maria Santos','2026-04-25',200.00,'Confirmed'),
  ('BKG003','CUS003','SHW004','Jose Rizal','2026-04-25',300.00,'Pending'),
  ('BKG004','CUS001','SHW005','Juan Dela Cruz','2026-04-25',700.00,'Cancelled'),
  ('BKG005','CUS005','SHW006','Carlo Mendoza','2026-04-25',360.00,'Confirmed');

INSERT IGNORE INTO `payments` VALUES
  ('PAY001','BKG001','2026-04-25','GCash','Paid',500.00),
  ('PAY002','BKG002','2026-04-25','Cash','Paid',200.00),
  ('PAY003','BKG003','2026-04-25','Maya','Pending',300.00),
  ('PAY004','BKG005','2026-04-25','Credit Card','Paid',360.00);

COMMIT;

-- ============================================================
--  TICKETS TABLE (from ERD)
-- ============================================================
USE cinemaclick;

CREATE TABLE IF NOT EXISTS `tickets` (
  `ticket_id`    varchar(15)    NOT NULL,
  `booking_id`   varchar(15)    NOT NULL,
  `seat_id`      varchar(15)    NOT NULL,
  `ticket_price` decimal(10,2)  NOT NULL,
  `issued_at`    datetime       DEFAULT current_timestamp(),
  PRIMARY KEY (`ticket_id`),
  KEY `booking_id` (`booking_id`),
  KEY `seat_id`    (`seat_id`),
  CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings`  (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `tickets_ibfk_2` FOREIGN KEY (`seat_id`)    REFERENCES `seats`     (`seat_id`)    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
--  TRIGGERS — tickets
-- ============================================================
DROP TRIGGER IF EXISTS `trg_tickets_after_insert`;
DELIMITER $$
CREATE TRIGGER `trg_tickets_after_insert`
AFTER INSERT ON `tickets` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, new_data)
  VALUES ('INSERT', 'tickets', NEW.ticket_id,
    CONCAT('booking_id=', NEW.booking_id, ', seat_id=', NEW.seat_id,
           ', ticket_price=', NEW.ticket_price));
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_tickets_after_delete`;
DELIMITER $$
CREATE TRIGGER `trg_tickets_after_delete`
AFTER DELETE ON `tickets` FOR EACH ROW
BEGIN
  INSERT INTO audit_log (operation, table_name, record_id, old_data)
  VALUES ('DELETE', 'tickets', OLD.ticket_id,
    CONCAT('booking_id=', OLD.booking_id, ', seat_id=', OLD.seat_id,
           ', ticket_price=', OLD.ticket_price));
END$$
DELIMITER ;

-- ============================================================
--  AUTO-GENERATE SEATS when a screen is added
--  (Run this once to seed seats for existing screens)
-- ============================================================
DROP PROCEDURE IF EXISTS generate_seats;
DELIMITER $$
CREATE PROCEDURE generate_seats()
BEGIN
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

-- Run it to generate seats for all existing screens
CALL generate_seats();
