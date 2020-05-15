$(document).ready(function(){
  $('.news_as_home_component.popup-modal').on('click', function(ev){
    var tgt = $(ev.target);
    if (tgt.is('.popup-modal') || tgt.is('.popup-close')) {
      $(this).remove();
      $('body').removeClass('modal-open');
    }
    return false;
  });
});