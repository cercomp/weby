module Journal::Admin
  class NewslettersController < Journal::ApplicationController
    def index
      @newsletterlist = get_newsletter
    end

    def destroy
      email = Journal::Newsletter.find(params[:id])
      found = false
      Journal::NewsletterHistories.where(site_id: current_site.id).each do |hist|
        if !found
          found = !hist.emails.split(',').index(email.id.to_s).nil?
        end
      end
      email.confirm = false
      found ? email.save : email.delete
      redirect_to admin_newsletters_path
    end

    def get_newsletter
      newsletter = Journal::Newsletter.where(site_id: current_site.id)
      if !params[:search].nil?
        search_condition = "%" + params[:search] + "%"
        newsletter = newsletter.where("email like ?",search_condition)
      end
      newsletter.order(params[:order] || 'email').
          page(params[:page]).per(params[:per_page])
    end
    private :get_newsletter
  end
end
