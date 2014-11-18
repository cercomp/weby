//= require init/datetime
//= require init/tinymce

$(document).ready(function(){
   $('#news_category_list').select2({
       width: 'resolve',
       tokenSeparators: [","],
       tags: $('#news_category_list').data('tags'),
       createSearchChoice: function(term){
         var eq = false
         $($('#news_category_list').select2('val')).each(function(){
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
