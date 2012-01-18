function ajaxUpload(){
   $('#fileupload').fileupload({
      url: "/sites/pessoal/repositories",
   dataType: "json",
   formData: [
   {name: "repository[description]", value: $("#description").val()},
   {name: "repository[site_id]", value: $("#site_id").val()},
   ],
   done: function (e, data) {
      resetFields();

      var repository = data.result.repositories.repository;
      var message = data.result.message;
      var response = $(document.createElement('li'));
      response.text([repository.description,
         " (", repository.archive_file_name, ")",
         " - ", message].join(''));

      $("#results").prepend(response);
   },
   fail: function (e, data) {
      var result = eval('(' + data.jqXHR.responseText + ')');
      var response = $(document.createElement('li'));
      response.text("Description - " + result.description[0]);
      $("#results").prepend(response);
   },
   progress: function (e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $("#upload-file-progress").show().val(progress);
   },
   always: function (e, data) {
      $("#upload-file-progress").hide();
   }
   });
}

function resetFields () {
   $("#fileupload").val("");
   $("#description").val("");
}
