//= require datetime
//= require tinymce
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

   $('#page_category_list').select2({
       width: 'resolve',
       tokenSeparators: [","],
       tags: $('#page_category_list').data('tags'),
       createSearchChoice: function(term){
         var eq = false
         $($('#page_category_list').select2('val')).each(function(){
            //Case insensitive tagging
            if(this.toUpperCase().replace(/^\s+|\s+$/g,"") == term.toUpperCase().replace(/^\s+|\s+$/g,""))
                eq = true
         });
         if (eq)
             return false
         else
             return {id: term, text: term.replace(/^\s+|\s+$/g,"")};
       }
   });
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

