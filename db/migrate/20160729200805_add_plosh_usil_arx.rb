class AddPloshUsilArx < ActiveRecord::Migration
  def change
    add_column :constants, :area_usil_arx, :float, default: 2.0
  end
end
