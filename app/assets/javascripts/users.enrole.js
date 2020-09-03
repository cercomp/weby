WEBY.initEnrolePage = function(){

  $('.search-user-input input').each(function(){
    var field = $(this);
    var list = field.closest('.search-user').find('.search-user-results');

    //// Prevent ENTER to trigger form submit on keydown
    field.keydown(function(ev){
      if (ev.keyCode == 13) {
        ev.preventDefault();
        return false;
      }
    })

    var searchTimer = null;
    field.keyup(function(ev){
      clearTimeout(searchTimer);
      searchTimer = setTimeout(function(){
        $.get(field.data('url'), {query: field.val()}, function(data){
          if (data.users.length > 0) {
            list.find('.users_list').html(data.users.map(function(i){
              return '<li>'+
                '<div class="checkbox">'+
                  '<label>'+
                    '<input type="checkbox" name="user[id][]" value="'+ i.id +'"/>'+
                    i.fullname + (i.login ? ' ('+ i.login +')' : '') +
                  '</label>'+
                '</div>'+
              '</li>';
            }).join(''));
            list.find('.msg').html('');
          } else {
            list.find('.users_list').html('');
            list.find('.msg').html('<div class="alert alert-warning">'+ data.meta.message +'</div>');
          }
          // var fullname = field.data('fullname');
          // if(fullname && fullname.length > 0){
          //   field.val(fullname);
          //   filter_user(fullname, list);
          // }
        });
        ev.preventDefault();
        return false;
      }, 420);
    });
  });
};

$(document).ready(WEBY.initEnrolePage);
