$(document).ready(function(){
  $('.banner a').click(function(){
    $.post('/count/banner/'+$(this).data('banner-id'));
  });

  $("#banner_list_component_orientation").change(function(){
    if($(this).val() == 'slider')
        $('.slider-form').show();
    else
        $('.slider-form').hide();
  }).change();

  var e = $('.banner_list_component .flexslider');
  if(e.length > 0){
      e.flexslider({
        controlNav: e.data('controls'),
        directionNav: e.data('controls'),
        animation: "slide",
        //controlsContainer: '.flex-container',
        prevText: '&lsaquo;',
        nextText: '&rsaquo;',
        slideshowSpeed: parseInt($(e).data('slideshowspeed'))
      });
  }
});

