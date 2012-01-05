/**
 * Coloca um countainer para a lista de paginas
 */
function show_dialog() {
  if(!$('#page_list').length)
    $('#div_link').append('<div id="page_list" style="display: none;" title="Selecione uma notícia"><img src="/images/spinner.gif"></div>');
    
  $('#page_list').dialog({
    width: '700',
    height: '400'
  });
}

/**
 * Ao selecionar a notícia, cria um input com o id da noticia selecionada
 */
function selected (id, title) {
  $('#page_list').dialog('close');
  $('#selected_page').html(title);
  $('#page_id').val(id);
}
