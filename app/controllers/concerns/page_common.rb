module PageCommon
  extend ActiveSupport::Concern
  
  def sort
    @ch_pos = current_site.pages.find(params[:id_moved], :readonly => false)
    increment = 1
    # In case it was moved to the end of the list or the end of a page (when paginated)
    if(params[:id_after] == '0')
      @before = current_site.pages.find(params[:id_before])
      condition = "position < #{@ch_pos.position} AND position >= #{@before.position}"
      new_pos = @before.position
    else
      @after = current_site.pages.find(params[:id_after])
      # In case it was moved from top to bottom
      if(@ch_pos.position > @after.position)
        condition = "position < #{@ch_pos.position} AND position > #{@after.position}"
        new_pos = @after.position+1
        # In case it was moved from bottom to top
      else
        increment = -1
        condition = "position > #{@ch_pos.position} AND position <= #{@after.position}"
        new_pos = @after.position
      end
    end
    current_site.pages.front.where(condition).update_all("position = position + (#{increment})")
    @ch_pos.update_attribute(:position, new_pos)
    render :nothing => true
  end
end

