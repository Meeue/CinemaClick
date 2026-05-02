<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

// AJAX: fetch available seats for a given booking's screen
if (isset($_GET['fetch_seats_for_booking'])) {
    $conn = getSlaveConn();
    $bid  = $conn->real_escape_string($_GET['booking_id'] ?? '');
    $result = $conn->query(
        "SELECT s.seat_id, CONCAT(sc.screen_name,' — Seat ',s.seat_number,' (',s.seat_type,')') AS label
         FROM seats s
         JOIN screens   sc ON s.screen_id  = sc.screen_id
         JOIN showtimes st ON st.screen_id  = sc.screen_id
         JOIN bookings   b ON b.showtime_id = st.showtime_id
         WHERE b.booking_id = '$bid'
           AND s.status = 'Available'
           AND s.seat_id NOT IN (
               SELECT seat_id FROM tickets
               JOIN bookings b2 ON tickets.booking_id = b2.booking_id
               WHERE b2.showtime_id = st.showtime_id
           )
         ORDER BY s.seat_number"
    );
    $seats = $result ? $result->fetch_all(MYSQLI_ASSOC) : [];
    $conn->close();
    header('Content-Type: application/json');
    echo json_encode($seats);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    if ($act === 'insert') {
        $id    = genId($conn,'tickets','ticket_id','TKT',4);
        $bid   = $conn->real_escape_string($_POST['booking_id']   ?? '');
        $sid   = $conn->real_escape_string($_POST['seat_id']      ?? '');
        $price = (float)($_POST['ticket_price'] ?? 0);
        if ($bid && $sid) {
            $conn->begin_transaction();
            try {
                $conn->query("INSERT INTO tickets (ticket_id,booking_id,seat_id,ticket_price) VALUES ('$id','$bid','$sid',$price)");
                $conn->query("UPDATE seats SET status='Taken' WHERE seat_id='$sid'");
                $conn->commit();
                $flash="Ticket $id issued."; $flash_type='success';
            } catch (Exception $e) {
                $conn->rollback();
                $flash='Error: '.$conn->error; $flash_type='error';
            }
        } else { $flash='Booking and seat required.'; $flash_type='error'; }
    }
    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['ticket_id'] ?? '');
        $res = $conn->query("SELECT seat_id FROM tickets WHERE ticket_id='$id'");
        $seatRow = $res ? $res->fetch_assoc() : null;
        $conn->begin_transaction();
        try {
            $conn->query("DELETE FROM tickets WHERE ticket_id='$id'");
            if ($seatRow) $conn->query("UPDATE seats SET status='Available' WHERE seat_id='".$conn->real_escape_string($seatRow['seat_id'])."'");
            $conn->commit();
            $flash="Ticket deleted."; $flash_type='success';
        } catch (Exception $e) {
            $conn->rollback();
            $flash='Error: '.$conn->error; $flash_type='error';
        }
    }
    $conn->close();
    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn     = getSlaveConn();
$q        = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$sort     = $_GET['sort'] ?? 'newest';
$sort_map = [
    'newest'     => 't.ticket_id DESC',
    'oldest'     => 't.ticket_id ASC',
    'az'         => 'b.customer_name ASC',
    'za'         => 'b.customer_name DESC',
];
$order_by = $sort_map[$sort] ?? 't.ticket_id DESC';
$where    = $q ? "WHERE (t.ticket_id LIKE '%$q%' OR b.customer_name LIKE '%$q%' OR s.seat_number LIKE '%$q%')" : '';
$rows     = $conn->query(
    "SELECT t.*, b.customer_name, s.seat_number, s.seat_type, m.title AS movie_title,
            st.show_date, st.start_time, st.end_time, ci.cinema_name, sc.screen_name
     FROM tickets t
     JOIN bookings  b  ON t.booking_id  = b.booking_id
     JOIN seats     s  ON t.seat_id     = s.seat_id
     JOIN showtimes st ON b.showtime_id = st.showtime_id
     JOIN movies    m  ON st.movie_id   = m.movie_id
     JOIN screens   sc ON st.screen_id  = sc.screen_id
     JOIN cinemas   ci ON sc.cinema_id  = ci.cinema_id
     $where ORDER BY $order_by"
)->fetch_all(MYSQLI_ASSOC);

$bookings = $conn->query(
    "SELECT b.booking_id, CONCAT(b.booking_id,' — ',b.customer_name) AS label, st.price
     FROM bookings b JOIN showtimes st ON b.showtime_id=st.showtime_id
     WHERE b.booking_status != 'Cancelled' ORDER BY b.booking_date DESC"
)->fetch_all(MYSQLI_ASSOC);

$total_tickets = count($rows);
$total_revenue = array_sum(array_column($rows,'ticket_price'));
$conn->close();

$bk_opts = implode('', array_map(fn($b) => '<option value="'.e($b['booking_id']).'" data-price="'.e($b['price']).'">'.e($b['label']).'</option>', $bookings));
$sort_labels = ['newest'=>'Newest first','oldest'=>'Oldest first','az'=>'A–Z','za'=>'Z–A'];
require_once '../includes/header.php';
?>
<form id="delForm" method="POST" style="display:none"><input type="hidden" name="_action" value="delete"><input type="hidden" name="ticket_id" id="delId"></form>

<!-- Issue Ticket Modal -->
<div class="modal-overlay" id="addModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Issue Ticket</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
  <form method="POST" id="addForm"><input type="hidden" name="_action" value="insert">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Booking *</label><select class="form-select" name="booking_id" id="a_booking" onchange="onBookingChange(this)"><?= $bk_opts ?></select></div>
    <div class="form-group full">
      <label class="form-label">Seat * <span id="seat_loading" style="font-size:11px;color:var(--text-muted);display:none">Loading…</span></label>
      <select class="form-select" name="seat_id" id="a_seat" disabled>
        <option value="">— Select a booking first —</option>
      </select>
      <small id="seat_hint" style="color:var(--text-muted);font-size:11px;margin-top:4px;display:block"></small>
    </div>
    <div class="form-group full"><label class="form-label">Ticket Price (₱)</label><input class="form-input" name="ticket_price" id="a_price" type="number" step="0.01" value="0"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button class="btn btn-primary">Issue Ticket</button></div>
  </form>
</div></div>

<!-- View Ticket Modal -->
<div class="modal-overlay" id="viewModal"><div class="modal" style="max-width:540px">
  <div class="modal-header"><div class="modal-title" id="vw_title">Ticket Details</div><button class="modal-close" onclick="CM('viewModal')">✕</button></div>
  <div class="modal-body"><div id="vwBody"></div></div>
  <div class="modal-footer"><button class="btn btn-ghost" onclick="CM('viewModal')">Close</button></div>
</div></div>

<script>
injectLayout({page:'tickets',title:'Tickets',sub:'Issued tickets',actionLabel:'+ Issue Ticket'});
document.getElementById('topbarAction').onclick=function(){
  OM('addModal');
  var bookingSel = document.getElementById('a_booking');
  if (bookingSel && bookingSel.value) onBookingChange(bookingSel);
};
document.getElementById('pageContent').innerHTML=`
<div class="toolbar">
  <form method="GET" id="sortForm" style="display:flex;gap:10px;flex:1;align-items:center;flex-wrap:wrap">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search tickets, customer, seat…"/></div>
    <button class="btn btn-ghost btn-sm" type="submit">Search</button>
    <input type="hidden" name="sort" id="sortVal" value="<?= htmlspecialchars($sort) ?>"/>
    <div style="position:relative" id="sortWrap">
      <button type="button" onclick="toggleSort()" style="display:flex;align-items:center;gap:6px;padding:7px 13px;border-radius:8px;border:.5px solid var(--border-md);background:var(--bg-surface);color:var(--text);font-size:13px;cursor:pointer;white-space:nowrap;font-family:'DM Sans',sans-serif;transition:all .15s" onmouseover="this.style.background='var(--bg-surface2)'" onmouseout="this.style.background='var(--bg-surface)'">
        <i class="fa-solid fa-arrow-up-arrow-down" style="color:var(--accent);font-size:11px"></i>
        <?= htmlspecialchars($sort_labels[$sort] ?? 'Newest first') ?>
        <i class="fa-solid fa-chevron-down" style="font-size:9px;color:var(--text-muted)"></i>
      </button>
      <div id="sortDrop" style="display:none;position:absolute;top:calc(100% + 6px);right:0;background:var(--bg-surface);border:.5px solid var(--border-md);border-radius:10px;box-shadow:0 8px 24px rgba(0,0,0,.3);z-index:999;min-width:155px;overflow:hidden;padding:4px 0">
        <?php foreach($sort_labels as $k=>$label): ?>
        <div onclick="setSort('<?= $k ?>')" style="padding:9px 16px;font-size:13px;cursor:pointer;color:<?= $sort===$k ? 'var(--accent)' : 'var(--text)' ?>;font-weight:<?= $sort===$k ? '600' : '400' ?>" onmouseover="this.style.background='var(--accent-dim)'" onmouseout="this.style.background='transparent'">
          <?php if($sort===$k): ?><i class="fa-solid fa-check" style="font-size:10px;margin-right:6px;color:var(--accent)"></i><?php else: ?><span style="display:inline-block;width:16px"></span><?php endif; ?>
          <?= $label ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
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
    <td style="text-align:right"><div class="actions">
      <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($r['ticket_id']) ?>')"><i class="fa-solid fa-trash-can" style="color:#c96a3aff"></i></button>
    </div></td>
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

// Sort
function toggleSort(){
  var d=document.getElementById('sortDrop');
  d.style.display=d.style.display==='block'?'none':'block';
}
function setSort(val){
  document.getElementById('sortVal').value=val;
  document.getElementById('sortDrop').style.display='none';
  document.getElementById('sortForm').submit();
}
document.addEventListener('click',function(e){
  var w=document.getElementById('sortWrap');
  if(w&&!w.contains(e.target)) document.getElementById('sortDrop').style.display='none';
});

// View ticket modal
function vf(label, value, full){
  return '<div class="vf'+(full?' full':'')+'"><div class="vf-label">'+label+'</div><div class="vf-value">'+value+'</div></div>';
}
function openView(r){
  document.getElementById('vw_title').textContent = 'Ticket #' + (r.ticket_id || '');
  document.getElementById('vwBody').innerHTML =
    '<div class="view-grid">' +
      vf('Ticket ID',   '<span style="font-family:\'DM Mono\',monospace">'+(r.ticket_id||'—')+'</span>') +
      vf('Booking ID',  '<span style="font-family:\'DM Mono\',monospace">'+(r.booking_id||'—')+'</span>') +
      vf('Customer',    r.customer_name||'—') +
      vf('Movie',       r.movie_title||'—', true) +
      vf('Cinema',      r.cinema_name||'—', true) +
      vf('Screen',      r.screen_name||'—') +
      vf('Show Date',   r.show_date||'—') +
      vf('Show Time',   r.start_time ? r.start_time.substring(0,5) : '—') +
      vf('Seat Number', r.seat_number||'—') +
      vf('Seat Type',   r.seat_type||'—') +
      vf('Ticket Price','<span style="color:var(--accent);font-weight:600">₱'+parseFloat(r.ticket_price||0).toFixed(2)+'</span>') +
      vf('Issued At',   r.issued_at||'—') +
    '</div>';
  OM('viewModal');
}

// Booking seat loader
function onBookingChange(sel) {
  var bid     = sel.value;
  var price   = sel.options[sel.selectedIndex]?.dataset?.price || 0;
  var seatSel = document.getElementById('a_seat');
  var hint    = document.getElementById('seat_hint');
  var loading = document.getElementById('seat_loading');

  document.getElementById('a_price').value = price;

  if (!bid) {
    seatSel.innerHTML = '<option value="">— Select a booking first —</option>';
    seatSel.disabled = true;
    hint.textContent = '';
    return;
  }

  seatSel.disabled = true;
  seatSel.innerHTML = '<option value="">Loading seats…</option>';
  loading.style.display = 'inline';
  hint.textContent = '';

  fetch('tickets.php?fetch_seats_for_booking=1&booking_id=' + encodeURIComponent(bid))
    .then(r => r.json())
    .then(seats => {
      loading.style.display = 'none';
      if (!seats.length) {
        seatSel.innerHTML = '<option value="">No available seats for this booking\'s screen</option>';
        seatSel.disabled = true;
        hint.textContent = '⚠ All seats in this screen are taken or unavailable.';
        hint.style.color = 'var(--danger, #e53e3e)';
      } else {
        seatSel.innerHTML = '<option value="">— Pick a seat —</option>' +
          seats.map(s => '<option value="' + s.seat_id + '">' + s.label + '</option>').join('');
        seatSel.disabled = false;
        hint.textContent = seats.length + ' seat(s) available for this booking\'s screen.';
        hint.style.color = 'var(--text-muted)';
      }
    })
    .catch(() => {
      loading.style.display = 'none';
      seatSel.innerHTML = '<option value="">Error loading seats</option>';
      hint.textContent = 'Could not load seats. Please try again.';
      hint.style.color = 'var(--danger, #e53e3e)';
    });
}

function doDelete(id){
  document.getElementById('delId').value = id;
  ajaxDelete(document.getElementById('delForm'), 'Delete Ticket', 'Ticket #'+id);
}
</script>
<?php require_once '../includes/footer.php'; ?>