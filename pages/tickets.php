<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    if ($act === 'insert') {
        $id    = genId($conn,'tickets','ticket_id','TKT',4);
        $bid   = $conn->real_escape_string($_POST['booking_id']   ?? '');
        $sid   = $conn->real_escape_string($_POST['seat_id']      ?? '');
        $price = (float)($_POST['ticket_price'] ?? 0);
        if ($bid && $sid) {
            if ($conn->query("INSERT INTO tickets (ticket_id,booking_id,seat_id,ticket_price) VALUES ('$id','$bid','$sid',$price)"))
                { $flash="Ticket $id issued."; $flash_type='success'; }
            else { $flash='Error: '.$conn->error; $flash_type='error'; }
        } else { $flash='Booking and seat required.'; $flash_type='error'; }
    }
    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['ticket_id'] ?? '');
        if ($conn->query("DELETE FROM tickets WHERE ticket_id='$id'"))
            { $flash="Ticket deleted."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    $conn->close();

    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn     = getSlaveConn();
$q        = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$where    = $q ? "WHERE (t.ticket_id LIKE '%$q%' OR b.customer_name LIKE '%$q%' OR s.seat_number LIKE '%$q%')" : '';
$rows     = $conn->query(
    "SELECT t.*, b.customer_name, s.seat_number, m.title AS movie_title,
            st.show_date, ci.cinema_name
     FROM tickets t
     JOIN bookings  b  ON t.booking_id  = b.booking_id
     JOIN seats     s  ON t.seat_id     = s.seat_id
     JOIN showtimes st ON b.showtime_id = st.showtime_id
     JOIN movies    m  ON st.movie_id   = m.movie_id
     JOIN screens   sc ON st.screen_id  = sc.screen_id
     JOIN cinemas   ci ON sc.cinema_id  = ci.cinema_id
     $where ORDER BY t.issued_at DESC"
)->fetch_all(MYSQLI_ASSOC);

$bookings = $conn->query(
    "SELECT b.booking_id, CONCAT(b.booking_id,' — ',b.customer_name) AS label, st.price
     FROM bookings b JOIN showtimes st ON b.showtime_id=st.showtime_id
     WHERE b.booking_status != 'Cancelled' ORDER BY b.booking_date DESC"
)->fetch_all(MYSQLI_ASSOC);
$seats_avail = $conn->query(
    "SELECT s.seat_id, CONCAT(sc.screen_name,' — Seat ',s.seat_number) AS label
     FROM seats s JOIN screens sc ON s.screen_id=sc.screen_id
     WHERE s.status='Available' ORDER BY sc.screen_name, s.seat_number LIMIT 200"
)->fetch_all(MYSQLI_ASSOC);

$total_tickets = count($rows);
$total_revenue = array_sum(array_column($rows,'ticket_price'));
$conn->close();

$bk_opts   = implode('', array_map(fn($b) => '<option value="'.e($b['booking_id']).'" data-price="'.e($b['price']).'">'.e($b['label']).'</option>', $bookings));
$seat_opts = implode('', array_map(fn($s) => '<option value="'.e($s['seat_id']).'">'.e($s['label']).'</option>', $seats_avail));
require_once '../includes/header.php';
?>
<form id="delForm" method="POST" style="display:none"><input type="hidden" name="_action" value="delete"><input type="hidden" name="ticket_id" id="delId"></form>

<div class="modal-overlay" id="addModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Issue Ticket</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
  <form method="POST" id="addForm"><input type="hidden" name="_action" value="insert">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Booking *</label><select class="form-select" name="booking_id" onchange="document.getElementById('a_price').value=this.options[this.selectedIndex].dataset.price||0"><?= $bk_opts ?></select></div>
    <div class="form-group full"><label class="form-label">Seat *</label><select class="form-select" name="seat_id"><?= $seat_opts ?></select></div>
    <div class="form-group full"><label class="form-label">Ticket Price (₱)</label><input class="form-input" name="ticket_price" id="a_price" type="number" step="0.01" value="0"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button class="btn btn-primary">Issue Ticket</button></div>
  </form>
</div></div>

<script>
injectLayout({page:'tickets',title:'Tickets',sub:'Issued tickets',actionLabel:'+ Issue Ticket'});
document.getElementById('topbarAction').onclick=function(){ OM('addModal'); };
document.getElementById('pageContent').innerHTML=`

<div class="toolbar">
  <form method="GET" style="display:flex;gap:10px;flex:1">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search tickets, customer, seat…"/></div>
    <button class="btn btn-ghost btn-sm">Search</button>
    <?php if($q): ?><a href="tickets.php" style="font-size:12px;color:var(--text-muted);align-self:center">Clear</a><?php endif; ?>
  </form>
</div>

<div class="table-wrap"><table>
  <thead><tr><th>Ticket ID</th><th>Booking</th><th>Customer</th><th>Movie</th><th>Cinema</th><th>Show Date</th><th>Seat</th><th>Price</th><th>Issued At</th><th style="text-align:right">Actions</th></tr></thead>
  <tbody>
  <?php foreach($rows as $r): ?>
  <tr>
    <td class="td-mono"><?= e($r['ticket_id']) ?></td>
    <td class="td-mono"><?= e($r['booking_id']) ?></td>
    <td class="td-bold"><?= e($r['customer_name']) ?></td>
    <td><?= e($r['movie_title']) ?></td>
    <td><?= e($r['cinema_name']) ?></td>
    <td><?= e($r['show_date']) ?></td>
    <td><span class="pill p-purple"><?= e($r['seat_number']) ?></span></td>
    <td style="color:var(--text);font-weight:500">₱<?= number_format($r['ticket_price'],2) ?></td>
    <td class="td-muted"><?= e($r['issued_at'] ?? '—') ?></td>
    <td style="text-align:right">
      <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($r['ticket_id']) ?>')"><i class="fa-solid fa-trash-can" style="color: #c96a3aff;"></i></button>
    </td>
  </tr>
  <?php endforeach; if(!$rows): ?>
  <tr><td colspan="10" style="text-align:center;padding:40px;color:var(--text-muted)">No tickets issued yet.</td></tr>
  <?php endif; ?>
  </tbody>
</table>
<div class="table-footer"><div class="table-count"><?= $total_tickets ?> tickets · ₱<?= number_format($total_revenue,2) ?> total</div></div>
</div>
`;

ajaxForm(document.getElementById('addForm'), { closeModal: 'addModal' });

function doDelete(id){
  document.getElementById('delId').value = id;
  ajaxDelete(document.getElementById('delForm'), 'Delete Ticket', 'Ticket #'+id);
}
</script>
<?php require_once '../includes/footer.php'; ?>