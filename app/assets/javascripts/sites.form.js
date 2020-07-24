$(function (){
  $('.select2').select2({
    placeholder: '',
    allowClear: true,
    width: 'resolve'
  });

  $(document).on('change', '#site_parent_id,#site_name,#site_domain', function(){
    var url = $('.url-preview');
    var main_site = $('#site_parent_id')
    var domain = $('#site_domain')
    url.find('.site-domain').text($('#site_name').val().length > 0 ? `${$('#site_name').val()}.` : `[${url.find('.site-domain').data('placeholder')}].`);
    url.find('.parent-domain').text(main_site.val() ? `${main_site.find(':selected').data('name')}.` : '');
    url.find('.domain').text(domain.val().length > 0 ? domain.val() : url.find('.domain').data('default'));
  });
});