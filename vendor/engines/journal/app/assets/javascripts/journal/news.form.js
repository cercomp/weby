//= require init/datetime
//= require init/tinymce

$(document).ready(function(){
   $('.input-category').select2({
       width: 'resolve',
       tokenSeparators: [","],
       tags: $('.input-category').data('taglist'),
       createSearchChoice: function(term){
         var eq = false
         $($('.input-category').select2('val')).each(function(){
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
