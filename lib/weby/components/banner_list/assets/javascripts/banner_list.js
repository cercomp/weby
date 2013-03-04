$(document).ready(function(){
  $('.banner a').click(function(){
    $.post('/count/banner/'+$(this).data('banner-id'));
  });
});