/**
 * data.js — Shared in-memory data store for Cinema Booking System
 *
 * TODO (PHP/MySQL integration):
 *   Replace each array with an async fetch() call to your PHP API endpoints.
 *   Example endpoint pattern:
 *     GET  /api/movies.php          → returns JSON array of movies
 *     POST /api/movies.php          → insert new movie
 *     PUT  /api/movies.php?id=X     → update movie
 *     DELETE /api/movies.php?id=X   → delete movie
 *
 *   For phpMyAdmin master-slave setup:
 *     - All READ queries  → slave  DB (set DB_HOST_SLAVE in your PHP config)
 *     - All WRITE queries → master DB (set DB_HOST_MASTER in your PHP config)
 */

var movies = [
  {movie_id:'MOV-001', title:'Girl, Boy, Bakla, Tomboy', genre:'Comedy', duration_minutes:148, rating:'PG-13', release_date:'2024-03-15', description:'A hilarious comedy about gender, identity, and love set in a small Filipino town.', poster_url:''},
  {movie_id:'MOV-002', title:'Spongebob', genre:'Animation', duration_minutes:122, rating:'G', release_date:'2024-04-01', description:'The beloved sea sponge goes on an epic underwater adventure with his friends.', poster_url:''},
  {movie_id:'MOV-003', title:'Kung Fu Panda 2', genre:'Action', duration_minutes:105, rating:'PG', release_date:'2024-04-25', description:'Po must face his past while protecting China from the ruthless Lord Shen.', poster_url:''},
  {movie_id:'MOV-004', title:'Dune: Part Two', genre:'Sci-Fi', duration_minutes:166, rating:'PG-13', release_date:'2024-03-01', description:'Paul Atreides unites with Chani and the Fremen on a warpath of revenge.', poster_url:''},
];

var showtimes = [
  {showtime_id:'SHW-001', movie_id:'MOV-002', screen_id:'SCR-001', show_date:'2026-04-20', start_time:'10:00', end_time:'12:02', price:250},
  {showtime_id:'SHW-002', movie_id:'MOV-001', screen_id:'SCR-002', show_date:'2026-04-20', start_time:'12:30', end_time:'15:01', price:300},
  {showtime_id:'SHW-003', movie_id:'MOV-003', screen_id:'SCR-001', show_date:'2026-04-20', start_time:'15:00', end_time:'16:45', price:280},
  {showtime_id:'SHW-004', movie_id:'MOV-002', screen_id:'SCR-003', show_date:'2026-04-20', start_time:'18:15', end_time:'20:17', price:250},
  {showtime_id:'SHW-005', movie_id:'MOV-003', screen_id:'SCR-001', show_date:'2026-04-21', start_time:'21:00', end_time:'22:45', price:280},
];

var bookings = [
  {booking_id:'BK-00482', customer_id:'C001', customer_name:'Maria Santos',    showtime_id:'SHW-001', booking_date:'2026-04-20', total_amount:500,  booking_status:'Confirmed'},
  {booking_id:'BK-00481', customer_id:'C002', customer_name:'Juan dela Cruz',  showtime_id:'SHW-002', booking_date:'2026-04-20', total_amount:1200, booking_status:'Confirmed'},
  {booking_id:'BK-00480', customer_id:'C003', customer_name:'Ana Reyes',       showtime_id:'SHW-001', booking_date:'2026-04-19', total_amount:300,  booking_status:'Pending'},
  {booking_id:'BK-00479', customer_id:'C004', customer_name:'Pedro Lim',       showtime_id:'SHW-003', booking_date:'2026-04-19', total_amount:600,  booking_status:'Cancelled'},
  {booking_id:'BK-00478', customer_id:'C005', customer_name:'Rosa Garcia',     showtime_id:'SHW-004', booking_date:'2026-04-18', total_amount:750,  booking_status:'Confirmed'},
];

var cinemas = [
  {cinema_id:'CIN-001', cinema_name:'SM Seaside Cebu Cinema',     location:'SRP, Mambaling, Cebu City',          contact_number:'032-234-5678'},
  {cinema_id:'CIN-002', cinema_name:'Ayala Center Cebu Cinema',   location:'Cebu Business Park, Cebu City',      contact_number:'032-888-9900'},
  {cinema_id:'CIN-003', cinema_name:'Robinsons Galleria Cebu',    location:'Gen. Maxilom Ave., Cebu City',       contact_number:'032-412-7000'},
];

var screens = [
  {screen_id:'SCR-001', screen_name:'Screen 1', cinema_id:'CIN-001', total_seats:120},
  {screen_id:'SCR-002', screen_name:'Screen 2', cinema_id:'CIN-001', total_seats:100},
  {screen_id:'SCR-003', screen_name:'Screen 3', cinema_id:'CIN-002', total_seats:80},
  {screen_id:'SCR-004', screen_name:'Screen 1', cinema_id:'CIN-002', total_seats:150},
];

var seats = [];
(function(){
  var sid = 1;
  screens.forEach(function(sc){
    var rc = Math.ceil(sc.total_seats/10), RL = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    for(var r=0;r<rc;r++) for(var c=1;c<=10;c++){
      seats.push({
        seat_id:   'SEA-'+String(sid).padStart(3,'0'),
        screen_id: sc.screen_id,
        seat_number: RL[r]+c,
        seat_type: 'Standard',
        status:    Math.random()<0.3 ? 'Taken' : 'Available'
      });
      sid++;
    }
  });
})();

// Counters for auto-ID generation
var mvCtr = movies.length;
var stCtr = showtimes.length;
var bkCtr = 483;
var ciCtr = cinemas.length;
var scCtr = screens.length;

// ── Shared helpers ──────────────────────────────────────────
function RC(r){return{G:'r-G',PG:'r-PG','PG-13':'r-PG13',R:'r-R','R-18':'r-R18'}[r]||'r-G';}
function MN(id){var m=movies.find(function(x){return x.movie_id===id;});return m?m.title:id;}
function ScrN(id){var s=screens.find(function(x){return x.screen_id===id;});return s?s.screen_name:id;}
function CiN(id){var c=cinemas.find(function(x){return x.cinema_id===id;});return c?c.cinema_name:id;}
function StL(id){var s=showtimes.find(function(x){return x.showtime_id===id;});return s?(MN(s.movie_id)+' · '+s.show_date+' '+s.start_time):id;}
function t12(t){if(!t)return'—';var parts=t.split(':'),hh=+parts[0];return(hh%12||12)+':'+parts[1]+' '+(hh<12?'AM':'PM');}
function ABtns(v,e,d){return '<div class="actions" style="justify-content:flex-end"><button class="btn btn-ghost btn-sm" onclick="'+v+'">View</button><button class="btn btn-ghost btn-sm" onclick="'+e+'">Edit</button><button class="btn btn-danger btn-sm" onclick="'+d+'">Delete</button></div>';}

// ── Shared modal helpers ─────────────────────────────────────
function OM(id){document.getElementById(id).classList.add('open');}
function CM(id){document.getElementById(id).classList.remove('open');}

function showView(title,html,editFn){
  document.getElementById('vwTitle').textContent=title;
  document.getElementById('vwBody').innerHTML=html;
  var eb=document.getElementById('vwEditBtn');
  if(editFn){eb.style.display='';eb.onclick=function(){CM('viewModal');setTimeout(editFn,150);};}
  else eb.style.display='none';
  OM('viewModal');
}

function showDelete(title,name,fn){
  document.getElementById('delTitle').textContent=title;
  document.getElementById('delName').textContent='"'+name+'"';
  document.getElementById('delConfirm').onclick=function(){fn();CM('deleteModal');};
  OM('deleteModal');
}

function vf(l,v,full){return'<div class="vf'+(full?' full':'')+'"><div class="vf-label">'+l+'</div><div class="vf-value">'+(v||'—')+'</div></div>';}

// ── Generic paginated table ──────────────────────────────────
function makeTable(data,cols,rowFn,tbId,ctId,pgId,per,pg){
  var tot=data.length, tp=Math.max(1,Math.ceil(tot/per));
  if(pg.v>tp) pg.v=tp;
  var slice=data.slice((pg.v-1)*per, pg.v*per);
  var tb=document.getElementById(tbId); tb.innerHTML='';
  if(!slice.length){
    tb.innerHTML='<tr><td colspan="'+cols+'"><div class="empty-state"><div class="empty-icon">🔍</div><div class="empty-text">No records found</div></div></td></tr>';
  } else {
    slice.forEach(function(d){var tr=document.createElement('tr');tr.innerHTML=rowFn(d);tb.appendChild(tr);});
  }
  document.getElementById(ctId).textContent='Showing '+slice.length+' of '+tot+' record'+(tot!==1?'s':'');
  var pg_el=document.getElementById(pgId); pg_el.innerHTML='';
  for(var p=1;p<=tp;p++){
    (function(p){
      var b=document.createElement('button');
      b.className='page-btn'+(p===pg.v?' active':'');
      b.textContent=p;
      b.onclick=function(){pg.v=p;b.dispatchEvent(new CustomEvent('repage'));};
      pg_el.appendChild(b);
    })(p);
  }
}

// ── Shared modal overlay close on backdrop click ─────────────
document.addEventListener('DOMContentLoaded',function(){
  document.querySelectorAll('.modal-overlay').forEach(function(o){
    o.addEventListener('click',function(e){if(e.target===o)o.classList.remove('open');});
  });
});
