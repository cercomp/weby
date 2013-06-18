//= require jquery-ui.min 
//= require string
//= require repository.dialog.search
//= require repository.dialog.upload

$(document).ready(function(){
    $('.add-uniq-file .close').click(function(){
        $container = $(this).hide().siblings("div");
        $container.find('input[type=radio]').val(null);
        $container.find('label figure').html(null);
        $container.parents('.add-uniq-file').addClass('without-image');
        return false;
    });
});
