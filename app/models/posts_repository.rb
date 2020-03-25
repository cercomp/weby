class PostsRepository < ApplicationRecord
  belongs_to :post, polymorphic: true
  belongs_to :repository
end
