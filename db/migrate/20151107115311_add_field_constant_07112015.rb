class AddFieldConstant07112015 < ActiveRecord::Migration
  def change
    add_column :constants, :job_natsen_diler, :float, default: 2.0
    add_column :constants, :job_procent_udor_svarki_telegki, :float, default: 2.0
    add_column :users, :diller, :boolean, default: false
  end
end
