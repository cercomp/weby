function makeTablesResponsive() {
  $('table.table').each(function() {
    var $table = $(this);
    var $parent = $table.parent();
    if (!$parent.hasClass('table-responsive') && !$parent.hasClass('table-wrapper')) {
      $table.wrap('<div class="table-responsive"></div>');
    }
  });
}

function wrap_table(){
  makeTablesResponsive();
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
