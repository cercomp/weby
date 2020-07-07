function wrap_table(){
  if ($('table.nowrap').length == 0) return;

  $('table.nowrap td').each(function(i, e) {
    //var width = ; //$('table.nowrap th')[$(e).index()].width;
    //$(e).wrapInner( '<div style="width:' + $(this).width() + 'px"></div>' );
  });
}

$(document).ready(function (){
  wrap_table();
  $(document).on('ajaxComplete', wrap_table);
});
