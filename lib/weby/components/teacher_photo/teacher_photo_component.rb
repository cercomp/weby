class TeacherPhotoComponent < Component
  initialize_component :image, :height, :width

  validates :image, :presence => true
end
