<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    if ($act === 'insert') {
        $id   = genId($conn,'cinemas','cinema_id','CIN');
        $name = $conn->real_escape_string(trim($_POST['cinema_name']    ?? ''));
        $loc  = $conn->real_escape_string(trim($_POST['location']       ?? ''));
        $con  = $conn->real_escape_string(trim($_POST['contact_number'] ?? ''));
        if ($name && $loc) {
            if ($conn->query("INSERT INTO cinemas VALUES ('$id','$name','$loc','$con')"))
                { $flash="Cinema \"$name\" added."; $flash_type='success'; }
            else { $flash='Error: '.$conn->error; $flash_type='error'; }
        } else { $flash='Name and location required.'; $flash_type='error'; }
    }
    if ($act === 'update') {
        $id   = $conn->real_escape_string($_POST['cinema_id']      ?? '');
        $name = $conn->real_escape_string(trim($_POST['cinema_name']    ?? ''));
        $loc  = $conn->real_escape_string(trim($_POST['location']       ?? ''));
        $con  = $conn->real_escape_string(trim($_POST['contact_number'] ?? ''));
        if ($conn->query("UPDATE cinemas SET cinema_name='$name',location='$loc',contact_number='$con' WHERE cinema_id='$id'"))
            { $flash="Cinema updated."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['cinema_id'] ?? '');
        $row = $conn->query("SELECT cinema_name FROM cinemas WHERE cinema_id='$id'")->fetch_assoc();
        if ($conn->query("DELETE FROM cinemas WHERE cinema_id='$id'"))
            { $flash="Cinema \"{$row['cinema_name']}\" deleted."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    $conn->close();
    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn = getSlaveConn();
$q    = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$sort = $_GET['sort'] ?? 'newest';
$sort_map = [
    'newest' => 'c.cinema_id DESC',
    'oldest' => 'c.cinema_id ASC',
    'az'     => 'cinema_name ASC',
    'za'     => 'cinema_name DESC',
];
$order_by = $sort_map[$sort] ?? 'c.cinema_id DESC';
$sort_labels = ['newest'=>'Newest first','oldest'=>'Oldest first','az'=>'A–Z','za'=>'Z–A'];

$where = $q ? "WHERE cinema_name LIKE '%$q%' OR location LIKE '%$q%'" : '';
$rows  = $conn->query("SELECT c.*, (SELECT COUNT(*) FROM screens s WHERE s.cinema_id=c.cinema_id) AS screen_count FROM cinemas c $where ORDER BY $order_by")->fetch_all(MYSQLI_ASSOC);
$conn->close();
require_once '../includes/header.php';
?>
<form id="delForm" method="POST" style="display:none"><input type="hidden" name="_action" value="delete"><input type="hidden" name="cinema_id" id="delId"></form>

<div class="modal-overlay" id="addModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Add Cinema</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
  <form method="POST" id="addForm"><input type="hidden" name="_action" value="insert">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Cinema Name *</label><input class="form-input" name="cinema_name" required placeholder="e.g. SM Cinema Cebu"/></div>
    <div class="form-group full"><label class="form-label">Location *</label><input class="form-input" name="location" required placeholder="e.g. SM City Cebu, North Reclamation"/></div>
    <div class="form-group full"><label class="form-label">Contact Number</label><input class="form-input" name="contact_number" placeholder="(032) 234-5678"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button class="btn btn-primary">Save Cinema</button></div>
  </form>
</div></div>

<div class="modal-overlay" id="editModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Edit Cinema</div><button class="modal-close" onclick="CM('editModal')">✕</button></div>
  <form method="POST" id="editForm"><input type="hidden" name="_action" value="update"><input type="hidden" name="cinema_id" id="e_id">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group full"><label class="form-label">Cinema Name *</label><input class="form-input" name="cinema_name" id="e_name" required/></div>
    <div class="form-group full"><label class="form-label">Location *</label><input class="form-input" name="location" id="e_loc" required/></div>
    <div class="form-group full"><label class="form-label">Contact Number</label><input class="form-input" name="contact_number" id="e_con"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('editModal')">Cancel</button><button class="btn btn-primary">Update Cinema</button></div>
  </form>
</div></div>

<script>
injectLayout({page:'cinemas',title:'Cinemas',sub:'Cinema venue management',actionLabel:'+ Add Cinema'});
document.getElementById('topbarAction').onclick=function(){ OM('addModal'); };
document.getElementById('pageContent').innerHTML=`
<div class="toolbar">
  <form method="GET" id="sortForm" style="display:flex;gap:10px;flex:1;flex-wrap:wrap;align-items:center">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search cinemas…"/></div>
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
    <?php if($q): ?><a href="cinemas.php" style="font-size:12px;color:var(--text-muted);align-self:center">Clear</a><?php endif; ?>
  </form>
</div>
<div class="table-wrap"><table>
  <thead><tr><th>ID</th><th>Cinema Name</th><th>Location</th><th>Contact</th><th>Screens</th><th style="text-align:left">Actions</th></tr></thead>
  <tbody>
  <?php foreach($rows as $r): ?>
  <tr>
    <td class="td-mono"><?= e($r['cinema_id']) ?></td>
    <td class="td-bold"><?= e($r['cinema_name']) ?></td>
    <td><?= e($r['location']) ?></td>
    <td><?= e($r['contact_number'] ?: '—') ?></td>
    <td><span class="pill p-purple"><?= $r['screen_count'] ?> screens</span></td>
    <td style="text-align:right"><div class="actions">
      <button class="btn btn-ghost btn-sm" onclick="openEdit(<?= htmlspecialchars(json_encode($r)) ?>)"><i class="fa-solid fa-pen-to-square" style="color: #7A7590;"></i></button>
      <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($r['cinema_id']) ?>','<?= e(addslashes($r['cinema_name'])) ?>')"><i class="fa-solid fa-trash-can" style="color: #c96a3aff;"></i></button>
    </div></td>
  </tr>
  <?php endforeach; if(!$rows): ?>
  <tr><td colspan="6" style="text-align:center;padding:40px;color:var(--text-muted)">No cinemas found.</td></tr>
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
  document.getElementById('e_id').value   = r.cinema_id;
  document.getElementById('e_name').value = r.cinema_name;
  document.getElementById('e_loc').value  = r.location;
  document.getElementById('e_con').value  = r.contact_number||'';
  OM('editModal');
}
function doDelete(id, name){
  document.getElementById('delId').value = id;
  ajaxDelete(document.getElementById('delForm'), 'Delete Cinema', '"'+name+'"');
}
</script>
<?php require_once '../includes/footer.php'; ?>