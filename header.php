<?php
// includes/header.php
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
<title><?= htmlspecialchars($page_title) ?> — Cinema Admin</title>
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
<script src="<?= $base ?>assets/js/layout.js"></script>
