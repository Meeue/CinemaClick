<?php
// ============================================================
//  customer.php — Read-Only Customer View
//  All queries use getSlaveConn() to demonstrate slave replication
// ============================================================
require_once 'connect.php';

$slave = getSlaveConn();

// --- Fetch Now Showing (showtimes from today onward, movies released) ---
$now_showing_sql = "
    SELECT DISTINCT
        m.movie_id, m.title, m.genre, m.duration_minutes,
        m.rating, m.release_date, m.description, m.poster_url,
        MIN(s.show_date) AS next_show_date,
        MIN(s.start_time) AS next_start_time,
        MIN(s.price) AS min_price
    FROM movies m
    JOIN showtimes s ON m.movie_id = s.movie_id
    WHERE s.show_date >= CURDATE()
    GROUP BY m.movie_id
    ORDER BY next_show_date ASC
";
$now_result = $slave->query($now_showing_sql);
$now_showing = [];
while ($row = $now_result->fetch_assoc()) $now_showing[] = $row;

// --- Fetch All Showtimes for schedule section ---
$schedule_sql = "
    SELECT
        s.showtime_id, s.show_date, s.start_time, s.end_time, s.price,
        m.title, m.genre, m.rating, m.duration_minutes,
        sc.screen_id
    FROM showtimes s
    JOIN movies m ON s.movie_id = m.movie_id
    JOIN screens sc ON s.screen_id = sc.screen_id
    WHERE s.show_date >= CURDATE()
    ORDER BY s.show_date ASC, s.start_time ASC
";
$schedule_result = $slave->query($schedule_sql);
$showtimes = [];
while ($row = $schedule_result->fetch_assoc()) $showtimes[] = $row;

// --- Upcoming: movies with no showtime yet or future release ---
$upcoming_sql = "
    SELECT m.movie_id, m.title, m.genre, m.duration_minutes,
           m.rating, m.release_date, m.description, m.poster_url
    FROM movies m
    LEFT JOIN showtimes s ON m.movie_id = s.movie_id AND s.show_date >= CURDATE()
    WHERE s.showtime_id IS NULL
       OR m.release_date > CURDATE()
    GROUP BY m.movie_id
    ORDER BY m.release_date ASC
";
$upcoming_result = $slave->query($upcoming_sql);
$upcoming = [];
while ($row = $upcoming_result->fetch_assoc()) $upcoming[] = $row;

// --- Genre list for filter ---
$genres = array_unique(array_column($now_showing, 'genre'));

// Group showtimes by date for display
$grouped = [];
foreach ($showtimes as $st) {
    $grouped[$st['show_date']][] = $st;
}

$slave->close();

// Rating color helper
function ratingColor($r) {
    return match($r) {
        'G'     => '#4caf50',
        'PG'    => '#2196f3',
        'PG-13' => '#ff9800',
        'R'     => '#f44336',
        'R-18'  => '#9c27b0',
        default => '#888'
    };
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>CinemaClick - Now Showing</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;1,9..40,300&display=swap" rel="stylesheet"/>
<style>
/* ── RESET & BASE ───────────────────────────────────────── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg:       #080810;
  --surface:  #10101c;
  --surface2: #17172a;
  --border:   rgba(255,255,255,.07);
  --accent:   #e8631a;
  --gold:     #f5c842;
  --text:     #f0ebe0;
  --muted:    #6a657a;
  --faint:    rgba(240,235,224,.18);
  --success:  #3daa6a;
  --r: 8px;
}

html { scroll-behavior: smooth; }

body {
  font-family: 'DM Sans', sans-serif;
  background: var(--bg);
  color: var(--text);
  min-height: 100vh;
  overflow-x: hidden;
}

/* ── NAVBAR ─────────────────────────────────────────────── */
nav {
  position: sticky; top: 0; z-index: 100;
  background: rgba(8,8,16,.85);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid var(--border);
  display: flex; align-items: center; justify-content: center;
  padding: 0 2rem;
  height: 64px;
}

.nav-logo {
  position: absolute;
  left: 2rem;
  display: inline-flex;
  align-items: center;
  gap: 0.72rem;
  font-family: 'Bebas Neue', sans-serif;
  font-size: 1.7rem;
  letter-spacing: 2px;
  color: var(--accent);
  text-decoration: none;
}
.nav-logo img {
  width: 34px;
  height: 34px;
  object-fit: contain;
}
.nav-logo span { color: var(--gold); }

.nav-links { display: flex; gap: 1.6rem; list-style: none; }
.nav-links a {
  color: var(--muted); text-decoration: none;
  font-size: .9rem; font-weight: 500; letter-spacing: .4px;
  transition: color .2s;
}
.nav-links a:hover, .nav-links a.active { color: var(--text); }

@keyframes pulse {
  0%,100%{ opacity:1; box-shadow:0 0 0 0 rgba(61,170,106,.5); }
  50%    { opacity:.7; box-shadow:0 0 0 5px rgba(61,170,106,0); }
}

/* ── HERO ───────────────────────────────────────────────── */
.hero {
  position: relative;
  padding: 6rem 2rem 4rem;
  text-align: center;
  overflow: hidden;
}
.hero::before {
  content:'';
  position: absolute; inset: 0;
  background:
    radial-gradient(ellipse 60% 40% at 50% 0%, rgba(232,99,26,.18) 0%, transparent 70%),
    radial-gradient(ellipse 40% 30% at 80% 80%, rgba(245,200,66,.08) 0%, transparent 60%);
  pointer-events: none;
}
.hero-tag {
  display: inline-block;
  background: var(--accent); color: #fff;
  font-size: .72rem; font-weight: 700; letter-spacing: 1.5px;
  text-transform: uppercase;
  padding: 4px 14px; border-radius: 4px;
  margin-bottom: 1.2rem;
}
.hero h1 {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(3rem, 8vw, 6rem);
  line-height: 1;
  letter-spacing: 3px;
  margin-bottom: .6rem;
}
.hero h1 span { color: var(--accent); }
.hero p {
  color: var(--muted); font-size: 1rem;
  max-width: 480px; margin: 0 auto;
}

/* ── SECTION SHELL ──────────────────────────────────────── */
section { padding: 3.5rem 2rem; max-width: 1280px; margin: 0 auto; }
.sec-header {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;
}
.sec-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 2rem; letter-spacing: 2px;
}
.sec-title span { color: var(--accent); }

/* ── GENRE FILTER ───────────────────────────────────────── */
.filter-bar { display: flex; gap: .6rem; flex-wrap: wrap; }
.filter-btn {
  padding: 5px 16px; border-radius: 20px;
  border: 1px solid var(--border);
  background: transparent; color: var(--muted);
  font-size: .82rem; font-family: inherit; font-weight: 500;
  cursor: pointer; transition: all .2s;
}
.filter-btn:hover, .filter-btn.active {
  background: var(--accent); border-color: var(--accent);
  color: #fff;
}

/* ── MOVIE GRID ─────────────────────────────────────────── */
.movie-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1.4rem;
}

.movie-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r);
  overflow: hidden;
  transition: transform .25s, border-color .25s, box-shadow .25s;
  cursor: pointer;
}
.movie-card:hover {
  transform: translateY(-6px);
  border-color: rgba(232,99,26,.4);
  box-shadow: 0 16px 40px rgba(0,0,0,.5);
}
.movie-card:hover .card-overlay { opacity: 1; }

.card-poster {
  position: relative;
  aspect-ratio: 2/3;
  overflow: hidden;
  background: var(--surface2);
}
.card-poster img {
  width: 100%; height: 100%;
  object-fit: cover;
  display: block;
  transition: transform .3s;
}
.movie-card:hover .card-poster img { transform: scale(1.04); }

.card-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(8,8,16,.95) 30%, transparent);
  opacity: 0; transition: opacity .3s;
  display: flex; flex-direction: column; justify-content: flex-end;
  padding: 1rem;
}
.card-overlay p {
  font-size: .78rem; color: rgba(240,235,224,.8);
  line-height: 1.45;
  display: -webkit-box; -webkit-line-clamp: 4;
  -webkit-box-orient: vertical; overflow: hidden;
}

.poster-placeholder {
  width: 100%; height: 100%;
  display: flex; align-items: center; justify-content: center;
  background: linear-gradient(135deg, var(--surface2), #1e1e35);
  font-family: 'Bebas Neue', sans-serif;
  font-size: 1.1rem; letter-spacing: 1px;
  color: var(--muted); text-align: center; padding: 1rem;
}

.rating-chip {
  position: absolute; top: 8px; left: 8px;
  padding: 2px 8px; border-radius: 4px;
  font-size: .65rem; font-weight: 700; letter-spacing: .8px;
  color: #fff;
}

.card-body { padding: .9rem 1rem 1rem; }
.card-title {
  font-weight: 600; font-size: .92rem;
  margin-bottom: .35rem; line-height: 1.3;
}
.card-meta {
  display: flex; align-items: center; gap: .5rem;
  font-size: .75rem; color: var(--muted); flex-wrap: wrap;
}
.genre-tag {
  background: var(--surface2);
  border: 1px solid var(--border);
  padding: 2px 8px; border-radius: 4px;
  font-size: .7rem; color: var(--muted);
}
.showtime-info {
  margin-top: .6rem; font-size: .78rem;
  color: var(--accent); font-weight: 500;
}
.price-tag {
  margin-top: .25rem; font-size: .75rem; color: var(--gold);
}

/* no results */
.no-results {
  grid-column: 1/-1; text-align: center;
  padding: 3rem; color: var(--muted); font-style: italic;
}

/* ── SCHEDULE TABLE ─────────────────────────────────────── */
.schedule-wrap { overflow-x: auto; }
.date-group { margin-bottom: 2rem; }
.date-label {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 1.2rem; letter-spacing: 2px;
  color: var(--gold);
  margin-bottom: .8rem;
  display: flex; align-items: center; gap: .7rem;
}
.date-label::after {
  content:''; flex: 1; height: 1px; background: var(--border);
}

table {
  width: 100%; border-collapse: collapse;
  font-size: .85rem;
}
th {
  text-align: left; padding: .65rem 1rem;
  color: var(--muted); font-weight: 500;
  border-bottom: 1px solid var(--border);
  white-space: nowrap;
}
td {
  padding: .75rem 1rem;
  border-bottom: 1px solid var(--border);
  vertical-align: middle;
}
tr:last-child td { border-bottom: none; }
tr:hover td { background: rgba(255,255,255,.025); }

.time-badge {
  display: inline-block;
  background: var(--surface2); border: 1px solid var(--border);
  border-radius: 4px; padding: 3px 10px;
  font-size: .78rem; font-weight: 600;
  letter-spacing: .3px;
}
.screen-chip {
  display: inline-block;
  font-size: .72rem; color: var(--muted);
  background: var(--surface2);
  border-radius: 4px; padding: 2px 8px;
}
.price-col { color: var(--gold); font-weight: 600; }

/* ── UPCOMING ───────────────────────────────────────────── */
.upcoming-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 1.2rem;
}
.upcoming-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r);
  padding: 1.2rem 1.4rem;
  display: flex; gap: 1rem;
  transition: border-color .2s;
}
.upcoming-card:hover { border-color: rgba(245,200,66,.3); }
.upcoming-dot {
  width: 10px; height: 10px; border-radius: 50%;
  background: var(--gold); flex-shrink: 0; margin-top: 5px;
}
.upcoming-body {}
.upcoming-title { font-weight: 600; margin-bottom: .3rem; }
.upcoming-sub {
  font-size: .78rem; color: var(--muted);
  display: flex; gap: .5rem; flex-wrap: wrap; align-items: center;
}
.coming-date {
  color: var(--gold); font-weight: 500; font-size: .78rem;
  margin-top: .4rem;
}

/* ── FOOTER ─────────────────────────────────────────────── */
footer {
  border-top: 1px solid var(--border);
  padding: 2rem;
  text-align: center;
  color: var(--muted);
  font-size: .8rem;
}
footer .db-note {
  margin-top: .5rem;
  display: inline-flex; align-items: center; gap: 6px;
  color: var(--success); font-size: .75rem;
}

/* ── MODAL ──────────────────────────────────────────────── */
.modal-bg {
  display: none;
  position: fixed; inset: 0; z-index: 200;
  background: rgba(0,0,0,.75);
  backdrop-filter: blur(6px);
  align-items: center; justify-content: center;
  padding: 1rem;
}
.modal-bg.open { display: flex; }

.modal {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  max-width: 600px; width: 100%;
  overflow: hidden;
  animation: pop .25s ease;
}
@keyframes pop {
  from { transform: scale(.94); opacity:0; }
  to   { transform: scale(1);   opacity:1; }
}
.modal-header {
  display: flex; align-items: flex-start; gap: 1.2rem;
  padding: 1.5rem;
  border-bottom: 1px solid var(--border);
}
.modal-poster {
  width: 90px; height: 135px;
  border-radius: 6px; object-fit: cover;
  background: var(--surface2);
  flex-shrink: 0;
}
.modal-info { flex: 1; }
.modal-info h2 {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 1.8rem; letter-spacing: 1.5px; margin-bottom: .4rem;
}
.modal-meta { display: flex; flex-wrap: wrap; gap: .5rem; font-size: .8rem; color: var(--muted); }
.modal-desc {
  padding: 1.2rem 1.5rem;
  font-size: .88rem; line-height: 1.65;
  color: rgba(240,235,224,.75);
}
.modal-showtimes {
  padding: 0 1.5rem 1.5rem;
}
.modal-showtimes h4 {
  font-size: .75rem; letter-spacing: 1px; text-transform: uppercase;
  color: var(--muted); margin-bottom: .8rem;
}
.showtime-pills { display: flex; gap: .5rem; flex-wrap: wrap; }
.showtime-pill {
  padding: 6px 14px;
  border-radius: 6px;
  border: 1px solid var(--border);
  background: var(--surface2);
  font-size: .82rem; font-weight: 500;
}
.modal-close {
  display: block; width: calc(100% - 3rem);
  margin: 0 1.5rem 1.5rem;
  padding: .75rem;
  background: var(--accent); color: #fff;
  border: none; border-radius: 6px;
  font-family: inherit; font-size: .9rem; font-weight: 600;
  cursor: pointer; letter-spacing: .3px;
  transition: background .2s;
}
.modal-close:hover { background: #c9561a; }

/* ── UTILITIES ──────────────────────────────────────────── */
.empty-state {
  text-align: center; padding: 3rem;
  color: var(--muted); font-style: italic;
}
</style>
</head>
<body>

<!-- NAVBAR -->
<nav>
  <a href="customer.php" class="nav-logo">
    <img src="assets/js/click.png" alt="CinemaClick logo">
    CinemaClick</span>
  </a>
  <ul class="nav-links">
    <li><a href="#now-showing" class="active">Now Showing</a></li>
    <li><a href="#schedule">Schedule</a></li>
    <li><a href="#upcoming">Upcoming</a></li>
  </ul>
</nav>

<!-- HERO -->
<div class="hero">
  <div class="hero-tag">Your Local Cinema</div>
  <h1>What's <span>Playing</span><br>This Week</h1>
  <p>Browse showtimes, explore genres, and plan your next movie night.</p>
</div>

<!-- ═══════════════════════════════════════════════════════════
     NOW SHOWING
════════════════════════════════════════════════════════════ -->
<section id="now-showing">
  <div class="sec-header">
    <h2 class="sec-title">Now <span>Showing</span></h2>
    <!-- Genre filter -->
    <div class="filter-bar">
      <button class="filter-btn active" data-genre="all">All</button>
      <?php foreach ($genres as $g): ?>
        <button class="filter-btn" data-genre="<?= htmlspecialchars($g) ?>"><?= htmlspecialchars($g) ?></button>
      <?php endforeach; ?>
    </div>
  </div>

  <?php if (empty($now_showing)): ?>
    <div class="empty-state">No showtimes available at the moment. Check back soon!</div>
  <?php else: ?>
  <div class="movie-grid" id="movieGrid">
    <?php foreach ($now_showing as $m):
      $poster = htmlspecialchars($m['poster_url'] ?? '');
      $rc = ratingColor($m['rating']);
      $mins = (int)$m['duration_minutes'];
      $dur = floor($mins/60).'h '.($mins%60).'m';
      $showDate = date('D, M j', strtotime($m['next_show_date']));
      $showTime = date('g:i A', strtotime($m['next_start_time']));
    ?>
    <div class="movie-card"
         data-genre="<?= htmlspecialchars($m['genre']) ?>"
         data-id="<?= htmlspecialchars($m['movie_id']) ?>"
         onclick="openModal(this)"
         data-title="<?= htmlspecialchars($m['title']) ?>"
         data-desc="<?= htmlspecialchars($m['description'] ?? 'No description available.') ?>"
         data-rating="<?= htmlspecialchars($m['rating']) ?>"
         data-genre-label="<?= htmlspecialchars($m['genre']) ?>"
         data-duration="<?= $dur ?>"
         data-poster="<?= $poster ?>"
         data-showdate="<?= $showDate ?>"
         data-showtime="<?= $showTime ?>"
         data-price="₱<?= number_format($m['min_price'], 2) ?>">

      <div class="card-poster">
        <?php if ($poster): ?>
          <img src="<?= $poster ?>" alt="<?= htmlspecialchars($m['title']) ?>"
               onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
          <div class="poster-placeholder" style="display:none"><?= htmlspecialchars($m['title']) ?></div>
        <?php else: ?>
          <div class="poster-placeholder"><?= htmlspecialchars($m['title']) ?></div>
        <?php endif; ?>
        <span class="rating-chip" style="background:<?= $rc ?>"><?= htmlspecialchars($m['rating']) ?></span>
        <div class="card-overlay">
          <p><?= htmlspecialchars($m['description'] ?? '') ?></p>
        </div>
      </div>

      <div class="card-body">
        <div class="card-title"><?= htmlspecialchars($m['title']) ?></div>
        <div class="card-meta">
          <span class="genre-tag"><?= htmlspecialchars($m['genre']) ?></span>
          <span><?= $dur ?></span>
        </div>
        <div class="showtime-info"><i class="fa-solid fa-clock" style="color: #c96a3a;"></i> <?= $showDate ?> · <?= $showTime ?></div>
        <div class="price-tag">From ₱<?= number_format($m['min_price'], 2) ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>
</section>

<!-- ═══════════════════════════════════════════════════════════
     FULL SCHEDULE
════════════════════════════════════════════════════════════ -->
<section id="schedule" style="border-top:1px solid var(--border)">
  <div class="sec-header">
    <h2 class="sec-title">Full <span>Schedule</span></h2>
  </div>

  <?php if (empty($grouped)): ?>
    <div class="empty-state">No upcoming showtimes scheduled.</div>
  <?php else: ?>
  <div class="schedule-wrap">
    <?php foreach ($grouped as $date => $shows): ?>
    <div class="date-group">
      <div class="date-label"><?= date('l, F j, Y', strtotime($date)) ?></div>
      <table>
        <thead>
          <tr>
            <th>Movie</th>
            <th>Genre</th>
            <th>Rating</th>
            <th>Time</th>
            <th>Duration</th>
            <th>Screen</th>
            <th>Price</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($shows as $st):
            $mins = (int)$st['duration_minutes'];
            $dur  = floor($mins/60).'h '.($mins%60).'m';
            $rc   = ratingColor($st['rating']);
          ?>
          <tr>
            <td><strong><?= htmlspecialchars($st['title']) ?></strong></td>
            <td><span class="genre-tag"><?= htmlspecialchars($st['genre']) ?></span></td>
            <td><span class="rating-chip" style="background:<?= $rc ?>;position:static;display:inline-block"><?= htmlspecialchars($st['rating']) ?></span></td>
            <td>
              <span class="time-badge"><?= date('g:i A', strtotime($st['start_time'])) ?></span>
              &rarr;
              <span class="time-badge"><?= date('g:i A', strtotime($st['end_time'])) ?></span>
            </td>
            <td><?= $dur ?></td>
            <td><span class="screen-chip"><?= htmlspecialchars($st['screen_id']) ?></span></td>
            <td class="price-col">₱<?= number_format($st['price'], 2) ?></td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>
</section>

<!-- ═══════════════════════════════════════════════════════════
     UPCOMING MOVIES
════════════════════════════════════════════════════════════ -->
<?php if (!empty($upcoming)): ?>
<section id="upcoming" style="border-top:1px solid var(--border)">
  <div class="sec-header">
    <h2 class="sec-title">Coming <span>Soon</span></h2>
  </div>
  <div class="upcoming-grid">
    <?php foreach ($upcoming as $u):
      $mins = (int)$u['duration_minutes'];
      $dur  = floor($mins/60).'h '.($mins%60).'m';
      $rel  = date('M j, Y', strtotime($u['release_date']));
    ?>
    <div class="upcoming-card">
      <div class="upcoming-dot"></div>
      <div class="upcoming-body">
        <div class="upcoming-title"><?= htmlspecialchars($u['title']) ?></div>
        <div class="upcoming-sub">
          <span class="genre-tag"><?= htmlspecialchars($u['genre']) ?></span>
          <span><?= $dur ?></span>
          <span class="rating-chip" style="background:<?= ratingColor($u['rating']) ?>;position:static;display:inline-block"><?= htmlspecialchars($u['rating']) ?></span>
        </div>
        <div class="coming-date"><i class="fa-solid fa-calendar" style="color: #c96a3a;"></i> Releasing <?= $rel ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
</section>
<?php endif; ?>

<!-- ═══════════════════════════════════════════════════════════
     MOVIE DETAIL MODAL
════════════════════════════════════════════════════════════ -->
<div class="modal-bg" id="modalBg" onclick="closeModal(event)">
  <div class="modal">
    <div class="modal-header">
      <img class="modal-poster" id="mPoster" src="" alt="">
      <div class="modal-info">
        <h2 id="mTitle"></h2>
        <div class="modal-meta" id="mMeta"></div>
      </div>
    </div>
    <div class="modal-desc" id="mDesc"></div>
    <div class="modal-showtimes">
      <h4>Next Showtime</h4>
      <div class="showtime-pills" id="mPills"></div>
    </div>
    <button class="modal-close" onclick="closeModal()">Close</button>
  </div>
</div>

<!-- ── FOOTER ─────────────────────────────────────────────── -->
<footer>
  <div>&copy; <?= date('Y') ?> CinemaClick &mdash; All rights reserved</div>
</footer>

<script>
// ── Genre filter ───────────────────────────────────────────
document.querySelectorAll('.filter-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    const genre = btn.dataset.genre;
    document.querySelectorAll('.movie-card').forEach(card => {
      card.style.display =
        (genre === 'all' || card.dataset.genre === genre) ? '' : 'none';
    });
  });
});

// ── Modal ──────────────────────────────────────────────────
function openModal(card) {
  const d = card.dataset;
  document.getElementById('mTitle').textContent = d.title;
  document.getElementById('mDesc').textContent  = d.desc;
  document.getElementById('mPoster').src        = d.poster || '';
  document.getElementById('mPoster').alt        = d.title;

  const rc = {G:'#4caf50',PG:'#2196f3','PG-13':'#ff9800',R:'#f44336','R-18':'#9c27b0'};
  document.getElementById('mMeta').innerHTML =
    `<span class="rating-chip" style="background:${rc[d.rating]||'#888'};position:static;display:inline-block">${d.rating}</span>
     <span>${d.genreLabel}</span>
     <span>${d.duration}</span>`;

  document.getElementById('mPills').innerHTML =
    `<span class="showtime-pill"><i class="fa-solid fa-calendar-day" style="color: #c96a3a;"></i> ${d.showdate} &nbsp;|&nbsp; <i class="fa-solid fa-clock" style="color: #c96a3a;"></i> ${d.showtime}</span>
     <span class="showtime-pill" style="color:var(--gold)">${d.price}</span>`;

  document.getElementById('modalBg').classList.add('open');
}

function closeModal(e) {
  if (!e || e.target === document.getElementById('modalBg') || e.type !== 'click' || !e.target.closest('.modal')) {
    document.getElementById('modalBg').classList.remove('open');
  }
}
document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });

// ── Smooth scroll nav highlight ─────────────────────────────
const sections = document.querySelectorAll('section[id]');
const navLinks  = document.querySelectorAll('.nav-links a');
window.addEventListener('scroll', () => {
  let cur = '';
  sections.forEach(s => { if (window.scrollY >= s.offsetTop - 120) cur = s.id; });
  navLinks.forEach(a => {
    a.classList.toggle('active', a.getAttribute('href') === '#'+cur);
  });
});
</script>
</body>
</html>
