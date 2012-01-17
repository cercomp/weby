// TODO arquivo semelhante ao menus.js estudar maneira de mescla-los

// Caso o usuário altere a url o page_id é zerado
$('#banner_url').change(function(){
  $('#banner_page_id').val(null);
});

// Caso o usuário altere a url o page_id é zerado
$('#banner_link').change(function(){
  $('#banner_page_id').val(null);
});

////!!!!Função show dialog movida para application.js

/**
 * Ao selecionar a notícia, cria um input com o id da noticia selecionada
 */
function selected (id, title) {
  var url = $('#url_to_pages').val() + '/' + id;

  $('#page_list').dialog('close');
  $('input#banner_url').val(url);

  // Adiciona a referencia para a página
  if ($('#banner_page_id').length == 0) {
    var page_reference = document.createElement('input');
    $(page_reference).attr('type', 'hidden')
      .attr('name', 'banner[page_id]')
      .attr('id', 'banner_page_id')
      .val(id);
    $('form[id*=banner]').append(page_reference);
  }
  // Ou se o campo já existir apenas muda o valor da página
  else {
    $('#banner_page_id').val(id);
  }
}
