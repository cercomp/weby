$(document).on("click", ".news-list .pagination a", function(){
    $comp = $(this).parents('.pagination');
    //alert($comp);
    addCloack($comp, 'center');
});

$(document).ready(function(){
  $('#news-search').on('ajax:send', function(){
    addCloack($('#news'), '20px');
  }).on('ajax:error', function(){
    $("#news").html('<div class="text-center">Ocorreu um erro, tente novamente</div>');
    if ($(this).data('retried') != 'true'){
      $(this).data('retried', 'true').submit();
    }
  }).submit();
});

function addCloack(comp, v_align) {
  if(comp.css('position')!='absolute') {
    var st = {position: 'relative'};
    if (comp.outerHeight() < 55) {
      st.minHeight = '55px';
    }
    comp.css(st);
  }
  comp.append($('<div class="loading-cloak"></div>').css({
    position: 'absolute',
    top: 0,
    left: 0,
    height: comp.outerHeight(),
    width: comp.outerWidth(),
    textAlign: 'center',
    background: 'rgba(255,255,255,.65) url(/assets/loading.gif) no-repeat center '+v_align
  }));
}

function toggleAdvancedSearch(){
  $(".advanced-search").fadeToggle(function(){
    if(!$(this).is(':visible')){
      $(".advanced-search input[type=radio]").prop('checked', false);
    }else{
      $('#search_type_1').prop('checked', true);
    }
  });
  return false;
}