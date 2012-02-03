var event_fields;
// Alterna o tipo da página entre evento e notícia
$("input#is_event").change(function(){
   $("input#page_type").val($(this).is(":checked")? 'Event':'News' );
   if($(this).is(":checked")){
      event_fields.appendTo('#form_event');
      $('#event_fields').slideDown(300);
   }else{
      $('#event_fields').slideUp(300, function(){
          event_fields = $('#event_fields').detach();
      });
   }
});

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
