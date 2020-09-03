$(document).ready(function(){
  /// styles sortable
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

  ///// styles collapse
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

  ///// components sortable
  var maxLayout = $('.maxi_layout');
  $('.order-list').each(function(){
    var list = $(this);
    list.sortable({
      //axis: 'y',
      dropOnEmpty: true,
      handle: '.handle',
      connectWith: '.order-list',
      forcePlaceholderSize: true,
      forceHelperSize: true,
      placeholder: 'drop-here',
      scrollSensitivity: 30,
      scrollSpeed: 10,
      items: '> li',
      opacity: 0.5,
      scroll: true,
      //tolerance: 'pointer',
      update: function(evt, ui){
        $('.maxi_level.multi').each(function(){ $(this).attr('style', ''); $(this).css({'height':$(this).height()}); });
        $.ajax({
          type: 'post',
          data: 'place_holder='+ $(this).data('place') +'&'+ $(this).sortable('serialize'),
          dataType: 'script',
          complete: function(request){ if(!ui.sender){ ui.item.effect('pulsate', {times: 1}, 350); } },
          url: maxLayout.data('sorturl')
        });
      }
    });
  });

  $('.maxi_level.multi').each(function(){
    var h = $(this).height();
    if(h > 0){
      $(this).css({'height': h});
    }
  });

  //// toggle disable ajax
  ///components
  appendToggleHandle('.widget-name > a', 'li');
  ////styles
  appendToggleHandle('td.publish a', 'tr');
});
