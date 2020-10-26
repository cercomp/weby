//= require init/sortable

$(document).ready(function(){
  $(document).on("click", ".front_news_component .pagination a", function(){
    $comp = $(this).parents('.pagination');
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

  var initSortable = function(list){
    var url = list.closest('.front_news_component').data('url');
    if(url && url.length > 0)
      $(list).sortable({
        dropOnEmpty:false,
        handle: '.handle',
        items: 'li',
        opacity: 0.7,
        scroll: true,
        cursor: 'move',
        tolerance: 'pointer',
        forcePlaceholderSize: true,
        placeholder: 'drop-here',
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
            error: function(){$('#news').sortable('cancel');},
            url: list.closest('.front_news_component').data('url')
          });
        }
      });
  };

  $(document).on('componentReload', '.front_news_component', function(){
    initSortable($(this).find('#news'));
  });

  $('.front_news_component').each(function(){
    initSortable($(this).find('#news'));
  });

  var $sel2 = $('#categories-list');
  if($sel2.length > 0){
    $sel2.select2({
     width: 'resolve',
     tokenSeparators: [","],
     tags: $('#categories-list').data('taglist'),
     createSearchChoice: function(term){
       var eq = false
       $($('#categories-list').select2('val')).each(function(){
         //Case insensitive tagging
         if(this.toUpperCase().replace(/^\s+|\s+$/g,"") == term.toUpperCase().replace(/^\s+|\s+$/g,""))
          eq = true
       });
       if (eq)
         return false
       else
         return {id: term, text: term.replace(/^\s+|\s+$/g,"")};
     }
   });
  }
});

