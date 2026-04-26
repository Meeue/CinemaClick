<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    if ($act === 'update_status') {
        $id   = $conn->real_escape_string($_POST['seat_id'] ?? '');
        $stat = $conn->real_escape_string($_POST['status']  ?? 'Available');
        if ($conn->query("UPDATE seats SET status='$stat' WHERE seat_id='$id'"))
            { $flash="Seat updated."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    $conn->close();
}

$conn    = getSlaveConn();
$screens = $conn->query(
    "SELECT s.screen_id, s.screen_name, s.total_seats, c.cinema_name
     FROM screens s JOIN cinemas c ON s.cinema_id=c.cinema_id ORDER BY c.cinema_name, s.screen_name"
)->fetch_all(MYSQLI_ASSOC);

$active_screen = $_GET['screen'] ?? ($screens[0]['screen_id'] ?? '');
$seats = [];
$screen_info = null;
if ($active_screen) {
    $sid = $conn->real_escape_string($active_screen);
    $screen_info = $conn->query("SELECT s.*,c.cinema_name FROM screens s JOIN cinemas c ON s.cinema_id=c.cinema_id WHERE s.screen_id='$sid'")->fetch_assoc();
    $seats = $conn->query("SELECT * FROM seats WHERE screen_id='$sid' ORDER BY seat_number")->fetch_all(MYSQLI_ASSOC);
}

$seat_counts = [];
foreach ($screens as $sc) {
    $sid2 = $conn->real_escape_string($sc['screen_id']);
    $r = $conn->query("SELECT status, COUNT(*) AS cnt FROM seats WHERE screen_id='$sid2' GROUP BY status");
    $seat_counts[$sc['screen_id']] = ['Available'=>0,'Taken'=>0,'Maintenance'=>0];
    while ($row = $r->fetch_assoc()) $seat_counts[$sc['screen_id']][$row['status']] = $row['cnt'];
}
$conn->close();

// Build seat grid — split into rows of ~10
$seat_rows = array_chunk($seats, 10);
require_once '../includes/header.php';
?>

<!-- Edit Seat Modal -->
<div class="modal-overlay" id="seatModal">
  <div class="modal" style="max-width:360px">
    <div class="modal-header"><div class="modal-title">Edit Seat</div><button class="modal-close" onclick="CM('seatModal')">✕</button></div>
    <form method="POST"><input type="hidden" name="_action" value="update_status"><input type="hidden" name="seat_id" id="s_id">
    <div class="modal-body"><div class="form-grid">
      <div class="form-group"><label class="form-label">Seat ID</label><input class="form-input" id="s_sid" disabled style="opacity:.4"/></div>
      <div class="form-group"><label class="form-label">Seat Number</label><input class="form-input" id="s_num" disabled style="opacity:.4"/></div>
      <div class="form-group full"><label class="form-label">Status *</label>
        <select class="form-select" name="status" id="s_stat">
          <option>Available</option><option>Taken</option><option>Maintenance</option>
        </select>
      </div>
    </div></div>
    <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('seatModal')">Cancel</button><button class="btn btn-primary">Save Seat</button></div>
    </form>
  </div>
</div>

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
    <?php if ($seats): ?>
    <div class="vis-rows">
      <?php foreach($seat_rows as $ri => $row): ?>
      <div class="vis-row">
        <div class="vis-rl"><?= chr(65+$ri) ?></div>
        <?php foreach($row as $i => $s):
          $cls = ['Available'=>'va','Taken'=>'vt','Maintenance'=>'vv'][$s['status']] ?? 'va';
          $title = e($s['seat_number']).' — '.$s['status'];
        ?>
        <?php if ($i === 5): ?><div class="vis-gap"></div><?php endif; ?>
        <div class="vs <?= $cls ?>" title="<?= $title ?>" style="cursor:pointer"
          onclick="openSeatEdit('<?= e($s['seat_id']) ?>','<?= e($s['seat_number']) ?>','<?= e($s['status']) ?>')"></div>
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
      <button class="btn btn-ghost btn-sm" onclick="openSeatEdit('<?= e($s['seat_id']) ?>','<?= e($s['seat_number']) ?>','<?= e($s['status']) ?>')">Edit Status</button>
    </td>
  </tr>
  <?php endforeach; ?>
  </tbody>
</table>
<div class="table-footer"><div class="table-count"><?= count($seats) ?> seats</div></div>
</div>
<?php endif; ?>

<?= flashMsg($flash,$flash_type) ?>
`;

function openSeatEdit(id, num, status){
  document.getElementById('s_id').value   = id;
  document.getElementById('s_sid').value  = id;
  document.getElementById('s_num').value  = num;
  document.getElementById('s_stat').value = status;
  OM('seatModal');
}
</script>
<?php require_once '../includes/footer.php'; ?>
