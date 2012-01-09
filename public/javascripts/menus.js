/**
 * Coloca um countainer para a lista de paginas
 */
function show_dialog(ele) {
  if(!$('#page_list').length)
    $('#div_link').append('<div id="page_list" style="display: none;" title="Selecione uma notícia"><img src="/images/spinner.gif"></div>');

  $.get(ele.attr('data-link'));
    
  $('#page_list').dialog({
    width: '700',
    height: '400'
  });
}

/**
 * Ao selecionar a notícia, cria um input com o id da noticia selecionada
 */
function selected (id, title) {
  var url = $('#url_to_pages').val() + '/' + id;

  $('#page_list').dialog('close');
  $('input#menu_link').val(url);

  // Adiciona a referencia para a página
  var page_reference = document.createElement('input');
  $(page_reference).attr('type', 'hidden')
    .attr('name', 'page_id')
    .val(id);
  $('form[id$=menu]').append(page_reference);
}
