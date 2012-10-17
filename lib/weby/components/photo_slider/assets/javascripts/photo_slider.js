//= require jquery.flexslider
$(document).ready(function() {
  var e = $('.flexslider');
  e.flexslider({
    animation: "slide",
    controlsContainer: '.flex-container',
    prevText: '&lsaquo;',
    nextText: '&rsaquo;',
    slideshowSpeed: parseInt($(e).data('slideshowspeed'))
  });
});
