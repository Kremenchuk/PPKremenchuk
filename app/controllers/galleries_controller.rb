class GalleriesController < ApplicationController
  before_action :check_if_admin, except: [:index, :galleries_view_photo, :gallery_view_photo_close]
  before_action :find_photo, only: [:photo_browser_destroy, :galleries_view_photo]

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
    if params[:image].present?
      gallery = Gallery.new
      gallery.image = params[:image]
      gallery.alt_to_image = params[:alt_image]
      gallery.image_folder = params[:image_type]
      gallery.save!
    end

    redirect_to photo_browser_index_path
  end

  private

  def find_photo
    @photo = Gallery.find(params[:id])
  end

end
