/**
 * Script para páginas com formulário de componentes
 *
 */

/* Configurações iniciais */
var settings;
var old_settings;
var settings_loc;

window.onload = function(){
  settings     = $.parseJSON($("#components_settings").attr('meta-data'));
  settings_loc = $.parseJSON($("#components_settings_locales").attr('meta-data'));
  custom       = $.parseJSON($("#components_custom_fields").attr('meta-data'));
  old_settings = $.parseJSON($("#component_settings").attr('meta-data'));
  
  switch_settings();
  $('form[id*="site_component"]').submit( join_data );
  $('#site_component_component').change( switch_settings );
};

/**
 * Altera os campos de configurações conforme componente selecionado
 *
 */
function switch_settings() {
  var setting = $("#site_component_component :selected").val();

  $('#settings .input').empty();

  $(settings[setting]).each(function (i, s){
    var label;
    try {
      label = settings_loc[setting][i];
    } catch (err) {
      label = s;
    }
    
    if(custom[setting] === undefined || custom[setting][s] === undefined) {
      var field = $(['<p><label>', label, '</label><input name="', s, '" type="text" value="',
        old_settings[s], '"></p>'].join(''));
    }
    else {
      var field = $(['<p><label>', label, '</label>', custom[setting][s],'</p>'].join(''));
    }

    $('#settings .input').append(field);
  });
}

/**
 * Ao submeter o formulário essa função realiza o parser das configurações
 * escritas pelo usuário.
 */
function join_data(){
  var result = [];

  $('#settings .input p').each(function(i, v){
    $(v).children('input, select').each(function(i2, v2){
      var input = $(v2);
      
      // Caso o input não tenha o atributo "name"
      if(input.attr('name') == '') return;
      
      // Caso o input seja um checkbox e não esteja marcado
      if(input.is(':checkbox') && $(input + ':checked').val() === undefined) return;
      
      result.push([':', input.attr('name'), ' => "', input.val(), '"'].join(''));
      
    });
  });

  $('#settings .input').append(['<textarea name="site_component[settings]" style="display:none">{',
    result.join(', '), '}</textarea>'].join(''));
  
}

/**
 * Abre um popup para seleção de páginas
 */
function select_page() {
  if(!$('#page_list').length)
    $('#settings').append('<div id="page_list" style="display: none;" title="Selecione uma notícia"><img src="/images/spinner.gif"></div>');
    
  $('#page_list').dialog({
    width: '500px'
  });
  
  
  $.get($('#list_published_site_pages_path').attr('meta-data'), function(){
  }, 'script');
}

/**
 * Ao selecionar a notícia, cria um input com o id da noticia selecionada
 */
function selected (id, title) {
  $('#settings .input p').append('<input type="hidden" name="page" value="' + id + '" />');
  $('#settings a').before('<input type="text" disabled="disabled" value="'+ title +'" />');
  $('#page_list').dialog('close');
}

/**
  * Funções para manipulação do mini Layout
  */

function clear_mini_layout(){
  $(".clicked").each(function(){
    $(this).removeClass("clicked");
  });
}

//Retorna o id sem o "mini_" como o valor para o input
function select_position(){
  var id = ""
  $(".clicked").each(function(){ id = this.id});	
  $("input[type=hidden][id=site_component_place_holder]").val(id.slice(5));
}

//Controla o que acontence no momento em que a local e selecionado
$("#[id*=mini_]").click(function(event){
  clear_mini_layout();
  $(event.target).addClass('clicked');
  select_position();
});
