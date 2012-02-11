function ajaxUpload(){
   $('#fileupload').fileupload({
      url: $("#ajax-upload-form").attr('action'),
   dataType: "json",
   formData: [
   {name: "repository[description]", value: $("#description").val()},
   {name: "repository[site_id]", value: $("#site_id").val()},
   ],
   // FIXME: fix this (light)pog!!
   // O erro está sendo tratado dentro do evento done
   // pois o IE8 não recupera o HTTPstatus de erro do IFrame
   // Para resolver isso quando da erro o HTTP passa 200
   // porem no content da mensagem o JSON possui o campo
   // error que carrega a mensagem de erro.
   done: function (e, data) {
      if(data.result.error){
         handleFail(data.result.error);
      }else{
         resetFields();
         var repository = data.result.repositories.repository;
         var message = data.result.message;
         var response = $(document.createElement('li'));
         response.text([repository.description,
               " (", repository.archive_file_name, ")",
               " - ", message].join(''));

         $("#results").prepend(response);
      }
   },
   fail: function(e, data) {
      var error = JSON.parse(data.jqXHR.responseText).error;
      handleFail(error);
   },
   progress: function (e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $("#upload-file-progress").show().val(progress);
   },
   always: function (e, data) {
      c = data;
      $("#upload-file-progress").hide();
   }
   });
}

function handleFail(respondError) {
   $(respondError).each(function(index, error){
      var response = $(document.createElement('li'));
      response.text(error);
      $("#results").prepend(response);
   });
}

function resetFields () {
   $("#fileupload").val("");
   $("#description").val("");
}
