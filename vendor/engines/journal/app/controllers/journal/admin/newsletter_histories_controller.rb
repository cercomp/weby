module Journal::Admin
  class NewsletterHistoriesController < Journal::ApplicationController
    def index
      @newsletterlist = get_news
    end

    def pdf
      Prawn::Document.generate("teste.pdf") do
        text "TESTE", size: 24, align: :center, style: :bold
        render_file('~')
      end
      redirect_to :back
    end

    def get_news
      dt_start = params[:dt_start].nil? ? Date.today-30 : params[:dt_start]
      dt_end = params[:dt_end].nil? ? Date.today : params[:dt_end]
      news = Journal::NewsletterHistories.get_by_date(current_site.id, dt_start, dt_end)
    end

  end
end
