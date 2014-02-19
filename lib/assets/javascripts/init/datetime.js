//= require jquery.ui.slider
//= require jquery.ui.datepicker
//= require jquery.ui.datepicker-pt-BR
//= require datetimepicker/jquery-ui-timepicker-addon
//= require datetimepicker/jquery-ui-timepicker-pt-BR

$(document).ready(function () {
  if($('.datepicker').datepicker)
    $('.datepicker').datepicker({
      //dateFormat: "yy-mm-dd",
      changeMonth: true,
      changeYear: true,
      showOn: "both",
      buttonImage: "/images/calendar-icon.gif",
      buttonImageOnly: false
    });

  if($('.datetimepicker').datetimepicker)
    $('.datetimepicker').datetimepicker({
      //dateFormat: "yy-mm-dd",
      changeMonth: true,
      changeYear: true
    });
})
