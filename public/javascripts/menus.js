// TODO arquivo semelhante ao banners.js estudar maneira de mescla-los

// Caso o usuário altere a url o page_id é zerado
$('#menu_link').change(function(){
  $('#menu_page_id').val(null);
});

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
  if ($('#menu_page_id').length == 0) {
    var page_reference = document.createElement('input');
    $(page_reference).attr('type', 'hidden')
      .attr('name', 'menu[page_id]')
      .attr('id', 'menu_page_id')
      .val(id);
    $('form[id*=menu]').append(page_reference);
  }
  // Ou se o campo já existir apenas muda o valor da página
  else {
    $('#menu_page_id').val(id);
  }

}
