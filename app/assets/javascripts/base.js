//= require jquery
//= require jquery_ujs
//= require moment
//= require moment/pt-br.js
//= require moment/es.js
//= require_self

var WEBY = {};

WEBY.toggleContrast = function(){
  var flag = localStorage.getItem('contrast') == 1 ? 0 : 1;
  localStorage.setItem('contrast', flag);
  /// save on users preferences
  var user = $('.user-avatar');
  if (user.length > 0) {
    $.post(user.data('pref'), {contrast: flag}, function(data){
      if(data.ok){
        //ok
      }else{
        //do something
      }
    });
  }
};

WEBY.checkContrast = function(){
  var cont = $('.contrast-css');
  if (cont.length > 0){
    if (cont.hasClass('active')) { ///if active class is present, it means contrast was set on backend
      localStorage.setItem('contrast', 1);
    }
  }
}

WEBY.applyContrast = function(){
  var flag = localStorage.getItem('contrast');
  var cont = $('.contrast-css');
  if (flag != 1) {
    if (cont.length > 0) cont.removeClass('active').attr('href', '');
    $('body').removeClass('contrast-mode');
    $('.toggle-contrast').each(function(){
      if ($(this).data('original-title')) $(this).attr('title', $(this).data('original-title'));
    });
  } else {
    if (cont.length > 0) cont.attr('href', cont.data('src')).addClass('active');
    $('body').addClass('contrast-mode');
    $('.toggle-contrast').each(function(){
      if ($(this).data('alt-title')) $(this).data('original-title', $(this).attr('title')).attr('title', $(this).data('alt-title'));
    });
  }
  /// contrast images
  $('[data-contrast-src]').each(function(){
    var $this = $(this);
    if (flag != 1) {
      if ($this.data('original-src')) $this.attr('src', $this.data('original-src'));
    } else {
      $this.data('original-src', $this.attr('src'));
      $this.attr('src', $this.data('contrast-src'));
    }
  });
};

WEBY.initAlbumPhoto = function(elem, photosData, initialIdx){
  var $overlay = $(elem);
  var $photoStage = $overlay.find('.photo-viewer-content');
  var $stage = $overlay.find('.photo-cube-stage, .photo-viewer-photo');
  var $viewport = $stage.find('.photo-cube-viewport');
  var $faceActive = $stage.find('.photo-cube-face.face-active');
  var $faceIncoming = $stage.find('.photo-cube-face.face-incoming');
  var $header = $overlay.find('.photo-viewer-header');
  var $caption = $overlay.find('.photo-viewer-caption');
  var $backdrop = $overlay.find('.photo-viewer-backdrop');
  var $counter = $overlay.find('.photo-counter-badge');
  var $title = $overlay.find('.photo-album-title');
  var $downloadBtn = $overlay.find('.download-btn');
  var $zoomBtn = $overlay.find('.zoom-btn');

  // Garante que o container possua a estrutura de cubo 3D
  if (!$viewport.length) {
    var $existingImg = $stage.find('img');
    var existingSrc = $existingImg.attr('src') || '';
    var existingAlt = $existingImg.attr('alt') || '';
    $stage.addClass('photo-cube-stage').empty().append([
      '<div class="photo-cube-viewport">',
        '<div class="photo-cube-face face-active">',
          '<img class="viewer-img" src="' + existingSrc + '" alt="' + existingAlt + '" draggable="false" />',
          '<div class="cube-face-shadow"></div>',
        '</div>',
        '<div class="photo-cube-face face-incoming" style="display: none;">',
          '<img class="viewer-img-incoming" src="" alt="" draggable="false" />',
          '<div class="cube-face-shadow"></div>',
        '</div>',
      '</div>'
    ].join(''));
    $viewport = $stage.find('.photo-cube-viewport');
    $faceActive = $stage.find('.photo-cube-face.face-active');
    $faceIncoming = $stage.find('.photo-cube-face.face-incoming');
  }

  var $img = $faceActive.find('img');

  // 1. Obter a coleção completa de todas as fotos do álbum para navegação irrestrita
  var photos = photosData || null;

  if (!photos) {
    // Tenta ler do manifesto geral do álbum na página
    var $manifest = $('#album-all-photos-data');
    if ($manifest.length && $manifest.text().trim() !== '') {
      try {
        photos = JSON.parse($manifest.text());
      } catch(e) {
        photos = null;
      }
    }
  }

  if (!photos) {
    // Tenta ler do manifesto embutido no elemento do viewer
    var $overlayManifest = $overlay.find('.album-photos-manifest');
    if ($overlayManifest.length && $overlayManifest.text().trim() !== '') {
      try {
        photos = JSON.parse($overlayManifest.text());
      } catch(e) {
        photos = null;
      }
    }
  }

  // Fallback: extrai da grade da página atual se não houver manifesto
  if (!photos && $('.modern-photos-grid .photo-card-link').length > 0) {
    photos = [];
    $('.modern-photos-grid .photo-card-link').each(function(){
      var $link = $(this);
      photos.push({
        id: $link.data('photo-id'),
        fullUrl: $link.data('full-url') || $link.attr('href'),
        previewUrl: $link.data('preview-url') || $link.find('img').attr('src'),
        thumbUrl: $link.data('thumb-url'),
        title: $link.data('title') || $('.modern-photos-grid').data('album-title') || '',
        description: $link.data('description') || '',
        downloadUrl: $link.data('download-url') || '#',
        views: $link.data('views') || 0,
        categories: $link.data('categories') ? $link.data('categories').toString().split(', ') : []
      });
    });
  }

  var currentIndex = (typeof initialIdx === 'number') ? initialIdx : 0;
  if (photos && typeof initialIdx !== 'number') {
    var curPhotoId = $stage.data('photo-id');
    for (var i = 0; i < photos.length; i++) {
      if (photos[i].id == curPhotoId) {
        currentIndex = i;
        break;
      }
    }
  }

  var isZoomed = false;
  var zoomScale = 2.2;
  var isDragging = false;
  var startX = 0, startY = 0;
  var currentX = 0, currentY = 0;
  var deltaX = 0, deltaY = 0;
  var startTime = 0;
  var swipeDirection = null;
  var isClosing = false;
  var isAnimating = false;
  var lastTapTime = 0;
  var panX = 0, panY = 0;
  var startPanX = 0, startPanY = 0;
  var dragIncomingPrepared = null;

  function resetZoom() {
    isZoomed = false;
    panX = 0;
    panY = 0;
    $zoomBtn.html('<i class="fa fa-search-plus"></i>').attr('title', 'Ampliar');
    $stage.removeClass('is-zoomed');
    $faceActive.find('img').css({
      transition: 'transform 0.24s cubic-bezier(0.16, 1, 0.3, 1)',
      transform: 'translate3d(0, 0, 0) scale(1)',
      cursor: ''
    });
  }

  function toggleZoom() {
    isZoomed = !isZoomed;
    var $activeImg = $faceActive.find('img');
    if (isZoomed) {
      $zoomBtn.html('<i class="fa fa-search-minus"></i>').attr('title', 'Reduzir');
      $stage.addClass('is-zoomed');
      panX = 0;
      panY = 0;
      $activeImg.css({
        transition: 'transform 0.28s cubic-bezier(0.16, 1, 0.3, 1)',
        transform: 'translate3d(0, 0, 0) scale(' + zoomScale + ')',
        cursor: 'grab'
      });
    } else {
      resetZoom();
    }
  }

  function toggleChrome() {
    $overlay.toggleClass('chrome-hidden');
  }

  function preloadAdjacent(idx) {
    if (!photos) return;
    if (photos[idx + 1]) {
      new Image().src = photos[idx + 1].previewUrl || photos[idx + 1].fullUrl;
    }
    if (photos[idx - 1]) {
      new Image().src = photos[idx - 1].previewUrl || photos[idx - 1].fullUrl;
    }
  }

  function updateMeta(idx) {
    if (!photos || photos.length === 0) return;
    var photo = photos[idx];

    // Atualiza contador: "1 / 150", "25 / 150", etc.
    if ($counter.length) {
      $counter.text((idx + 1) + ' / ' + photos.length);
    }
    if (photo.title && $title.length) {
      $title.text(photo.title);
    }
    if (photo.downloadUrl && $downloadBtn.length) {
      $downloadBtn.attr('href', photo.downloadUrl);
    }

    if ($caption.length) {
      var $desc = $caption.find('.caption-description');
      if (photo.description && photo.description.trim() !== '') {
        if ($desc.length) $desc.text(photo.description).show();
        else $caption.prepend('<div class="caption-description">' + $('<div>').text(photo.description).html() + '</div>');
      } else {
        $desc.hide();
      }

      var $views = $caption.find('.views-count, .caption-views');
      if (photo.views !== undefined && $views.length) {
        $views.html('<i class="fa fa-eye"></i> ' + photo.views);
      }

      var $cats = $caption.find('.caption-categories');
      if (photo.categories && photo.categories.length) {
        var pills = photo.categories.filter(Boolean).map(function(c){
          return '<span class="cat-pill">' + $('<div>').text(c).html() + '</span>';
        }).join('');
        $cats.html(pills).show();
      } else {
        $cats.empty().hide();
      }
    }

    // Controle de setas de navegação (continua até a última foto do álbum)
    if (idx === 0) {
      $overlay.find('.ctrl-prev').addClass('disabled').css('opacity', '0.25');
    } else {
      $overlay.find('.ctrl-prev').removeClass('disabled').css('opacity', '');
    }

    if (idx === photos.length - 1) {
      $overlay.find('.ctrl-next').addClass('disabled').css('opacity', '0.25');
    } else {
      $overlay.find('.ctrl-next').removeClass('disabled').css('opacity', '');
    }
  }

  // --- Transição em Cubo 3D Estilizado ---
  function rotateCube(targetIdx, direction) {
    if (!photos || photos.length === 0) return;
    if (isAnimating || targetIdx === currentIndex) return;
    if (targetIdx < 0 || targetIdx >= photos.length) return;

    resetZoom();
    isAnimating = true;

    currentIndex = targetIdx;
    var nextPhoto = photos[currentIndex];

    updateMeta(currentIndex);

    var stageWidth = $stage.width() || window.innerWidth;
    var depth = Math.round(stageWidth / 2);

    var $incomingImg = $faceIncoming.find('img');
    $incomingImg.attr('src', nextPhoto.previewUrl || nextPhoto.fullUrl);
    $incomingImg.attr('alt', nextPhoto.description || nextPhoto.title || '');

    if (nextPhoto.fullUrl && nextPhoto.fullUrl !== nextPhoto.previewUrl) {
      var highRes = new Image();
      highRes.onload = function() {
        if (currentIndex === targetIdx) $incomingImg.attr('src', nextPhoto.fullUrl);
      };
      highRes.src = nextPhoto.fullUrl;
    }

    var startActiveAngle = 0;
    var endActiveAngle = (direction === 'next') ? -90 : 90;
    var startIncomingAngle = (direction === 'next') ? 90 : -90;
    var endIncomingAngle = 0;

    // Posiciona as faces no espaço tridimensional
    $faceActive.css({
      transition: 'none',
      transform: 'translateZ(' + depth + 'px) rotateY(' + startActiveAngle + 'deg)',
      zIndex: 2,
      display: 'flex'
    });
    $faceActive.find('.cube-face-shadow').css({
      transition: 'none',
      opacity: 0
    });

    $faceIncoming.css({
      transition: 'none',
      transform: 'translateZ(' + depth + 'px) rotateY(' + startIncomingAngle + 'deg)',
      zIndex: 1,
      display: 'flex'
    });
    $faceIncoming.find('.cube-face-shadow').css({
      transition: 'none',
      opacity: 0.75
    });

    // Força reflow do navegador para engajar animação de cubo 3D
    if ($faceIncoming[0]) $faceIncoming[0].offsetHeight;

    var animDuration = '400ms';
    var animEasing = 'cubic-bezier(0.25, 1, 0.4, 1)';

    $faceActive.css({
      transition: 'transform ' + animDuration + ' ' + animEasing,
      transform: 'translateZ(' + depth + 'px) rotateY(' + endActiveAngle + 'deg)'
    });
    $faceActive.find('.cube-face-shadow').css({
      transition: 'opacity ' + animDuration + ' ' + animEasing,
      opacity: 0.75
    });

    $faceIncoming.css({
      transition: 'transform ' + animDuration + ' ' + animEasing,
      transform: 'translateZ(' + depth + 'px) rotateY(' + endIncomingAngle + 'deg)'
    });
    $faceIncoming.find('.cube-face-shadow').css({
      transition: 'opacity ' + animDuration + ' ' + animEasing,
      opacity: 0
    });

    setTimeout(function(){
      // Inverte referências das faces para o próximo ciclo
      var $temp = $faceActive;
      $faceActive = $faceIncoming;
      $faceIncoming = $temp;
      $img = $faceActive.find('img');

      $faceActive.removeClass('face-incoming').addClass('face-active').css({
        transition: 'none',
        transform: 'translateZ(' + depth + 'px) rotateY(0deg)',
        zIndex: 2
      });
      $faceIncoming.removeClass('face-active').addClass('face-incoming').css({
        transition: 'none',
        display: 'none',
        zIndex: 1
      });

      isAnimating = false;
      preloadAdjacent(currentIndex);
    }, 420);
  }

  function initSlide(idx) {
    if (!photos || photos.length === 0) return;
    if (idx < 0) idx = 0;
    if (idx >= photos.length) idx = photos.length - 1;
    currentIndex = idx;
    var photo = photos[idx];

    updateMeta(currentIndex);

    var stageWidth = $stage.width() || window.innerWidth;
    var depth = Math.round(stageWidth / 2);

    $img = $faceActive.find('img');
    $img.attr('src', photo.previewUrl || photo.fullUrl);
    $img.attr('alt', photo.description || photo.title || '');

    $faceActive.css({
      transition: 'none',
      transform: 'translateZ(' + depth + 'px) rotateY(0deg)',
      display: 'flex',
      zIndex: 2
    });
    $faceActive.find('.cube-face-shadow').css({ opacity: 0 });

    $faceIncoming.css({
      display: 'none',
      zIndex: 1
    });

    if (photo.fullUrl && photo.fullUrl !== photo.previewUrl) {
      var highRes = new Image();
      highRes.onload = function(){
        if (currentIndex === idx) $img.attr('src', photo.fullUrl);
      };
      highRes.src = photo.fullUrl;
    }

    preloadAdjacent(currentIndex);
  }

  function closeViewer(flyDirection) {
    if (isClosing) return;
    isClosing = true;
    $(document).off('keydown.photoViewer');

    var flyY = flyDirection === 'down' ? '70vh' : (flyDirection === 'up' ? '-70vh' : '0');
    var flyScale = flyDirection ? 0.75 : 0.94;

    $faceActive.css({
      transition: 'transform 0.22s ease-in, opacity 0.22s ease-in',
      transform: 'translate3d(0, ' + flyY + ', 0) scale(' + flyScale + ')',
      opacity: 0
    });

    $overlay.fadeOut(200, function(){
      $overlay.remove();
      $('body').css({overflow: ''});
    });
  }

  // --- Handlers de Gestos Touch e Arrastar no Celular (Cubo 3D Interativo) ---
  function onGestureStart(e) {
    if (isClosing || isAnimating) return;
    var touch = e.touches ? e.touches[0] : e;
    startX = touch.clientX;
    startY = touch.clientY;
    currentX = startX;
    currentY = startY;
    deltaX = 0;
    deltaY = 0;
    startTime = Date.now();
    isDragging = true;
    swipeDirection = null;
    dragIncomingPrepared = null;

    if (isZoomed) {
      startPanX = panX;
      startPanY = panY;
    }
  }

  function onGestureMove(e) {
    if (!isDragging || isClosing || isAnimating) return;
    var touch = e.touches ? e.touches[0] : e;
    currentX = touch.clientX;
    currentY = touch.clientY;
    deltaX = currentX - startX;
    deltaY = currentY - startY;

    if (isZoomed) {
      if (e.cancelable) e.preventDefault();
      panX = startPanX + deltaX;
      panY = startPanY + deltaY;
      $faceActive.find('img').css({
        transition: 'none',
        transform: 'translate3d(' + panX + 'px, ' + panY + 'px, 0) scale(' + zoomScale + ')'
      });
      return;
    }

    if (!swipeDirection) {
      if (Math.abs(deltaX) > 8 || Math.abs(deltaY) > 8) {
        swipeDirection = (Math.abs(deltaX) > Math.abs(deltaY)) ? 'horizontal' : 'vertical';
      }
    }

    if (swipeDirection === 'horizontal') {
      if (e.cancelable) e.preventDefault();

      var stageWidth = $stage.width() || window.innerWidth;
      var depth = Math.round(stageWidth / 2);
      var isFirst = (currentIndex === 0 && deltaX > 0);
      var isLast = (currentIndex === (photos.length - 1) && deltaX < 0);
      var resistance = (isFirst || isLast) ? 0.25 : 1;
      var moveX = deltaX * resistance;

      var ratio = Math.max(-1, Math.min(1, moveX / stageWidth));
      var activeAngle = ratio * 90;

      if (deltaX < 0 && currentIndex < photos.length - 1) {
        // Puxando cubo para a esquerda (foto seguinte entrando pela direita)
        var targetPhoto = photos[currentIndex + 1];
        if (dragIncomingPrepared !== currentIndex + 1) {
          dragIncomingPrepared = currentIndex + 1;
          var $incImg = $faceIncoming.find('img');
          $incImg.attr('src', targetPhoto.previewUrl || targetPhoto.fullUrl);
          $faceIncoming.css('display', 'flex');
        }
        var incomingAngle = 90 + activeAngle;
        $faceActive.css({
          transition: 'none',
          transform: 'translateZ(' + depth + 'px) rotateY(' + activeAngle + 'deg)'
        });
        $faceActive.find('.cube-face-shadow').css({
          transition: 'none',
          opacity: Math.abs(ratio) * 0.75
        });
        $faceIncoming.css({
          transition: 'none',
          transform: 'translateZ(' + depth + 'px) rotateY(' + incomingAngle + 'deg)'
        });
        $faceIncoming.find('.cube-face-shadow').css({
          transition: 'none',
          opacity: Math.max(0, (1 - Math.abs(ratio)) * 0.75)
        });
      } else if (deltaX > 0 && currentIndex > 0) {
        // Puxando cubo para a direita (foto anterior entrando pela esquerda)
        var targetPhoto = photos[currentIndex - 1];
        if (dragIncomingPrepared !== currentIndex - 1) {
          dragIncomingPrepared = currentIndex - 1;
          var $incImg = $faceIncoming.find('img');
          $incImg.attr('src', targetPhoto.previewUrl || targetPhoto.fullUrl);
          $faceIncoming.css('display', 'flex');
        }
        var incomingAngle = -90 + activeAngle;
        $faceActive.css({
          transition: 'none',
          transform: 'translateZ(' + depth + 'px) rotateY(' + activeAngle + 'deg)'
        });
        $faceActive.find('.cube-face-shadow').css({
          transition: 'none',
          opacity: Math.abs(ratio) * 0.75
        });
        $faceIncoming.css({
          transition: 'none',
          transform: 'translateZ(' + depth + 'px) rotateY(' + incomingAngle + 'deg)'
        });
        $faceIncoming.find('.cube-face-shadow').css({
          transition: 'none',
          opacity: Math.max(0, (1 - Math.abs(ratio)) * 0.75)
        });
      } else {
        // Primeira ou última foto (resistência elástica)
        $faceActive.css({
          transition: 'none',
          transform: 'translateZ(' + depth + 'px) rotateY(' + activeAngle + 'deg)'
        });
      }
    } else if (swipeDirection === 'vertical') {
      if (e.cancelable) e.preventDefault();
      // Pull to dismiss
      var progress = Math.min(Math.abs(deltaY) / 350, 0.85);
      var scale = Math.max(0.72, 1 - progress * 0.28);
      var opacity = Math.max(0.15, 1 - progress);

      $faceActive.css({
        transition: 'none',
        transform: 'translate3d(0, ' + deltaY + 'px, 0) scale(' + scale + ')'
      });
      $backdrop.css('opacity', opacity);
      $header.css('opacity', Math.max(0, 1 - progress * 2.5));
      $caption.css('opacity', Math.max(0, 1 - progress * 2.5));
    }
  }

  function onGestureEnd() {
    if (!isDragging) return;
    isDragging = false;
    dragIncomingPrepared = null;
    var duration = Date.now() - startTime;
    var vx = Math.abs(deltaX) / Math.max(duration, 1);
    var vy = Math.abs(deltaY) / Math.max(duration, 1);

    if (isZoomed || isAnimating) return;

    // Detecta toque rápido (Tap ou Double Tap)
    if (Math.abs(deltaX) < 10 && Math.abs(deltaY) < 10 && duration < 300) {
      var now = Date.now();
      if (now - lastTapTime < 320) {
        toggleZoom();
        lastTapTime = 0;
        return;
      }
      lastTapTime = now;
      setTimeout(function(){
        if (lastTapTime > 0) {
          toggleChrome();
        }
      }, 320);
      return;
    }

    var stageWidth = $stage.width() || window.innerWidth;
    var depth = Math.round(stageWidth / 2);

    if (swipeDirection === 'horizontal') {
      if ((deltaX < -50 || (deltaX < -25 && vx > 0.35)) && currentIndex < photos.length - 1) {
        rotateCube(currentIndex + 1, 'next');
      } else if ((deltaX > 50 || (deltaX > 25 && vx > 0.35)) && currentIndex > 0) {
        rotateCube(currentIndex - 1, 'prev');
      } else {
        // Retorna suavemente o cubo para a posição inicial (0 graus)
        $faceActive.css({
          transition: 'transform 0.26s cubic-bezier(0.25, 1, 0.4, 1)',
          transform: 'translateZ(' + depth + 'px) rotateY(0deg)'
        });
        $faceActive.find('.cube-face-shadow').css({
          transition: 'opacity 0.26s ease',
          opacity: 0
        });
        $faceIncoming.css({
          transition: 'transform 0.26s cubic-bezier(0.25, 1, 0.4, 1), opacity 0.26s ease',
          opacity: 0
        });
        setTimeout(function(){
          $faceIncoming.css({ display: 'none', opacity: '' });
        }, 260);
      }
    } else if (swipeDirection === 'vertical') {
      // Pull to dismiss
      if (Math.abs(deltaY) > 75 || (Math.abs(deltaY) > 35 && vy > 0.35)) {
        closeViewer(deltaY > 0 ? 'down' : 'up');
      } else {
        $faceActive.css({
          transition: 'transform 0.26s cubic-bezier(0.16, 1, 0.3, 1)',
          transform: 'translateZ(' + depth + 'px) rotateY(0deg) scale(1)'
        });
        $backdrop.css({ transition: 'opacity 0.26s ease', opacity: '' });
        $header.css({ transition: 'opacity 0.26s ease', opacity: '' });
        $caption.css({ transition: 'opacity 0.26s ease', opacity: '' });
      }
    }
  }

  // Vincular eventos de toque e mouse
  $stage.on('touchstart', onGestureStart);
  $stage.on('touchmove', onGestureMove);
  $stage.on('touchend touchcancel', onGestureEnd);

  $stage.on('mousedown', onGestureStart);
  $(document).on('mousemove.photoViewerDrag', onGestureMove);
  $(document).on('mouseup.photoViewerDrag', onGestureEnd);

  // Botões de ação
  $overlay.on('click', '.close, .back-btn', function(e){
    e.preventDefault();
    closeViewer();
  });

  $zoomBtn.on('click', function(e){
    e.preventDefault();
    toggleZoom();
  });

  $overlay.on('click', '.ctrl-prev a, .nav-prev', function(e){
    e.preventDefault();
    if (photos && currentIndex > 0) {
      rotateCube(currentIndex - 1, 'prev');
    }
  });

  $overlay.on('click', '.ctrl-next a, .nav-next', function(e){
    e.preventDefault();
    if (photos && currentIndex < photos.length - 1) {
      rotateCube(currentIndex + 1, 'next');
    }
  });

  // Fechar ao clicar no backdrop externo
  $backdrop.on('click', function(){
    closeViewer();
  });

  // Navegação por teclado
  $(document).off('keydown.photoViewer').on('keydown.photoViewer', function(e){
    if (e.key === 'Escape' || e.keyCode === 27) {
      closeViewer();
    } else if (e.key === 'ArrowLeft' || e.keyCode === 37) {
      if (photos && currentIndex > 0) {
        rotateCube(currentIndex - 1, 'prev');
      }
    } else if (e.key === 'ArrowRight' || e.keyCode === 39) {
      if (photos && currentIndex < photos.length - 1) {
        rotateCube(currentIndex + 1, 'next');
      }
    }
  });

  // Limpeza de eventos globais ao destruir
  $overlay.on('remove', function(){
    $(document).off('.photoViewerDrag');
    $(document).off('keydown.photoViewer');
  });

  // Inicializa o primeiro slide
  if (photos && photos.length > 0) {
    initSlide(currentIndex);
  }
};

WEBY.openGooglePhotosViewer = function(photos, initialIdx){
  if (!photos || photos.length === 0) return;
  initialIdx = initialIdx || 0;
  var currentPhoto = photos[initialIdx];

  $('.photo-viewer-overlay').remove();

  var html = [
    '<div class="photo-viewer-overlay google-photos-viewer" role="dialog" aria-modal="true">',
      '<div class="photo-viewer-backdrop"></div>',
      '<div class="photo-viewer">',
        '<div class="photo-viewer-header">',
          '<div class="photo-viewer-meta">',
            '<button type="button" class="action-btn back-btn close" title="Voltar" aria-label="Voltar">',
              '<i class="fa fa-arrow-left"></i>',
            '</button>',
            '<div class="photo-viewer-title-group">',
              '<span class="photo-album-title">' + $('<div>').text(currentPhoto.title || '').html() + '</span>',
              '<span class="photo-counter-badge">' + (initialIdx + 1) + ' / ' + photos.length + '</span>',
            '</div>',
          '</div>',
          '<div class="photo-viewer-actions">',
            '<button type="button" class="action-btn zoom-btn" title="Ampliar / Reduzir" aria-label="Ampliar">',
              '<i class="fa fa-search-plus"></i>',
            '</button>',
            '<a class="action-btn download-btn" title="Baixar imagem original" href="' + (currentPhoto.downloadUrl || '#') + '" download>',
              '<i class="fa fa-download"></i>',
            '</a>',
            '<button type="button" class="action-btn close-btn close" title="Fechar" aria-label="Fechar">',
              '<i class="fa fa-times"></i>',
            '</button>',
          '</div>',
        '</div>',
        '<div class="photo-viewer-content">',
          '<div class="ctrl ctrl-prev' + (initialIdx === 0 ? ' disabled' : '') + '">',
            '<a href="#" class="nav-arrow nav-prev" title="Foto anterior" aria-label="Anterior">',
              '<i class="fa fa-chevron-left"></i>',
            '</a>',
          '</div>',
          '<div class="photo-cube-stage photo-viewer-photo">',
            '<div class="photo-cube-viewport">',
              '<div class="photo-cube-face face-active">',
                '<img class="viewer-img" src="' + (currentPhoto.previewUrl || currentPhoto.fullUrl) + '" alt="' + $('<div>').text(currentPhoto.description || currentPhoto.title || '').html() + '" draggable="false" />',
                '<div class="cube-face-shadow"></div>',
              '</div>',
              '<div class="photo-cube-face face-incoming" style="display: none;">',
                '<img class="viewer-img-incoming" src="" alt="" draggable="false" />',
                '<div class="cube-face-shadow"></div>',
              '</div>',
            '</div>',
          '</div>',
          '<div class="ctrl ctrl-next' + (initialIdx === (photos.length - 1) ? ' disabled' : '') + '">',
            '<a href="#" class="nav-arrow nav-next" title="Próxima foto" aria-label="Próxima">',
              '<i class="fa fa-chevron-right"></i>',
            '</a>',
          '</div>',
        '</div>',
        '<div class="photo-viewer-caption">',
          (currentPhoto.description ? '<div class="caption-description">' + $('<div>').text(currentPhoto.description).html() + '</div>' : '<div class="caption-description" style="display:none;"></div>'),
          '<div class="caption-footer">',
            '<div class="caption-categories"></div>',
            '<div class="caption-views"><i class="fa fa-eye"></i> <span class="views-count">' + (currentPhoto.views || 0) + '</span></div>',
          '</div>',
        '</div>',
      '</div>',
    '</div>'
  ].join('');

  var $overlay = $(html);
  $('body').append($overlay).css({overflow: 'hidden'});

  WEBY.initAlbumPhoto($overlay, photos, initialIdx);
};

////doc ready

$(document).ready(function(){
  moment.locale($('html').attr('lang'));

  //// search tab
  $('.search-result-tabs').on('click', '.result-tab', function(){
    const parent = $(this).closest('.search-result-tabs');
    const panels = parent.siblings('.result-panel');
    parent.find('.result-tab').removeClass('active');
    panels.removeClass('active');
    $(this).addClass('active');
    panels.filter($(this).attr('href')).addClass('active');
    return false;
  });


  //// Alerts on front end
  var alert = $('.flash-alert');

  if (alert.length > 0) {
    alert.addClass('visible');
    setTimeout(function(){
      alert.removeClass('visible');
    }, 5000);
  }

  $('.toggle-contrast').click(function(){
    WEBY.toggleContrast();
    WEBY.applyContrast();
    return false;
  });
  ///init
  WEBY.checkContrast();
  WEBY.applyContrast();

  $('.newtab-links iframe').each(function(){
    $(this).on('load', function(ev){
      const doc = this.contentDocument ? this.contentDocument : this.contentWindow.document;
      $(doc).find('a').attr('target', '_blank');
    });
  });

  $('.open-full-modal').click(function(){
    if ($('.full-modal').is('.open')) {
      $('.full-modal').removeClass('open')
      $('body').css({overflow: ''})
    } else {
      $('.full-modal').addClass('open')
      $('body').css({overflow: 'hidden'})
    }
  })
  $('.close-full-modal, .full-modal').click(function(ev){
    if ($(ev.target).hasClass('close-full-modal') || $(ev.target).hasClass('full-modal')){
      $('.full-modal').removeClass('open')
      $('body').css({overflow: ''})
    }
  });

  // Intercepta cliques na grade de fotos para abrir o visualizador estilo Google Photos instantaneamente
  $(document).on('click', '.modern-photos-grid .photo-card-link', function(e){
    e.preventDefault();
    e.stopPropagation();

    var $link = $(this);
    var clickedPhotoId = $link.data('photo-id');
    var photos = null;
    var clickedIdx = 0;

    // 1. Tenta carregar todas as fotos do manifesto completo do álbum (permitindo navegar além da paginação)
    var $manifest = $('#album-all-photos-data');
    if ($manifest.length && $manifest.text().trim() !== '') {
      try {
        photos = JSON.parse($manifest.text());
      } catch(err) {
        photos = null;
      }
    }

    if (photos && photos.length > 0) {
      if (clickedPhotoId) {
        for (var i = 0; i < photos.length; i++) {
          if (photos[i].id == clickedPhotoId) {
            clickedIdx = i;
            break;
          }
        }
      }
    } else {
      // Fallback: extrai da grade da página atual
      var $grid = $link.closest('.modern-photos-grid');
      photos = [];
      clickedIdx = $link.data('index');
      if (typeof clickedIdx !== 'number') clickedIdx = 0;

      $grid.find('.photo-card-link').each(function(i){
        var $el = $(this);
        photos.push({
          id: $el.data('photo-id'),
          fullUrl: $el.data('full-url') || $el.attr('href'),
          previewUrl: $el.data('preview-url') || $el.find('img').attr('src'),
          thumbUrl: $el.data('thumb-url'),
          title: $el.data('title') || $grid.data('album-title') || '',
          description: $el.data('description') || '',
          downloadUrl: $el.data('download-url') || '#',
          views: $el.data('views') || 0,
          categories: $el.data('categories') ? $el.data('categories').toString().split(', ') : []
        });
      });
    }

    WEBY.openGooglePhotosViewer(photos, clickedIdx);
  });
});
