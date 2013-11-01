//= require jquery.flexslider-weby_news_slider

$(document).ready(function(){
  var e = $(".weby_news_slider_component .flexslider");
  e.flexslider({
    controlNav: false,
    prevText: '&lsaquo;',
    nextText: '&rsaquo;',
    slideshowSpeed: parseInt($(e).data('slideshowspeed'))
  });
});

