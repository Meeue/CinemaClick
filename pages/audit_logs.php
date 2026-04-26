<?php
require_once '../connect.php';
require_once '../includes/helpers.php';

$conn   = getSlaveConn();
$q      = $conn->real_escape_string(trim($_GET['q']    ?? ''));
$op_f   = $conn->real_escape_string($_GET['op']        ?? '');
$tbl_f  = $conn->real_escape_string($_GET['tbl']       ?? '');
$cond   = [];
if ($q)    $cond[] = "(record_id LIKE '%$q%' OR table_name LIKE '%$q%' OR old_data LIKE '%$q%' OR new_data LIKE '%$q%')";
if ($op_f) $cond[] = "operation='$op_f'";
if ($tbl_f)$cond[] = "table_name='$tbl_f'";
$where  = $cond ? 'WHERE '.implode(' AND ',$cond) : '';
$logs   = $conn->query("SELECT * FROM audit_log $where ORDER BY changed_at DESC LIMIT 300")->fetch_all(MYSQLI_ASSOC);
$tables = $conn->query("SELECT DISTINCT table_name FROM audit_log ORDER BY table_name")->fetch_all(MYSQLI_ASSOC);

$ins_count = $conn->query("SELECT COUNT(*) AS c FROM audit_log WHERE operation='INSERT'")->fetch_assoc()['c'];
$upd_count = $conn->query("SELECT COUNT(*) AS c FROM audit_log WHERE operation='UPDATE'")->fetch_assoc()['c'];
$del_count = $conn->query("SELECT COUNT(*) AS c FROM audit_log WHERE operation='DELETE'")->fetch_assoc()['c'];
$conn->close();

$op_colors = ['INSERT'=>'var(--success)','UPDATE'=>'var(--warning)','DELETE'=>'var(--danger)'];
require_once '../includes/header.php';
?>

<!-- Log Detail Modal -->
<div class="modal-overlay" id="logModal">
  <div class="modal" style="max-width:680px">
    <div class="modal-header"><div class="modal-title" id="lgTitle">Log Details</div><button class="modal-close" onclick="CM('logModal')">✕</button></div>
    <div class="modal-body"><div id="lgBody"></div></div>
    <div class="modal-footer"><button class="btn btn-ghost" onclick="CM('logModal')">Close</button></div>
  </div>
</div>

<script>
injectLayout({page:'audit_logs',title:'Audit Logs',sub:'System transaction history'});
document.getElementById('pageContent').innerHTML=`

<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:20px">
  <div class="stat-card"><div class="stat-label">INSERT Events</div><div class="stat-value" style="color:var(--success)"><?= number_format($ins_count) ?></div></div>
  <div class="stat-card"><div class="stat-label">UPDATE Events</div><div class="stat-value" style="color:var(--warning)"><?= number_format($upd_count) ?></div></div>
  <div class="stat-card"><div class="stat-label">DELETE Events</div><div class="stat-value" style="color:var(--danger)"><?= number_format($del_count) ?></div></div>
</div>

<div class="toolbar">
  <form method="GET" style="display:flex;gap:10px;flex:1;flex-wrap:wrap;align-items:center">
    <div class="search-box"><span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span><input type="text" name="q" value="<?= e($q) ?>" placeholder="Search record ID, table, data…"/></div>
    <select class="filter-select" name="op" onchange="this.form.submit()">
      <option value="">All Operations</option>
      <option value="INSERT" <?= $op_f==='INSERT'?'selected':'' ?>>INSERT</option>
      <option value="UPDATE" <?= $op_f==='UPDATE'?'selected':'' ?>>UPDATE</option>
      <option value="DELETE" <?= $op_f==='DELETE'?'selected':'' ?>>DELETE</option>
    </select>
    <select class="filter-select" name="tbl" onchange="this.form.submit()">
      <option value="">All Tables</option>
      <?php foreach($tables as $t): ?><option value="<?= e($t['table_name']) ?>" <?= $tbl_f===$t['table_name']?'selected':'' ?>><?= e($t['table_name']) ?></option><?php endforeach; ?>
    </select>
    <?php if($q||$op_f||$tbl_f): ?><a href="audit_logs.php" style="font-size:12px;color:var(--text-muted)">Clear</a><?php endif; ?>
  </form>
</div>

<div class="table-wrap"><table>
  <thead><tr><th>Log ID</th><th>Operation</th><th>Table</th><th>Row ID</th><th>Before Value</th><th>After Value</th><th>Timestamp</th><th style="text-align:right">Detail</th></tr></thead>
  <tbody>
  <?php foreach($logs as $l):
    $op_color = $op_colors[$l['operation']] ?? 'var(--text-muted)';
    $old_clip = $l['old_data'] ? mb_strimwidth($l['old_data'],0,40,'…') : '<em style="color:var(--text-faint)">null</em>';
    $new_clip = $l['new_data'] ? mb_strimwidth($l['new_data'],0,40,'…') : '<em style="color:var(--text-faint)">null</em>';
    $detail_json = htmlspecialchars(json_encode($l), ENT_QUOTES);
  ?>
  <tr>
    <td class="td-mono">#<?= e($l['log_id']) ?></td>
    <td><strong style="color:<?= $op_color ?>;font-size:11px"><?= e($l['operation']) ?></strong></td>
    <td><code style="font-size:11px;background:var(--bg-surface2);padding:2px 6px;border-radius:4px;color:var(--accent)"><?= e($l['table_name']) ?></code></td>
    <td class="td-mono"><?= e($l['record_id'] ?? '—') ?></td>
    <td style="font-size:11px;color:var(--text-muted);max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= $old_clip ?></td>
    <td style="font-size:11px;color:var(--text-muted);max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= $new_clip ?></td>
    <td class="td-muted" style="white-space:nowrap"><?= e($l['changed_at']) ?></td>
    <td style="text-align:right"><button class="btn btn-ghost btn-sm" onclick='viewLog(<?= $detail_json ?>)'>View</button></td>
  </tr>
  <?php endforeach; if(!$logs): ?>
  <tr><td colspan="8" style="text-align:center;padding:40px;color:var(--text-muted)">No audit entries yet. Actions on the system will appear here automatically.</td></tr>
  <?php endif; ?>
  </tbody>
</table>
<div class="table-footer"><div class="table-count"><?= count($logs) ?> entries (showing max 300)</div></div>
</div>
`;

function viewLog(l){
  var opColor = {INSERT:'var(--success)',UPDATE:'var(--warning)',DELETE:'var(--danger)'}[l.operation]||'var(--text-muted)';
  document.getElementById('lgTitle').textContent = 'Log Entry #' + l.log_id;
  document.getElementById('lgBody').innerHTML =
    '<div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:16px">' +
      vf('Log ID',      '#'+l.log_id) +
      vf('Operation',   '<strong style="color:'+opColor+'">'+l.operation+'</strong>') +
      vf('Table',       '<code style="color:var(--accent)">'+l.table_name+'</code>') +
      vf('Row ID',   l.record_id||'—') +
      vf('Timestamp',   l.changed_at) +
      vf('Changed By',  l.changed_by||'system') +
    '</div>' +
    '<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">' +
      '<div><div style="font-size:11px;font-weight:700;color:var(--danger);text-transform:uppercase;letter-spacing:.07em;margin-bottom:6px">Before Value</div>' +
        '<pre style="background:var(--danger-dim);border:.5px solid var(--danger);border-radius:8px;padding:12px;font-size:11px;font-family:monospace;color:var(--danger);overflow:auto;max-height:200px;white-space:pre-wrap;word-break:break-all">'+(l.old_data||'null')+'</pre></div>' +
      '<div><div style="font-size:11px;font-weight:700;color:var(--success);text-transform:uppercase;letter-spacing:.07em;margin-bottom:6px">After Value</div>' +
        '<pre style="background:var(--success-dim);border:.5px solid var(--success);border-radius:8px;padding:12px;font-size:11px;font-family:monospace;color:var(--success);overflow:auto;max-height:200px;white-space:pre-wrap;word-break:break-all">'+(l.new_data||'null')+'</pre></div>' +
    '</div>';
  OM('logModal');
}
</script>
<?php require_once '../includes/footer.php'; ?>
