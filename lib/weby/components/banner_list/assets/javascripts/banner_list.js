$(document).ready(function(){
  $('.banner a').click(function(){
    $.post('/count/banner/'+$(this).data('banner-id'));
  });
});

// Can also be used with $(document).ready()
$(window).load(function() {
    $('.flexslider').flexslider({
          animation: "slide",
          controlNav: false,
          directionNav: false
        });
});
