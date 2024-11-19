class AddImageToGallery < ActiveRecord::Migration[7.0]
  def change
    add_column :galleries, :image, :string
    remove_column :galleries, :path_to_image, :string
    remove_column :galleries, :path_to_thumb, :string
  end
end
