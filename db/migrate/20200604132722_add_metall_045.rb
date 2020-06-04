class AddMetall045 < ActiveRecord::Migration
  def change
    add_column :constants, :mat_list_2_1_045, :float, default: 2.0
    add_column :constants, :wei_list_2_1_045, :float, default: 2.0
  end
end
