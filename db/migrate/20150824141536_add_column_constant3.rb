class AddColumnConstant3 < ActiveRecord::Migration
  def change
    add_column :constants, :mat_setka_50_50_3, :float, default: 2.0
    add_column :constants, :wei_setka_50_50_3, :float, default: 2.0
  end
end
