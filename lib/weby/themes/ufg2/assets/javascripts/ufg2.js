$(document).ready(function(){
  //
  $('.form_search input[type=submit]').click(function(ev){
    ev.preventDefault();
    $(this).parents('.form_search').find('#search').toggleClass('show-input');
    $(this).toggleClass('open');
    return false;
  });

  $('#search').keydown(function(ev){
    if (ev.which == 13 || ev.keyCode == 13) {
      $(this).closest('form').submit();
      return false;
    }
  })
});

