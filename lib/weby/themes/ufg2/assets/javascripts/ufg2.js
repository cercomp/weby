$(document).ready(function(){
  //
  $('.form_search input[type=submit]').click(function(ev){
    ev.preventDefault();
    var $this = $(this);
    $this.parents('.form_search').find('#search').toggleClass('show-input');
    $this.toggleClass('open');
    return false;
  });

  $('body').click(function(ev){
    if( $(ev.target).closest('.search_box_component').length == 0 ) {
      var searchToggle = $('.form_search input[type=submit]');
      searchToggle.parents('.form_search').find('#search').removeClass('show-input');
      searchToggle.removeClass('open');
    }
  });

  $('#search').keydown(function(ev){
    if (ev.which == 13 || ev.keyCode == 13) {
      $(this).closest('form').submit();
      return false;
    }
  });

  //Stick menu on scroll
  // When the user scrolls the page, execute stickyHeader
  $(window).scroll(stickyHeader);

  // Get the menuBar
  var menuBar = $('.menu-bar');

  // Get the offset position of the navbar
  var sticky = menuBar.offset().top;

  // Add the sticky class to the menuBar when you reach its scroll position. Remove "sticky" when you leave the scroll position
  function stickyHeader() {
    if (window.pageYOffset > sticky) {
      menuBar.addClass('fixed');
      //menuBar.parentElement.style.paddingTop = ''+menuBar.offsetHeight+'px';
    } else {
      menuBar.removeClass('fixed');
      //menuBar.parentElement.style.paddingTop = '0px';
    }
  }
});

