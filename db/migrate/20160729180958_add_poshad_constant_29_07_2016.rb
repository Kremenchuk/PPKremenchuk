class AddPoshadConstant29072016 < ActiveRecord::Migration
  def change
    add_column :constants, :mat_profil_usil_warehouse, :float, default: 2.0
    add_column :constants, :area_profil_usil_warehouse, :float, default: 2.0
    add_column :constants, :wei_profil_usil_warehouse, :float, default: 2.0

    add_column :constants, :area_stoyki_arx, :float, default: 2.0
    add_column :constants, :area_pyatki_arx, :float, default: 2.0
    add_column :constants, :area_stoyki_sklad, :float, default: 2.0
    add_column :constants, :area_traversa_sklad, :float, default: 2.0
    add_column :constants, :area_pyatki_sklad, :float, default: 2.0
    add_column :constants, :area_ukosi_sklad, :float, default: 2.0
    add_column :constants, :area_zatsep_sklad, :float, default: 2.0
    add_column :constants, :area_truba_25_25_12, :float, default: 2.0
    add_column :constants, :area_truba_25_25_15, :float, default: 2.0
    add_column :constants, :area_truba_25_25_2, :float, default: 2.0
    add_column :constants, :area_shina_30_4, :float, default: 2.0
    add_column :constants, :area_skoba_styagnogo, :float, default: 2.0
    add_column :constants, :area_stoyki_pallet, :float, default: 2.0
    add_column :constants, :area_pyatki_pallet, :float, default: 2.0
    add_column :constants, :area_zatsep_pallet, :float, default: 2.0
    add_column :constants, :area_ukosi_pallet, :float, default: 2.0
    add_column :constants, :area_truba_du_20_25, :float, default: 2.0
    add_column :constants, :area_plastini_teleg, :float, default: 2.0
    add_column :constants, :area_ugolok_20_20_3, :float, default: 2.0
    add_column :constants, :area_100x60x100x15, :float, default: 2.0
    add_column :constants, :area_setka_50_50_3, :float, default: 2.0
    add_column :constants, :area_shpingalet_naves, :float, default: 2.0

  end
end
