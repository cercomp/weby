module Journal
  class ApplicationController < ::ApplicationController
    include ApplicationHelper

    def sort
#      Journal::News.includes(:sites, :user, :image)
#      .where('journal_news.site_id = :site OR journal_news_sites.site_id = :site', site: site.id).available_fronts
#      .order("#{order_by} #{direction}").page(page_param).per(quant)

      @ch_pos = Journal::NewsSite.where(site_id: current_site.id).front.where(journal_news_id: params[:id_moved]).first
      increment = 1
      # In case it was moved to the end of the list or the end of a page (when paginated)
      if (params[:id_after] == '0')
        @before = Journal::NewsSite.where(site_id: current_site.id).where(journal_news_id: params[:id_before]).first
        condition = "position < #{@ch_pos.position} AND position >= #{@before.position}"
        new_pos = @before.position
      else
        @after = Journal::NewsSite.where(site_id: current_site.id).where(journal_news_id: params[:id_after]).first
        # In case it was moved from top to bottom
        if @ch_pos.position > @after.position
          condition = "position < #{@ch_pos.position} AND position > #{@after.position}"
          new_pos = @after.position + 1
          # In case it was moved from bottom to top
        else
          increment = -1
          condition = "position > #{@ch_pos.position} AND position <= #{@after.position}"
          new_pos = @after.position
        end
      end
      Journal::NewsSite.where(site_id: current_site.id).front.where(condition).update_all("position = position + (#{increment})")
      @ch_pos.update_attribute(:position, new_pos)
      head :ok
    end

    def load_extension
      @extension = current_site.extensions.find_by(name: 'journal')
    end
  end
end
