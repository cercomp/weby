$(document).ready(function wrap_table() {
  if ($('table.nowrap').length == 0) return;

  var width;
  $('table.nowrap td').each(function(i, e) {
    width = $('table.nowrap th')[$(e).index()].width;
    $(e).html( '<div style="width:' + width + '">' + $(e).html() + '</div>' );
  });

  $('table.nowrap tr').hover(function() {
    $('td > div', this).css('white-space', 'normal');
  }, function() {
    $('td > div', this).css('white-space', 'nowrap');
  });

  $(document).live('ajaxComplete', wrap_table);
});
