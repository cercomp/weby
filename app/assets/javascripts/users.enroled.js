function test_unrole(form_id){
  if( $('#'+form_id+' input:checked').length == 0 ){
    if(!confirm($('.role-submit').data('confirm-unrole'))){
      return false;
    }
  }
  return true;
}
