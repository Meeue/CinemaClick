<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    if ($act === 'insert') {
        $id    = genId($conn,'showtimes','showtime_id','SHW');
        $mid   = $conn->real_escape_string($_POST['movie_id']   ?? '');
        $sid   = $conn->real_escape_string($_POST['screen_id']  ?? '');
        $date  = $conn->real_escape_string($_POST['show_date']  ?? date('Y-m-d'));
        $start = $conn->real_escape_string($_POST['start_time'] ?? '10:00');
        $end   = $conn->real_escape_string($_POST['end_time']   ?? '12:00');
        $price = (float)($_POST['price'] ?? 0);
        if ($mid && $sid) {
            if ($conn->query("INSERT INTO showtimes VALUES ('$id','$mid','$sid','$date','$start','$end',$price)"))
                { $flash="Showtime added."; $flash_type='success'; }
            else { $flash='Error: '.$conn->error; $flash_type='error'; }
        } else { $flash='Movie and screen required.'; $flash_type='error'; }
    }
    if ($act === 'update') {
        $id    = $conn->real_escape_string($_POST['showtime_id'] ?? '');
        $mid   = $conn->real_escape_string($_POST['movie_id']   ?? '');
        $sid   = $conn->real_escape_string($_POST['screen_id']  ?? '');
        $date  = $conn->real_escape_string($_POST['show_date']  ?? '');
        $start = $conn->real_escape_string($_POST['start_time'] ?? '');
        $end   = $conn->real_escape_string($_POST['end_time']   ?? '');
        $price = (float)($_POST['price'] ?? 0);
        if ($conn->query("UPDATE showtimes SET movie_id='$mid',screen_id='$sid',show_date='$date',start_time='$start',end_time='$end',price=$price WHERE showtime_id='$id'"))
            { $flash="Showtime updated."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['showtime_id'] ?? '');
        if ($conn->query("DELETE FROM showtimes WHERE showtime_id='$id'"))
            { $flash="Showtime deleted."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    $conn->close();

    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn    = getSlaveConn();
$q       = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$date_f  = $conn->real_escape_string($_GET['date_filter'] ?? '');
$cond    = [];
if ($q)      $cond[] = "(m.title LIKE '%$q%' OR ci.cinema_name LIKE '%$q%')";
if ($date_f === 'today')    $cond[] = "st.show_date = CURDATE()";
if ($date_f === 'upcoming') $cond[] = "st.show_date >= CURDATE()";
$where = $cond ? 'WHERE '.implode(' AND ',$cond) : '';
$rows = $conn->query(
    "SELECT st.*, m.title, sc.screen_name, ci.cinema_name
     FROM showtimes st
     JOIN movies  m  ON st.movie_id  = m.movie_id
     JOIN screens sc ON st.screen_id = sc.screen_id
     JOIN cinemas ci ON sc.cinema_id = ci.cinema_id
     $where ORDER BY st.show_date DESC, st.start_time"
)->fetch_all(MYSQLI_ASSOC);
$movies  = $conn->query("SELECT movie_id, title FROM movies ORDER BY title")->fetch_all(MYSQLI_ASSOC);
$screens = $conn->query(
    "SELECT s.screen_id, CONCAT(c.cinema_name,' — ',s.screen_name) AS label
     FROM screens s JOIN cinemas c ON s.cinema_id=c.cinema_id ORDER BY label"
)->fetch_all(MYSQLI_ASSOC);
$conn->close();

$movie_opts  = implode('', array_map(fn($m) => '<option value="'.e($m['movie_id']).'">'.e($m['title']).'</option>', $movies));
$screen_opts = implode('', array_map(fn($s) => '<option value="'.e($s['screen_id']).'">'.e($s['label']).'</option>', $screens));
require_once '../includes/header.php';
?>
<form id="delForm" method="POST" style="display:none"><input type="hidden" name="_action" value="delete"><input type="hidden" name="showtime_id" id="delId"></form>

<div class="modal-overlay" id="addModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Add Showtime</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
  <form method="POST" id="addForm"><input type="hidden" name="_action" value="insert">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Movie *</label><select class="form-select" name="movie_id"><?= $movie_opts ?></select></div>
    <div class="form-group full"><label class="form-label">Screen *</label><select class="form-select" name="screen_id"><?= $screen_opts ?></select></div>
    <div class="form-group"><label class="form-label">Show Date</label><input class="form-input" name="show_date" type="date" value="<?= date('Y-m-d') ?>"/></div>
    <div class="form-group"><label class="form-label">Price (₱)</label><input class="form-input" name="price" type="number" step="0.01" value="250.00"/></div>
    <div class="form-group"><label class="form-label">Start Time</label><input class="form-input" name="start_time" type="time" value="10:00"/></div>
    <div class="form-group"><label class="form-label">End Time</label><input class="form-input" name="end_time" type="time" value="12:00"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button class="btn btn-primary">Save Showtime</button></div>
  </form>
</div></div>

<div class="modal-overlay" id="editModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Edit Showtime</div><button class="modal-close" onclick="CM('editModal')">✕</button></div>
  <form method="POST" id="editForm"><input type="hidden" name="_action" value="update"><input type="hidden" name="showtime_id" id="e_id">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Movie *</label><select class="form-select" name="movie_id" id="e_mid"><?= $movie_opts ?></select></div>
    <div class="form-group full"><label class="form-label">Screen *</label><select class="form-select" name="screen_id" id="e_sid"><?= $screen_opts ?></select></div>
    <div class="form-group"><label class="form-label">Show Date</label><input class="form-input" name="show_date" id="e_date" type="date"/></div>
    <div class="form-group"><label class="form-label">Price (₱)</label><input class="form-input" name="price" id="e_price" type="number" step="0.01"/></div>
    <div class="form-group"><label class="form-label">Start Time</label><input class="form-input" name="start_time" id="e_start" type="time"/></div>
    <div class="form-group"><label class="form-label">End Time</label><input class="form-input" name="end_time" id="e_end" type="time"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('editModal')">Cancel</button><button class="btn btn-primary">Update Showtime</button></div>
  </form>
</div></div>

<script>
injectLayout({page:'showtimes',title:'Showtimes',sub:'Schedule management',actionLabel:'+ Add Showtime'});
document.getElementById('topbarAction').onclick=function(){ OM('addModal'); };
document.getElementById('pageContent').innerHTML=`
<div class="toolbar">
  <form method="GET" style="display:flex;gap:10px;flex:1;flex-wrap:wrap;align-items:center">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search showtimes…"/></div>
    <select class="filter-select" name="date_filter" onchange="this.form.submit()">
      <option value="">All Dates</option>
      <option value="today" <?= $date_f==='today'?'selected':'' ?>>Today</option>
      <option value="upcoming" <?= $date_f==='upcoming'?'selected':'' ?>>Upcoming</option>
    </select>
    <?php if($q||$date_f): ?><a href="showtimes.php" style="font-size:12px;color:var(--text-muted)">Clear</a><?php endif; ?>
  </form>
</div>
<div class="table-wrap"><table>
  <thead><tr><th>ID</th><th>Movie</th><th>Cinema</th><th>Screen</th><th>Date</th><th>Start</th><th>End</th><th>Price</th><th style="text-align:left">Actions</th></tr></thead>
  <tbody>
  <?php foreach($rows as $r): ?>
  <tr>
    <td class="td-mono"><?= e($r['showtime_id']) ?></td>
    <td class="td-bold"><?= e($r['title']) ?></td>
    <td><?= e($r['cinema_name']) ?></td>
    <td><?= e($r['screen_name']) ?></td>
    <td><?= e($r['show_date']) ?></td>
    <td><?= date('g:i A', strtotime($r['start_time'])) ?></td>
    <td><?= date('g:i A', strtotime($r['end_time'])) ?></td>
    <td style="color:var(--text);font-weight:500">₱<?= number_format($r['price'],2) ?></td>
    <td style="text-align:right"><div class="actions">
      <button class="btn btn-ghost btn-sm" onclick="openEdit(<?= htmlspecialchars(json_encode($r)) ?>)"><i class="fa-solid fa-pen-to-square" style="color: #7A7590;"></i></button>
      <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($r['showtime_id']) ?>','<?= e(addslashes($r['title'])) ?> on <?= e($r['show_date']) ?>')"><i class="fa-solid fa-trash-can" style="color: #ff4520;"></i></button>
    </div></td>
  </tr>
  <?php endforeach; if(!$rows): ?>
  <tr><td colspan="9" style="text-align:center;padding:40px;color:var(--text-muted)">No showtimes found.</td></tr>
  <?php endif; ?>
  </tbody>
</table>
<div class="table-footer"><div class="table-count"><?= count($rows) ?> records</div></div>
</div>
`;

ajaxForm(document.getElementById('addForm'),  { closeModal: 'addModal'  });
ajaxForm(document.getElementById('editForm'), { closeModal: 'editModal' });

function openEdit(r){
  document.getElementById('e_id').value    = r.showtime_id;
  document.getElementById('e_mid').value   = r.movie_id;
  document.getElementById('e_sid').value   = r.screen_id;
  document.getElementById('e_date').value  = r.show_date;
  document.getElementById('e_price').value = r.price;
  document.getElementById('e_start').value = r.start_time ? r.start_time.substring(0,5) : '';
  document.getElementById('e_end').value   = r.end_time   ? r.end_time.substring(0,5)   : '';
  OM('editModal');
}
function doDelete(id, name){
  document.getElementById('delId').value = id;
  ajaxDelete(document.getElementById('delForm'), 'Delete Showtime', '"'+name+'"');
}
</script>
<?php require_once '../includes/footer.php'; ?>