//= require datetimepicker/jquery.datetimepicker.full.min

$(document).ready(function () {

  var locale = $('html').attr('lang');
  jQuery.datetimepicker.setLocale(locale);
  var format = 'd/m/Y H:i';
  if (locale == 'en') {
    format = 'm/d/Y H:i';
  }


  if($('.datepicker').datetimepicker)
    $('.datepicker').datetimepicker({
      format: format.replace(' H:i', ''),
      timepicker:false
    });

  if($('.datetimepicker').datetimepicker)
    $('.datetimepicker').datetimepicker({
      format: format,
      step: 30
    });
})
