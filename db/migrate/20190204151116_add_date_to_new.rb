class AddDateToNew < ActiveRecord::Migration
  def change
    add_column :news, :news_date, :date
  end
end
