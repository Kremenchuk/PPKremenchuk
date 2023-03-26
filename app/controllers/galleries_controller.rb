class GalleriesController < ApplicationController
  before_action :check_if_admin, except: [
    :index, :galleries_view_photo, :galleries_previous_view_photo, :galleries_next_view_photo,
    :gallery_view_photo_close
  ]
  before_action :find_photo, only: [
    :photo_browser_destroy, :galleries_view_photo, :galleries_previous_view_photo, :galleries_next_view_photo
  ]

  def index
    @mezanines = Gallery.where(image_folder: 'mezzanine')
    @stillages = Gallery.where(image_folder: 'stillage')
    @pallets = Gallery.where(image_folder: 'pallet')
    @warehouses = Gallery.where(image_folder: 'werehouse')
    @trolleys = Gallery.where(image_folder: 'trolleys')
    @platforms = Gallery.where(image_folder: 'platforms')
    @lofts = Gallery.where(image_folder: 'lofts')
  end

  def galleries_view_photo
  end

  def galleries_previous_view_photo
    previous_photo = @photo.previous
    redirect_to galleries_view_photo_path(id: previous_photo&.id.present? ? previous_photo.id : @photo.id)
  end

  def galleries_next_view_photo
    photo_next = @photo.next
    redirect_to galleries_view_photo_path(id: photo_next&.id.present? ? photo_next.id : @photo.id)
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
    # :path_to_image, :path_to_thumb, :alt_to_image, :horizontal, :image_folder
    begin
      image_name = "stillage_#{params[:image_type]}_#{params[:image].original_filename}"
      image_path = File.join(Rails.root,'public/assets/gallery', params[:image_type])

      thumb_image_name = "thumb_stillage_#{params[:image_type]}_#{params[:thumb_image].original_filename}"
      thumb_image_path = File.join(Rails.root,'public/assets/gallery', params[:image_type], 'thumbs')

      if !File.exist?(File.join(image_path))
        FileUtils.mkdir_p(image_path)
      end

      File.open(File.join(image_path, image_name),'wb') do |f|
        f.write(params[:image].read)
      end

      if !File.exist?(File.join(thumb_image_path))
        FileUtils.mkdir_p(thumb_image_path)
      end

      File.open(File.join(thumb_image_path, thumb_image_name),'wb') do |f|
        f.write(params[:thumb_image].read)
      end

      gallery = Gallery.new
      gallery.path_to_image = File.join('/assets/gallery',  params[:image_type],image_name)
      gallery.path_to_thumb = File.join('/assets/gallery', params[:image_type], 'thumbs', thumb_image_name)
      gallery.alt_to_image = params[:alt_image]
      gallery.image_folder = params[:image_type]
      gallery.horizontal = params[:horizontal] == 'Да' ? true : false
      gallery.save!
    end
    redirect_to photo_browser_index_path
  end

  private

  def find_photo
    @photo = Gallery.find(params[:id])
  end

end