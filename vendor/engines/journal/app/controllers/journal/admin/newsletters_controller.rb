module Journal::Admin
  class NewslettersController < Journal::ApplicationController
    def index
      @newsletterlist = Journal::Newsletter.where(site_id: current_site.id)
      if !params[:search].nil?
        search_condition = "%" + params[:search] + "%"
        @newsletterlist = @newsletterlist.where("email like ?",search_condition)
      end
      @newsletterlist = @newsletterlist.order(params[:order] || 'email')
    end

    def destroy
    end
  end
end
