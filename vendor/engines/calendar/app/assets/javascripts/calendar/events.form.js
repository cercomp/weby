//= require init/datetime
//= require init/tinymce

$(document).ready(function(){
   $('#event_category_list').select2({
       width: 'resolve',
       tokenSeparators: [","],
       tags: $('#event_category_list').data('taglist'),
       createSearchChoice: function(term){
         var eq = false
         $($('#event_category_list').select2('val')).each(function(){
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
