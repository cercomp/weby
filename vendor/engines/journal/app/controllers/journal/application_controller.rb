module Journal
  class ApplicationController < ::ApplicationController
    def sort
#      Journal::News.includes(:sites, :user, :image)
#      .where('journal_news.site_id = :site OR journal_news_sites.site_id = :site', site: site.id).available_fronts
#      .order("#{order_by} #{direction}").page(page_param).per(quant)

      @ch_pos = Journal::News
      .where(site_id: current_site.id).union(Journal::NewsSite.where(site_id: current_site.id)).available_fronts.find(params[:id_moved])
      increment = 1
      # In case it was moved to the end of the list or the end of a page (when paginated)
      if (params[:id_after] == '0')
        @before = current_site.news.find(params[:id_before])
        condition = "position < #{@ch_pos.position} AND position >= #{@before.position}"
        new_pos = @before.position
      else
        @after = current_site.news.find(params[:id_after])
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
      current_site.news.front.where(condition).update_all("position = position + (#{increment})")
      @ch_pos.update_attribute(:position, new_pos)
      render nothing: true
    end
  end
end
