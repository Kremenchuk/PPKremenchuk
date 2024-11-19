class Gallery < ActiveRecord::Base
  default_scope { order(horizontal: :desc) }

  mount_uploader :image, GalleryImageUploader
  serialize :image, JSON
  before_save :set_orientation

  def self.next(params)
    current_gallery = find_gallery(params)

    return nil if current_gallery.nil?

    Gallery.unscoped.where("id > ?", current_gallery.id).order(id: :asc).first
  end

  def self.previous(params)
    current_gallery = find_gallery(params)

    return nil if current_gallery.nil?

    Gallery.unscoped.where("id < ?", current_gallery.id).order(id: :desc).first
  end

  private

  def set_orientation
    return unless image.present? && image.file.present?

    img = MiniMagick::Image.open(image.path)
    self.horizontal = img[:width] > img[:height]
  end

  def self.find_gallery(params)
    Gallery.find_by(id: params[:id], image_folder: params[:image_folder])
  end
end
