$(document).ready(function() {
  $('.search-filter').select2({
    placeholder: "Filtrar por status",
    width: 'resolve',
    minimumResultsForSearch: -1,
    allowClear: true
  });
  $('.search-filter').on('change', function(e){
    //$('#search').val(null);
    $('button[type=submit]').click();
  });

  //// ajax enable disable menu item
  if ($('td.front').length > 0) {
    appendToggleHandle('td.front a');
  }
  if ($('td.activate').length > 0) {
    appendToggleHandle('td.activate a', 'tr');
  }
});
