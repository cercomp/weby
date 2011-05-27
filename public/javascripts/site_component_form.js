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

  $('#settings .input').empty().append("<br>");

  $(settings[setting]).each(function (i, s){
    var label;
    try {
      label = settings_loc[setting][0];
    } catch (err) {
      label = s;
    }
    
    var field = $(['<p><label>', label, '</label><input name="', s, '" type="text" value="',
      old_settings[s], '"></p>'].join(''));

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
    var input = $(v).children('input');
    result.push([':', input.attr('name'), ' => "', input.val(), '"'].join(''));
  });

  $('#settings .input').append(['<textarea name="site_component[settings]" style="display:none">{',
    result.join(', '), '}</textarea>'].join(''));
}
