// Show component extented menu accessibility.
var slide_fields = function(checkbox){
  if(checkbox.is(":checked")){
    $('.extended_fields').slideDown(300);
  }else{
    $('.extended_fields').slideUp(300);
  }
}
$(document).ready(function(){
  $("#menu_accessibility_component_extended_accessibility").change(function(){
    slide_fields($(this))
  });
  slide_fields($("#menu_accessibility_component_extended_accessibility"))
});

