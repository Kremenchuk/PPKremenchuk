module GalleriesHelper
  def next_image_in_gallery_present?(id)
    Gallery.next_present?(id)
  end

  def previous_image_in_gallery_present?(id)
    Gallery.previous_present?(id)
  end
end
