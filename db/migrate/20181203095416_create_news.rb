class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string :news_header
      t.string :short_text
      t.string :text
      t.string :photo
      t.timestamps null: false
    end
  end
end
