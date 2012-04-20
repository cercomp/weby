//= require jquery-ui.min
//= require dialog
//= require tabs

// TODO arquivo semelhante ao banners.js estudar maneira de mescla-los

// Caso o usuário altere a url o page_id é zerado
$('#menu_item_url').change(function(){
  $('#menu_item_target_id').val(null);
  $('#menu_item_target_type').val(null);
});

////!!!!! Função show_dialog movida para application.js

/**
 * Ao selecionar a notícia, cria um input com o id da noticia selecionada
 */
function selected (id, title, type) {
  var url = $('#url_to_pages').val() + '/' + id;

  $('#page_list').dialog('close');
  $('input#menu_item_url').val(url);

  // Adiciona a referencia para a página
  if ($('#menu_item_target_id').length == 0) {
    var page_reference = document.createElement('input');
    $(page_reference).attr('type', 'hidden')
      .attr('name', 'menu_item[target_id]')
      .attr('id', 'menu_item_target_id')
      .val(id);
    $('form[id*=menu_item]').append(page_reference);
    var page_type = document.createElement('input');
    $(page_type).attr('type', 'hidden')
      .attr('name', 'menu_item[target_type]')
      .attr('id', 'menu_item_target_type')
      .val(type);
    $('form[id*=menu_item]').append(page_type);
  }
  // Ou se o campo já existir apenas muda o valor da página
  else {
    $('#menu_item_target_id').val(id);
    $('#menu_item_target_type').val(type);
  }

}
