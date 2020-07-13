module Journal::Admin
  class NewslettersController < Journal::ApplicationController
    def index
      @newsletterlist = get_newsletter
    end

    def destroy
      email = current_site.newsletters.find(params[:id])
      destroy_email email
      redirect_to admin_newsletters_path
    end

    def destroy_many
      current_site.newsletters.where(id: params[:ids].split(',')).each do |email|
        destroy_email email
      end
      redirect_to admin_newsletters_path
    end

    def get_newsletter
      newsletter = current_site.newsletters
      if !params[:search].nil?
        search_condition = "%" + params[:search] + "%"
        newsletter = newsletter.where("email like ?",search_condition)
      end
      newsletter.order(params[:order] || 'email').
          page(params[:page]).per(params[:per_page])
    end
    private :get_newsletter

    def destroy_email email
      found = false
      Journal::NewsletterHistories.where(site_id: current_site.id).each do |hist|
        if !found
          found = !hist.emails.split(',').index(email.id.to_s).nil?
        end
      end
      email.confirm = false
      found ? email.save : email.delete
    end
    private :destroy_email
  end
end
