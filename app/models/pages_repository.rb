class PagesRepository < ActiveRecord::Base
  belongs_to :page
  belongs_to :repository
end
