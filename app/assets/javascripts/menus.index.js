$(document).ready(function() {
  var dropped = false;
  // init menu items sortable
  $('#main-menu > menu').nestedSortable({
    rootID: 'root',
    listType: 'menu',
    handle: '.handle',
    items: 'li',
    opacity: 0.7,
    scroll: true,
    forcePlaceholderSize: true,
    placeholder: 'drop-here',
    tolerance: 'pointer',
    toleranceElement: 'div.menuitem-ctrl',
    isTree: true,
    expandOnHover: 700,
    startCollapsed: false,
    update: function(event, ui){
      if(dropped){
        $(this).nestedSortable('cancel');
        dropped = false;
        return;
      }
      var id = ui.item.attr('id').replace('menu_item_','');
      $.ajax({
        type: 'post',
        data: 'id='+ id +'&'+ $(this).nestedSortable('serialize'),
        dataType: 'script',
        complete: function(request,text){
          if(text=='success') ui.item.effect('pulsate', {times: 1}, 350);
          else $('#main-menu > menu').nestedSortable('cancel');
        },
        url: $('#main-menu').data('sort-url')
      });
    }
  });
  ///toggles sub menu expanded
  $('.disclose').on('click', function() {
    $(this).closest('li').toggleClass('mjs-nestedSortable-collapsed').toggleClass('mjs-nestedSortable-expanded');
  });
  //// Drop menu item on another menu tab
  $( "#tabs li" ).not('.active').droppable({
    accept: '.mjs-nestedSortable-branch,.mjs-nestedSortable-leaf',
    hoverClass: "drop-here",
    tolerance: "pointer",
    drop: function( event, ui ) {
      var drop_li = $(this)
      var id = ui.draggable.attr('id').replace('menu_item_','');
      var menu_id = drop_li.data('menu-id');

      dropped = true;
      ////Testa para não alterar pra o proprio menu
      if( !drop_li.hasClass('active') ){
        $.ajax({
          type: 'post',
          data: 'id='+id+'&new_menu_id='+menu_id,
          dataType: 'script',
          complete: function(request,text){
            if(text=='success'){
              ui.draggable.remove();
              location = drop_li.find('a').attr('href');
            }
          },
         url: $('#main-menu').data('change-url')
        });
      }
    }
  });
  /// init menus sortable
  $('#tabs').sortable({
    placeholder: 'drop-here',
    forcePlaceholderSize: true,
    tolerance: 'pointer',
    handle: '.glyphicon',
    update: function(event, ui){
      var $this = $(this);
      if(dropped){
        $this.sortable('cancel');
        dropped = false;
        return;
      }
      $.ajax({
        type: 'post',
        data: $this.sortable('serialize'),
        dataType: 'script',
        complete: function(request,text){
          if(text=='success') ui.item.effect('pulsate', {times: 1}, 350);
          else $this.sortable('cancel');
        },
        url: $('#tabs').data('url')
      });
    }
  });
  ////FIX-ME
  //$('#main-menu').css({'height':$('#main-menu').height()});
});
