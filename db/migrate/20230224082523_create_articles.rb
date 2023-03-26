class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.json   :title,       null: false, default: { uk: '', en: '', ru: '' }
      t.json   :short_body,  null: false, default: { uk: '', en: '', ru: '' }
      t.json   :body,        null: false, default: { uk: '', en: '', ru: '' }
      t.timestamps
    end
  end
end
