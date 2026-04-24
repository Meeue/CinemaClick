/* layout.js — shared shell injected on every page */

/* ── theme bootstrap (runs before paint) ── */
(function(){
  var saved = localStorage.getItem('cinema-theme') || 'dark';
  document.documentElement.setAttribute('data-theme', saved);
  document.body.setAttribute('data-theme', saved);
})();

function injectLayout(opts){
  opts = opts || {};
  var page        = opts.page        || '';
  var title       = opts.title       || '';
  var sub         = opts.sub         || '';
  var actionLabel = opts.actionLabel || null;

  var navItems = [
    {id:'dashboard', icon:'⬛', label:'Dashboard',  href:'dashboard.html',  section:'Main'},
    {id:'movies',    icon:'🎬', label:'Movies',     href:'movies.html'},
    {id:'showtimes', icon:'🕐', label:'Showtimes',  href:'showtimes.html'},
    {id:'bookings',  icon:'📋', label:'Bookings',   href:'bookings.html'},
    {id:'tickets',   icon:'🎟', label:'Tickets',    href:'tickets.html'},
    {id:'customers', icon:'👤', label:'Customers',  href:'customers.html'},
    {id:'cinemas',   icon:'🏛', label:'Cinemas',    href:'cinemas.html',    section:'Venue'},
    {id:'screens',   icon:'📺', label:'Screens',    href:'screens.html'},
    {id:'seats',     icon:'💺', label:'Seats',      href:'seats.html'},
    {id:'payments',  icon:'💳', label:'Payments',   href:'payments.html',   section:'Finance'},
  ];

  var navHtml = navItems.map(function(item){
    var sec = item.section
      ? '<div class="nav-section">'+item.section+'</div>'
      : '';
    var active = item.id === page ? ' active' : '';
    return sec +
      '<a class="nav-item'+active+'" href="'+item.href+'">'+
        '<span class="nav-icon">'+item.icon+'</span>'+item.label+
      '</a>';
  }).join('');

  var actionBtn = actionLabel
    ? '<button class="btn btn-primary" id="topbarAction">'+actionLabel+'</button>'
    : '<button class="btn btn-primary" id="topbarAction" style="display:none"></button>';

  var theme = document.body.getAttribute('data-theme') || 'dark';
  var toggleIcon = theme === 'dark' ? '☀️' : '🌙';
  var toggleTitle = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';

  document.getElementById('app').innerHTML =
    '<div class="sidebar">'+
      '<div class="sidebar-logo">'+
        '<div class="logo-mark">'+
          '<div class="logo-icon">🎬</div>'+
          '<div>'+
            '<div class="logo-text">CineAdmin</div>'+
            '<div class="logo-sub">Ticket Booking</div>'+
          '</div>'+
        '</div>'+
      '</div>'+
      '<nav class="nav">'+navHtml+'</nav>'+
    '</div>'+
    '<div class="main">'+
      '<div class="topbar">'+
        '<div class="topbar-left">'+
          '<div class="page-title">'+title+'</div>'+
          (sub ? '<div class="breadcrumb">'+sub+'</div>' : '')+
        '</div>'+
        '<div class="topbar-right">'+
          actionBtn+
          '<button class="theme-toggle" id="themeToggle" title="'+toggleTitle+'">'+toggleIcon+'</button>'+
          '<div class="avatar">AD</div>'+
        '</div>'+
      '</div>'+
      '<div class="content" id="pageContent"></div>'+
    '</div>';

  /* wire up toggle */
  document.getElementById('themeToggle').addEventListener('click', toggleTheme);
}

function toggleTheme(){
  var current = document.body.getAttribute('data-theme') || 'dark';
  var next = current === 'dark' ? 'light' : 'dark';
  document.body.setAttribute('data-theme', next);
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('cinema-theme', next);
  var btn = document.getElementById('themeToggle');
  if(btn){
    btn.textContent = next === 'dark' ? '☀️' : '🌙';
    btn.title = next === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
  }
}

/* ── helpers used across all pages ── */

function OM(id){ document.getElementById(id).classList.add('open'); }
function CM(id){ document.getElementById(id).classList.remove('open'); }

function RC(r){
  return {G:'r-G',PG:'r-PG','PG-13':'r-PG13',R:'r-R','R-18':'r-R18'}[r]||'';
}

function MN(mid){
  var m = movies.find(function(x){return x.movie_id===mid;});
  return m ? m.title : mid;
}

function ScrN(sid){
  var s = screens.find(function(x){return x.screen_id===sid;});
  return s ? s.screen_name : sid;
}

function CiN(cid){
  var c = cinemas.find(function(x){return x.cinema_id===cid;});
  return c ? c.cinema_name : cid;
}

function t12(t){
  if(!t) return '';
  var p = t.split(':'), h = +p[0], m = p[1];
  return (h%12||12)+':'+m+' '+(h<12?'AM':'PM');
}

function StL(sid){
  var s = showtimes.find(function(x){return x.showtime_id===sid;});
  if(!s) return sid;
  return MN(s.movie_id)+' · '+t12(s.start_time)+' · '+ScrN(s.screen_id);
}

function ABtns(vFn, eFn, dFn){
  return '<div class="actions">'+
    '<button class="btn btn-ghost btn-sm" onclick="'+vFn+'">View</button>'+
    '<button class="btn btn-ghost btn-sm" onclick="'+eFn+'">Edit</button>'+
    '<button class="btn btn-danger btn-sm" onclick="'+dFn+'">Del</button>'+
  '</div>';
}

function vf(label, value, full){
  return '<div class="vf'+(full?' full':'')+'">'+
    '<div class="vf-label">'+label+'</div>'+
    '<div class="vf-value">'+value+'</div>'+
  '</div>';
}

function showView(title, bodyHtml, onEdit){
  var overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML =
    '<div class="modal modal-sm" style="width:480px">'+
      '<div class="modal-header">'+
        '<div class="modal-title">'+title+'</div>'+
        '<button class="modal-close" onclick="this.closest(\'.modal-overlay\').remove()">✕</button>'+
      '</div>'+
      '<div class="modal-body">'+
        '<div class="view-grid">'+bodyHtml+'</div>'+
      '</div>'+
      '<div class="modal-footer">'+
        '<button class="btn btn-ghost" onclick="this.closest(\'.modal-overlay\').remove()">Close</button>'+
        (onEdit ? '<button class="btn btn-primary" id="viewEditBtn">Edit</button>' : '')+
      '</div>'+
    '</div>';
  document.body.appendChild(overlay);
  requestAnimationFrame(function(){ overlay.classList.add('open'); });
  overlay.addEventListener('click', function(e){ if(e.target===overlay) overlay.remove(); });
  if(onEdit){
    overlay.querySelector('#viewEditBtn').addEventListener('click', function(){
      overlay.remove();
      onEdit();
    });
  }
}

function showDelete(title, name, onConfirm){
  var overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML =
    '<div class="modal modal-sm">'+
      '<div class="modal-header">'+
        '<div class="modal-title">'+title+'</div>'+
        '<button class="modal-close" onclick="this.closest(\'.modal-overlay\').remove()">✕</button>'+
      '</div>'+
      '<div class="modal-body">'+
        '<div class="confirm-icon">🗑️</div>'+
        '<div class="confirm-msg">Are you sure you want to delete <span class="confirm-name">'+name+'</span>? This cannot be undone.</div>'+
      '</div>'+
      '<div class="modal-footer">'+
        '<button class="btn btn-ghost" onclick="this.closest(\'.modal-overlay\').remove()">Cancel</button>'+
        '<button class="btn btn-danger" id="confirmDelBtn">Delete</button>'+
      '</div>'+
    '</div>';
  document.body.appendChild(overlay);
  requestAnimationFrame(function(){ overlay.classList.add('open'); });
  overlay.addEventListener('click', function(e){ if(e.target===overlay) overlay.remove(); });
  overlay.querySelector('#confirmDelBtn').addEventListener('click', function(){
    overlay.remove();
    onConfirm();
  });
}

function makeTable(data, colCount, rowFn, bodyId, countId, pagId, perPage, pgObj){
  var total  = data.length;
  var pages  = Math.max(1, Math.ceil(total / perPage));
  if(pgObj.v > pages) pgObj.v = 1;
  var start  = (pgObj.v - 1) * perPage;
  var slice  = data.slice(start, start + perPage);

  var body = document.getElementById(bodyId);
  if(!slice.length){
    body.innerHTML = '<tr><td colspan="'+colCount+'" style="text-align:center;padding:32px;color:var(--text-muted);font-size:13px;">No results found</td></tr>';
  } else {
    body.innerHTML = slice.map(function(item){ return '<tr>'+rowFn(item)+'</tr>'; }).join('');
  }

  var count = document.getElementById(countId);
  if(count) count.textContent = total + ' record' + (total !== 1 ? 's' : '');

  var pag = document.getElementById(pagId);
  if(!pag) return;
  if(pages <= 1){ pag.innerHTML = ''; return; }
  var btns = '';
  for(var i = 1; i <= pages; i++){
    btns += '<button class="page-btn'+(i===pgObj.v?' active':'')+'" data-pg="'+i+'">'+i+'</button>';
  }
  pag.innerHTML = btns;
  pag.querySelectorAll('.page-btn').forEach(function(btn){
    btn.addEventListener('click', function(){
      pgObj.v = +this.dataset.pg;
      btn.dispatchEvent(new Event('repage', {bubbles:true}));
    });
  });
}