# Cinema Booking System — Admin Panel

## Folder Structure

```
cinema/
├── dashboard.html      — Overview stats, seat map, recent activity
├── movies.html         — Movie catalog with card/poster layout
├── showtimes.html      — Showtime scheduling
├── bookings.html       — Customer booking management
├── cinemas.html        — Cinema venues
├── screens.html        — Screen configuration per cinema
├── seats.html          — Seat layout & availability per screen
├── payments.html       — (placeholder — connect DB)
├── customers.html      — (placeholder — connect DB)
├── tickets.html        — (placeholder — connect DB)
│
├── styles.css          — All shared styles
├── data.js             — In-memory data store + shared helpers
├── layout.js           — Sidebar, topbar, modal HTML injector
└── README.md           — This file
```

## How to Run

Just open any `.html` file in your browser from the same folder.
All navigation links between pages work via relative hrefs — no server required for the frontend-only version.

---

## PHP / phpMyAdmin Master-Slave Integration Guide

When you're ready to connect a real database, replace the in-memory arrays in `data.js` with `fetch()` calls to your PHP API.

### Recommended PHP API pattern

Create a folder `api/` alongside the HTML files:

```
api/
├── config.php         — DB credentials (master + slave hosts)
├── movies.php
├── showtimes.php
├── bookings.php
├── cinemas.php
├── screens.php
└── seats.php
```

### config.php (master-slave example)

```php
<?php
define('DB_MASTER', 'master-host.example.com');   // Writes go here
define('DB_SLAVE',  'slave-host.example.com');    // Reads go here
define('DB_USER',   'cinema_user');
define('DB_PASS',   'yourpassword');
define('DB_NAME',   'cinema_db');

function getMasterPDO() {
    return new PDO("mysql:host=".DB_MASTER.";dbname=".DB_NAME, DB_USER, DB_PASS);
}
function getSlavePDO() {
    return new PDO("mysql:host=".DB_SLAVE.";dbname=".DB_NAME, DB_USER, DB_PASS);
}
```

### Example movies.php (CRUD)

```php
<?php
require 'config.php';
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // READ from slave
    $pdo = getSlavePDO();
    $stmt = $pdo->query("SELECT * FROM movies ORDER BY release_date DESC");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));

} elseif ($method === 'POST') {
    // INSERT to master
    $body = json_decode(file_get_contents('php://input'), true);
    $pdo  = getMasterPDO();
    $stmt = $pdo->prepare("INSERT INTO movies (title,genre,duration_minutes,rating,release_date,description,poster_url) VALUES (?,?,?,?,?,?,?)");
    $stmt->execute([$body['title'],$body['genre'],$body['duration_minutes'],$body['rating'],$body['release_date'],$body['description'],$body['poster_url']]);
    echo json_encode(['movie_id' => $pdo->lastInsertId()]);

} elseif ($method === 'PUT') {
    // UPDATE to master
    $id   = $_GET['id'];
    $body = json_decode(file_get_contents('php://input'), true);
    $pdo  = getMasterPDO();
    $stmt = $pdo->prepare("UPDATE movies SET title=?,genre=?,duration_minutes=?,rating=?,release_date=?,description=?,poster_url=? WHERE movie_id=?");
    $stmt->execute([$body['title'],$body['genre'],$body['duration_minutes'],$body['rating'],$body['release_date'],$body['description'],$body['poster_url'],$id]);
    echo json_encode(['success' => true]);

} elseif ($method === 'DELETE') {
    // DELETE from master
    $id  = $_GET['id'];
    $pdo = getMasterPDO();
    $pdo->prepare("DELETE FROM movies WHERE movie_id=?")->execute([$id]);
    echo json_encode(['success' => true]);
}
```

### Connecting data.js to the API

In `data.js`, replace the static arrays with async loaders:

```javascript
// Example: replace static movies array
async function loadMovies() {
    const res = await fetch('api/movies.php');
    movies = await res.json();
    renderMovies(); // or whichever render function is on that page
}

// Call on page load instead of using the static array:
loadMovies();
```

### Movie Poster Storage

For poster images, you have two options:
1. **Base64 (current)** — stored inline. Works for prototyping; not ideal for DB storage.
2. **File upload to server** — send multipart form to PHP, save to `/uploads/posters/`, store the path in `poster_url` column.

```php
// In movies.php POST handler, if a file is uploaded:
if (!empty($_FILES['poster'])) {
    $dest = '../uploads/posters/' . uniqid() . '_' . basename($_FILES['poster']['name']);
    move_uploaded_file($_FILES['poster']['tmp_name'], $dest);
    $poster_url = $dest;
}
```
