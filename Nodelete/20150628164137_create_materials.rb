class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.float :mat_list_2_1_055,                 default: 0
      t.float :mat_list_2_1_07,                 default: 0
      t.float :mat_list_25_125_07,                 default: 0
      t.float :mat_list_2_1_1,                 default: 0
      t.float :mat_list_2_1_2,                 default: 0
      t.float :mat_list_25_125_2,                 default: 0
      t.float :mat_list_2_1_25,                 default: 0
      t.float :mat_list_25_125_25,                 default: 0
      t.float :mat_stoyki_arx,                 default: 0
      t.float :mat_pyatki_arx,                 default: 0

      t.float :mat_stoyki_sklad,                 default: 0
      t.float :mat_traversa_sklad,                 default: 0
      t.float :mat_pyatki_sklad,                 default: 0
      t.float :mat_metizi_sklad,                 default: 0
      t.float :mat_ukosi_sklad,                 default: 0
      t.float :mat_zatsep_sklad,                 default: 0
      t.float :mat_truba_25_25_12,                 default: 0
      t.float :mat_truba_25_25_15,                 default: 0
      t.float :mat_truba_25_25_2,                 default: 0
      t.float :mat_shina_30_4,                 default: 0
      t.float :mat_skoba_styagnogo,                 default: 0

      t.float :mat_stoyki_pallet,                 default: 0
      t.float :mat_pyatki_pallet,                 default: 0
      t.float :mat_metizi_pallet_ram,                 default: 0
      t.float :mat_metizi_pallet_travers,                 default: 0
      t.float :mat_zatsep_pallet,                 default: 0
      t.float :mat_ukosi_pallet,                 default: 0

      t.float :mat_truba_du_20_25,                 default: 0
      t.float :mat_plastini_teleg,                 default: 0
      t.float :mat_metizi_teleg,                 default: 0
      t.float :mat_ugolok_20_20_3,                 default: 0

      t.float :mat_dsp_laminat,                 default: 0
      t.float :mat_dsp_shlif,                 default: 0


      t.timestamps null: false
    end
  end
end
