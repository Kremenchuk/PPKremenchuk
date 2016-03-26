class AddKratnostStoykiConstant2603 < ActiveRecord::Migration
  def change
    add_column :constants, :rack_multiplicity, :integer, default: 1
    add_column :constants, :otxod_pk, :float, default: 1.0
    add_column :constants, :otxod_sk, :float, default: 1.0
    add_column :constants, :otxod_pl, :float, default: 1.0
    add_column :constants, :otxod_trol, :float, default: 1.0
  end
end
