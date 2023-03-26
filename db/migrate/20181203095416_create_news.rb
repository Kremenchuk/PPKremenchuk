class CreateNews < ActiveRecord::Migration[7.0]
  def change
    create_table :news do |t|
      t.json   :title,      null: false, default: { uk: '', en: '', ru: '' }
      t.json   :short_text, null: false, default: { uk: '', en: '', ru: '' }
      t.json   :text,       null: false, default: { uk: '', en: '', ru: '' }
      t.string :photo,      null: false
      t.date   :news_date,  null: false
      t.timestamps          null: false
    end
  end
end
