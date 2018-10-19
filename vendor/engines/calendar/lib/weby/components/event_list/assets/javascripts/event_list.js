$(function(){
  $(document).on("click", ".event_list_component .pagination a", function(){
      $comp = $(this).parents('.event_list_component');
      if($comp.css('position')!='absolute') $comp.css('position', 'relative');
      $tbl = $comp.find('table.list');
      $tblpos = $tbl.position();
      $comp.prepend($('<div class="loading-cloak"></div>').css({
          position: 'absolute',
          top: $tblpos.top,
          left: $tblpos.left,
          height: $tbl.outerHeight(),
          width: $tbl.outerWidth(),
          textAlign: 'center',
          background: 'rgba(255,255,255,.65) url(/assets/loading.gif) no-repeat center center'
      }));
  });

  var $sel2 = $('#categories-list');
  if($sel2.length > 0){
    $sel2.select2({
     width: 'resolve',
     tokenSeparators: [","],
     tags: $('#categories-list').data('taglist'),
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
  }
});
