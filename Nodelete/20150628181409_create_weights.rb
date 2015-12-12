class CreateWeights < ActiveRecord::Migration
  def change
    create_table :weights do |t|
      t.float :wei_list_2_1_055,          default: 0
      t.float :wei_list_2_1_07,           default: 0
      t.float :wei_list_25_125_07,        default: 0
      t.float :wei_list_2_1_1,            default: 0
      t.float :wei_list_2_1_2,            default: 0
      t.float :wei_list_25_125_2,         default: 0
      t.float :wei_list_2_1_25,           default: 0
      t.float :wei_list_25_125_25,        default: 0
      t.float :wei_stoyki_arx,            default: 0
      t.float :wei_pyatki_arx,            default: 0

      t.float :wei_stoyki_sklad,          default: 0
      t.float :wei_traversa_sklad,        default: 0
      t.float :wei_pyatki_sklad,          default: 0
      t.float :wei_metizi_sklad,          default: 0
      t.float :wei_ukosi_sklad,           default: 0
      t.float :wei_zatsep_sklad,          default: 0
      t.float :wei_truba_25_25_12,        default: 0
      t.float :wei_truba_25_25_15,        default: 0
      t.float :wei_shina_30_4,            default: 0
      t.float :wei_skoba_styagnogo,       default: 0

      t.float :wei_stoyki_pallet,          default: 0
      t.float :wei_pyatki_pallet,          default: 0
      t.float :wei_metizi_pallet_ram,      default: 0
      t.float :wei_metizi_pallet_travers,  default: 0
      t.float :wei_zatsep_pallet,          default: 0
      t.float :wei_ukosi_pallet,           default: 0

      t.float :wei_truba_du_20_25,         default: 0
      t.float :wei_plastini_teleg,         default: 0
      t.float :wei_metizi_teleg,           default: 0
      t.float :wei_ugolok_20_20_3,         default: 0

      t.float :wei_dsp_laminat,            default: 0
      t.float :wei_dsp_shlif,              default: 0

      t.timestamps null: false
    end
  end
end
