class TeacherPhotoComponent < Component
  component_settings :image, :height, :width

  validates :image, :presence => true
end
