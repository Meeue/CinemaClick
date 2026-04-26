<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$conn = getSlaveConn();

$total_customers = $conn->query("SELECT COUNT(*) AS c FROM customers WHERE status='Active'")->fetch_assoc()['c'];
$total_movies    = $conn->query("SELECT COUNT(*) AS c FROM movies")->fetch_assoc()['c'];
$total_bookings  = $conn->query("SELECT COUNT(*) AS c FROM bookings")->fetch_assoc()['c'];
$revenue         = $conn->query("SELECT COALESCE(SUM(amount),0) AS t FROM payments WHERE payment_status='Paid'")->fetch_assoc()['t'];

$now_showing = $conn->query(
    "SELECT m.movie_id, m.title, m.genre, m.duration_minutes, m.rating, m.poster_url
     FROM movies m
     JOIN showtimes st ON m.movie_id = st.movie_id
     WHERE st.show_date >= CURDATE()
     GROUP BY m.movie_id ORDER BY m.title LIMIT 4"
)->fetch_all(MYSQLI_ASSOC);

$today_shows = $conn->query(
    "SELECT st.showtime_id, st.start_time, st.end_time, st.price,
            m.title, sc.screen_name
     FROM showtimes st
     JOIN movies  m  ON st.movie_id  = m.movie_id
     JOIN screens sc ON st.screen_id = sc.screen_id
     WHERE st.show_date = CURDATE()
     ORDER BY st.start_time LIMIT 6"
)->fetch_all(MYSQLI_ASSOC);

$recent_bookings = $conn->query(
    "SELECT b.booking_id, b.customer_name, b.total_amount, b.booking_status,
            m.title AS movie_title
     FROM bookings b
     JOIN showtimes st ON b.showtime_id = st.showtime_id
     JOIN movies    m  ON st.movie_id   = m.movie_id
     ORDER BY b.booking_date DESC LIMIT 5"
)->fetch_all(MYSQLI_ASSOC);

$seat_stats = $conn->query(
    "SELECT status, COUNT(*) AS cnt FROM seats GROUP BY status"
)->fetch_all(MYSQLI_ASSOC);
$total_seats = array_sum(array_column($seat_stats,'cnt')) ?: 1;
$taken_seats = 0;
foreach($seat_stats as $s) if($s['status']==='Taken') $taken_seats = $s['cnt'];
$occupancy = round($taken_seats / $total_seats * 100);
$conn->close();

$page_title = 'Dashboard'; $page_key = 'dashboard';
$page_sub   = 'Welcome admin! ' . date('l, M j, Y');
require_once '../includes/header.php';
?>
<script>
injectLayout({page:'dashboard',title:<?= json_encode($page_title) ?>,sub:<?= json_encode($page_sub) ?>});
document.getElementById('pageContent').innerHTML = `

<div class="stats-row">
  <div class="stat-card">
    <div class="stat-label">Total Bookings</div>
    <div class="stat-value"><?= number_format($total_bookings) ?></div>
    <div class="stat-change up">All time</div>
  </div>
  <div class="stat-card">
    <div class="stat-label">Revenue Collected</div>
    <div class="stat-value">₱<?= number_format($revenue, 0) ?></div>
    <div class="stat-change up">From paid payments</div>
  </div>
  <div class="stat-card">
    <div class="stat-label">Seat Occupancy</div>
    <div class="stat-value"><?= $occupancy ?>%</div>
    <div class="stat-change <?= $occupancy > 50 ? 'up' : 'down' ?>"><?= $taken_seats ?> of <?= $total_seats ?> seats taken</div>
  </div>
  <div class="stat-card">
    <div class="stat-label">Active Customers</div>
    <div class="stat-value"><?= number_format($total_customers) ?></div>
    <div class="stat-change up"><?= $total_movies ?> movies in catalog</div>
  </div>
</div>

<div class="grid-2">
  <div class="panel">
    <div class="panel-header">
      <div class="panel-title">Now Showing</div>
      <a class="panel-action" href="movies.php">manage movies →</a>
    </div>
    <div class="panel-body">
      <div class="movie-list">
        <?php if ($now_showing): foreach ($now_showing as $i => $m): ?>
        <div class="movie-item">
          <div class="movie-thumb t<?= ($i%3)+1 ?>">
            <?php if ($m['poster_url']): ?>
            <img src="../<?= e($m['poster_url']) ?>" style="width:36px;height:52px;object-fit:cover;border-radius:3px">
            <?php else: ?>🎬<?php endif; ?>
          </div>
          <div class="movie-info">
            <div class="movie-title-db"><?= e($m['title']) ?></div>
            <div class="movie-meta"><?= e($m['genre']) ?> · <?= $m['duration_minutes'] ?> min · <?= e($m['rating']) ?></div>
          </div>
          <span class="movie-badge badge-playing">Playing</span>
        </div>
        <?php endforeach; else: ?>
        <div style="text-align:center;padding:24px;color:var(--text-muted);font-size:13px">No active showtimes today</div>
        <?php endif; ?>
      </div>
    </div>
  </div>

  <div class="panel">
    <div class="panel-header">
      <div class="panel-title">Today's Showtimes</div>
      <a class="panel-action" href="showtimes.php">view all →</a>
    </div>
    <div class="panel-body">
      <div class="db-st-grid">
        <?php if ($today_shows): foreach ($today_shows as $s): ?>
        <div class="db-st-row">
          <div class="show-time"><?= date('g:i A', strtotime($s['start_time'])) ?></div>
          <div>
            <div class="show-film"><?= e($s['title']) ?></div>
            <div class="show-screen"><?= e($s['screen_name']) ?></div>
          </div>
          <div style="font-size:12px;color:var(--accent);font-weight:500">₱<?= number_format($s['price'], 0) ?></div>
        </div>
        <?php endforeach; else: ?>
        <div style="text-align:center;padding:24px;color:var(--text-muted);font-size:13px">No showtimes scheduled today</div>
        <?php endif; ?>
      </div>
    </div>
  </div>
</div>

<div class="panel">
  <div class="panel-header">
    <div class="panel-title">Recent Bookings</div>
    <a class="panel-action" href="bookings.php">view all →</a>
  </div>
  <div style="overflow-x:auto">
    <table>
      <thead><tr><th>Booking ID</th><th>Customer</th><th>Movie</th><th>Amount</th><th>Status</th></tr></thead>
      <tbody>
        <?php if ($recent_bookings): foreach ($recent_bookings as $b): ?>
        <tr>
          <td class="td-mono"><?= e($b['booking_id']) ?></td>
          <td class="td-bold"><?= e($b['customer_name']) ?></td>
          <td><?= e($b['movie_title']) ?></td>
          <td style="color:var(--text);font-weight:500">₱<?= number_format($b['total_amount'], 2) ?></td>
          <td><?= pill($b['booking_status']) ?></td>
        </tr>
        <?php endforeach; else: ?>
        <tr><td colspan="5" style="text-align:center;padding:32px;color:var(--text-muted)">No bookings yet</td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
</div>
`;
</script>
<?php require_once '../includes/footer.php'; ?>
