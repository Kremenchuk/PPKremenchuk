class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.string  :path_to_image
      t.string  :path_to_thumb
      t.string  :alt_to_image
      t.boolean :horizontal
      t.string :image_folder
      t.timestamps null: false
    end
  end
end
