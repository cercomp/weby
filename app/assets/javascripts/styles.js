function initStylesSortable(){
  $('#style_list').sortable({
    axis: 'y',
    dropOnEmpty:false,
    handle: '.handle',
    items: 'tbody > tr',
    opacity: 0.6,
    scroll: true,
    forcePlaceholderSize: true,
    placeholder: 'drop-here',
    tolerance: 'pointer',
    start: function (event, ui){
      ui.placeholder.html('<td colspan="'+ui.helper.find('td').length+'">&nbsp;</td>');
    },
    update: function(ev, ui){
      $.ajax({
        type: 'post',
        data: $(this).sortable('serialize'),
        dataType: 'script',
        complete: function(request){ ui.item.effect('pulsate', {times: 1}, 350); },
        error: function(){$(this).sortable('cancel');},
        url: '<%= sort_site_admin_styles_path %>'
      });
    }
  });
}

window.onload=function(){
  $(document).ready(function(){
    initStylesSortable();
  });
};

