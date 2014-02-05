class PagePositionObserver < ActiveRecord::Observer
  observe :page

  # UPDATE
  def before_save(page)
    @page = page
    update_position if @page.front_changed? && !@page.new_record?
  end

  # CREATE
  def before_validation(page)
    @page = page
    # Sempre seta position
    @page.position = 0 if @page.position.nil?
    turning_front if @page.front && @page.new_record?
  end

  def before_destroy(page)
    @page = page
    leaving_fronts 
  end

  private
  def update_position
    @page.front ? turning_front : leaving_fronts 
  end

  def leaving_fronts
    update_fronts_up_me
    @page.position = 0
  end

  def update_fronts_up_me
    @page.owner.pages.front.where("position > #{@page.position}").
      update_all("position = position - 1")
  end

  def turning_front
    @page.position = last_front_position + 1
  end

  def last_front_position
    @page.owner.pages.front.maximum('position').to_i
  end
end
