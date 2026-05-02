<?php
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash      = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();
    if ($act === 'insert') {
        $id    = genId($conn,'customers','customer_id','CUS');
        $fname = $conn->real_escape_string(trim($_POST['first_name'] ?? ''));
        $lname = $conn->real_escape_string(trim($_POST['last_name']  ?? ''));
        $email = $conn->real_escape_string(trim($_POST['email']      ?? ''));
        $phone = $conn->real_escape_string(trim($_POST['phone_number']?? ''));
        $stat  = $conn->real_escape_string($_POST['status']          ?? 'Active');
        $pw    = password_hash($_POST['password'] ?? 'changeme123', PASSWORD_BCRYPT);
        if ($fname && $lname && $email) {
            if ($conn->query("INSERT INTO customers (customer_id,first_name,last_name,email,phone_number,password,status) VALUES ('$id','$fname','$lname','$email','$phone','$pw','$stat')"))
                { $flash="Customer added."; $flash_type='success'; }
            else { $flash='Error: '.$conn->error; $flash_type='error'; }
        } else { $flash='Name and email required.'; $flash_type='error'; }
    }
    if ($act === 'update') {
        $id    = $conn->real_escape_string($_POST['customer_id']   ?? '');
        $fname = $conn->real_escape_string(trim($_POST['first_name'] ?? ''));
        $lname = $conn->real_escape_string(trim($_POST['last_name']  ?? ''));
        $email = $conn->real_escape_string(trim($_POST['email']      ?? ''));
        $phone = $conn->real_escape_string(trim($_POST['phone_number']?? ''));
        $stat  = $conn->real_escape_string($_POST['status']          ?? 'Active');
        if ($conn->query("UPDATE customers SET first_name='$fname',last_name='$lname',email='$email',phone_number='$phone',status='$stat' WHERE customer_id='$id'"))
            { $flash="Customer updated."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['customer_id'] ?? '');
        if ($conn->query("DELETE FROM customers WHERE customer_id='$id'"))
            { $flash="Customer deleted."; $flash_type='success'; }
        else { $flash='Error: '.$conn->error; $flash_type='error'; }
    }
    $conn->close();
    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn  = getSlaveConn();
$q     = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$sf    = $conn->real_escape_string($_GET['status'] ?? '');
$sort  = $_GET['sort'] ?? 'newest';
$sort_map = [
    'newest' => 'customer_id DESC',
    'oldest' => 'customer_id ASC',
    'az'     => 'first_name ASC',
    'za'     => 'first_name DESC',
];
$order_by = $sort_map[$sort] ?? 'customer_id DESC';
$sort_labels = ['newest'=>'Newest first','oldest'=>'Oldest first','az'=>'A–Z','za'=>'Z–A'];

$cond  = [];
if ($q)  $cond[] = "(first_name LIKE '%$q%' OR last_name LIKE '%$q%' OR email LIKE '%$q%')";
if ($sf) $cond[] = "status='$sf'";
$where = $cond ? 'WHERE '.implode(' AND ',$cond) : '';
$rows  = $conn->query("SELECT * FROM customers $where ORDER BY $order_by")->fetch_all(MYSQLI_ASSOC);
$conn->close();
require_once '../includes/header.php';
?>
<form id="delForm" method="POST" style="display:none"><input type="hidden" name="_action" value="delete"><input type="hidden" name="customer_id" id="delId"></form>

<div class="modal-overlay" id="addModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Add Customer</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
  <form method="POST" id="addForm"><input type="hidden" name="_action" value="insert">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group"><label class="form-label">First Name *</label><input class="form-input" name="first_name" required/></div>
    <div class="form-group"><label class="form-label">Last Name *</label><input class="form-input" name="last_name" required/></div>
    <div class="form-group full"><label class="form-label">Email *</label><input class="form-input" name="email" type="email" required/></div>
    <div class="form-group"><label class="form-label">Phone</label><input class="form-input" name="phone_number" placeholder="09XX-XXX-XXXX"/></div>
    <div class="form-group"><label class="form-label">Status</label><select class="form-select" name="status"><option>Active</option><option>Inactive</option><option>Suspended</option></select></div>
    <div class="form-group full"><label class="form-label">Password</label><input class="form-input" name="password" type="password" placeholder="Default: changeme123"/></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button class="btn btn-primary">Save Customer</button></div>
  </form>
</div></div>

<div class="modal-overlay" id="editModal"><div class="modal">
  <div class="modal-header"><div class="modal-title">Edit Customer</div><button class="modal-close" onclick="CM('editModal')">✕</button></div>
  <form method="POST" id="editForm"><input type="hidden" name="_action" value="update"><input type="hidden" name="customer_id" id="e_id">
  <div class="modal-body"><div class="form-grid">
    <div class="form-group"><label class="form-label">First Name *</label><input class="form-input" name="first_name" id="e_fn" required/></div>
    <div class="form-group"><label class="form-label">Last Name *</label><input class="form-input" name="last_name" id="e_ln" required/></div>
    <div class="form-group full"><label class="form-label">Email *</label><input class="form-input" name="email" id="e_em" type="email" required/></div>
    <div class="form-group"><label class="form-label">Phone</label><input class="form-input" name="phone_number" id="e_ph"/></div>
    <div class="form-group"><label class="form-label">Status</label><select class="form-select" name="status" id="e_st"><option>Active</option><option>Inactive</option><option>Suspended</option></select></div>
  </div></div>
  <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('editModal')">Cancel</button><button class="btn btn-primary">Update Customer</button></div>
  </form>
</div></div>

<script>
injectLayout({page:'customers',title:'Customers',sub:'Customer management',actionLabel:'+ Add Customer'});
document.getElementById('topbarAction').onclick=function(){ OM('addModal'); };
document.getElementById('pageContent').innerHTML=`
<div class="toolbar">
  <form method="GET" id="sortForm" style="display:flex;gap:10px;flex:1;flex-wrap:wrap;align-items:center">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search customers…"/></div>
    <select class="filter-select" name="status" onchange="this.form.submit()">
      <option value="">All Status</option>
      <?php foreach(['Active','Inactive','Suspended'] as $s): ?>
      <option value="<?= $s ?>" <?= $sf===$s?'selected':'' ?>><?= $s ?></option>
      <?php endforeach; ?>
    </select>
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
    <?php if($q||$sf): ?><a href="customers.php" style="font-size:12px;color:var(--text-muted)">Clear</a><?php endif; ?>
  </form>
</div>
<div class="table-wrap">
<table>
  <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Status</th><th>Joined</th><th style="text-align:left">Actions</th></tr></thead>
  <tbody>
  <?php if($rows): foreach($rows as $r): ?>
  <tr>
    <td class="td-mono"><?= e($r['customer_id']) ?></td>
    <td class="td-bold"><?= e($r['first_name'].' '.$r['last_name']) ?></td>
    <td><?= e($r['email']) ?></td>
    <td><?= e($r['phone_number'] ?: '—') ?></td>
    <td><?= pill($r['status']) ?></td>
    <td class="td-muted"><?= e(substr($r['created_at'],0,10)) ?></td>
    <td style="text-align:right"><div class="actions">
      <button class="btn btn-ghost btn-sm" onclick="openEdit(<?= htmlspecialchars(json_encode($r)) ?>)"><i class="fa-solid fa-pen-to-square" style="color: #7A7590;"></i></button>
      <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($r['customer_id']) ?>','<?= e(addslashes($r['first_name'].' '.$r['last_name'])) ?>')"><i class="fa-solid fa-trash-can" style="color: #c96a3aff;"></i></button>
    </div></td>
  </tr>
  <?php endforeach; else: ?>
  <tr><td colspan="7" style="text-align:center;padding:32px;color:var(--text-muted)">No customers found.</td></tr>
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
  document.getElementById('e_id').value = r.customer_id;
  document.getElementById('e_fn').value = r.first_name;
  document.getElementById('e_ln').value = r.last_name;
  document.getElementById('e_em').value = r.email;
  document.getElementById('e_ph').value = r.phone_number || '';
  document.getElementById('e_st').value = r.status;
  OM('editModal');
}
function doDelete(id, name){
  document.getElementById('delId').value = id;
  ajaxDelete(document.getElementById('delForm'), 'Delete Customer', '"'+name+'"');
}
</script>
<?php require_once '../includes/footer.php'; ?>