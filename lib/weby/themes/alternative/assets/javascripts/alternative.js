$(document).ready(function(){
  //
  $('.search-toggle button').click(function(ev){
    var $button = $(this);
    var $toggle = $button.parent();
    var $search = $toggle.siblings('.search_box_component');
    $toggle.toggleClass('open');
    $search.toggleClass('open');
    if ($toggle.hasClass('open')) {
      $search.find('#search').focus();
      $button.data('original-title', $button.attr('title'))
      $button.attr('title', $button.data('alt-title'));
    } else {
      $button.attr('title', $button.data('original-title'));
    }
    return false;
  });

  $('body').click(function(ev){
    var $target = $(ev.target)
    if( $target.closest('.search_box_component').length == 0 ) {
      $('.search-toggle').removeClass('open');
      $('.search-toggle').siblings('.search_box_component').removeClass('open');
    }

    //// Menu focus, keyboard nav
    $('.empty-href').each(function(){
      $(this).closest('li').removeClass('open-menu')
    });
    if( $target.is('.empty-href') ) {
      $target.parents('li').addClass('open-menu');
    }
  });

  $('#search').keydown(function(ev){
    if (ev.which == 13 || ev.keyCode == 13) {
      $(this).closest('form').submit();
      return false;
    }
  });

  $('.increase-font').click(function(){
    var bd = $('body');
    if (bd.hasClass('zoom-out')) {
      bd.removeClass('zoom-out');
    } else {
      bd.addClass('zoom-in');
    }
    return false;
  })

  $('.decrease-font').click(function(){
    var bd = $('body');
    if (bd.hasClass('zoom-in')) {
      bd.removeClass('zoom-in');
    } else {
      bd.addClass('zoom-out');
    }
    return false;
  });

  //// menu toggle
  $('.menu-handle').click(function(){
    var menuBar = $('.menu-bar');
    menuBar.toggleClass('mob-open');
    if (menuBar.hasClass('mob-open')) {
      $('.social-toggle + .social-icons').removeClass('open');
    }
  });

  /// social-toggle
  $('.social-toggle').click(function(){
    var $this = $(this);
    var panel = $this.next('.social-icons');
    panel.toggleClass('open');
    return false;
  });

  //Stick menu on scroll
  // When the user scrolls the page, execute stickyHeader
  $(window).scroll(stickyHeader);

  // Get the header
  var header = $('body > header');

  // Get the offset position of the navbar
  var sticky = header.offset().top;

  var maxHeight = document.body.scrollHeight;

  // Add the sticky class to the menuBar when you reach its scroll position. Remove "sticky" when you leave the scroll position
  function stickyHeader() {
    var fromTop = $(this).scrollTop();

    if (window.pageYOffset > sticky) {
      header.addClass('fixed');
      //menuBar.parentElement.style.paddingTop = ''+menuBar.offsetHeight+'px';
    } else {
      header.removeClass('fixed');
      //menuBar.parentElement.style.paddingTop = '0px';
    }

    /////// back to top - visible
    if (fromTop > maxHeight * 0.2) {
      $('.smooth_scroll').addClass('visible');
    }else{
      $('.smooth_scroll').removeClass('visible');
    }
  }

  ////modal
  $(document).on('click', '[data-toggle=modal]', function(){
    $($(this).data('target')).toggleClass('open');
    return false;
  }).on('click', '[data-dismiss=modal]', function(){
    $(this).closest('.modal').removeClass('open');
    return false;
  });

  ////accordion
  $(document).on('click', '[data-toggle=collapse]', function(){
    var parent = $($(this).data('parent'))
    if (parent.length > 0){
      parent.find('.accordion-body').removeClass('in');
    }
    $($(this).attr('href')).toggleClass('in');
    return false;
  });

  //Change list-grid
  $('.show_list').click(function(ev){
    $('.show_grid').removeClass('active');
    $(this).addClass('active');
    $('#news, #events').removeClass('grid');
    $('#news, #events').addClass('list');
  });

  $('.show_grid').click(function(ev){
    $('.show_list').removeClass('active');
    $(this).addClass('active');
    $('#news, #events').removeClass('list');
    $('#news, #events').addClass('grid');
  });

  thisToggleAdvancedSearch();
});

function thisToggleAdvancedSearch(){
  $(".advanced-search").fadeToggle(function(){
    if(!$(this).is(':visible')){
      $(".advanced-search input[type=radio]").prop('checked', false);
    }else{
      $('#search_type_1').prop('checked', true);
    }
  });
  return false;
}