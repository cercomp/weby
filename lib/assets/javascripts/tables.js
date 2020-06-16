function wrap_table(){
  if ($('table.nowrap').length == 0) return;

  var width;
  $('table.nowrap td').each(function(i, e) {
    width = $(this).width(); //$('table.nowrap th')[$(e).index()].width;
    $(e).wrapInner( '<div style="width:' + width + 'px"></div>' );
  });

  $('table.nowrap tr').hover(function() {
    $('td > div', this).css('white-space', 'normal');
  }, function() {
    $('td > div', this).css('white-space', 'nowrap');
  });
}

$(document).ready(function (){
  wrap_table();
  $(document).on('ajaxComplete', wrap_table);
});
