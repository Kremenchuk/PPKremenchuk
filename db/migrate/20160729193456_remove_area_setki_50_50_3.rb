class RemoveAreaSetki50503 < ActiveRecord::Migration
  def change
    change_table :constants do |t|
      t.remove :area_setka_50_50_3
    end
  end
end
