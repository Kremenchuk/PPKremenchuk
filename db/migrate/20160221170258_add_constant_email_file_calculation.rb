class AddConstantEmailFileCalculation < ActiveRecord::Migration
  def change
    add_column :constants, :email_to_send, :string
    add_column :constants, :on_off_calc_stillage, :boolean
    add_column :constants, :on_off_calc_stillage_warehouse, :boolean
    add_column :constants, :on_off_calc_stillage_pallet, :boolean
    add_column :constants, :on_off_calc_TP01, :boolean
    add_column :constants, :on_off_calc_TP02, :boolean
    add_column :constants, :on_off_calc_TP03, :boolean
    add_column :constants, :on_off_calc_TP04, :boolean
    add_column :constants, :on_off_calc_TP05, :boolean
    add_column :constants, :on_off_calc_TP06, :boolean
    add_column :constants, :on_off_calc_TP07, :boolean
    add_column :constants, :on_off_calc_KS01, :boolean
    add_column :constants, :on_off_calc_KS02, :boolean
    add_column :constants, :on_off_calc_KS03, :boolean
    add_column :constants, :on_off_calc_KS04, :boolean
    add_column :constants, :on_off_calc_PT01, :boolean
    add_column :constants, :on_off_calc_PT02, :boolean
    add_column :constants, :on_off_calc_PT03, :boolean
    add_column :constants, :on_off_calc_PT04, :boolean

  end
end
