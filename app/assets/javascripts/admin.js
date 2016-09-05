$(document).ready(function() {
  var $calendar = $('#calendar');
  $calendar.fullCalendar({
    height: 420,
    lang: $('html').attr('lang'),
    header: {left: 'today prev,next', center: 'title', right: 'month,basicWeek'},
    events: {
      url: $calendar.data('url'),
      cache: true,
      error: function() {
          alert('Erro ao pesquisar os eventos');
      }
    }
  });
});