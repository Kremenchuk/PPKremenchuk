class GalleriesController < ApplicationController
  before_action :check_if_admin, except: [:index, :galleries_view_photo, :gallery_view_photo_close]
  before_action :find_photo, only: [:photo_browser_destroy, :galleries_view_photo]

  def index
    # Ordered category definitions. `folder` matches the stored image_folder
    # value (note the legacy spellings: "werehouse", "trolleys"); `title_key`
    # maps to page.gallery.* i18n. Only non-empty categories are shown.
    defs = [
      { key: 'stillage',  folder: 'stillage',  title_key: 'arxiv' },
      { key: 'warehouse', folder: 'werehouse', title_key: 'warehouse' },
      { key: 'pallet',    folder: 'pallet',    title_key: 'pallet' },
      { key: 'trolley',   folder: 'trolleys',  title_key: 'trolley' },
      { key: 'mezzanine', folder: 'mezzanine', title_key: 'mezzanine' },
      { key: 'platform',  folder: 'platforms', title_key: 'platforms' },
      { key: 'loft',      folder: 'lofts',     title_key: 'lofts' }
    ]

    grouped = Gallery.all.group_by(&:image_folder)
    @gallery_categories = defs.filter_map do |d|
      photos = grouped[d[:folder]]
      next if photos.blank?

      d.merge(photos: photos)
    end
    @gallery_total = @gallery_categories.sum { |c| c[:photos].size }
  end

  def galleries_view_photo
    Gallery.find_by(id: params[:id], image_folder: params[:image_folder])
  end

  def photo_browser_index
    @galleries = Gallery.all
  end

  def gallery_view_photo_close
    redirect_to galleries_path
  end

  def photo_browser_destroy
    @photo.destroy!
    redirect_to photo_browser_index_path
  end

  def photo_browser_new
    if params[:images].present?
      Array(params[:images]).each do |image|
        if image.is_a?(ActionDispatch::Http::UploadedFile)
          gallery = Gallery.new
          gallery.image = image
          gallery.alt_to_image = params[:alt_image]
          gallery.image_folder = params[:image_type]
          gallery.save!
        end
      end
    end

    redirect_to photo_browser_index_path
  end

  private

  def find_photo
    @photo = Gallery.find(params[:id])
  end

end
