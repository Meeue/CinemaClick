<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    if ($act === 'insert') {
        $id    = genId($conn,'payments','payment_id','PAY');
        $bid   = $conn->real_escape_string($_POST['booking_id']     ?? '');
        $pdate = $conn->real_escape_string($_POST['payment_date']   ?? date('Y-m-d'));
        $meth  = $conn->real_escape_string($_POST['payment_method'] ?? 'Cash');
        $stat  = $conn->real_escape_string($_POST['payment_status'] ?? 'Pending');
        $amt   = (float)($_POST['amount'] ?? 0);
        if ($bid && $amt > 0) {
            if ($conn->query("INSERT INTO payments VALUES ('$id','$bid','$pdate','$meth','$stat',$amt)")) {
                if ($stat === 'Paid') $conn->query("UPDATE bookings SET booking_status='Confirmed' WHERE booking_id='$bid'");
                $flash="Payment $id recorded."; $flash_type='success';
            } else { $flash='Error: '.$conn->error; $flash_type='error'; }
        } else { $flash='Booking and amount required.'; $flash_type='error'; }
    }
    if ($act === 'update') {
        $id    = $conn->real_escape_string($_POST['payment_id']     ?? '');
        $pdate = $conn->real_escape_string($_POST['payment_date']   ?? '');
        $meth  = $conn->real_escape_string($_POST['payment_method'] ?? 'Cash');
        $stat  = $conn->real_escape_string($_POST['payment_status'] ?? 'Pending');
        $amt   = (float)($_POST['amount'] ?? 0);
        if ($conn->query("UPDATE payments SET payment_date='$pdate',payment_method='$meth',payment_status='$stat',amount=$amt WHERE payment_id='$id'")) {
            $p = $conn->query("SELECT booking_id FROM payments WHERE payment_id='$id'")->fetch_assoc();
            if ($p) {
                if ($stat==='Paid')     $conn->query("UPDATE bookings SET booking_status='Confirmed' WHERE booking_id='{$p['booking_id']}'");
                if ($stat==='Refunded') $conn->query("UPDATE bookings SET booking_status='Cancelled' WHERE booking_id='{$p['booking_id']}'");
            }
            $flash="Payment updated."; $flash_type='success';
        } else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['payment_id'] ?? '');
        if ($conn->query("DELETE FROM payments WHERE payment_id='$id'"))
            { $flash="Payment deleted."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    $conn->close();

    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn  = getSlaveConn();
$q     = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$sf    = $conn->real_escape_string($_GET['status'] ?? '');
$cond  = [];
if ($q)  $cond[] = "(p.payment_id LIKE '%$q%' OR b.customer_name LIKE '%$q%' OR p.payment_method LIKE '%$q%')";
if ($sf) $cond[] = "p.payment_status='$sf'";
$where = $cond ? 'WHERE '.implode(' AND ',$cond) : '';
$rows  = $conn->query(
    "SELECT p.*, b.customer_name, m.title AS movie_title
     FROM payments p
     JOIN bookings  b  ON p.booking_id  = b.booking_id
     JOIN showtimes st ON b.showtime_id = st.showtime_id
     JOIN movies    m  ON st.movie_id   = m.movie_id
     $where ORDER BY p.payment_date DESC"
)->fetch_all(MYSQLI_ASSOC);
$bookings = $conn->query(
    "SELECT b.booking_id, CONCAT(b.booking_id,' — ',b.customer_name,' — ₱',b.total_amount) AS label, b.total_amount
     FROM bookings b WHERE b.booking_status!='Cancelled' ORDER BY b.booking_date DESC"
)->fetch_all(MYSQLI_ASSOC);
$conn->close();

$methods  = ['Cash','GCash','Maya','Credit Card','Debit Card'];
$statuses = ['Pending','Paid','Failed','Refunded'];
$bk_opts  = implode('', array_map(fn($b) => '<option value="'.e($b['booking_id']).'" data-amt="'.e($b['total_amount']).'">'.e($b['label']).'</option>', $bookings));
require_once '../includes/header.php';
?>
<form id="delForm" method="POST" style="display:none"><input type="hidden" name="_action" value="delete"><input type="hidden" name="payment_id" id="delId"></form>

<div class="modal-overlay" id="addModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Add Payment</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
  <form method="POST" id="addForm"><input type="hidden" name="_action" value="insert">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Booking *</label><select class="form-select" name="booking_id" onchange="document.getElementById('a_amt').value=this.options[this.selectedIndex].dataset.amt"><?= $bk_opts ?></select></div>
    <div class="form-group"><label class="form-label">Payment Date</label><input class="form-input" name="payment_date" type="date" value="<?= date('Y-m-d') ?>"/></div>
    <div class="form-group"><label class="form-label">Amount (₱)</label><input class="form-input" name="amount" id="a_amt" type="number" step="0.01" value="0"/></div>
    <div class="form-group"><label class="form-label">Method</label><select class="form-select" name="payment_method"><?php foreach($methods as $m): ?><option><?= $m ?></option><?php endforeach; ?></select></div>
    <div class="form-group"><label class="form-label">Status</label><select class="form-select" name="payment_status"><?php foreach($statuses as $s): ?><option><?= $s ?></option><?php endforeach; ?></select></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button class="btn btn-primary">Save Payment</button></div>
  </form>
</div></div>

<div class="modal-overlay" id="editModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Edit Payment</div><button class="modal-close" onclick="CM('editModal')">✕</button></div>
  <form method="POST" id="editForm"><input type="hidden" name="_action" value="update"><input type="hidden" name="payment_id" id="e_id">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group"><label class="form-label">Payment Date</label><input class="form-input" name="payment_date" id="e_date" type="date"/></div>
    <div class="form-group"><label class="form-label">Amount (₱)</label><input class="form-input" name="amount" id="e_amt" type="number" step="0.01"/></div>
    <div class="form-group"><label class="form-label">Method</label><select class="form-select" name="payment_method" id="e_meth"><?php foreach($methods as $m): ?><option><?= $m ?></option><?php endforeach; ?></select></div>
    <div class="form-group"><label class="form-label">Status</label><select class="form-select" name="payment_status" id="e_stat"><?php foreach($statuses as $s): ?><option><?= $s ?></option><?php endforeach; ?></select></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('editModal')">Cancel</button><button class="btn btn-primary">Update Payment</button></div>
  </form>
</div></div>

<script>
injectLayout({page:'payments',title:'Payments',sub:'Payment transactions',actionLabel:'+ Add Payment'});
document.getElementById('topbarAction').onclick=function(){ OM('addModal'); };
document.getElementById('pageContent').innerHTML=`
<div class="toolbar">
  <form method="GET" style="display:flex;gap:10px;flex:1;flex-wrap:wrap;align-items:center">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search payments…"/></div>
    <select class="filter-select" name="status" onchange="this.form.submit()">
      <option value="">All Status</option>
      <?php foreach($statuses as $s): ?><option value="<?= $s ?>" <?= $sf===$s?'selected':'' ?>><?= $s ?></option><?php endforeach; ?>
    </select>
    <?php if($q||$sf): ?><a href="payments.php" style="font-size:12px;color:var(--text-muted)">Clear</a><?php endif; ?>
  </form>
</div>
<div class="table-wrap"><table>
  <thead><tr><th>ID</th><th>Booking</th><th>Customer</th><th>Movie</th><th>Method</th><th>Amount</th><th>Status</th><th>Date</th><th style="text-align:left">Actions</th></tr></thead>
  <tbody>
  <?php foreach($rows as $r): ?>
  <tr>
    <td class="td-mono"><?= e($r['payment_id']) ?></td>
    <td class="td-mono"><?= e($r['booking_id']) ?></td>
    <td class="td-bold"><?= e($r['customer_name']) ?></td>
    <td><?= e($r['movie_title']) ?></td>
    <td><?= e($r['payment_method']) ?></td>
    <td style="color:var(--text);font-weight:500">₱<?= number_format($r['amount'],2) ?></td>
    <td><?= pill($r['payment_status']) ?></td>
    <td class="td-muted"><?= e($r['payment_date']) ?></td>
    <td style="text-align:right"><div class="actions">
      <button class="btn btn-ghost btn-sm" onclick="openEdit(<?= htmlspecialchars(json_encode($r)) ?>)"><i class="fa-solid fa-pen-to-square" style="color: #7A7590;"></i></button>
      <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($r['payment_id']) ?>','<?= e($r['payment_id']) ?>')"><i class="fa-solid fa-trash-can" style="color: #ff4520;"></i></button>
    </div></td>
  </tr>
  <?php endforeach; if(!$rows): ?>
  <tr><td colspan="9" style="text-align:center;padding:40px;color:var(--text-muted)">No payments found.</td></tr>
  <?php endif; ?>
  </tbody>
</table>
<div class="table-footer"><div class="table-count"><?= count($rows) ?> records</div></div>
</div>
`;

ajaxForm(document.getElementById('addForm'),  { closeModal: 'addModal'  });
ajaxForm(document.getElementById('editForm'), { closeModal: 'editModal' });

function openEdit(r){
  document.getElementById('e_id').value   = r.payment_id;
  document.getElementById('e_date').value = r.payment_date;
  document.getElementById('e_amt').value  = r.amount;
  document.getElementById('e_meth').value = r.payment_method;
  document.getElementById('e_stat').value = r.payment_status;
  OM('editModal');
}
function doDelete(id, name){
  document.getElementById('delId').value = id;
  ajaxDelete(document.getElementById('delForm'), 'Delete Payment', 'Payment #'+name);
}
</script>
<?php require_once '../includes/footer.php'; ?>