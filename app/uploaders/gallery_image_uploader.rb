class GalleryImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  storage :file

    # process resize_to_fit: [width, height]
  version :thumb do
    process :dynamic_resize
  end

  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.image_folder}/#{model.id}"
  end

  private

  def dynamic_resize
    if landscape?
      resize_to_fit(150, 113)
    else
      resize_to_fit(113, 150)
    end
  end

  def landscape?
    image = MiniMagick::Image.open(file.file)
    image[:width] > image[:height]
  end

end
