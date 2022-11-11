//= require jquery.flexslider-photo_slider
$(document).ready(function() {
  var e = $('.photo_slider_component .flexslider');
  e.flexslider({
    controlNav: e.data('controls'),
    directionNav: e.data('controls'),
    animation: "slide",
    controlsContainer: '.flex-container',
    prevText: '&lsaquo;',
    nextText: '&rsaquo;',
    slideshowSpeed: parseInt($(e).data('slideshowspeed'))
  });
});
