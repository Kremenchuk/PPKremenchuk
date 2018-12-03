class Gallery < ActiveRecord::Base
  default_scope { order(horizontal: :desc) }
  attr_accessible :path_to_image, :path_to_thumb, :alt_to_image, :horizontal, :image_folder
end
