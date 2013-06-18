$(document).ready(function(){
   $('#about-weby').click(function(e) {
        if( $('#about-modal').length > 0 ){
            $('#about-modal').lightbox_me({
              centered: true
            });
        }else{
        $.get('/about', function(data){

           $('body').append('<div id="about-modal" style="display:none; background-color:white;">'+
            '<i class="icon-remove icon-black close"></i>'+
            '<div>'+
            data +
            '</div>'+
           '</div>');
           $('#about-modal').lightbox_me({
              centered: true
            });
        });
        }
        e.preventDefault();
        return false;
   });
});