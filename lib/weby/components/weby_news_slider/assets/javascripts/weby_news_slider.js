//= require jquery.flexslider

$(document).ready(function(){
  var e = $("div.flexslider");
  e.flexslider({
    controlNav: false,
    prevText: '&lsaquo;',
    nextText: '&rsaquo;',
    slideshowSpeed: parseInt($(e).data('slideshowspeed'))
  });
});

