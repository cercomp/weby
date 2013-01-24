class View < ActiveRecord::Base
  belongs_to :site
  belongs_to :viewable, polymorphic: true
  belongs_to :user
  attr_accessible :ip_address, :query_string, :referer, :user_agent, :request_path, :session_hash, :viewable, :user
end
