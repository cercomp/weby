module Journal
  class NewslettersController < Journal::ApplicationController
    layout :choose_layout

    def new
      email = params[:email]
      @comp = current_site.components.find_by_name("newsletter")
      if !email.blank?
        if params[:opt].to_s == "delete"
          user = Newsletter.where("email = '"+email+"' AND site_id = "+current_site.id.to_s)[0]
          NewsletterMailer.delete_email(Weby::Components.factory(@comp).send_as, user, current_site.url).deliver
          redirect_to :back, flash: { success: t('deactivation_sent_successful') }
        else
          add_record = Newsletter.where("email = '"+email+"' AND site_id = "+current_site.id.to_s)[0]
          if add_record.nil?
            add_record = Newsletter.new
            add_record.site_id = current_site.id
            add_record.group = params[:group]
            add_record.email = params[:email]
          end
          add_record.token = Digest::SHA1.hexdigest([Time.now, rand].join)
          add_record.confirm = false
          if add_record.save
            NewsletterMailer.confirm_email(add_record, current_site.url).deliver
            redirect_to :back, flash: { success: t('activation_sent_successful') }
          else
          	redirect_to :back, flash: { error: t('error_creating_object') }
          end
        end
      end
    end

    def show
      if params[:id] == "confirmation"
        val = params[:token].split(':')
        user = Newsletter.where("id = "+val[1]+" AND token = '"+val[0]+"'")[0]
        if user.nil?
          redirect_to :root, flash: { error: t('error_creating_object') }
        else 
          user.token = Digest::SHA1.hexdigest([Time.now, rand].join)
          user.confirm = true
          user.save
          redirect_to :root, flash: { success: t('enable') }
        end
      end
      if params[:id] == "getout"
        val = params[:token].split(':')
        user = Newsletter.where("id = "+val[1]+" AND token = '"+val[0]+"'")[0]
        if user.nil?
          redirect_to :root, flash: { error: t('error_creating_object') }
        else
          user.token = Digest::SHA1.hexdigest([Time.now, rand].join)
          user.confirm = false
          user.save
          redirect_to :root, flash: { success: t('disable') }
        end
      end
    end
  end
end
