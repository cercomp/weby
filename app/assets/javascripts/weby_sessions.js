//= require jquery
//= require jquery_ujs
//= require bootstrap

$(document).ready(function() {
  // Captcha refresh loading feedback & field focus
  $(document).on('click', '.btn-refresh-captcha', function() {
    var $btn = $(this);
    var $icon = $btn.find('.fa-refresh');
    var $wrap = $btn.closest('.weby-captcha-box');
    var $input = $wrap.find('.weby-captcha-input');

    $icon.addClass('fa-spin');
    if ($input.length) {
      $input.val('').focus();
    }
    setTimeout(function() {
      $icon.removeClass('fa-spin');
    }, 1200);
  });

  // Ensure captcha opens reliably: automatic retry and refresh if image fails
  $(document).on('error', '.weby-captcha-img', function() {
    var $img = $(this);
    var attempts = parseInt($img.data('retry-attempts') || '0', 10);
    if (attempts < 2) {
      $img.data('retry-attempts', attempts + 1);
      setTimeout(function() {
        var baseSrc = $img.attr('src').split('&_retry=')[0];
        $img.attr('src', baseSrc + '&_retry=' + new Date().getTime());
      }, 400);
    } else {
      $img.closest('.weby-captcha-box').find('.btn-refresh-captcha').trigger('click');
    }
  });

  $(document).on('load', '.weby-captcha-img', function() {
    $(this).data('retry-attempts', 0);
  });

  // Automatically check captcha visibility when user switches to #signup tab
  $(document).on('shown.bs.tab', 'a[data-toggle="tab"]', function(e) {
    var target = $(e.target).attr('href');
    if (target === '#signup') {
      var $signup = $('#signup');
      var $img = $signup.find('.weby-captcha-img');
      if ($img.length) {
        var domImg = $img[0];
        if (!domImg.complete || domImg.naturalWidth === 0) {
          $signup.find('.btn-refresh-captcha').trigger('click');
        }
      }
    }
  });

  // Password visibility toggle
  $(document).on('click', '.toggle-password-btn', function(e) {
    e.preventDefault();
    var $btn = $(this);
    var targetSelector = $btn.data('target');
    var $input = targetSelector ? $(targetSelector) : $btn.closest('.password-toggle-wrapper').find('input');
    var $icon = $btn.find('i');

    if ($input.length) {
      if ($input.attr('type') === 'password') {
        $input.attr('type', 'text');
        $icon.removeClass('fa-eye').addClass('fa-eye-slash');
      } else {
        $input.attr('type', 'password');
        $icon.removeClass('fa-eye-slash').addClass('fa-eye');
      }
    }
  });

  // Auto-uppercase for captcha input
  $(document).on('input', '.weby-captcha-input', function() {
    var start = this.selectionStart;
    var end = this.selectionEnd;
    this.value = this.value.toUpperCase();
    this.setSelectionRange(start, end);
  });
});
