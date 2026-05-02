<?php
session_start();
require_once '../connect.php';
require_once '../includes/helpers.php';
$flash = $flash_type = '';

// Logout
if (isset($_GET['logout'])) {
    session_destroy();
    header('Location: ../login.php');
    exit;
}

// Pull live stats from slave
$conn = getSlaveConn();
$stat_cinemas  = $conn->query("SELECT COUNT(*) AS c FROM cinemas")->fetch_assoc()['c'];
$stat_bookings = $conn->query("SELECT COUNT(*) AS c FROM bookings")->fetch_assoc()['c'];
$stat_movies   = $conn->query("SELECT COUNT(*) AS c FROM movies")->fetch_assoc()['c'];
$stat_screens  = $conn->query("SELECT COUNT(*) AS c FROM screens")->fetch_assoc()['c'];
$conn->close();

// Update personal info — saves to DB and session
if ($_SERVER["REQUEST_METHOD"] === "POST" && ($_POST["_action"] ?? "") === "update_profile") {
    $conn  = getMasterConn();
    $id    = $conn->real_escape_string($_SESSION['admin_id'] ?? '');
    $fname = $conn->real_escape_string(trim($_POST['first_name'] ?? ''));
    $lname = $conn->real_escape_string(trim($_POST['last_name']  ?? ''));
    $email = $conn->real_escape_string(trim($_POST['email']      ?? ''));
    $phone = $conn->real_escape_string(trim($_POST['phone']      ?? ''));
    $conn->query("UPDATE admins SET first_name='$fname',last_name='$lname',email='$email',phone_number='$phone',name='$fname $lname' WHERE admin_id='$id'");
    $_SESSION['admin_fname'] = $fname;
    $_SESSION['admin_lname'] = $lname;
    $_SESSION['admin_email'] = $email;
    $_SESSION['admin_phone'] = $phone;
    $conn->close();
    $flash = 'Profile updated successfully.'; $flash_type = 'success';
    if (isAjax()) jsonResponse($flash, $flash_type);
}

// Change password — verifies current, updates DB
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['_action'] ?? '') === 'change_password') {
    $conn    = getMasterConn();
    $id      = $conn->real_escape_string($_SESSION['admin_id'] ?? '');
    $current = $_POST['current_password']  ?? '';
    $new     = $_POST['new_password']      ?? '';
    $confirm = $_POST['confirm_password']  ?? '';
    $row     = $conn->query("SELECT password FROM admins WHERE admin_id='$id' LIMIT 1")->fetch_assoc();
    if (!$row || !password_verify($current, $row['password'])) {
        $flash = 'Current password is incorrect.'; $flash_type = 'error';
    } elseif ($new !== $confirm) {
        $flash = 'New passwords do not match.'; $flash_type = 'error';
    } elseif (strlen($new) < 6) {
        $flash = 'Password must be at least 6 characters.'; $flash_type = 'error';
    } else {
        $hash = $conn->real_escape_string(password_hash($new, PASSWORD_BCRYPT));
        $conn->query("UPDATE admins SET password='$hash' WHERE admin_id='$id'");
        $flash = 'Password changed successfully.'; $flash_type = 'success';
    }
    $conn->close();
    if (isAjax()) jsonResponse($flash, $flash_type);
}

$fname    = $_SESSION['admin_fname'] ?? 'Admin';
$lname    = $_SESSION['admin_lname'] ?? '';
$email    = $_SESSION['admin_email'] ?? '';
$phone    = $_SESSION['admin_phone'] ?? '';
$initials = strtoupper(substr($fname,0,1) . substr($lname,0,1));
$full_name = trim("$fname $lname");

require_once '../includes/header.php';
?>

<script>
injectLayout({page:'profile', title:'My Profile', sub:'Account settings'});
document.getElementById('pageContent').innerHTML = `
<div class="profile-layout">

  <!-- LEFT: Avatar card -->
  <div>
    <div class="profile-card">
      <div class="profile-avatar-lg" id="avatarCircle" onclick="document.getElementById('avatarFile').click()" title="Click to change photo">
        <span id="avatarInitials"><?= e($initials) ?></span>
        <img id="avatarImg" src="" style="display:none;width:100%;height:100%;object-fit:cover;border-radius:50%;position:absolute;top:0;left:0"/>
        <div class="profile-avatar-edit"><i class="fa-solid fa-pencil" style="color: rgb(207, 185, 105);"></i></div>
      </div>
      <input type="file" id="avatarFile" accept="image/*" style="display:none" onchange="handleAvatar(event)"/>
      <div class="profile-name" id="displayName"><?= e($full_name) ?></div>
      <div class="profile-role">Administrator</div>
      <hr class="profile-divider"/>
      <div class="profile-stats">
        <div class="profile-stat"><div class="profile-stat-val"><?= $stat_cinemas ?></div><div class="profile-stat-lbl">Cinemas</div></div>
        <div class="profile-stat"><div class="profile-stat-val"><?= $stat_bookings ?></div><div class="profile-stat-lbl">Bookings</div></div>
        <div class="profile-stat"><div class="profile-stat-val"><?= $stat_movies ?></div><div class="profile-stat-lbl">Movies</div></div>
        <div class="profile-stat"><div class="profile-stat-val"><?= $stat_screens ?></div><div class="profile-stat-lbl">Screens</div></div>
      </div>
      <hr class="profile-divider"/>
      <div style="font-size:11px;color:var(--text-muted);text-align:left;line-height:1.8">
        <div><i class="fa-solid fa-at" style="color: #c96a3a;"></i> <?= e($email) ?></div>
        <div><i class="fa-solid fa-mobile" style="color: #c96a3a;"></i> <?= e($phone ?: 'Not set') ?></div>
        <div><i class="fa-solid fa-calendar" style="color: #c96a3a;"></i> Member since 2024</div>
      </div>
      <hr class="profile-divider"/>
      <div style="display:flex;align-items:center;justify-content:space-between;padding:4px 0">
        <span style="font-size:12px;color:var(--text-muted)">Theme</span>
        <button onclick="toggleTheme()" style="background:var(--bg-surface2);border:.5px solid var(--border-md);border-radius:20px;padding:4px 14px;font-size:12px;color:var(--text-muted);cursor:pointer" id="themeBtn">
          <i class="fa-solid fa-moon" style="color: #c96a3a;"></i> Dark
        </button>
      </div>
      <hr class="profile-divider"/>
      <a href="javascript:void(0)" onclick="confirmLogout()" style="display:flex;align-items:center;justify-content:center;gap:8px;width:100%;padding:9px;background:var(--danger-dim);color:var(--danger);border:.5px solid var(--danger-dim);border-radius:8px;font-size:13px;font-weight:500;text-decoration:none;transition:all .15s" onmouseover="this.style.filter='brightness(1.2)'" onmouseout="this.style.filter='brightness(1)'">
        <i class="fa-solid fa-right-from-bracket"></i> Log Out
      </a>
    </div>
  </div>

  <!-- RIGHT: Edit forms -->
  <div class="profile-form-panel">

    <!-- Personal Info -->
    <div class="profile-form-section">
      <div class="profile-section-title">
        <div class="profile-section-icon"><i class="fa-solid fa-user" style="color: #c96a3a;"></i></div>
        Personal Information
      </div>
      <form method="POST" id="profileForm">
        <input type="hidden" name="_action" value="update_profile">
        <div class="form-grid">
          <div class="form-group"><label class="form-label">First Name</label><input class="form-input" name="first_name" value="<?= e($fname) ?>" required/></div>
          <div class="form-group"><label class="form-label">Last Name</label><input class="form-input" name="last_name" value="<?= e($lname) ?>" required/></div>
          <div class="form-group full"><label class="form-label">Email Address</label><input class="form-input" name="email" type="email" value="<?= e($email) ?>"/></div>
          <div class="form-group full"><label class="form-label">Phone Number</label><input class="form-input" name="phone" value="<?= e($phone) ?>" placeholder="09XX-XXX-XXXX"/></div>
          <div class="form-group full"><label class="form-label">Role</label><input class="form-input" value="Administrator" disabled style="opacity:.5"/></div>
        </div>
        <div style="display:flex;justify-content:flex-end;margin-top:16px">
          <button type="submit" class="btn btn-primary">Save Changes</button>
        </div>
      </form>
    </div>

    <!-- Change Password -->
    <div class="profile-form-section">
      <div class="profile-section-title">
        <div class="profile-section-icon"><i class="fa-solid fa-lock" style="color: #c96a3a;"></i></div>
        Change Password
      </div>
      <form method="POST" id="passwordForm">
        <input type="hidden" name="_action" value="change_password">
        <div class="form-grid">
          <div class="form-group full"><label class="form-label">Current Password</label><input class="form-input" name="current_password" type="password" placeholder="Enter current password"/></div>
          <div class="form-group"><label class="form-label">New Password</label><input class="form-input" name="new_password" type="password" placeholder="Min. 6 characters"/></div>
          <div class="form-group"><label class="form-label">Confirm New Password</label><input class="form-input" name="confirm_password" type="password" placeholder="Repeat new password"/></div>
        </div>
        <div style="display:flex;justify-content:flex-end;margin-top:16px">
          <button type="submit" class="btn btn-primary">Update Password</button>
        </div>
      </form>
    </div>

    <!-- System Info -->
    <div class="profile-form-section">
      <div class="profile-section-title">
        <div class="profile-section-icon"><i class="fa-solid fa-database" style="color: #c96a3a;"></i></div>
        Database Connection Status
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
        <div class="vf">
          <div class="vf-label">Master DB</div>
          <div class="vf-value" style="display:flex;align-items:center;gap:8px">
            <span style="width:8px;height:8px;border-radius:50%;background:var(--success);display:inline-block"></span>
            127.0.0.1:3306
          </div>
        </div>
        <div class="vf">
          <div class="vf-label">Slave DB</div>
          <div class="vf-value" style="display:flex;align-items:center;gap:8px">
            <span style="width:8px;height:8px;border-radius:50%;background:var(--success);display:inline-block"></span>
            127.0.0.1:3308
          </div>
        </div>
        <div class="vf"><div class="vf-label">Database</div><div class="vf-value">cinemaclick</div></div>
        <div class="vf"><div class="vf-label">PHP Version</div><div class="vf-value"><?= phpversion() ?></div></div>
        <div class="vf full"><div class="vf-label">Server Time</div><div class="vf-value"><?= date('F j, Y — g:i A') ?></div></div>
      </div>
    </div>

  </div>
</div>
`;

// Wire AJAX — profile doesn't need page reload on success (just update display)
ajaxForm(document.getElementById('profileForm'), {
  onSuccess: function(data){
    // Update display name from form values
    var fn = document.querySelector('[name=first_name]')?.value || '';
    var ln = document.querySelector('[name=last_name]')?.value  || '';
    var el = document.getElementById('displayName');
    if(el) el.textContent = fn + ' ' + ln;
  }
});
// Password form — no reload needed either; just show result
ajaxForm(document.getElementById('passwordForm'));

// Avatar upload preview
function handleAvatar(e){
  var file = e.target.files[0];
  if(!file) return;
  var reader = new FileReader();
  reader.onload = function(ev){
    var img = document.getElementById('avatarImg');
    img.src = ev.target.result;
    img.style.display = 'block';
    document.getElementById('avatarInitials').style.display = 'none';
    localStorage.setItem('cinema-profile-initials', document.getElementById('avatarInitials').textContent);
  };
  reader.readAsDataURL(file);
}

// Logout confirm modal
function confirmLogout(){
  var overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML =
    '<div class="modal modal-sm">'+
      '<div class="modal-header">'+
        '<div class="modal-title">Log Out</div>'+
        '<button class="modal-close" onclick="this.closest(\'.modal-overlay\').remove()">✕</button>'+
      '</div>'+
      '<div class="modal-body" style="padding:28px 22px;text-align:center">'+
        '<div class="confirm-icon"><i class="fa-solid fa-right-from-bracket" style="color:var(--danger);font-size:32px"></i></div>'+
        '<div class="confirm-msg">Are you sure you want to log out?<br>You will be redirected to the login page.</div>'+
      '</div>'+
      '<div class="modal-footer">'+
        '<button class="btn btn-ghost" onclick="this.closest(\'.modal-overlay\').remove()">Cancel</button>'+
        '<button class="btn btn-danger" onclick="window.location.href=\'profile.php?logout=1\'">Log Out</button>'+
      '</div>'+
    '</div>';
  document.body.appendChild(overlay);
  requestAnimationFrame(function(){ overlay.classList.add('open'); });
  overlay.addEventListener('click', function(e){ if(e.target===overlay) overlay.remove(); });
}
(function(){
  var t = localStorage.getItem('cinema-theme') || 'dark';
  var btn = document.getElementById('themeBtn');
  if(btn) btn.textContent = t === 'dark' ? '☀️ Light' : '🌙 Dark';
})();

var _origToggle = window.toggleTheme;
window.toggleTheme = function(){
  _origToggle();
  var t = localStorage.getItem('cinema-theme') || 'dark';
  var btn = document.getElementById('themeBtn');
  if(btn) btn.textContent = t === 'dark' ? '☀️ Light' : '🌙 Dark';
};
</script>
<?php require_once '../includes/footer.php'; ?>