$(function (){
    $('.search-filter').on('change', function(e){
        //$('#search').val(null);
        $('button[type=submit]').click();
    });
});

function updateMails() {
    var result_id = "";
    var result_email = "";
    var checks = document.getElementsByName("select_email");
    var target_id = document.getElementById("id_emails_to");
    var target_email = document.getElementById("emails_to");
    for (var i=0;i<checks.length;i++){
        if (checks[i].checked === true) {
            if (result_id !== "") {
                result_id = result_id + ',';
                result_email = result_email + '; ';
            };
            result_id = result_id + checks[i].id;
            result_email = result_email + checks[i].value;
        };
    };
    target_id.value = result_id;
    target_email.innerHTML = result_email;
    document.getElementById("selected_users").innerHTML = result_email;
};
