module Feedback
  module Admin::GroupsHelper
    def email_list group, options={}
      options[:max] ||= 3

      emails = group.emails_array
      [
        emails.first(options[:max].to_i).map{|e| content_tag(:span, e, class: 'label label-info') },
        (content_tag(:span, '...', class: 'more') if emails.size > options[:max].to_i)
      ].compact.flatten.join(' ').html_safe
    end
  end
end
