/**
 * Script para páginas com formulário de componentes
 *
 */

/* Configurações iniciais */
var settings;
var old_settings;

window.onload = function(){
  settings = $.parseJSON($("#components_settings").attr('meta-components_settings'));
  old_settings = $.parseJSON($("#component_settings").attr('meta-component_settings'));

  switch_settings();
  $('form[id*="site_component"]').submit( join_data );
  $('#component').change( switch_settings );
};

/**
 * Altera os campos de configurações conforme componente selecionado
 *
 */
function switch_settings() {
  var setting = $("#component :selected").val();

  $('#settings').empty();

  $(settings[setting]).each(function (i, s){
    var a = $(['<p><label>', s, '</label><input name="', s, '" type="text" value="',
      old_settings[s], '"></p>'].join(''));

    $('#settings').append(a);
  });
}

/**
 * Ao submeter o formulário essa função realiza o parser das configurações
 * escritas pelo usuário.
 */
function join_data(){
  var result = [];

  $('#settings p').each(function(i, v){
    var input = $(v).children('input');
    result.push([':', input.attr('name'), ' => "', input.val(), '"'].join(''));
  });

  $('#settings').append(['<textarea name="site_component[settings]" style="display:none">{',
    result.join(', '), '}</textarea>'].join(''));
}
