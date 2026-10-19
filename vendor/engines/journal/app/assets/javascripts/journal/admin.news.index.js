//= require init/datetime

$(document).ready(function() {
  // Inicializar datepicker nos campos de data (igual aos álbuns)
  var locale = $('html').attr('lang');
  jQuery.datetimepicker.setLocale(locale);
  var format = 'd/m/Y H:i';
  if (locale == 'en') {
    format = 'm/d/Y H:i';
  }

  if($('.datepicker').datetimepicker) {
    $('.datepicker').datetimepicker({
      format: format.replace(' H:i', ''),
      timepicker: false
    });
  }

  // helper para submeter o form do campo
  function submitFieldForm($field) {
    var $form = $field.closest('form');
    if ($form.length) {
      $form.submit();
    } else {
      $('form').first().submit();
    }
  }

  // Handler para campos datepicker (apenas seleção no calendário)
  $('.datepicker').each(function() {
    var $field = $(this);

    // Submite o form quando uma data é selecionada no calendário
    $field.on('change', function() {
      submitFieldForm($field);
    });
  });

  // Handler para limpar filtro de data
  $('.clear-date-filter').on('click', function() {
    // Limpa os campos de data
    $('input[name="start_date"]').val('');
    $('input[name="end_date"]').val('');

    // Submete o formulário para remover o filtro
    var $form = $(this).closest('form');
    if ($form.length) {
      $form.submit();
    } else {
      $('form').first().submit();
    }
  });

  // restante do seu código (mantive as mudanças seguras do submit por closest('form'))
  $('.search-filter').select2({
    placeholder: $('.search-filter').attr('placeholder'),
    width: 'resolve',
    minimumResultsForSearch: -1,
    allowClear: true
  });

  $('.search-filter').on('change', function(){
    var $form = $(this).closest('form');
    if ($form.length) $form.submit();
  });  //// ajax enable disable menu item
  if ($('td.front').length > 0) {
    appendToggleHandle('td.front a');
  }
  if ($('td.activate').length > 0) {
    appendToggleHandle('td.activate a', 'tr');
  }

  // Handler para os toggles de publicação
  $(document).on('change', '.toggle-publish-form input[type=checkbox]', function() {
    var $form = $(this).closest('form');
    if ($form.length) $form.submit();
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
