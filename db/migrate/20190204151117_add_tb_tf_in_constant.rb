class AddTbTfInConstant < ActiveRecord::Migration
  def change
      add_column :constants, :job_tb_tf_traversa, :float, default: 2.0
      add_column :constants, :mat_list_25_125_08, :float, default: 2.0
      add_column :constants, :mat_list_2_1_08, :float, default: 2.0
      add_column :constants, :wei_list_25_125_08, :float, default: 2.0
      add_column :constants, :wei_list_2_1_08, :float, default: 2.0
      add_column :constants, :area_tb_tf, :float, default: 2.0
  end
end
