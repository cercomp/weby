$(document).ready(function(){
  // expand menu
  $(".menu-head").click(function() {
    var $menu = $('.menu-panel');
    var $hamburger = $($(this).find('.hamburger'));
    // Toggle class "is-active"
    if ($hamburger.hasClass('is-active')){
      $hamburger.removeClass('is-active');
      $menu.slideUp(200);
    }else{
      $hamburger.addClass('is-active');
      $menu.slideDown(200);
    }
    return false;
  });

  $('.mobile-menu').on('click', '.menu', function(){
    $('.menu-panel').toggleClass('open-fixed');
  });

  // When the user scrolls the page, execute stickyHeader
  window.onscroll = function() {stickyHeader()};

  // Get the header
  var header = document.getElementsByClassName("header");
  header = header[0];

  // Get the offset position of the navbar
  var sticky = header.offsetTop;

  // Add the sticky class to the header when you reach its scroll position. Remove "sticky" when you leave the scroll position
  function stickyHeader() {
    if (window.pageYOffset > sticky) {
      header.classList.add("navbar-fixed-top");
      header.parentElement.style.paddingTop = ''+header.offsetHeight+'px';
    } else {
      header.classList.remove("navbar-fixed-top");
      header.parentElement.style.paddingTop = '0px';
    }
  }

});

