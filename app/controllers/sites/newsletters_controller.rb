class Sites::NewslettersController < ApplicationController
  layout :choose_layout

  def new 
    email = params[:email]
    if !email.blank?
      add_record = Newsletter.where("email = '"+email+"' AND site_id = "+current_site.id.to_s)[0]
      if add_record.nil?
        add_record = Newsletter.new
        add_record.site_id = current_site.id
        add_record.group = params[:group]
        add_record.email = params[:email]
      end
      add_record.chave = Digest::SHA1.hexdigest([Time.now, rand].join)
      add_record.confirm = false
      add_record.save
      flash[:notice] = t('.success')
    end
    redirect_to :root
  end

  def show
  end

end
