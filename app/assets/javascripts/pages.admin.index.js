//= require init/datetime

$(document).ready(function() {
  //// ajax enable disable menu item
  appendToggleHandle('td.publish a', 'tr');

  $('.search-filter').select2({
    placeholder: $('.search-filter').attr('placeholder'),
    width: 'resolve',
    minimumResultsForSearch: -1,
    allowClear: true
  });
  $('.search-filter').on('change', function(e){
    //$('#search').val(null);
    $('button[type=submit]').click();
  });
});
