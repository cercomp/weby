module Feedback
  module MessagesHelper

    def params_groups
      if params['groups']
       verify_groups
      end
    end

    def verify_groups
      groups = params['groups'].split(',')
      [].tap do |groups_id|
        @groups.each do |group|
          if groups.include? group.name
            groups_id << group.id
          end
        end
      end
    end
    private :verify_groups
  end
end
