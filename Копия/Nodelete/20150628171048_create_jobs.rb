class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.float :job_stoyki_arx,                 default: 0
      t.float :job_polki_arx,                 default: 0
      t.float :job_usil_arx,                 default: 0
      t.float :job_upakovka_arx,                 default: 0
      t.float :job_ogranich,                 default: 0
      t.float :job_okr_stoyki_arx,                 default: 0
      t.float :job_okr_polki_arx,                 default: 0

      t.float :job_stoyki_sklad,                 default: 0
      t.float :job_traversi_sklad,                 default: 0
      t.float :job_polki_sklad,                 default: 0
      t.float :job_ukosi_sklad,                 default: 0
      t.float :job_usil_styagnoy,                 default: 0
      t.float :job_usil_g,                 default: 0
      t.float :job_okr_usil_sklad,                 default: 0
      t.float :job_okr_stoyki_sklad,                 default: 0
      t.float :job_ork_polki_sklad,                 default: 0
      t.float :job_okr_traversi_sklad,                 default: 0
      t.float :job_upakovka_sklad,                 default: 0

      t.float :job_stoyki_pallet,                 default: 0
      t.float :job_traversi_pallet,                 default: 0
      t.float :job_okr_travers_pallet,                 default: 0
      t.float :job_ukosi_pallet,                 default: 0

      t.float :job_svarka_ks_01,                 default: 0
      t.float :job_svarka_ks_02,                 default: 0
      t.float :job_svarka_ks_03,                 default: 0
      t.float :job_svarka_ks_04,                 default: 0
      t.float :job_svarka_pt_01,                 default: 0
      t.float :job_svarka_pt_02,                 default: 0
      t.float :job_svarka_pt_03,                 default: 0
      t.float :job_svarka_pt_04,                 default: 0
      t.float :job_svarka_tp_01,                 default: 0
      t.float :job_svarka_tp_02,                 default: 0
      t.float :job_svarka_tp_03,                 default: 0
      t.float :job_svarka_tp_04,                 default: 0
      t.float :job_svarka_tp_05,                 default: 0
      t.float :job_svarka_tp_06,                 default: 0
      t.float :job_svarka_tp_07,                 default: 0
      t.float :job_rezka,                 default: 0
      t.float :job_okr_ks_01,                 default: 0
      t.float :job_okr_ks_02,                 default: 0
      t.float :job_okr_ks_03,                 default: 0
      t.float :job_okr_ks_04,                 default: 0
      t.float :job_okr_pt_01,                 default: 0
      t.float :job_okr_pt_02,                 default: 0
      t.float :job_okr_pt_03,                 default: 0
      t.float :job_okr_pt_04,                 default: 0
      t.float :job_okr_tp_01,                 default: 0
      t.float :job_okr_tp_02,                 default: 0
      t.float :job_okr_tp_03,                 default: 0
      t.float :job_okr_tp_04,                 default: 0
      t.float :job_okr_tp_05,                 default: 0
      t.float :job_okr_tp_06,                 default: 0
      t.float :job_okr_tp_07,                 default: 0
      t.float :job_gibka_du_20_25,                 default: 0
      t.float :job_rixtovka_ugolka,                 default: 0
      t.float :job_upakovka_teleg,                 default: 0

      t.float :job_rez_dsp_1mp,                 default: 0

      t.float :job_natsenka,                 default: 0           #наценка
      t.float :job_dostavka_1kg,                 default: 0       #стоимость доставки 1 кг
      t.float :job_kostven_arx,                 default: 0        #коственные затраты на архивные стеллажи
      t.float :job_kostven_sklad,                 default: 0      #коственные затраты на складские
      t.float :job_kostven_pallet,                 default: 0     #коственные затраты на паллетные
      t.float :job_kostven_telegi,                 default: 0     #коственные затраты на телеги



      t.timestamps null: false
    end
  end
end
