$(document).ready(function(){
 $('#categories-list').select2({
       width: 'resolve',
       tokenSeparators: [","],
       tags: $('#categories-list').data('tags'),
       createSearchChoice: function(term){
         var eq = false
         $($('#categories-list').select2('val')).each(function(){
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

