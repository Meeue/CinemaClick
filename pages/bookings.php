<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    if ($act === 'insert') {
        $id    = genId($conn,'bookings','booking_id','BKG');
        $cid   = $conn->real_escape_string($_POST['customer_id']    ?? '');
        $stid  = $conn->real_escape_string($_POST['showtime_id']    ?? '');
        $cname = $conn->real_escape_string(trim($_POST['customer_name']  ?? ''));
        $bdate = $conn->real_escape_string($_POST['booking_date']   ?? date('Y-m-d'));
        $amt   = (float)($_POST['total_amount'] ?? 0);
        $stat  = $conn->real_escape_string($_POST['booking_status'] ?? 'Pending');
        if ($cid && $stid && $cname) {
            if ($conn->query("INSERT INTO bookings VALUES ('$id','$cid','$stid','$cname','$bdate',$amt,'$stat')"))
                { $flash="Booking $id created."; $flash_type='success'; }
            else { $flash='Error: '.$conn->error; $flash_type='error'; }
        } else { $flash='Customer, showtime and name required.'; $flash_type='error'; }
    }
    if ($act === 'update') {
        $id    = $conn->real_escape_string($_POST['booking_id']     ?? '');
        $cname = $conn->real_escape_string(trim($_POST['customer_name']  ?? ''));
        $amt   = (float)($_POST['total_amount'] ?? 0);
        $stat  = $conn->real_escape_string($_POST['booking_status'] ?? 'Pending');
        if ($conn->query("UPDATE bookings SET customer_name='$cname',total_amount=$amt,booking_status='$stat' WHERE booking_id='$id'"))
            { $flash="Booking updated."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['booking_id'] ?? '');
        if ($conn->query("DELETE FROM bookings WHERE booking_id='$id'"))
            { $flash="Booking deleted."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    $conn->close();

    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn = getSlaveConn();
$q    = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$sf   = $conn->real_escape_string($_GET['status'] ?? '');
$cond = [];
if ($q)  $cond[] = "(b.customer_name LIKE '%$q%' OR b.booking_id LIKE '%$q%' OR m.title LIKE '%$q%')";
if ($sf) $cond[] = "b.booking_status='$sf'";
$where = $cond ? 'WHERE '.implode(' AND ',$cond) : '';
$rows  = $conn->query(
    "SELECT b.*, m.title AS movie_title, ci.cinema_name, st.show_date AS show_dt, st.start_time, st.price AS unit_price
     FROM bookings b
     JOIN showtimes st ON b.showtime_id = st.showtime_id
     JOIN movies    m  ON st.movie_id   = m.movie_id
     JOIN screens   sc ON st.screen_id  = sc.screen_id
     JOIN cinemas   ci ON sc.cinema_id  = ci.cinema_id
     $where ORDER BY b.booking_date DESC"
)->fetch_all(MYSQLI_ASSOC);
$customers = $conn->query("SELECT customer_id,CONCAT(first_name,' ',last_name) AS name FROM customers WHERE status='Active' ORDER BY first_name")->fetch_all(MYSQLI_ASSOC);
$showtimes = $conn->query("SELECT st.showtime_id,CONCAT(m.title,' | ',st.show_date,' ',st.start_time,' | ₱',st.price) AS label,st.price FROM showtimes st JOIN movies m ON st.movie_id=m.movie_id WHERE st.show_date>=CURDATE() ORDER BY st.show_date,st.start_time")->fetch_all(MYSQLI_ASSOC);
$conn->close();

$cust_opts = implode('', array_map(fn($c) => '<option value="'.e($c['customer_id']).'">'.e($c['name']).'</option>', $customers));
$show_opts = implode('', array_map(fn($s) => '<option value="'.e($s['showtime_id']).'" data-price="'.e($s['price']).'">'.e($s['label']).'</option>', $showtimes));
require_once '../includes/header.php';
?>
<form id="delForm" method="POST" style="display:none"><input type="hidden" name="_action" value="delete"><input type="hidden" name="booking_id" id="delId"></form>

<div class="modal-overlay" id="addModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Add Booking</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
  <form method="POST" id="addForm"><input type="hidden" name="_action" value="insert">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Customer *</label><select class="form-select" name="customer_id" id="a_cust" onchange="fillName(this)"><?= $cust_opts ?></select></div>
    <div class="form-group full"><label class="form-label">Showtime *</label><select class="form-select" name="showtime_id" onchange="fillPrice(this)"><?= $show_opts ?></select></div>
    <div class="form-group full"><label class="form-label">Customer Name *</label><input class="form-input" name="customer_name" id="a_cname" required/></div>
    <div class="form-group"><label class="form-label">Booking Date</label><input class="form-input" name="booking_date" type="date" value="<?= date('Y-m-d') ?>"/></div>
    <div class="form-group"><label class="form-label">Total Amount (₱)</label><input class="form-input" name="total_amount" id="a_amt" type="number" step="0.01" value="0"/></div>
    <div class="form-group full"><label class="form-label">Status</label><select class="form-select" name="booking_status"><option>Pending</option><option>Confirmed</option><option>Cancelled</option></select></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button class="btn btn-primary">Save Booking</button></div>
  </form>
</div></div>

<div class="modal-overlay" id="editModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Edit Booking</div><button class="modal-close" onclick="CM('editModal')">✕</button></div>
  <form method="POST" id="editForm"><input type="hidden" name="_action" value="update"><input type="hidden" name="booking_id" id="e_id">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Customer Name</label><input class="form-input" name="customer_name" id="e_cname"/></div>
    <div class="form-group"><label class="form-label">Total Amount (₱)</label><input class="form-input" name="total_amount" id="e_amt" type="number" step="0.01"/></div>
    <div class="form-group"><label class="form-label">Status</label><select class="form-select" name="booking_status" id="e_stat"><option>Pending</option><option>Confirmed</option><option>Cancelled</option></select></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('editModal')">Cancel</button><button class="btn btn-primary">Update Booking</button></div>
  </form>
</div></div>

<script>
injectLayout({page:'bookings',title:'Bookings',sub:'Booking records',actionLabel:'+ Add Booking'});
document.getElementById('topbarAction').onclick=function(){ OM('addModal'); };
document.getElementById('pageContent').innerHTML=`
<div class="toolbar">
  <form method="GET" style="display:flex;gap:10px;flex:1;flex-wrap:wrap;align-items:center">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search bookings…"/></div>
    <select class="filter-select" name="status" onchange="this.form.submit()">
      <option value="">All Status</option>
      <?php foreach(['Confirmed','Pending','Cancelled'] as $s): ?>
      <option value="<?= $s ?>" <?= $sf===$s?'selected':'' ?>><?= $s ?></option>
      <?php endforeach; ?>
    </select>
    <?php if($q||$sf): ?><a href="bookings.php" style="font-size:12px;color:var(--text-muted)">Clear</a><?php endif; ?>
  </form>
</div>
<div class="table-wrap"><table>
  <thead><tr><th>ID</th><th>Customer</th><th>Movie</th><th>Cinema</th><th>Show Date</th><th>Amount</th><th>Status</th><th>Booked</th><th style="text-align:center">Actions</th></tr></thead>
  <tbody>
  <?php foreach($rows as $r): ?>
  <tr>
    <td class="td-mono"><?= e($r['booking_id']) ?></td>
    <td class="td-bold"><?= e($r['customer_name']) ?></td>
    <td><?= e($r['movie_title']) ?></td>
    <td><?= e($r['cinema_name']) ?></td>
    <td><?= e($r['show_dt']) ?></td>
    <td style="color:var(--text);font-weight:500">₱<?= number_format($r['total_amount'],2) ?></td>
    <td><?= pill($r['booking_status']) ?></td>
    <td class="td-muted"><?= e($r['booking_date']) ?></td>
    <td style="text-align:right"><div class="actions">
      <button class="btn btn-ghost btn-sm" onclick="openEdit(<?= htmlspecialchars(json_encode($r)) ?>)"><i class="fa-solid fa-pen-to-square" style="color: #7A7590;"></i></button>
      <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($r['booking_id']) ?>','<?= e($r['booking_id']) ?>')"><i class="fa-solid fa-trash-can" style="color: #ff4520;"></i></button>
    </div></td>
  </tr>
  <?php endforeach; if(!$rows): ?>
  <tr><td colspan="9" style="text-align:center;padding:40px;color:var(--text-muted)">No bookings found.</td></tr>
  <?php endif; ?>
  </tbody>
</table>
<div class="table-footer"><div class="table-count"><?= count($rows) ?> records</div></div>
</div>
`;

ajaxForm(document.getElementById('addForm'),  { closeModal: 'addModal'  });
ajaxForm(document.getElementById('editForm'), { closeModal: 'editModal' });

function fillPrice(sel){ var p=sel.options[sel.selectedIndex]?.dataset?.price; if(p) document.getElementById('a_amt').value=p; }
function fillName(sel){ var t=sel.options[sel.selectedIndex]?.text; if(t) document.getElementById('a_cname').value=t; }
function openEdit(r){
  document.getElementById('e_id').value    = r.booking_id;
  document.getElementById('e_cname').value = r.customer_name;
  document.getElementById('e_amt').value   = r.total_amount;
  document.getElementById('e_stat').value  = r.booking_status;
  OM('editModal');
}
function doDelete(id, name){
  document.getElementById('delId').value = id;
  ajaxDelete(document.getElementById('delForm'), 'Delete Booking', 'Booking #'+name);
}
</script>
<?php require_once '../includes/footer.php'; ?>