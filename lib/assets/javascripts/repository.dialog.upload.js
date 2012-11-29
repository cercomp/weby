//= require fileupload/vendor/jquery.ui.widget
//= require fileupload/jquery.iframe-transport
//= require fileupload/jquery.fileupload

//= require_self
$(function(){
   $('#ajax-upload-form')
   
   .bind('fileuploaddone', function (e, data) {
      if(data.result.error){
         handleFail(data.result.error);
      }else{
         resetFields();
         var repository = data.result.repositories.repository;
         var message = data.result.message;
         text_msg = [repository.description,
               " (", repository.archive_file_name, ")",
               " - ", message].join('');
          $("#results").prepend('<span class="label label-success">'+text_msg+'</span>');
      }
   })
       // FIXME: fix this (light)pog!!
       // O erro está sendo tratado dentro do evento done
       // pois o IE8 não recupera o HTTPstatus de erro do IFrame
       // Para resolver isso quando da erro o HTTP passa 200
       // porem no content da mensagem o JSON possui o campo
       // error que carrega a mensagem de erro.
    .bind('fileuploadfail', function(e, data) {
          console.log(data)
          var error = JSON.parse(data.jqXHR.responseText).errors;
          handleFail(error);
       })
    .bind('fileuploadalways', function (e, data) {
          c = data;
          $("#upload-file-progress").hide();
          disableText(false, $("#ajax-upload-form *[type=submit]"));
       })
    .bind('fileuploadprogressall', function (e, data) {
          var progress = parseInt(data.loaded / data.total * 100, 10);
          $("#upload-file-progress").show().val(progress);
     })
     ///Inicializar, sem enviar no onchange doe files
     .fileupload({fileInput: null});
});


function ajaxUpload(){
   ///SEND//
   disableText(true, $("#ajax-upload-form *[type=submit]"));
   $('#ajax-upload-form').fileupload('send', {
       url: $("#ajax-upload-form").attr('action'),
       fileInput: $('#fileupload'),
       dataType: "json",
       formData: [
       {name: "repository[description]", value: $("#description").val()},
       {name: "repository[site_id]", value: $("#site_id").val()},
    ]});
    
}

function showFileName(field){
    $(".file-name").text($(field).val().replace("C:\\fakepath\\", ""));
}

function disableText(disab, field){
    field.prop('disabled', disab);
    var aux = field.data('disabled-text');
    field.data('disabled-text', field.text());
    field.text(aux);
}

function handleFail(respondError) {
   for (var key in respondError){
       $("#results").prepend('<span class="label label-important">'+key+' '+respondError[key]+'</span>');
   }
}

function resetFields () {
   $("#fileupload").val("");
   $("#fileupload").change();
   $("#description").val("");
}
