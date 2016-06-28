# coding: utf-8
module SitesHelper
  def render_social_share type
    html = ''
    if current_site.send("#{type}_social_share_networks".to_sym).to_a.include?('twitter')
      html += '<a href="https://twitter.com/share" class="twitter-share-button">Tweet</a>'
      html += "<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>"
    end
    if current_site.send("#{type}_social_share_networks".to_sym).to_a.include?('facebook')
      html += <<EOF
        <div id="fb-root"></div>
        <script>// <![CDATA[
        (function(d, s, id) {
          var js, fjs = d.getElementsByTagName(s)[0];
          if (d.getElementById(id)) return;
          js = d.createElement(s); js.id = id;
          js.src = "//connect.facebook.net/pt_BR/sdk.js#xfbml=1&version=v2.5";
          fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
        // ]]></script>
        <div class="fb-like" data-href="" data-layout="standard" data-action="like" data-show-faces="true" data-share="true"></div>
EOF
    end
    html.html_safe
  end
end