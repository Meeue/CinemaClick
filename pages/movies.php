<?php
require_once '../connect.php';
require_once '../includes/helpers.php';

$flash = $flash_type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act  = $_POST['_action'] ?? '';
    $conn = getMasterConn();

    if ($act === 'insert') {
        $id    = genId($conn, 'movies', 'movie_id', 'MOV');
        $title = $conn->real_escape_string(trim($_POST['title'] ?? ''));
        $genre = $conn->real_escape_string($_POST['genre'] ?? 'Action');
        $dur   = (int)($_POST['duration_minutes'] ?? 90);
        $rat   = $conn->real_escape_string($_POST['rating'] ?? 'G');
        $rdate = $conn->real_escape_string($_POST['release_date'] ?? date('Y-m-d'));
        $desc  = $conn->real_escape_string(trim($_POST['description'] ?? ''));
        $poster = '';
        if (!empty($_FILES['poster']['name'])) {
            $ext = strtolower(pathinfo($_FILES['poster']['name'], PATHINFO_EXTENSION));
            if (in_array($ext, ['jpg','jpeg','png','gif','webp'])) {
                $fname = $id . '.' . $ext;
                $dest  = '../uploads/posters/' . $fname;
                if (move_uploaded_file($_FILES['poster']['tmp_name'], $dest)) {
                    $poster = 'uploads/posters/' . $fname;
                }
            }
        }
        $poster = $conn->real_escape_string($poster);
        if ($title) {
            if ($conn->query("INSERT INTO movies VALUES ('$id','$title','$genre',$dur,'$rat','$rdate','$desc','$poster')")) {
                $flash = "Movie \"$title\" added successfully."; $flash_type = 'success';
            } else { $flash = 'Error: '.$conn->error; $flash_type = 'error'; }
        } else { $flash = 'Title is required.'; $flash_type = 'error'; }
    }

    if ($act === 'update') {
        $id    = $conn->real_escape_string($_POST['movie_id'] ?? '');
        $title = $conn->real_escape_string(trim($_POST['title'] ?? ''));
        $genre = $conn->real_escape_string($_POST['genre'] ?? '');
        $dur   = (int)($_POST['duration_minutes'] ?? 90);
        $rat   = $conn->real_escape_string($_POST['rating'] ?? 'G');
        $rdate = $conn->real_escape_string($_POST['release_date'] ?? '');
        $desc  = $conn->real_escape_string(trim($_POST['description'] ?? ''));
        $poster_clause = '';
        if (!empty($_FILES['poster']['name'])) {
            $ext = strtolower(pathinfo($_FILES['poster']['name'], PATHINFO_EXTENSION));
            if (in_array($ext, ['jpg','jpeg','png','gif','webp'])) {
                $fname = $id . '.' . $ext;
                $dest  = '../uploads/posters/' . $fname;
                if (move_uploaded_file($_FILES['poster']['tmp_name'], $dest)) {
                    $pv = $conn->real_escape_string('uploads/posters/'.$fname);
                    $poster_clause = ",poster_url='$pv'";
                }
            }
        }
        $sql = "UPDATE movies SET title='$title',genre='$genre',duration_minutes=$dur,rating='$rat',release_date='$rdate',description='$desc'$poster_clause WHERE movie_id='$id'";
        if ($conn->query($sql)) { $flash = "Movie updated."; $flash_type = 'success'; }
        else { $flash = 'Error: '.$conn->error; $flash_type = 'error'; }
    }

    if ($act === 'delete') {
        $id = $conn->real_escape_string($_POST['movie_id'] ?? '');
        $m  = $conn->query("SELECT title FROM movies WHERE movie_id='$id'")->fetch_assoc();
        if ($conn->query("DELETE FROM movies WHERE movie_id='$id'")) {
            $flash = "Movie \"{$m['title']}\" deleted."; $flash_type = 'success';
        } else { $flash = 'Error: '.$conn->error; $flash_type = 'error'; }
    }
    $conn->close();

    if (isAjax()) jsonResponse($flash, $flash_type);
}

$conn     = getSlaveConn();
$search   = $conn->real_escape_string(trim($_GET['q'] ?? ''));
$genre_f  = $conn->real_escape_string($_GET['genre']  ?? '');
$rating_f = $conn->real_escape_string($_GET['rating'] ?? '');
$sort     = $_GET['sort'] ?? 'newest';
$sort_map = [
    'newest'    => 'movie_id DESC',
    'oldest'    => 'movie_id ASC',
    'az'        => 'title ASC',
    'za'        => 'title DESC',
];
$order_by    = $sort_map[$sort] ?? 'movie_id DESC';
$sort_labels = ['newest'=>'Newest first','oldest'=>'Oldest first','az'=>'A–Z','za'=>'Z–A'];

$cond = [];
if ($search)   $cond[] = "(title LIKE '%$search%' OR genre LIKE '%$search%')";
if ($genre_f)  $cond[] = "genre='$genre_f'";
if ($rating_f) $cond[] = "rating='$rating_f'";
$where  = $cond ? 'WHERE '.implode(' AND ',$cond) : '';
$movies = $conn->query("SELECT * FROM movies $where ORDER BY $order_by")->fetch_all(MYSQLI_ASSOC);
$conn->close();

$genres  = ['Action','Adventure','Animation','Comedy','Drama','Horror','Romance','Sci-Fi','Thriller'];
$ratings = ['G','PG','PG-13','R','R-18'];
require_once '../includes/header.php';
?>

<!-- DELETE FORM -->
<form id="deleteForm" method="POST" style="display:none">
  <input type="hidden" name="_action" value="delete">
  <input type="hidden" name="movie_id" id="deleteId">
</form>

<!-- ADD MODAL -->
<div class="modal-overlay" id="addModal">
  <div class="modal">
    <div class="modal-header"><div class="modal-title">Add Movie</div><button class="modal-close" onclick="CM('addModal')">✕</button></div>
    <form method="POST" enctype="multipart/form-data" id="addForm">
      <input type="hidden" name="_action" value="insert">
      <div class="modal-body">
        <div class="form-grid">
          <div class="form-group full"><label class="form-label">Title *</label><input class="form-input" name="title" required placeholder="e.g. Avengers: Doomsday"/></div>
          <div class="form-group"><label class="form-label">Genre</label>
            <select class="form-select" name="genre"><?php foreach($genres as $g): ?><option><?= $g ?></option><?php endforeach; ?></select>
          </div>
          <div class="form-group"><label class="form-label">Rating</label>
            <select class="form-select" name="rating"><?php foreach($ratings as $r): ?><option><?= $r ?></option><?php endforeach; ?></select>
          </div>
          <div class="form-group"><label class="form-label">Duration (mins)</label><input class="form-input" name="duration_minutes" type="number" value="90" min="1"/></div>
          <div class="form-group"><label class="form-label">Release Date</label><input class="form-input" name="release_date" type="date" value="<?= date('Y-m-d') ?>"/></div>
          <div class="form-group full"><label class="form-label">Description</label><textarea class="form-textarea" name="description" placeholder="Short synopsis…"></textarea></div>
          <div class="form-group full"><label class="form-label">Movie Poster</label><input class="form-input" name="poster" type="file" accept="image/*" style="padding:6px"/></div>
        </div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('addModal')">Cancel</button><button type="submit" class="btn btn-primary">Save Movie</button></div>
    </form>
  </div>
</div>

<!-- EDIT MODAL -->
<div class="modal-overlay" id="editModal">
  <div class="modal">
    <div class="modal-header"><div class="modal-title">Edit Movie</div><button class="modal-close" onclick="CM('editModal')">✕</button></div>
    <form method="POST" enctype="multipart/form-data" id="editForm">
      <input type="hidden" name="_action" value="update">
      <input type="hidden" name="movie_id" id="e_id">
      <div class="modal-body">
        <div class="form-grid">
          <div class="form-group full"><label class="form-label">Title *</label><input class="form-input" name="title" id="e_title" required/></div>
          <div class="form-group"><label class="form-label">Genre</label>
            <select class="form-select" name="genre" id="e_genre"><?php foreach($genres as $g): ?><option><?= $g ?></option><?php endforeach; ?></select>
          </div>
          <div class="form-group"><label class="form-label">Rating</label>
            <select class="form-select" name="rating" id="e_rating"><?php foreach($ratings as $r): ?><option><?= $r ?></option><?php endforeach; ?></select>
          </div>
          <div class="form-group"><label class="form-label">Duration (mins)</label><input class="form-input" name="duration_minutes" id="e_dur" type="number" min="1"/></div>
          <div class="form-group"><label class="form-label">Release Date</label><input class="form-input" name="release_date" id="e_rdate" type="date"/></div>
          <div class="form-group full"><label class="form-label">Description</label><textarea class="form-textarea" name="description" id="e_desc"></textarea></div>
          <div class="form-group full"><label class="form-label">Replace Poster (optional)</label><input class="form-input" name="poster" type="file" accept="image/*" style="padding:6px"/></div>
        </div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-ghost" onclick="CM('editModal')">Cancel</button><button type="submit" class="btn btn-primary">Update Movie</button></div>
    </form>
  </div>
</div>

<script>
injectLayout({page:'movies', title:'Movies', sub:'Movie catalog management', actionLabel:'+ Add Movie'});
document.getElementById('topbarAction').onclick = function(){ OM('addModal'); };

document.getElementById('pageContent').innerHTML = `
<div class="toolbar">
  <form method="GET" id="sortForm" style="display:flex;gap:10px;align-items:center;flex:1;flex-wrap:wrap">
    <div class="search-box">
      <span class="search-icon"><i class="fa-solid fa-magnifying-glass" style="color:var(--accent)"></i></span>
      <input type="text" name="q" value="<?= e($search) ?>" placeholder="Search movies…"/>
    </div>
    <select class="filter-select" name="genre" onchange="this.form.submit()">
      <option value="">All Genres</option>
      <?php foreach($genres as $g): ?>
      <option value="<?= $g ?>" <?= $genre_f===$g?'selected':'' ?>><?= $g ?></option>
      <?php endforeach; ?>
    </select>
    <select class="filter-select" name="rating" onchange="this.form.submit()">
      <option value="">All Ratings</option>
      <?php foreach($ratings as $r): ?>
      <option value="<?= $r ?>" <?= $rating_f===$r?'selected':'' ?>><?= $r ?></option>
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
    <?php if ($search || $genre_f || $rating_f): ?><a href="movies.php" style="font-size:12px;color:var(--text-muted);white-space:nowrap">Clear</a><?php endif; ?>
  </form>
</div>

<div class="movies-grid" id="moviesGrid">
<?php if ($movies): foreach ($movies as $m):
    $poster = $m['poster_url'] ? '../'.$m['poster_url'] : '';
    $ratingCls = ['G'=>'r-G','PG'=>'r-PG','PG-13'=>'r-PG13','R'=>'r-R','R-18'=>'r-R18'][$m['rating']] ?? '';
?>
<div class="movie-card">
  <div class="movie-poster">
    <?php if ($poster): ?>
    <img src="<?= e($poster) ?>" alt="<?= e($m['title']) ?>"/>
    <?php else: ?>
    <div class="movie-poster-placeholder">
      <div class="poster-icon"><i class="fa-solid fa-file-import" style="color: #c96a3aff;"></i></div>
      <div class="poster-label">No Poster</div>
    </div>
    <?php endif; ?>
    <div class="movie-poster-badge"><span class="rating-badge <?= $ratingCls ?>"><?= e($m['rating']) ?></span></div>
    <label class="poster-upload-btn" onclick="openPosterUpload('<?= e($m['movie_id']) ?>', '<?= e(addslashes($m['title'])) ?>', '<?= e($m['genre']) ?>', '<?= $m['duration_minutes'] ?>', '<?= e($m['rating']) ?>', '<?= e($m['release_date']) ?>', \`<?= e(addslashes($m['description'])) ?>\`)">
      <i class="fa-solid fa-arrow-up-from-bracket" style="color: #c96a3aff;"></i> Change Poster
    </label>
  </div>
  <div class="movie-card-body">
    <div class="movie-card-title"><?= e($m['title']) ?></div>
    <div class="movie-card-meta"><?= e($m['genre']) ?> · <?= $m['duration_minutes'] ?> min</div>
    <div class="movie-card-footer">
      <span class="genre-tag"><?= e($m['release_date']) ?></span>
      <div class="movie-card-actions">
        <button class="btn btn-ghost btn-sm" onclick="openEdit('<?= e($m['movie_id']) ?>','<?= e(addslashes($m['title'])) ?>','<?= e($m['genre']) ?>','<?= $m['duration_minutes'] ?>','<?= e($m['rating']) ?>','<?= e($m['release_date']) ?>',\`<?= e(addslashes($m['description'] ?? '')) ?>\`)"><i class="fa-solid fa-pen-to-square" style="color: #7A7590;"></i></button>
        <button class="btn btn-danger btn-sm" onclick="doDelete('<?= e($m['movie_id']) ?>','<?= e(addslashes($m['title'])) ?>')"><i class="fa-solid fa-trash-can" style="color: #c96a3aff;"></i></button>
      </div>
    </div>
  </div>
</div>
<?php endforeach; else: ?>
<div style="grid-column:1/-1;text-align:center;padding:60px 24px;color:var(--text-muted)">
  <div style="font-size:48px;margin-bottom:12px;opacity:.3">🎬</div>
  <div>No movies found. <a href="movies.php" style="color:var(--accent)">Clear search</a></div>
</div>
<?php endif; ?>
</div>
`;

ajaxForm(document.getElementById('addForm'),  { closeModal: 'addModal'  });
ajaxForm(document.getElementById('editForm'), { closeModal: 'editModal' });

function toggleSort(){var d=document.getElementById('sortDrop');d.style.display=d.style.display==='block'?'none':'block';}
function setSort(val){document.getElementById('sortVal').value=val;document.getElementById('sortDrop').style.display='none';document.getElementById('sortForm').submit();}
document.addEventListener('click',function(e){var w=document.getElementById('sortWrap');if(w&&!w.contains(e.target))document.getElementById('sortDrop').style.display='none';});

function openEdit(id,title,genre,dur,rating,rdate,desc){
  document.getElementById('e_id').value    = id;
  document.getElementById('e_title').value = title;
  document.getElementById('e_genre').value = genre;
  document.getElementById('e_dur').value   = dur;
  document.getElementById('e_rating').value= rating;
  document.getElementById('e_rdate').value = rdate;
  document.getElementById('e_desc').value  = desc;
  OM('editModal');
}

function openPosterUpload(id,title,genre,dur,rating,rdate,desc){
  openEdit(id,title,genre,dur,rating,rdate,desc);
  setTimeout(function(){ document.querySelector('#editModal input[type=file]').click(); },300);
}

function doDelete(id, name){
  document.getElementById('deleteId').value = id;
  ajaxDelete(document.getElementById('deleteForm'), 'Delete Movie', '"'+name+'"');
}
</script>
<?php require_once '../includes/footer.php'; ?>