//= require jquery-ui.min 

/**
 * Script para páginas com formulário de componentes
 */

/* Configurações iniciais */
var place_holder = "#mini_"

window.onload = function(){
  place_holder += $("input#component_place_holder").val();
  $(place_holder).addClass('clicked');
};

/**
  * Funções para manipulação do mini Layout
  */
// Remove a classe de selecionado dos elementos
function clear_mini_layout(){
  $(".clicked").each(function(){
    $(this).removeClass("clicked");
  });
}

//Retorna o id sem o "mini_" como o valor para o input
function select_position(){
  var id = ""
  $(".clicked").each(function(){ id = this.id});	
  $("input[id$=_place_holder]").val(id.slice(5));
}

//Controla o que acontence no momento em que a local e selecionado
$("[id*=mini_]").click(function(event){
  clear_mini_layout();
  $(event.target).addClass('clicked');
  select_position();
});
