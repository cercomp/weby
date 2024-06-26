$(document).ready(function() {
  var $calendar = $('#calendar');
  $calendar.fullCalendar({
    height: 460,
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

  $('.refresh-view-count').click(function(ev) {
    $.getJSON($(this).data('url'), function(data){
      $('.view-count-text').text(data.site.view_count);
    });
    return false;
  });
});