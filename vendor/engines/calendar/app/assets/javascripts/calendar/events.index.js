$(document).ready(function() {
  var $calendar = $('#calendar');
  $calendar.fullCalendar({
    lang: $('html').attr('lang'),
    header: {left: 'today prev,next', center: 'title', right: 'month,basicWeek'},
    nextDayThreshold: '00:00:00',
    events: {
      url: $calendar.data('url'),
      cache: true,
      error: function() {
          alert('Erro ao pesquisar os eventos');
      }
    }
  });
});

$(document).on("click", ".events-list .pagination a", function(){
    $comp = $(this).parents('.pagination');
    //alert($comp);
    if($comp.css('position')!='absolute') $comp.css('position', 'relative');
    $comp.prepend($('<div class="loading-cloak"></div>').css({
        position: 'absolute',
        top: 0,
        left: 0,
        height: $comp.outerHeight(),
        width: $comp.outerWidth(),
        textAlign: 'center',
        background: 'rgba(255,255,255,.65) url(/assets/loading.gif) no-repeat center center'
    }));
});

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