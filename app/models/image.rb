class Image < ActiveRecord::Base
  validates :path_to_image, presence: true
end
