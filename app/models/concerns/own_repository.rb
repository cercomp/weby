module OwnRepository
  extend ActiveSupport::Concern

  included do
    belongs_to :image, class_name: 'Repository', foreign_key: 'repository_id', optional: true

    validate :should_be_image
    validate :should_be_own_image
    validate :should_be_own_files

    def image=(file)
      return self.repository_id = file.id if file.is_a?(Repository)
      self.repository_id = file
    end

    private

    def should_be_image
      return unless image
      error_message = I18n.t('should_be_image')
      errors.add(:image, error_message) unless is_image?
    end

    def should_be_own_image
      return unless image
      error_message = I18n.t('should_be_own_image')
      errors.add(:image, error_message) unless own_image?
    end

    def should_be_own_files
      error_message = I18n.t('should_be_own_files')
      errors.add(:related_files, error_message) unless own_files?
    end

    def is_image?
      image.archive_content_type =~ /image/
    end

    def own_image?
      image.site_id == site.id
    end

    def own_files?
      related_files.each do |file|
        return false if file.site_id != site.id
      end
      true
    end
  end
end
