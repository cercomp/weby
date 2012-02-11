//= require jquery-ui.min 
//= require jquery-ui-timepicker-addon
//= require jquery-ui-timepicker-pt-BR

$(document).ready(function () {
  $('.datepicker').datepicker({
     dateFormat: "yy-mm-dd",
      changeMonth: true,
      changeYear: true,
      showOn: "both",
      buttonImage: "/images/calendar-icon.gif",
      buttonImageOnly: false
  });

  $('.datetimepicker').datetimepicker({
     dateFormat: "yy-mm-dd",
     changeMonth: true,
     changeYear: true
  });

})
