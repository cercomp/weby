$(document).ready(function(){
   $('.share_button').click(function(e) {       
        $.get($(this).data('url'), function(data){

           $(data).modal('show').on('hidden', function(){ $(this).remove(); });
        });
        e.preventDefault();
        return false;
   });
});

function save(){

   $("input:checkbox").attr("checked",true); 

}