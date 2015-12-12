class AddColumnConstant2 < ActiveRecord::Migration
  def change
    add_column :constants, :mat_100x60x100x15, :float
    add_column :constants, :wei_100x60x100x15, :float
  end
end
