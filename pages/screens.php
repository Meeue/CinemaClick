<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();

    if ($act === 'insert') {
        $id    = genId($conn,'screens','screen_id','SCR');
        $cid   = $conn->real_escape_string($_POST['cinema_id']   ?? '');
        $sname = $conn->real_escape_string(trim($_POST['screen_name'] ?? ''));
        $seats = (int)($_POST['total_seats'] ?? 100);
        if ($cid && $sname) {
            if ($conn->query("INSERT INTO screens VALUES ('$id','$cid','$sname',$seats)")) {
                $rows_count = (int)ceil($seats / 10);
                $seat_num   = 1;
                for ($r = 0; $r < $rows_count; $r++) {
                    $row_letter = chr(65 + $r);
                    $cols = min(10, $seats - ($r * 10));
                    for ($c = 1; $c <= $cols; $c++) {
                        $seat_label = $conn->real_escape_string($row_letter . str_pad($c, 2, '0', STR_PAD_LEFT));
                        $sid_val    = $conn->real_escape_string($id . '-' . str_pad($seat_num, 3, '0', STR_PAD_LEFT));
                        $conn->query("INSERT INTO seats (seat_id, screen_id, seat_number, seat_type, status)
                                      VALUES ('$sid_val','$id','$seat_label','Standard','Available')");
                        $seat_num++;
                    }
                }
                $flash="Screen \"$sname\" added with $seats seats."; $flash_type='success';
            } else { $flash='Error: '.$conn->error; $flash_type='error'; }
        } else { $flash='Cinema and screen name required.'; $flash_type='error'; }
    }

    if ($act === 'update') {
        $id    = $conn->real_escape_string($_POST['screen_id']   ?? '');
        $cid   = $conn->real_escape_string($_POST['cinema_id']   ?? '');
        $sname = $conn->real_escape_string(trim($_POST['screen_name'] ?? ''));
        $seats = (int)($_POST['total_seats'] ?? 100);
        if ($conn->query("UPDATE screens SET cinema_id='$cid',screen_name='$sname',total_seats=$seats WHERE screen_id='$id'"))
            { $flash="Screen updated."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }

    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['screen_id'] ?? '');
        $row = $conn->query("SELECT screen_name FROM screens WHERE screen_id='$id'")->fetch_assoc();
        if ($conn->query("DELETE FROM screens WHERE screen_id='$id'"))
            { $flash="Screen \"{$row['screen_name']}\" deleted."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    $conn->close();
    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn    = getSlaveConn();
$q       = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$sort    = $_GET['sort'] ?? 'newest';
$sort_map = [
    'newest' => 's.screen_id DESC',
    'oldest' => 's.screen_id ASC',
    'az'     => 's.screen_name ASC',
    'za'     => 's.screen_name DESC',
];
$order_by = $sort_map[$sort] ?? 's.screen_id DESC';
$sort_labels = ['newest'=>'Newest first','oldest'=>'Oldest first','az'=>'A–Z','za'=>'Z–A'];

$where   = $q ? "WHERE s.screen_name LIKE '%$q%' OR c.cinema_name LIKE '%$q%'" : '';
$rows    = $conn->query(
    "SELECT s.*, c.cinema_name FROM screens s JOIN cinemas c ON s.cinema_id=c.cinema_id
     $where ORDER BY $order_by"
)->fetch_all(MYSQLI_ASSOC);
$cinemas = $conn->query("SELECT cinema_id, cinema_name FROM cinemas ORDER BY cinema_name")->fetch_all(MYSQLI_ASSOC);
$conn->close();

$cinema_opts = implode('', array_map(fn($c) =>
    '<option value="'.e($c['cinema_id']).'">'.e($c['cinema_name']).'</option>', $cinemas));
require_once '../includes/header.php';
?>
<form id="delForm" method="POST" style="display:none"><input type="hidden" name="_action" value="delete"><input type="hidden" name="screen_id" id="delId"></form>

<div class="modal-overlay" id="addModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Add Screen</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
  <form method="POST" id="addForm"><input type="hidden" name="_action" value="insert">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Cinema *</label><select class="form-select" name="cinema_id"><?= $cinema_opts ?></select></div>
    <div class="form-group"><label class="form-label">Screen Name *</label><input class="form-input" name="screen_name" required placeholder="e.g. Screen A"/></div>
    <div class="form-group"><label class="form-label">Total Seats *</label><input class="form-input" name="total_seats" type="number" value="120" min="1" max="260"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button class="btn btn-primary">Save Screen</button></div>
  </form>
</div></div>

<div class="modal-overlay" id="editModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Edit Screen</div><button class="modal-close" onclick="CM('editModal')">✕</button></div>
  <form method="POST" id="editForm"><input type="hidden" name="_action" value="update"><input type="hidden" name="screen_id" id="e_id">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Cinema *</label><select class="form-select" name="cinema_id" id="e_cid"><?= $cinema_opts ?></select></div>
    <div class="form-group"><label class="form-label">Screen Name *</label><input class="form-input" name="screen_name" id="e_sname" required/></div>
    <div class="form-group"><label class="form-label">Total Seats *</label><input class="form-input" name="total_seats" id="e_seats" type="number" min="1"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('editModal')">Cancel</button><button class="btn btn-primary">Update Screen</button></div>
  </form>
</div></div>

<script>
injectLayout({page:'screens',title:'Screens',sub:'Screen configuration',actionLabel:'+ Add Screen'});
document.getElementById('topbarAction').onclick=function(){ OM('addModal'); };
document.getElementById('pageContent').innerHTML=`
<div class="toolbar">
  <form method="GET" id="sortForm" style="display:flex;gap:10px;flex:1;flex-wrap:wrap;align-items:center">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search screens…"/></div>
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
        <div onclick="setSort('<?= $k ?>')" style="padding:9px 16px;font-size:13px;cursor:pointer;color:<?= $sort===$k?'var(--accent)':'var(--text)' ?>;font-weight:<?= $sort===$k?'600':'400' ?>" onmouseover="this.style.background='var(--accent-dim)'" onmouseout="this.style.background='transparent'">
          <?php if($sort===$k): ?><i class="fa-solid fa-check" style="font-size:10px;margin-right:6px;color:var(--accent)"></i><?php else: ?><span style="display:inline-block;width:16px"></span><?php endif; ?>
          <?= $label ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
    <?php if($q): ?><a href="screens.php" style="font-size:12px;color:var(--text-muted);align-self:center">Clear</a><?php endif; ?>
  </form>
</div>
<div class="table-wrap"><table>
  <thead><tr><th>ID</th><th>Cinema</th><th>Screen Name</th><th>Total Seats</th><th style="text-align:left">Actions</th></tr></thead>
  <tbody>
  <?php foreach($rows as $r): ?>
  <tr>
    <td class="td-mono"><?= e($r['screen_id']) ?></td>
    <td><?= e($r['cinema_name']) ?></td>
    <td class="td-bold"><?= e($r['screen_name']) ?></td>
    <td><span class="pill p-purple"><?= (int)$r['total_seats'] ?> seats</span></td>
    <td style="text-align:right"><div class="actions">
      <button class="btn btn-ghost btn-sm" onclick="openEdit(<?= htmlspecialchars(json_encode($r)) ?>)"><i class="fa-solid fa-pen-to-square" style="color: #7A7590;"></i></button>
      <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($r['screen_id']) ?>','<?= e(addslashes($r['screen_name'])) ?>')"><i class="fa-solid fa-trash-can" style="color: #c96a3aff;"></i></button>
    </div></td>
  </tr>
  <?php endforeach; if(!$rows): ?>
  <tr><td colspan="5" style="text-align:center;padding:40px;color:var(--text-muted)">No screens found.</td></tr>
  <?php endif; ?>
  </tbody>
</table>
<div class="table-footer"><div class="table-count"><?= count($rows) ?> records</div></div>
</div>
`;

ajaxForm(document.getElementById('addForm'),  { closeModal: 'addModal'  });
ajaxForm(document.getElementById('editForm'), { closeModal: 'editModal' });

function toggleSort(){var d=document.getElementById('sortDrop');d.style.display=d.style.display==='block'?'none':'block';}
function setSort(val){document.getElementById('sortVal').value=val;document.getElementById('sortDrop').style.display='none';document.getElementById('sortForm').submit();}
document.addEventListener('click',function(e){var w=document.getElementById('sortWrap');if(w&&!w.contains(e.target))document.getElementById('sortDrop').style.display='none';});

function openEdit(r){
  document.getElementById('e_id').value    = r.screen_id;
  document.getElementById('e_cid').value   = r.cinema_id;
  document.getElementById('e_sname').value = r.screen_name;
  document.getElementById('e_seats').value = r.total_seats;
  OM('editModal');
}
function doDelete(id, name){
  document.getElementById('delId').value = id;
  ajaxDelete(document.getElementById('delForm'), 'Delete Screen', '"'+name+'"');
}
</script>
<?php require_once '../includes/footer.php'; ?>