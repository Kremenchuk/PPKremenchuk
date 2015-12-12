class AddColumnConstant < ActiveRecord::Migration
  def change
    add_column :constants, :wei_truba_25_25_2, :float
  end
end
