class AddColTreeDilerShping < ActiveRecord::Migration
  def change
      add_column :constants, :job_natsen_diler_second, :float, default: 2.0
      add_column :constants, :job_natsen_diler_third, :float, default: 2.0
      add_column :constants, :mat_shpingalet_naves, :float, default: 2.0
      add_column :constants, :wei_shpingalet_naves, :float, default: 2.0

      change_table :users do |f|
        f.change :diller, :integer, default: 4.0
      end
  end
end
