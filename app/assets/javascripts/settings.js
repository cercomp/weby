$(document).ready(function(){
    $('.setting-input input[type="checkbox"]').change(function(){
        var $input = $(this).parents('.setting-input').find('.setting-field');
        $input.prop('disabled', !$(this).is(":checked"));
        var aux = $input.val();
        $input.val($input.data('disabledtext'));
        $input.data('disabledtext', aux);
    });

    $('.select2').select2({
       width: 'resolve'
   });
});