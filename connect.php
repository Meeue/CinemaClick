<?php
// ============================================================
//  connect.php — Master-Slave Database Connection
//  Master (port 3306) → handles INSERT / UPDATE / DELETE
//  Slave  (port 3308) → handles SELECT (read-only replica)
// ============================================================

define('DB_HOST',     '127.0.0.1');
define('DB_USER',     'root');
define('DB_PASS',     '');
define('DB_NAME',     'cinemaclick');
define('MASTER_PORT', 3306);
define('SLAVE_PORT',  3308);

/**
 * Returns a connection to the MASTER server (writes).
 */
function getMasterConn(): mysqli {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, MASTER_PORT);
    if ($conn->connect_error) {
        die(json_encode([
            'success' => false,
            'message' => 'Master DB connection failed: ' . $conn->connect_error
        ]));
    }
    $conn->set_charset('utf8mb4');
    return $conn;
}

/**
 * Returns a connection to the SLAVE server (reads).
 * Automatically falls back to MASTER if slave is unreachable.
 */
function getSlaveConn(): mysqli {
    $conn = @new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, SLAVE_PORT);
    if ($conn->connect_error) {
        $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, MASTER_PORT);
        if ($conn->connect_error) {
            die(json_encode([
                'success' => false,
                'message' => 'All DB servers unavailable.'
            ]));
        }
    }
    $conn->set_charset('utf8mb4');
    return $conn;
}
