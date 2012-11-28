//= require datetime
//= require tinymce
//= require repository.dialog
//= require tiny_mce/jquery.tinymce 
//= require_self

$(document).ready(function(){
   $("input#page_type").val($("input#is_event").is(":checked")? 'Event':'News' );
   if($("input#is_event").is(":checked")){
      //event_fields.appendTo('#form_event');
      $('#event_fields').show();
   }else{
      $('#event_fields').hide();
      event_fields = $('#event_fields').detach();
   }
});

var event_fields;
// Alterna o tipo da página entre evento e notícia
$("input#is_event").change(function(){
   $("input#page_type").val($(this).is(":checked")? 'Event':'News' );
   if($(this).is(":checked")){
      $(event_fields).appendTo('#form_event');
      $('#event_fields').slideDown(300);
   }else{
      $('#event_fields').slideUp(300, function(){
         event_fields = $('#event_fields').detach();
      });
   }
});

//Pega as categorias marcadas no checbox e 
//joga elas no campo Categorias
function set_categories() {
   var category_vet = $('input[name*="category_id"]');
   var category_names = "";

   $('#modal_tag_list').modal('hide');

   for(i=0;i<category_vet.size();i++){
      if(category_vet[i].checked ){
         category_names+=category_vet[i].value + ",";
      }
   }
   category_names += parse_categories(category_vet);
   category_names = category_names.slice(0,category_names.length - 1);
   $('input#page_category_list').val(category_names);

}

//verifica se alguma categoria no campo CAtegoris é nova
function parse_categories(category_vet){
   var new_category = "";
   var categories = new Array();
   var category_list = $('input#page_category_list').val().split(",");

   for(i=0 ; i<category_vet.size() ; i++){
      categories.push(category_vet[i].value);
   }

   for(i=0 ; i<category_list.length ; i++){
      if( categories.indexOf(trim(category_list[i])) == -1 ){
         new_category += category_list[i] + ",";
      }
   }
   return new_category;
}

//função que pega as categorias que estão escritas no campo
//Categorias, marca elas no checkbox se elas existirem
function categories_checked(){

   if($('input#page_category_list').val() != ""){
      var categories_list =  space_delete($('input#page_category_list').val().split(","));
      var categories_check = $('input[name*="category_id"]');

      for(i=0;i<categories_check.size();i++){
         if(categories_list.indexOf(categories_check[i].value) != -1){
            $(categories_check[i]).attr('checked', true);
         }
      }
   }

}

//função que recebe um array de string
//e retira os espações das string utilizando a função
//trim
function space_delete(array_categories){
   for(i=0;i<array_categories.length; i++){
      array_categories[i] = trim(array_categories[i]);
   }
   return array_categories;
}

//Função que retira os espaços do começo e do final de uma string
function trim(str) {
   return str.replace(/^\s+|\s+$/g,"");
}

