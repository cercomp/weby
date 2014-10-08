class PostsRepository < ActiveRecord::Base
  belongs_to :post, polymorphic: true
  belongs_to :repository
end
