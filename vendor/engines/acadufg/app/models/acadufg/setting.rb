module Acadufg
  class Setting < ActiveRecord::Base
    attr_accessible :programa_id, :site_id
  end
end
