module GalleriesHelper
  def next_image_in_gallery(**params)
    Gallery.next(params)
  end

  def previous_image_in_gallery(**params)
    Gallery.previous(params)
  end
end
