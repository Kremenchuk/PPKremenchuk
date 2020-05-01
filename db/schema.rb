# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190204151117) do

  create_table "constants", force: :cascade do |t|
    t.float    "mat_list_2_1_055",                default: 0.0
    t.float    "mat_list_2_1_07",                 default: 0.0
    t.float    "mat_list_25_125_07",              default: 0.0
    t.float    "mat_list_2_1_1",                  default: 0.0
    t.float    "mat_list_2_1_2",                  default: 0.0
    t.float    "mat_list_25_125_2",               default: 0.0
    t.float    "mat_list_2_1_25",                 default: 0.0
    t.float    "mat_list_25_125_25",              default: 0.0
    t.float    "mat_stoyki_arx",                  default: 0.0
    t.float    "mat_pyatki_arx",                  default: 0.0
    t.float    "mat_stoyki_sklad",                default: 0.0
    t.float    "mat_traversa_sklad",              default: 0.0
    t.float    "mat_pyatki_sklad",                default: 0.0
    t.float    "mat_metizi_sklad",                default: 0.0
    t.float    "mat_ukosi_sklad",                 default: 0.0
    t.float    "mat_zatsep_sklad",                default: 0.0
    t.float    "mat_truba_25_25_12",              default: 0.0
    t.float    "mat_truba_25_25_15",              default: 0.0
    t.float    "mat_truba_25_25_2",               default: 0.0
    t.float    "mat_shina_30_4",                  default: 0.0
    t.float    "mat_skoba_styagnogo",             default: 0.0
    t.float    "mat_stoyki_pallet",               default: 0.0
    t.float    "mat_pyatki_pallet",               default: 0.0
    t.float    "mat_metizi_pallet_ram",           default: 0.0
    t.float    "mat_metizi_pallet_travers",       default: 0.0
    t.float    "mat_zatsep_pallet",               default: 0.0
    t.float    "mat_ukosi_pallet",                default: 0.0
    t.float    "mat_truba_du_20_25",              default: 0.0
    t.float    "mat_plastini_teleg",              default: 0.0
    t.float    "mat_metizi_teleg",                default: 0.0
    t.float    "mat_ugolok_20_20_3",              default: 0.0
    t.float    "mat_dsp_laminat",                 default: 0.0
    t.float    "mat_dsp_shlif",                   default: 0.0
    t.float    "job_stoyki_arx",                  default: 0.0
    t.float    "job_polki_arx",                   default: 0.0
    t.float    "job_usil_arx",                    default: 0.0
    t.float    "job_upakovka_arx",                default: 0.0
    t.float    "job_ogranich",                    default: 0.0
    t.float    "job_okr_stoyki_arx",              default: 0.0
    t.float    "job_okr_polki_arx",               default: 0.0
    t.float    "job_stoyki_sklad",                default: 0.0
    t.float    "job_traversi_sklad",              default: 0.0
    t.float    "job_polki_sklad",                 default: 0.0
    t.float    "job_ukosi_sklad",                 default: 0.0
    t.float    "job_usil_styagnoy",               default: 0.0
    t.float    "job_usil_g",                      default: 0.0
    t.float    "job_okr_usil_sklad",              default: 0.0
    t.float    "job_okr_stoyki_sklad",            default: 0.0
    t.float    "job_ork_polki_sklad",             default: 0.0
    t.float    "job_okr_traversi_sklad",          default: 0.0
    t.float    "job_upakovka_sklad",              default: 0.0
    t.float    "job_stoyki_pallet",               default: 0.0
    t.float    "job_traversi_pallet",             default: 0.0
    t.float    "job_okr_travers_pallet",          default: 0.0
    t.float    "job_ukosi_pallet",                default: 0.0
    t.float    "job_svarka_ks_01",                default: 0.0
    t.float    "job_svarka_ks_02",                default: 0.0
    t.float    "job_svarka_ks_03",                default: 0.0
    t.float    "job_svarka_ks_04",                default: 0.0
    t.float    "job_svarka_pt_01",                default: 0.0
    t.float    "job_svarka_pt_02",                default: 0.0
    t.float    "job_svarka_pt_03",                default: 0.0
    t.float    "job_svarka_pt_04",                default: 0.0
    t.float    "job_svarka_tp_01",                default: 0.0
    t.float    "job_svarka_tp_02",                default: 0.0
    t.float    "job_svarka_tp_03",                default: 0.0
    t.float    "job_svarka_tp_04",                default: 0.0
    t.float    "job_svarka_tp_05",                default: 0.0
    t.float    "job_svarka_tp_06",                default: 0.0
    t.float    "job_svarka_tp_07",                default: 0.0
    t.float    "job_rezka",                       default: 0.0
    t.float    "job_okr_telegek",                 default: 0.0
    t.float    "job_gibka_du_20_25",              default: 0.0
    t.float    "job_rixtovka_ugolka",             default: 0.0
    t.float    "job_upakovka_teleg",              default: 0.0
    t.float    "job_rez_dsp_1mp",                 default: 0.0
    t.float    "job_natsenka",                    default: 0.0
    t.float    "job_dostavka_1kg",                default: 0.0
    t.float    "job_kostven_arx",                 default: 0.0
    t.float    "job_kostven_sklad",               default: 0.0
    t.float    "job_kostven_pallet",              default: 0.0
    t.float    "job_kostven_telegi",              default: 0.0
    t.float    "wei_list_2_1_055",                default: 0.0
    t.float    "wei_list_2_1_07",                 default: 0.0
    t.float    "wei_list_25_125_07",              default: 0.0
    t.float    "wei_list_2_1_1",                  default: 0.0
    t.float    "wei_list_2_1_2",                  default: 0.0
    t.float    "wei_list_25_125_2",               default: 0.0
    t.float    "wei_list_2_1_25",                 default: 0.0
    t.float    "wei_list_25_125_25",              default: 0.0
    t.float    "wei_stoyki_arx",                  default: 0.0
    t.float    "wei_pyatki_arx",                  default: 0.0
    t.float    "wei_stoyki_sklad",                default: 0.0
    t.float    "wei_traversa_sklad",              default: 0.0
    t.float    "wei_pyatki_sklad",                default: 0.0
    t.float    "wei_metizi_sklad",                default: 0.0
    t.float    "wei_ukosi_sklad",                 default: 0.0
    t.float    "wei_zatsep_sklad",                default: 0.0
    t.float    "wei_truba_25_25_12",              default: 0.0
    t.float    "wei_truba_25_25_15",              default: 0.0
    t.float    "wei_shina_30_4",                  default: 0.0
    t.float    "wei_skoba_styagnogo",             default: 0.0
    t.float    "wei_stoyki_pallet",               default: 0.0
    t.float    "wei_pyatki_pallet",               default: 0.0
    t.float    "wei_metizi_pallet_ram",           default: 0.0
    t.float    "wei_metizi_pallet_travers",       default: 0.0
    t.float    "wei_zatsep_pallet",               default: 0.0
    t.float    "wei_ukosi_pallet",                default: 0.0
    t.float    "wei_truba_du_20_25",              default: 0.0
    t.float    "wei_plastini_teleg",              default: 0.0
    t.float    "wei_metizi_teleg",                default: 0.0
    t.float    "wei_ugolok_20_20_3",              default: 0.0
    t.float    "wei_dsp_laminat",                 default: 0.0
    t.float    "wei_dsp_shlif",                   default: 0.0
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.float    "wei_truba_25_25_2"
    t.float    "mat_100x60x100x15"
    t.float    "wei_100x60x100x15"
    t.float    "mat_setka_50_50_3",               default: 2.0
    t.float    "wei_setka_50_50_3",               default: 2.0
    t.float    "job_natsen_diler",                default: 2.0
    t.float    "job_procent_udor_svarki_telegki", default: 2.0
    t.string   "email_to_send"
    t.boolean  "on_off_calc_stillage"
    t.boolean  "on_off_calc_stillage_warehouse"
    t.boolean  "on_off_calc_stillage_pallet"
    t.boolean  "on_off_calc_TP01"
    t.boolean  "on_off_calc_TP02"
    t.boolean  "on_off_calc_TP03"
    t.boolean  "on_off_calc_TP04"
    t.boolean  "on_off_calc_TP05"
    t.boolean  "on_off_calc_TP06"
    t.boolean  "on_off_calc_TP07"
    t.boolean  "on_off_calc_KS01"
    t.boolean  "on_off_calc_KS02"
    t.boolean  "on_off_calc_KS03"
    t.boolean  "on_off_calc_KS04"
    t.boolean  "on_off_calc_PT01"
    t.boolean  "on_off_calc_PT02"
    t.boolean  "on_off_calc_PT03"
    t.boolean  "on_off_calc_PT04"
    t.integer  "rack_multiplicity",               default: 1
    t.float    "otxod_pk",                        default: 1.0
    t.float    "otxod_sk",                        default: 1.0
    t.float    "otxod_pl",                        default: 1.0
    t.float    "otxod_trol",                      default: 1.0
    t.float    "job_natsen_diler_second",         default: 2.0
    t.float    "job_natsen_diler_third",          default: 2.0
    t.float    "mat_shpingalet_naves",            default: 2.0
    t.float    "wei_shpingalet_naves",            default: 2.0
    t.float    "mat_profil_usil_warehouse",       default: 2.0
    t.float    "area_profil_usil_warehouse",      default: 2.0
    t.float    "wei_profil_usil_warehouse",       default: 2.0
    t.float    "area_stoyki_arx",                 default: 2.0
    t.float    "area_pyatki_arx",                 default: 2.0
    t.float    "area_stoyki_sklad",               default: 2.0
    t.float    "area_traversa_sklad",             default: 2.0
    t.float    "area_pyatki_sklad",               default: 2.0
    t.float    "area_ukosi_sklad",                default: 2.0
    t.float    "area_zatsep_sklad",               default: 2.0
    t.float    "area_truba_25_25_12",             default: 2.0
    t.float    "area_truba_25_25_15",             default: 2.0
    t.float    "area_truba_25_25_2",              default: 2.0
    t.float    "area_shina_30_4",                 default: 2.0
    t.float    "area_skoba_styagnogo",            default: 2.0
    t.float    "area_stoyki_pallet",              default: 2.0
    t.float    "area_pyatki_pallet",              default: 2.0
    t.float    "area_zatsep_pallet",              default: 2.0
    t.float    "area_ukosi_pallet",               default: 2.0
    t.float    "area_truba_du_20_25",             default: 2.0
    t.float    "area_plastini_teleg",             default: 2.0
    t.float    "area_ugolok_20_20_3",             default: 2.0
    t.float    "area_100x60x100x15",              default: 2.0
    t.float    "area_shpingalet_naves",           default: 2.0
    t.float    "area_usil_arx",                   default: 2.0
    t.float    "job_tb_tf_traversa",              default: 2.0
    t.float    "mat_list_25_125_08",              default: 2.0
    t.float    "mat_list_2_1_08",                 default: 2.0
    t.float    "wei_list_25_125_08",              default: 2.0
    t.float    "wei_list_2_1_08",                 default: 2.0
    t.float    "area_tb_tf",                      default: 2.0
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "text"
  end

  create_table "galleries", force: :cascade do |t|
    t.string   "path_to_image"
    t.string   "path_to_thumb"
    t.string   "alt_to_image"
    t.boolean  "horizontal"
    t.string   "image_folder"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "news", force: :cascade do |t|
    t.string   "news_header"
    t.string   "short_text"
    t.string   "text"
    t.string   "photo"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.date     "news_date"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "login",                  default: "",    null: false
    t.string   "name",                   default: "",    null: false
    t.boolean  "admin",                  default: false
    t.integer  "diller",                 default: 4
    t.string   "language",               default: "ru"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
