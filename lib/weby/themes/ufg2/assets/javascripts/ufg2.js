$(document).ready(function(){
  //
  $('.form_search input[type=submit]').click(function(ev){
    ev.preventDefault();
    var $this = $(this);
    $this.parents('.form_search').find('#search').toggleClass('show-input');
    $this.toggleClass('open');
    return false;
  });

  $('body').click(function(ev){
    if( $(ev.target).closest('.search_box_component').length == 0 ) {
      var searchToggle = $('.form_search input[type=submit]');
      searchToggle.parents('.form_search').find('#search').removeClass('show-input');
      searchToggle.removeClass('open');
    }
  });

  $('#search').keydown(function(ev){
    if (ev.which == 13 || ev.keyCode == 13) {
      $(this).closest('form').submit();
      return false;
    }
  })
});

