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
  var $photoContainer = $overlay.find('.photo-viewer-photo');
  var $img = $photoContainer.find('img');
  var $header = $overlay.find('.photo-viewer-header');
  var $caption = $overlay.find('.photo-viewer-caption');
  var $backdrop = $overlay.find('.photo-viewer-backdrop');
  var $counter = $overlay.find('.photo-counter-badge');
  var $title = $overlay.find('.photo-album-title');
  var $downloadBtn = $overlay.find('.download-btn');
  var $zoomBtn = $overlay.find('.zoom-btn');

  // Se photosData não foi passado, tenta extrair da grade presente na página
  var photos = photosData || null;
  if (!photos && $('.modern-photos-grid .photo-card-link').length > 0) {
    photos = [];
    $('.modern-photos-grid .photo-card-link').each(function(i){
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
    var curPhotoId = $photoContainer.data('photo-id');
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
  var swipeDirection = null; // 'horizontal', 'vertical', or null
  var isClosing = false;
  var lastTapTime = 0;
  var panX = 0, panY = 0;
  var startPanX = 0, startPanY = 0;

  function resetZoom() {
    isZoomed = false;
    panX = 0;
    panY = 0;
    $zoomBtn.html('<i class="fa fa-search-plus"></i>').attr('title', 'Ampliar');
    $photoContainer.removeClass('is-zoomed');
    $img.css({
      transition: 'transform 0.24s cubic-bezier(0.16, 1, 0.3, 1)',
      transform: 'translate3d(0, 0, 0) scale(1)',
      cursor: ''
    });
  }

  function toggleZoom(originX, originY) {
    isZoomed = !isZoomed;
    if (isZoomed) {
      $zoomBtn.html('<i class="fa fa-search-minus"></i>').attr('title', 'Reduzir');
      $photoContainer.addClass('is-zoomed');
      panX = 0;
      panY = 0;
      $img.css({
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

  function updateSlide(idx, direction) {
    if (!photos || photos.length === 0) return;
    if (idx < 0) idx = 0;
    if (idx >= photos.length) idx = photos.length - 1;
    currentIndex = idx;
    var photo = photos[idx];

    resetZoom();

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

    // Atualiza estado das setas
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

    // Animação de transição fluida Google Photos
    var outX = direction === 'next' ? '-50px' : (direction === 'prev' ? '50px' : '0px');
    var inX = direction === 'next' ? '50px' : (direction === 'prev' ? '-50px' : '0px');

    if (direction) {
      $img.css({
        transition: 'transform 0.15s ease-in, opacity 0.15s ease-in',
        transform: 'translate3d(' + outX + ', 0, 0) scale(0.96)',
        opacity: 0
      });

      setTimeout(function(){
        $img.attr('src', photo.previewUrl || photo.fullUrl);
        $img.attr('alt', photo.description || photo.title || '');

        if (photo.fullUrl && photo.fullUrl !== photo.previewUrl) {
          var highRes = new Image();
          highRes.onload = function(){
            if (currentIndex === idx) {
              $img.attr('src', photo.fullUrl);
            }
          };
          highRes.src = photo.fullUrl;
        }

        $img.css({
          transition: 'none',
          transform: 'translate3d(' + inX + ', 0, 0) scale(0.96)',
          opacity: 0
        });

        // Força reflow do navegador
        if ($img[0]) $img[0].offsetHeight;

        $img.css({
          transition: 'transform 0.24s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.24s ease-out',
          transform: 'translate3d(0, 0, 0) scale(1)',
          opacity: 1
        });
      }, 150);
    } else {
      $img.attr('src', photo.previewUrl || photo.fullUrl);
      if (photo.fullUrl && photo.fullUrl !== photo.previewUrl) {
        var highRes = new Image();
        highRes.onload = function(){
          if (currentIndex === idx) $img.attr('src', photo.fullUrl);
        };
        highRes.src = photo.fullUrl;
      }
      $img.css({
        transform: 'translate3d(0, 0, 0) scale(1)',
        opacity: 1
      });
    }

    // Pré-carregamento imediato das fotos adjacentes
    if (photos[idx + 1]) {
      new Image().src = photos[idx + 1].fullUrl || photos[idx + 1].previewUrl;
    }
    if (photos[idx - 1]) {
      new Image().src = photos[idx - 1].fullUrl || photos[idx - 1].previewUrl;
    }
  }

  function closeViewer(flyDirection) {
    if (isClosing) return;
    isClosing = true;
    $(document).off('keydown.photoViewer');

    var flyY = flyDirection === 'down' ? '70vh' : (flyDirection === 'up' ? '-70vh' : '0');
    var flyScale = flyDirection ? 0.75 : 0.94;

    $img.css({
      transition: 'transform 0.22s ease-in, opacity 0.22s ease-in',
      transform: 'translate3d(0, ' + flyY + ', 0) scale(' + flyScale + ')',
      opacity: 0
    });

    $overlay.fadeOut(200, function(){
      $overlay.remove();
      $('body').css({overflow: ''});
    });
  }

  // --- Handlers de Gestos Touch e Arrastar com Dedo (Google Photos) ---
  function onGestureStart(e) {
    if (isClosing) return;
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

    if (isZoomed) {
      startPanX = panX;
      startPanY = panY;
    } else {
      $img.css('transition', 'none');
      $backdrop.css('transition', 'none');
    }
  }

  function onGestureMove(e) {
    if (!isDragging || isClosing) return;
    var touch = e.touches ? e.touches[0] : e;
    currentX = touch.clientX;
    currentY = touch.clientY;
    deltaX = currentX - startX;
    deltaY = currentY - startY;

    if (isZoomed) {
      if (e.cancelable) e.preventDefault();
      panX = startPanX + deltaX;
      panY = startPanY + deltaY;
      $img.css({
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
      var isFirst = photos && currentIndex === 0 && deltaX > 0;
      var isLast = photos && currentIndex === (photos.length - 1) && deltaX < 0;
      var resistance = (isFirst || isLast) ? 0.35 : 1;
      var moveX = deltaX * resistance;

      $img.css({
        transform: 'translate3d(' + moveX + 'px, 0, 0)'
      });
    } else if (swipeDirection === 'vertical') {
      if (e.cancelable) e.preventDefault();
      // Puxar para fechar (pull-to-dismiss)
      var progress = Math.min(Math.abs(deltaY) / 350, 0.85);
      var scale = Math.max(0.72, 1 - progress * 0.28);
      var opacity = Math.max(0.15, 1 - progress);

      $img.css({
        transform: 'translate3d(0, ' + deltaY + 'px, 0) scale(' + scale + ')'
      });
      $backdrop.css('opacity', opacity);
      $header.css('opacity', Math.max(0, 1 - progress * 2.5));
      $caption.css('opacity', Math.max(0, 1 - progress * 2.5));
    }
  }

  function onGestureEnd(e) {
    if (!isDragging) return;
    isDragging = false;
    var duration = Date.now() - startTime;
    var vx = Math.abs(deltaX) / Math.max(duration, 1);
    var vy = Math.abs(deltaY) / Math.max(duration, 1);

    if (isZoomed) return;

    // Detecta toque rápido (Tap ou Double Tap)
    if (Math.abs(deltaX) < 10 && Math.abs(deltaY) < 10 && duration < 300) {
      var now = Date.now();
      if (now - lastTapTime < 320) {
        toggleZoom(startX, startY);
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

    if (swipeDirection === 'horizontal') {
      $img.css('transition', 'transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.25s ease');

      if (deltaX < -50 || (deltaX < -25 && vx > 0.35)) {
        // Próxima foto
        if (photos && currentIndex < photos.length - 1) {
          updateSlide(currentIndex + 1, 'next');
        } else {
          var $nextAjax = $overlay.find('.ctrl-next a');
          if ($nextAjax.length) $nextAjax[0].click();
          else $img.css('transform', 'translate3d(0, 0, 0)');
        }
      } else if (deltaX > 50 || (deltaX > 25 && vx > 0.35)) {
        // Foto anterior
        if (photos && currentIndex > 0) {
          updateSlide(currentIndex - 1, 'prev');
        } else {
          var $prevAjax = $overlay.find('.ctrl-prev a');
          if ($prevAjax.length) $prevAjax[0].click();
          else $img.css('transform', 'translate3d(0, 0, 0)');
        }
      } else {
        $img.css('transform', 'translate3d(0, 0, 0)');
      }
    } else if (swipeDirection === 'vertical') {
      // Pull to dismiss
      if (Math.abs(deltaY) > 75 || (Math.abs(deltaY) > 35 && vy > 0.35)) {
        closeViewer(deltaY > 0 ? 'down' : 'up');
      } else {
        $img.css({
          transition: 'transform 0.26s cubic-bezier(0.16, 1, 0.3, 1)',
          transform: 'translate3d(0, 0, 0) scale(1)'
        });
        $backdrop.css({
          transition: 'opacity 0.26s ease',
          opacity: ''
        });
        $header.css({ transition: 'opacity 0.26s ease', opacity: '' });
        $caption.css({ transition: 'opacity 0.26s ease', opacity: '' });
      }
    }
  }

  // Vincular eventos de toque e mouse
  $photoContainer.on('touchstart', onGestureStart);
  $photoContainer.on('touchmove', onGestureMove);
  $photoContainer.on('touchend touchcancel', onGestureEnd);

  $photoContainer.on('mousedown', onGestureStart);
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

  $overlay.on('click', '.ctrl-prev a, .stage-nav-prev', function(e){
    if (photos) {
      e.preventDefault();
      if (currentIndex > 0) updateSlide(currentIndex - 1, 'prev');
    }
  });

  $overlay.on('click', '.ctrl-next a, .stage-nav-next', function(e){
    if (photos) {
      e.preventDefault();
      if (currentIndex < photos.length - 1) updateSlide(currentIndex + 1, 'next');
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
        updateSlide(currentIndex - 1, 'prev');
      } else {
        var $prev = $overlay.find('.ctrl-prev a');
        if ($prev.length) $prev[0].click();
      }
    } else if (e.key === 'ArrowRight' || e.keyCode === 39) {
      if (photos && currentIndex < photos.length - 1) {
        updateSlide(currentIndex + 1, 'next');
      } else {
        var $next = $overlay.find('.ctrl-next a');
        if ($next.length) $next[0].click();
      }
    }
  });

  // Limpeza de eventos globais ao destruir
  $overlay.on('remove', function(){
    $(document).off('.photoViewerDrag');
    $(document).off('keydown.photoViewer');
  });

  // Inicializa o primeiro slide se dados de fotos foram fornecidos
  if (photos && photos.length > 0) {
    updateSlide(currentIndex);
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
          '<div class="photo-viewer-photo">',
            '<img class="viewer-img" src="' + (currentPhoto.previewUrl || currentPhoto.fullUrl) + '" alt="' + $('<div>').text(currentPhoto.description || currentPhoto.title || '').html() + '" draggable="false" />',
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

    var $grid = $(this).closest('.modern-photos-grid');
    var photos = [];
    var clickedIdx = $(this).data('index');
    if (typeof clickedIdx !== 'number') clickedIdx = 0;

    $grid.find('.photo-card-link').each(function(i){
      var $link = $(this);
      photos.push({
        id: $link.data('photo-id'),
        fullUrl: $link.data('full-url') || $link.attr('href'),
        previewUrl: $link.data('preview-url') || $link.find('img').attr('src'),
        thumbUrl: $link.data('thumb-url'),
        title: $link.data('title') || $grid.data('album-title') || '',
        description: $link.data('description') || '',
        downloadUrl: $link.data('download-url') || '#',
        views: $link.data('views') || 0,
        categories: $link.data('categories') ? $link.data('categories').toString().split(', ') : []
      });
    });

    WEBY.openGooglePhotosViewer(photos, clickedIdx);
  });
});
