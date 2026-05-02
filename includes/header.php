<?php
// includes/header.php
if (session_status() === PHP_SESSION_NONE) session_start();
$page_title   = $page_title   ?? 'CinemaClick';
$page_key     = $page_key     ?? 'dashboard';
$page_sub     = $page_sub     ?? '';
$action_label = $action_label ?? '';

$in_pages = str_contains($_SERVER['SCRIPT_NAME'], '/pages/');
$base     = $in_pages ? '../' : './';
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0"/>
<title><?= htmlspecialchars($page_title) ?></title>
<link rel="stylesheet" href="<?= $base ?>assets/css/style.css"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
<script>
/* Apply theme before paint to avoid flash */
(function(){
  document.documentElement.setAttribute('data-theme', localStorage.getItem('cinema-theme')||'dark');
})();
</script>
</head>
<body>
<div class="app" id="app"></div>

<!-- load layout.js BEFORE any page script so injectLayout() is available -->
<script>
// Session data from PHP — used by layout.js for sidebar name/initials
window.ADMIN_NAME     = <?= json_encode(trim(($_SESSION['admin_fname'] ?? '') . ' ' . ($_SESSION['admin_lname'] ?? '')) ?: 'Administrator') ?>;
window.ADMIN_INITIALS = <?= json_encode(strtoupper(substr($_SESSION['admin_fname'] ?? 'A', 0, 1) . substr($_SESSION['admin_lname'] ?? 'D', 0, 1))) ?>;
</script>
<script src="<?= $base ?>assets/js/layout.js"></script>