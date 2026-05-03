<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    // Edit status removed
    $conn->close();

    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn    = getSlaveConn();
$screens = $conn->query(
    "SELECT s.screen_id, s.screen_name, s.total_seats, c.cinema_name
     FROM screens s JOIN cinemas c ON s.cinema_id=c.cinema_id ORDER BY c.cinema_name, s.screen_name"
)->fetch_all(MYSQLI_ASSOC);

$active_screen = $_GET['screen']   ?? ($screens[0]['screen_id'] ?? '');
$seat_q        = trim($_GET['sq']  ?? '');
$status_f      = $_GET['status_f'] ?? '';
$all_seats   = []; // unfiltered — used for the visual layout
$seats       = []; // filtered   — used for the table below
$screen_info = null;
if ($active_screen) {
    $sid     = $conn->real_escape_string($active_screen);
    $sq_safe = $conn->real_escape_string($seat_q);
    $sf_safe = $conn->real_escape_string($status_f);
    $screen_info = $conn->query("SELECT s.*,c.cinema_name FROM screens s JOIN cinemas c ON s.cinema_id=c.cinema_id WHERE s.screen_id='$sid'")->fetch_assoc();
    // Always load ALL seats for the visual layout
    $all_seats = $conn->query("SELECT * FROM seats WHERE screen_id='$sid' ORDER BY seat_number")->fetch_all(MYSQLI_ASSOC);
    // Apply filters only for the table
    $scond = ["screen_id='$sid'"];
    if ($sq_safe) $scond[] = "seat_number LIKE '%$sq_safe%'";
    if ($sf_safe) $scond[] = "status='$sf_safe'";
    $swhere = 'WHERE '.implode(' AND ', $scond);
    $seats = $conn->query("SELECT * FROM seats $swhere ORDER BY seat_number")->fetch_all(MYSQLI_ASSOC);
}

$seat_counts = [];
foreach ($screens as $sc) {
    $sid2 = $conn->real_escape_string($sc['screen_id']);
    $r = $conn->query("SELECT status, COUNT(*) AS cnt FROM seats WHERE screen_id='$sid2' GROUP BY status");
    $seat_counts[$sc['screen_id']] = ['Available'=>0,'Taken'=>0,'Maintenance'=>0];
    while ($row = $r->fetch_assoc()) $seat_counts[$sc['screen_id']][$row['status']] = $row['cnt'];
}
$conn->close();

$seat_rows = array_chunk($all_seats, 10); // layout always uses unfiltered
require_once '../includes/header.php';
?>

<script>
injectLayout({page:'seats',title:'Seats',sub:'Seat layout & availability'});
document.getElementById('pageContent').innerHTML=`
<div class="seats-top">
  <div class="screen-picker">
    <div class="panel-header"><div class="panel-title">Select Screen</div></div>
    <?php foreach($screens as $sc):
      $counts = $seat_counts[$sc['screen_id']] ?? [];
      $avail  = $counts['Available'] ?? 0;
      $taken  = $counts['Taken']     ?? 0;
      $maint  = $counts['Maintenance']??0;
      $isActive = $sc['screen_id'] === $active_screen;
    ?>
    <a href="seats.php?screen=<?= e($sc['screen_id']) ?>" class="screen-list-item <?= $isActive?'active-screen':'' ?>" style="text-decoration:none">
      <div>
        <div class="sl-name"><?= e($sc['screen_name']) ?></div>
        <div class="sl-meta"><?= e($sc['cinema_name']) ?></div>
      </div>
      <div style="text-align:right">
        <div class="sl-count"><?= $sc['total_seats'] ?> seats</div>
        <div style="font-size:10px;color:var(--success);margin-top:2px"><?= $avail ?> free</div>
      </div>
    </a>
    <?php endforeach; ?>
  </div>

  <div class="seat-visual-panel">
    <?php if ($screen_info): ?>
    <div class="svp-title">
      <span><?= e($screen_info['screen_name']) ?> — <?= e($screen_info['cinema_name']) ?></span>
      <span style="font-size:11px;color:var(--text-muted)"><?= e($screen_info['total_seats']) ?> total seats</span>
    </div>
    <div class="big-screen-bar">◀ SCREEN ▶</div>
    <?php if ($all_seats): ?>
    <div class="vis-rows">
      <?php foreach($seat_rows as $ri => $row): ?>
      <div class="vis-row">
        <div class="vis-rl"><?= chr(65+$ri) ?></div>
        <?php foreach($row as $i => $s):
          $cls = ['Available'=>'va','Taken'=>'vt','Maintenance'=>'vv'][$s['status']] ?? 'va';
          $title = e($s['seat_number']).' — '.$s['status'];
        ?>
        <?php if ($i === 5): ?><div class="vis-gap"></div><?php endif; ?>
        <div class="vs <?= $cls ?>" title="<?= $title ?>"></div>
        <?php endforeach; ?>
      </div>
      <?php endforeach; ?>
    </div>
    <div class="vis-legend">
      <div class="legend-item"><div class="legend-dot" style="background:var(--success-dim);border:.5px solid var(--success)"></div>Available</div>
      <div class="legend-item"><div class="legend-dot" style="background:var(--danger-dim);border:.5px solid var(--danger)"></div>Taken</div>
      <div class="legend-item"><div class="legend-dot" style="background:var(--warning-dim);border:.5px solid var(--warning)"></div>Maintenance</div>
    </div>
    <?php else: ?>
    <div style="text-align:center;padding:40px;color:var(--text-muted);font-size:13px">
      No seats configured for this screen.<br>
      <small style="font-size:11px">Seats are auto-generated when a screen is added via the database setup SQL.</small>
    </div>
    <?php endif; ?>

    <?php else: ?>
    <div style="text-align:center;padding:40px;color:var(--text-muted)">Select a screen to view seats.</div>
    <?php endif; ?>
  </div>
</div>

<?php if ($screen_info): ?>
<div class="toolbar" style="margin-top:16px">
  <form method="GET" style="display:flex;gap:10px;flex:1;flex-wrap:wrap;align-items:center">
    <input type="hidden" name="screen" value="<?= e($active_screen) ?>"/>
    <div class="search-box">
      <span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span>
      <input type="text" name="sq" value="<?= e($seat_q) ?>" placeholder="Search seat number…"/>
    </div>
    <select class="filter-select" name="status_f" onchange="this.form.submit()">
      <option value="">All Status</option>
      <option value="Available"   <?= $status_f==='Available'   ?'selected':'' ?>>Available</option>
      <option value="Taken"       <?= $status_f==='Taken'       ?'selected':'' ?>>Taken</option>
      <option value="Maintenance" <?= $status_f==='Maintenance' ?'selected':'' ?>>Maintenance</option>
    </select>
    <button class="btn btn-ghost btn-sm" type="submit">Search</button>
    <?php if ($seat_q || $status_f): ?>
      <a href="seats.php?screen=<?= e($active_screen) ?>" style="font-size:12px;color:var(--text-muted);align-self:center">Clear</a>
    <?php endif; ?>
  </form>
</div>
<?php endif; ?>

<?php if ($seats): ?>
<div class="table-wrap"><table>
  <thead><tr><th>Seat ID</th><th>Seat Number</th><th>Type</th><th>Status</th><th style="text-align:right">Actions</th></tr></thead>
  <tbody>
  <?php foreach($seats as $s): ?>
  <tr>
    <td class="td-mono"><?= e($s['seat_id']) ?></td>
    <td class="td-bold"><?= e($s['seat_number']) ?></td>
    <td><?= e($s['seat_type']) ?></td>
    <td><?= pill($s['status']) ?></td>
    <td style="text-align:right">
      <!-- Edit status removed -->
    </td>
  </tr>
  <?php endforeach; ?>
  </tbody>
</table>
<div class="table-footer"><div class="table-count"><?= count($seats) ?> seat<?= count($seats)!==1?'s':'' ?><?= ($seat_q||$status_f) ? ' found' : '' ?></div></div>
</div>
<?php endif; ?>
`;

// Edit status functionality removed
</script>
<?php require_once '../includes/footer.php'; ?>