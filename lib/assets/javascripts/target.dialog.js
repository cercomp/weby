//= require target.dialog.window

$(function(){

  $('.target-btn').click(function(){
    var $urlfield = $('.url-field');
    WEBY.getTargetDialog().open({
      editable_url: !$urlfield.is(':disabled'),
      onsubmit: function(sel, url){
        $urlfield.val(url);
        $cont = $urlfield.parents('.target_select');
        $cont.find('input[data-target-id]').val(sel.data('id'))
        $cont.find('input[data-target-type]').val(sel.data('type'));
      }
    });
    return false;
  });

  $('input[data-target-content]').change(function(){
    $('input[data-target-id][data-prefix='+$(this).data('prefix')+']').val(null);
    $('input[data-target-type][data-prefix='+$(this).data('prefix')+']').val(null);
  });

});

