class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :path_to_image
      t.timestamps
    end
  end
end
