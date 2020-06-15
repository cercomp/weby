$(document).ready(function() {
  $('#list').sortable({
    axis: 'y',
    dropOnEmpty:false,
    handle: '.handle',
    items: 'tbody > tr',
    opacity: 0.7,
    scroll: true,
    forcePlaceholderSize: true,
    placeholder: 'drop-here',
    tolerance: 'pointer',
    start: function (event, ui){
      ui.placeholder.html('<td colspan="'+ui.helper.find('td').length+'">&nbsp;</td>');
    },
    update: function(ev, ui){
      id_moved = ui.item.attr('id').replace('sort_news_','');
      id_after = ui.item.next().attr('id') ? ui.item.next().attr('id').replace('sort_news_','') : 0;
      id_before = ui.item.prev().attr('id') ? ui.item.prev().attr('id').replace('sort_news_','') : 0;
      //alert(id_moved+' between '+id_before+' and '+id_after);
      $.ajax({
        type: 'post',
        data: {'id_moved':id_moved,'id_after':id_after,'id_before':id_before},
        dataType: 'script',
        complete: function(request){ ui.item.effect('pulsate', {times: 1}, 350); },
        error: function(){$('#list').sortable('cancel');},
        url: $('#list').data('sort-url')
      });
    }
  });

  $('.select2').select2({
     placeholder: "Filtrar por categoria",
     width: 'resolve'
  });

  var applyFilter = function(){
    var onlyEvents = $('#filter-events'),
        categories = $('#filter-category');

    $('.sort_news').hide();

    if(categories.val().length > 0){
      $(categories.val()).each(function(idx, category){
        $('.sort_news.'+category).show();
      });
    }else{
      $('.sort_news').show();
    }

    if(onlyEvents.is(':checked')){
      $('.sort_news.news').hide();
    }
  }

  $('#filter-events, #filter-category').change(applyFilter);
});
