class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def unscoped_destroy
    Calendar::Event.unscoped do
      Journal::News.unscoped do
        Repository.unscoped do
          Page.unscoped do
            destroy
          end
        end
      end
    end
  end
end
