<?php
// includes/helpers.php — shared utility functions

function pill(string $status): string {
    $map = [
        'Active'    => 'p-green',  'Confirmed' => 'p-green',
        'Paid'      => 'p-green',  'Available' => 'p-green',
        'Playing'   => 'p-green',
        'Pending'   => 'p-yellow', 'Inactive'  => 'p-gray',
        'Suspended' => 'p-red',    'Cancelled' => 'p-red',
        'Failed'    => 'p-red',    'Taken'     => 'p-red',
        'Refunded'  => 'p-purple', 'Maintenance'=> 'p-yellow',
        'Coming Soon'=> 'p-yellow',
    ];
    $cls = $map[$status] ?? 'p-gray';
    return '<span class="pill '.$cls.'">'.htmlspecialchars($status).'</span>';
}

function ratingBadge(string $r): string {
    $cls = ['G'=>'r-G','PG'=>'r-PG','PG-13'=>'r-PG13','R'=>'r-R','R-18'=>'r-R18'][$r] ?? '';
    return '<span class="rating-badge '.$cls.'">'.htmlspecialchars($r).'</span>';
}

function genId(mysqli $conn, string $table, string $pk, string $prefix, int $pad = 3): string {
    $len = strlen($prefix) + 1;
    $res = $conn->query("SELECT MAX(CAST(SUBSTRING($pk, $len) AS UNSIGNED)) AS mx FROM `$table`");
    $mx  = (int)($res->fetch_assoc()['mx'] ?? 0);
    return $prefix . str_pad($mx + 1, $pad, '0', STR_PAD_LEFT);
}

function e(string $s): string { return htmlspecialchars($s, ENT_QUOTES); }

/**
 * Send a JSON response for AJAX form submissions.
 * Call this after processing a POST action when the request is via fetch().
 */
function jsonResponse(string $msg, string $type = 'success'): void {
    header('Content-Type: application/json');
    echo json_encode(['message' => $msg, 'type' => $type]);
    exit;
}

/**
 * Detect if the current request is an AJAX/fetch call.
 * Pages set X-Requested-With: fetch in the ajaxForm() helper.
 */
function isAjax(): bool {
    return (
        (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'fetch') ||
        (isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'application/json') !== false)
    );
}

function flashMsg(string $msg, string $type = 'success'): string {
    if (!$msg) return '';
    $icon = $type === 'success' ? '✓' : '✕';
    $color = $type === 'success' ? 'var(--success)' : 'var(--danger)';
    return "<div id='flashMsg' style='position:fixed;bottom:24px;right:24px;z-index:9999;padding:10px 18px;border-radius:8px;font-size:13px;font-weight:500;color:#fff;background:$color;box-shadow:0 4px 16px rgba(0,0,0,.3)'>$icon &nbsp;".e($msg)."</div>
<script>setTimeout(function(){var m=document.getElementById('flashMsg');if(m){m.style.transition='opacity .3s';m.style.opacity='0';setTimeout(function(){m.remove()},350);}},2800);</script>";
}