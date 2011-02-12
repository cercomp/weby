class Twitter < ::WillPaginate::ViewHelpers::LinkRenderer
  def pagination
    [:next_page]
  end

  protected

  def next_page
    return unless @collection.next_page

    previous_or_next_page(@collection.next_page,
                          @options[:twitter_label],
                          @options[:twitter_class])
  end
end
