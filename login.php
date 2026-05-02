<?php
session_start();
$error = '';

if (!empty($_SESSION['admin'])) {
    header('Location: pages/dashboard.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $u = trim($_POST['username'] ?? '');
    $p = $_POST['password'] ?? '';
    require_once 'connect.php';
    $conn  = getMasterConn();
    $u_esc = $conn->real_escape_string($u);
    $row   = $conn->query("SELECT * FROM admins WHERE username='$u_esc' LIMIT 1")->fetch_assoc();
    $conn->close();
    if ($row && password_verify($p, $row['password'])) {
        $_SESSION['admin']       = true;
        $_SESSION['admin_id']    = $row['admin_id'];
        $_SESSION['admin_fname'] = $row['first_name'];
        $_SESSION['admin_lname'] = $row['last_name'];
        $_SESSION['admin_email'] = $row['email'];
        $_SESSION['admin_phone'] = $row['phone_number'];
        header('Location: pages/dashboard.php');
        exit;
    } else {
        $error = 'Invalid username or password.';
    }
}
?>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>CinemaClick - Login</title>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
<style>
*{box-sizing:border-box;margin:0;padding:0;}

:root,[data-theme="dark"]{
  --bg:          #0C0C14;
  --bg-sidebar:  #13121E;
  --bg-surface:  #1D1B2E;
  --bg-surface2: #23213a;
  --accent:      #C96A3A;
  --accent-hover:#A8552C;
  --accent-dim:  rgba(201,106,58,.14);
  --text:        #F0EAE0;
  --text-muted:  #7A7590;
  --text-faint:  rgba(240,234,224,.25);
  --border:      rgba(255,255,255,.07);
  --border-md:   rgba(255,255,255,.12);
  --danger:      #FF4520;
}

[data-theme="light"]{
  --bg:          #D8CFC4;
  --bg-sidebar:  #CFC4B6;
  --bg-surface:  #E4DDD4;
  --bg-surface2: #D4C9BC;
  --accent:      #B05E30;
  --accent-hover:#8F4C24;
  --accent-dim:  rgba(200,55,10,.1);
  --text:        #F0EAE0;
  --text-muted:  #c2beb9;
  --text-faint:  rgba(28,28,40,.45);
  --border:      rgba(28,28,40,.1);
  --border-md:   rgba(28,28,40,.25);
  --danger:      #C8370A;
}

body{
  font-family:'DM Sans',sans-serif;
  background:var(--bg);
  color:var(--text);
  min-height:100vh;
  display:flex;
  align-items:center;
  justify-content:center;
  transition:background .25s,color .25s;
}

.page-wrap{
  display:flex;
  width:min(960px,95vw);
  min-height:560px;
  border-radius:20px;
  overflow:hidden;
  box-shadow:0 32px 80px rgba(0,0,0,.5);
  border:.5px solid var(--border-md);
  animation:fadeUp .5s ease both;
}

@keyframes fadeUp{
  from{opacity:0;transform:translateY(24px);}
  to{opacity:1;transform:translateY(0);}
}

.left{
  flex:1;
  background:var(--bg-surface);
  padding:44px 48px;
  display:flex;
  flex-direction:column;
  justify-content:space-between;
  transition:background .25s;
}

.brand{display:flex;align-items:center;gap:10px;}
.brand-dot{width:10px;height:10px;border-radius:50%;background:var(--accent);}
.brand-name{font-size:14px;font-weight:600;color:var(--text);letter-spacing:.01em;}

.form-area{flex:1;display:flex;flex-direction:column;justify-content:center;padding:32px 0 0;}

.heading{font-size:32px;font-weight:700;color:var(--text);line-height:1.2;margin-bottom:8px;}
.subheading{font-size:13px;color:var(--text-muted);margin-bottom:36px;}

.form-field{margin-bottom:16px;position:relative;}
.form-field input{
  width:100%;
  background:var(--bg);
  border:.5px solid var(--border-md);
  border-radius:10px;
  padding:13px 16px 13px 44px;
  font-size:13px;
  color:var(--text);
  font-family:'DM Sans',sans-serif;
  outline:none;
  transition:border-color .2s,background .25s;
}
.form-field input::placeholder{color:var(--text-faint);}
.form-field input:focus{border-color:var(--accent);}
.field-icon{
  position:absolute;left:15px;top:50%;
  transform:translateY(-50%);
  color:var(--text-muted);font-size:13px;
  pointer-events:none;transition:color .2s;
}
.form-field:focus-within .field-icon{color:var(--accent);}

.toggle-pw{
  position:absolute;right:14px;top:50%;
  transform:translateY(-50%);
  background:none;border:none;
  color:var(--text-muted);cursor:pointer;font-size:12px;
  padding:4px;transition:color .15s;
}
.toggle-pw:hover{color:var(--accent);}

.form-extras{display:flex;align-items:center;justify-content:space-between;margin-bottom:28px;}
.remember{display:flex;align-items:center;gap:8px;font-size:12px;color:var(--text-muted);cursor:pointer;user-select:none;}
.remember input[type=checkbox]{
  appearance:none;width:16px;height:16px;
  border:.5px solid var(--border-md);border-radius:4px;
  background:var(--bg);cursor:pointer;transition:all .15s;position:relative;
}
.remember input[type=checkbox]:checked{background:var(--accent);border-color:var(--accent);}
.remember input[type=checkbox]:checked::after{
  content:'';position:absolute;left:4px;top:1px;
  width:5px;height:9px;border:2px solid #fff;
  border-top:none;border-left:none;transform:rotate(45deg);
}
.forgot{font-size:12px;color:var(--text-muted);text-decoration:none;transition:color .15s;}
.forgot:hover{color:var(--accent);}

.btn-login{
  width:100%;padding:13px;
  background:var(--accent);color:#fff;border:none;border-radius:10px;
  font-size:14px;font-weight:600;font-family:'DM Sans',sans-serif;
  cursor:pointer;transition:background .15s,transform .1s,box-shadow .15s;
  letter-spacing:.02em;box-shadow:0 4px 20px rgba(201,106,58,.35);
}
.btn-login:hover{background:var(--accent-hover);transform:translateY(-1px);box-shadow:0 6px 24px rgba(201,106,58,.45);}
.btn-login:active{transform:translateY(0);}

.error-msg{
  font-size:12px;color:var(--danger);margin-bottom:12px;
  padding:10px 14px;background:rgba(255,69,32,.08);
  border-radius:8px;border:.5px solid rgba(255,69,32,.25);
  display:flex;align-items:center;gap:8px;
}

.bottom-note{font-size:12px;color:var(--text-muted);padding-top:16px;text-align:center;}

.right{
  width:420px;flex-shrink:0;
  background:
    linear-gradient(145deg,rgba(12,12,20,.88) 0%,rgba(42,31,24,.82) 50%,rgba(30,21,16,.88) 100%),
    url("assets/js/back.jpg");
  background-size:cover;
  background-position:center;
  background-repeat:no-repeat;
  position:relative;overflow:hidden;
  display:flex;align-items:center;justify-content:center;
}

.filmstrip{position:absolute;top:0;bottom:0;width:28px;display:flex;flex-direction:column;gap:6px;padding:10px 4px;opacity:.12;}
.filmstrip.left-strip{left:0;}
.filmstrip.right-strip{right:0;}
.film-hole{width:20px;height:14px;border-radius:3px;background:rgba(255,255,255,.6);flex-shrink:0;}

.orb{position:absolute;border-radius:50%;filter:blur(60px);pointer-events:none;}
.orb1{width:280px;height:280px;background:rgba(201,106,58,.25);top:-60px;right:-40px;}
.orb2{width:200px;height:200px;background:rgba(201,106,58,.12);bottom:-40px;left:20px;}

.illustration{position:relative;z-index:2;display:flex;flex-direction:column;align-items:center;gap:24px;padding:40px 32px;}

.cinema-icon-wrap{position:relative;}
.big-icon{
  width:200px;height:200px;
  background: transparent;
  border-radius:28px;display:flex;align-items:center;justify-content:center;
  
  animation:float 3.5s ease-in-out infinite;
  overflow:hidden;
}
.big-icon img{
  width:100%;
  height:100%;
  object-fit:contain;
  display:block;
}
@keyframes float{0%,100%{transform:translateY(0);}50%{transform:translateY(-10px);}}


.right-text{text-align:center;}
.right-title{font-size:20px;font-weight:700;color:var(--text);margin-bottom:8px;line-height:1.3;}
.right-sub{font-size:12px;color:var(--text-muted);line-height:1.6;max-width:260px;}

.stats-row{display:flex;gap:16px;}
.stat-pill{background:rgba(255,255,255,.06);border:.5px solid var(--border-md);border-radius:10px;padding:10px 16px;text-align:center;flex:1;}
.stat-num{font-size:18px;font-weight:700;color:var(--accent);font-family:'DM Mono',monospace;}
.stat-lbl{font-size:9px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.08em;margin-top:2px;}

.theme-btn{
  position:fixed;top:20px;right:20px;
  width:34px;height:34px;border-radius:8px;
  border:.5px solid var(--border-md);background:var(--bg-surface2);
  color:var(--text-muted);cursor:pointer;font-size:14px;
  display:flex;align-items:center;justify-content:center;
  transition:all .2s;z-index:10;
}
.theme-btn:hover{background:var(--accent-dim);color:var(--accent);border-color:var(--accent);}
</style>
</head>
<body>



<div class="page-wrap">

  <!-- LEFT: Login Form -->
  <div class="left">
    <div class="brand">
      <div class="brand-dot"></div>
      <span class="brand-name" style="color: #7A7590;">CinemaClick</span>
    </div>

    <div class="form-area">
      <div class="heading" style="color: #7A7590;">Welcome,<br>Admin Portal</div>
      <div class="subheading" style="color: #7A7590;">Sign in to manage your cinema system</div>

      <?php if($error): ?>
      <div class="error-msg">
        <i class="fa-solid fa-circle-exclamation"></i>
        <?= htmlspecialchars($error) ?>
      </div>
      <?php endif; ?>

      <form method="POST" id="loginForm">
        <div class="form-field">
          <input type="text" name="username" placeholder="Username" autocomplete="username" required value="<?= htmlspecialchars($_POST['username'] ?? '') ?>"/>
          <span class="field-icon"><i class="fa-solid fa-user"></i></span>
        </div>
        <div class="form-field">
          <input type="password" name="password" id="pwField" placeholder="Password" autocomplete="current-password" required/>
          <span class="field-icon"><i class="fa-solid fa-lock"></i></span>
          <button type="button" class="toggle-pw" onclick="togglePw()">
            <i class="fa-solid fa-eye" id="eyeIcon"></i>
          </button>
        </div>
        <button type="submit" class="btn-login">
          <i class="fa-solid fa-right-to-bracket" style="margin-right:8px"></i>Sign In
        </button>
      </form>
    </div>

    <div class="bottom-note" style="color: #7A7590;">
      CinemaClick Admin &copy; <?= date('Y') ?> · All rights reserved
    </div>
  </div>

  <!-- RIGHT: Illustration -->
  <div class="right">
    <div class="orb orb1"></div>
    <div class="orb orb2"></div>

    <div class="filmstrip left-strip">
      <?php for($i=0;$i<30;$i++): ?><div class="film-hole"></div><?php endfor; ?>
    </div>
    <div class="filmstrip right-strip">
      <?php for($i=0;$i<30;$i++): ?><div class="film-hole"></div><?php endfor; ?>
    </div>

    <div class="illustration">
      <div class="cinema-icon-wrap">
        <div class="big-icon">
          <img src="assets/js/click.png" alt="CinemaClick logo">
        </div>
      </div>

      <div class="right-text">
        <div class="right-title">CinemaClick</div>
        <div class="right-sub">Manage movies, bookings, tickets, payments and more from one powerful dashboard.</div>
      </div>

      </div>
    </div>
  </div>

</div>

<button class="theme-btn" onclick="toggleTheme()" title="Toggle theme">
  <i class="fa-solid fa-sun" id="themeIcon" style="color:rgb(255,212,59)"></i>
</button>

<script>
(function(){
  var saved = localStorage.getItem('cinema-theme') || 'dark';
  document.documentElement.setAttribute('data-theme', saved);
  document.getElementById('themeIcon').className = saved === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
  document.getElementById('themeIcon').style.color = saved === 'dark' ? 'rgb(255,212,59)' : '#c96a3a';
})();

function toggleTheme(){
  var cur = document.documentElement.getAttribute('data-theme') || 'dark';
  var next = cur === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('cinema-theme', next);
  var icon = document.getElementById('themeIcon');
  icon.className = next === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
  icon.style.color = next === 'dark' ? 'rgb(255,212,59)' : '#c96a3a';
}

function togglePw(){
  var f = document.getElementById('pwField');
  var i = document.getElementById('eyeIcon');
  if(f.type === 'password'){
    f.type = 'text';
    i.className = 'fa-solid fa-eye-slash';
  } else {
    f.type = 'password';
    i.className = 'fa-solid fa-eye';
  }
}
</script>
</body>
</html>