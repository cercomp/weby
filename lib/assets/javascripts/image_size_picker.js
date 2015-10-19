$(function(){

    $('.image-size-picker .custom-size input').focus(function(){
       $(this).closest(".radio").children().first().prop("checked", true);
    });

    $('.image-size-picker .radio').click(function(){
        $(this).find('input[type=radio]').prop('checked', true).change();
    });

    $(".image-size-picker input[type=radio][value!='']").change(function(){
       if($(this).is(":checked")) $(".image-size-picker .custom-size input[type=number]").val(null);
    });

});