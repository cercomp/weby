// Apresenta os campos da versao extendida do menu de acessibilidade
var slide_fields = function(checkbox){
    if(checkbox.is(":checked")){
        $('.extended_fields').slideDown(300);
    }else{
        $('.extended_fields').slideUp(300);
    }
}
$(document).ready(function(){
    $("input#extended_accessibility").change(function(){
      slide_fields($(this))
    });
    slide_fields($("input#extended_accessibility"))
});