//= require datetimepicker/jquery.datetimepicker.full.min
//= require daterangepicker

$(document).ready(function () {

  var locale = $('html').attr('lang');
  jQuery.datetimepicker.setLocale(locale);
  moment.locale(locale);
  var format = 'd/m/Y H:i';
  var localeData = {
    format: "DD/MM/YYYY",
    separator: " - ",
    applyLabel: "Aplicar",
    cancelLabel: "Cancelar",
    fromLabel: "De",
    toLabel: "Até",
    daysOfWeek: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"],
    monthNames: ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho",
                  "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"],
    firstDay: 0
  };
  if (locale == 'en') {
    format = 'm/d/Y H:i';
    localeData = {
      format: "MM/DD/YYYY",
      separator: " - ",
      applyLabel: "Apply",
      cancelLabel: "Cancel",
      fromLabel: "From",
      toLabel: "To",
      daysOfWeek: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
      monthNames: ["January", "February", "March", "April", "May", "June", "July",
                    "August", "September", "October", "November", "December"],
      firstDay: 1
    };
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

  $('input[id="daterange"]').daterangepicker({
    //startDate: moment().subtract(30, 'days'),
    //endDate: moment(),
    locale: localeData
  });

});
