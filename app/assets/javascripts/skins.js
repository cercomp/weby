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
      var $this = $(this);
      $.ajax({
        url: $this.data('url'),
        type: 'post',
        data: $this.sortable('serialize'),
        dataType: 'script',
        complete: function(request){ ui.item.effect('pulsate', {times: 1}, 350); },
        error: function(){ $(this).sortable('cancel'); }
      });
    }
  });
}

window.onload=function(){
  $(document).ready(function(){
    initStylesSortable();

    $('.btn-change').click(function(){
      $('.skins').slideToggle();
      return false;
    });

    $('.toggle-styles').click(function(){
      var $this = $(this);
      var $icon = $this.find('.glyphicon');
      $('.style-site-' + $this.data('site')).toggle();
      if ($icon.hasClass('glyphicon-chevron-down')){
        $icon.addClass('glyphicon-chevron-right').removeClass('glyphicon-chevron-down')
      }else{
        $icon.addClass('glyphicon-chevron-down').removeClass('glyphicon-chevron-right')
      }
    });
  });
};

