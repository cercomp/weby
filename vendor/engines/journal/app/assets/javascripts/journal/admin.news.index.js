$(document).ready(function() {
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

  //// ajax enable disable menu item
  if ($('td.front').length > 0) {
    appendToggleHandle('td.front a');
  }
  if ($('td.activate').length > 0) {
    appendToggleHandle('td.activate a', 'tr');
  }

  // Handler para os toggles de publicação
  $(document).on('change', '.toggle-publish-form input[type=checkbox]', function() {
    $(this).closest('form').submit();
  });

  // Handler para success/error do toggle de publicação
  $(document).on('ajax:success', '.toggle-publish-form', function(ev, data) {
    var $form = $(this); // O form que disparou o evento
    handleToggle($form, data, 'tr');

    // Atualiza o campo de status se retornado
    if (data.status_html && data.news_id) {
      // Encontra a linha da tabela correspondente e atualiza o status
      var $row = $form.closest('tr');
      // A coluna de status é a segunda td.publish (não a que contém o form)
      var $statusCell = $row.find('td.publish').not(':has(form)');
      $statusCell.html(data.status_html);
    }
  }).on('ajax:error', '.toggle-publish-form', function(ev, data) {
    handleToggle($(this), data.responseJSON, 'tr');
  });
});
