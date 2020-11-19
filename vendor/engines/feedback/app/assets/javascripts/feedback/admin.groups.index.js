$(document).ready(function() {
  $('#groups-table').sortable({
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
      var $this = $(this);
      //id_moved = ui.item.attr('id').replace('sort_news_','');
      $.ajax({
        type: 'post',
        data: $this.sortable('serialize'),
        dataType: 'script',
        complete: function(request,text){
          if(text=='success') ui.item.effect('pulsate', {times: 1}, 350);
          else $this.sortable('cancel');
        },
        error: function(){ $this.sortable('cancel'); },
        url: $this.data('sort-url')
      });
    }
  });
});
