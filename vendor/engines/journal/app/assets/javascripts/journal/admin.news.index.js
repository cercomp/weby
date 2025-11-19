$(document).ready(function() {
  // helper para submeter o form do campo
  function submitFieldForm($field) {
    var $form = $field.closest('form');
    if ($form.length) {
      $form.submit();
    } else {
      $('form').first().submit();
    }
  }

  // função que verifica se a data está completa e válida
  function isDateComplete(value) {
    if (!value) return true; // vazio é válido (limpa filtro)

    // Verifica se tem exatamente 10 caracteres no formato YYYY-MM-DD
    if (value.length !== 10) return false;
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;

    // Verifica se é uma data válida
    var parts = value.split('-');
    var year = parseInt(parts[0], 10);
    var month = parseInt(parts[1], 10);
    var day = parseInt(parts[2], 10);

    // Validações básicas
    if (year < 1900 || year > 2100) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;

    // Verifica se a data é válida usando JavaScript Date
    var testDate = new Date(year, month - 1, day);
    return testDate.getFullYear() === year &&
           testDate.getMonth() === (month - 1) &&
           testDate.getDate() === day;
  }

  // Handler inteligente para filtros de data
  $('.date-filter').each(function() {
    var $field = $(this);
    var lastValue = $field.val();
    var submitTimer = null;

    function checkAndSubmit() {
      var currentValue = $field.val();

      if (isDateComplete(currentValue)) {
        if (submitTimer) {
          clearTimeout(submitTimer);
        }
        submitFieldForm($field);
      }
    }

    // Monitora mudanças no campo
    $field.on('input', function() {
      var currentValue = $field.val();

      // Limpa timer anterior
      if (submitTimer) {
        clearTimeout(submitTimer);
      }

      // Se a data estiver completa, agenda submissão
      if (isDateComplete(currentValue)) {
        submitTimer = setTimeout(function() {
          submitFieldForm($field);
        }, 300);
      }

      lastValue = currentValue;
    });

    // Submite imediatamente ao sair do campo se válido
    $field.on('blur', function() {
      if (submitTimer) {
        clearTimeout(submitTimer);
      }
      checkAndSubmit();
    });

    // Enter submite imediatamente
    $field.on('keydown', function(e) {
      if (e.key === 'Enter' || e.which === 13) {
        e.preventDefault();
        if (submitTimer) {
          clearTimeout(submitTimer);
        }
        checkAndSubmit();
      }
    });

    // Change event para seleção de calendário
    $field.on('change', function() {
      if (submitTimer) {
        clearTimeout(submitTimer);
      }
      checkAndSubmit();
    });
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
