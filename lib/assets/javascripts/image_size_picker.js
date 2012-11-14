//= require jquery-ui.min
//= require repository.dialog

$(function(){

    $('.image-size-picker .controls .controls input').focus(function(){
       $(this).closest(".radio").children().first().prop("checked", true);
    });

    $('.image-size-picker .controls input[type=radio][value!=]').change(function(){
       if($(this).is(":checked")) $(".image-size-picker .controls input[type=number]").val(null);
    });

});