class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def screen_name
    if respond_to?(:title) && self.title.present?
      self.title
    elsif respond_to?(:alias) && self.alias.present?
      self.alias
    elsif respond_to?(:name) && self.name.present? && !is_a?(Component)
      self.name
    elsif respond_to?(:email) && self.email.present?
      self.email
    elsif is_a?(Component)
      I18n.t("components.#{name}.name")
    else
      I18n.t("activerecord.models.#{self.class.name.underscore}")
    end
  end

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

  def unscoped_destroy!
    Calendar::Event.unscoped do
      Journal::News.unscoped do
        Repository.unscoped do
          Page.unscoped do
            destroy!
          end
        end
      end
    end
  end
end
