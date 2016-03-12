class ConstantsController < ApplicationController
  before_filter :find_item, only: [:edit, :update, :show]
  before_filter :check_if_admin, only: [:index, :show, :edit, :update]


  #index
  #%form{:action => "index", :method => "get", :name => "contact_form", :onsubmit => "return validate_form ( );"}
  #%input.input_style{:maxlength => "8", :name => "mat_list_2_1_055", :pattern => "\[0-9]+\[.]\[0-9]{2}",
  #    :size => "12", :value => "#{@constant.mat_list_2_1_055}", :type => "text"}



  def index
    #@constants = Constant.all
    #@constant = Constant.where("id = 1")




  end

  def edit
    button_const
    #@material = Material.where("id = 1")
    #flash[:success]="Отредактировано"
  end

  def show
    redirect_to action: "edit"

    
    
    


    @constants = Constant.new

    @constants.mat_list_2_1_055= 1.00
    @constants.mat_list_2_1_07= 1.00
    @constants.mat_list_25_125_07= 1.00
    @constants.mat_list_2_1_1= 1.00
    @constants.mat_list_2_1_2= 1.00
    @constants.mat_list_25_125_2= 1.00
    @constants.mat_list_2_1_25= 1.00
    @constants.mat_list_25_125_25= 1.00
    @constants.mat_stoyki_arx= 1.00
    @constants.mat_pyatki_arx= 1.00
    @constants.mat_stoyki_sklad= 1.00
    @constants.mat_traversa_sklad= 1.00
    @constants.mat_pyatki_skladv= 1.00
    @constants.mat_metizi_sklad= 1.00
    @constants.mat_ukosi_sklad= 1.00
    @constants.mat_zatsep_sklad= 1.00
    @constants.mat_truba_25_25_12= 1.00
    @constants.mat_truba_25_25_15= 1.00
    @constants.mat_truba_25_25_2= 1.00
    @constants.mat_shina_30_4= 1.00
    @constants.mat_skoba_styagnogo= 1.00
    @constants.mat_stoyki_pallet= 1.00
    @constants.mat_pyatki_pallet= 1.00
    @constants.mat_metizi_pallet_ram= 1.00
    @constants.mat_metizi_pallet_travers= 1.00
    @constants.mat_zatsep_pallet= 1.00
    @constants.mat_ukosi_pallet= 1.00
    @constants.mat_truba_du_20_25= 1.00
    @constants.mat_plastini_teleg= 1.00
    @constants.mat_metizi_teleg= 1.00
    @constants.mat_ugolok_20_20_3= 1.00
    @constants.mat_dsp_laminat= 1.00
    @constants.mat_dsp_shlif= 1.00
    @constants.job_stoyki_arx= 1.00
    @constants.job_polki_arx= 1.00
    @constants.job_usil_arx= 1.00
    @constants.job_upakovka_arx= 1.00
    @constants.job_ogranich= 1.00
    @constants.job_okr_stoyki_arx= 1.00
    @constants.job_okr_polki_arx= 1.00
    @constants.job_stoyki_sklad= 1.00
    @constants.job_traversi_sklad= 1.00
    @constants.job_polki_sklad= 1.00
    @constants.job_ukosi_sklad= 1.00
    @constants.job_usil_styagnoy= 1.00
    @constants.job_usil_g= 1.00
    @constants.job_okr_usil_sklad= 1.00
    @constants.job_okr_stoyki_sklad= 1.00
    @constants.job_ork_polki_sklad= 1.00
    @constants.job_okr_traversi_sklad= 1.00
    @constants.job_upakovka_sklad= 1.00
    @constants.job_stoyki_pallet= 1.00
    @constants.job_traversi_pallet= 1.00
    @constants.job_okr_travers_pallet= 1.00
    @constants.job_ukosi_pallet= 1.00
    @constants.job_svarka_ks_01= 1.00
    @constants.job_svarka_ks_02= 1.00
    @constants.job_svarka_ks_03= 1.00
    @constants.job_svarka_ks_04= 1.00
    @constants.job_svarka_pt_01= 1.00
    @constants.job_svarka_pt_02= 1.00
    @constants.job_svarka_pt_03= 1.00
    @constants.job_svarka_pt_04= 1.00
    @constants.job_svarka_tp_01= 1.00
    @constants.job_svarka_tp_02= 1.00
    @constants.job_svarka_tp_03= 1.00
    @constants.job_svarka_tp_04= 1.00
    @constants.job_svarka_tp_05= 1.00
    @constants.job_svarka_tp_06= 1.00
    @constants.job_svarka_tp_07= 1.00
    @constants.job_rezka= 1.00
    @constants.job_okr_telegek= 1.00
    @constants.job_gibka_du_20_25= 1.00
    @constants.job_rixtovka_ugolka= 1.00
    @constants.job_upakovka_teleg= 1.00
    @constants.job_rez_dsp_1mp= 1.00
    @constants.job_natsenka= 1.00
    @constants.job_dostavka_1kg= 1.00
    @constants.job_kostven_arx= 1.00
    @constants.job_kostven_sklad= 1.00
    @constants.job_kostven_pallet= 1.00
    @constants.job_kostven_telegi= 1.00
    @constants.wei_list_2_1_055= 1.00
    @constants.wei_list_2_1_07= 1.00
    @constants.wei_list_25_125_07= 1.00
    @constants.wei_list_2_1_1= 1.00
    @constants.wei_list_2_1_2= 1.00
    @constants.wei_list_25_125_2= 1.00
    @constants.wei_list_2_1_25= 1.00
    @constants.wei_list_25_125_25= 1.00
    @constants.wei_stoyki_arx= 1.00
    @constants.wei_pyatki_arx= 1.00
    @constants.wei_stoyki_sklad= 1.00
    @constants.wei_traversa_sklad= 1.00
    @constants.wei_pyatki_sklad= 1.00
    @constants.wei_metizi_sklad= 1.00
    @constants.wei_ukosi_sklad= 1.00
    @constants.wei_zatsep_sklad= 1.00
    @constants.wei_truba_25_25_12= 1.00
    @constants.wei_truba_25_25_15= 1.00
    @constants.wei_shina_30_4= 1.00
    @constants.wei_skoba_styagnogo= 1.00
    @constants.wei_stoyki_pallet= 1.00
    @constants.wei_pyatki_pallet= 1.00
    @constants.wei_metizi_pallet_ram= 1.00
    @constants.wei_metizi_pallet_travers= 1.00
    @constants.wei_zatsep_pallet= 1.00
    @constants.wei_ukosi_pallet= 1.00
    @constants.wei_truba_du_20_25= 1.00
    @constants.wei_plastini_teleg= 1.00
    @constants.wei_metizi_teleg= 1.00
    @constants.wei_ugolok_20_20_3= 1.00
    @constants.wei_dsp_laminat= 1.00
    @constants.wei_dsp_shlif= 1.00
    @constants.wei_truba_25_25_2= 1.00
    @constants.mat_100x60x100x15= 1.00
    @constants.wei_100x60x100x15= 1.00
    @constants.mat_setka_50_50_3= 1.00
    @constants.wei_setka_50_50_3= 1.00
    @constants.job_natsen_diler= 1.00
    @constants.job_procent_udor_svarki_telegki= 1.00
    @constants.email_to_send= 1.00
    @constants.on_off_calc_stillage= 1
    @constants.on_off_calc_stillage_warehouse= 1
    @constants.on_off_calc_stillage_pallet= 1
    @constants.on_off_calc_TP01= 1
    @constants.on_off_calc_TP02= 1
    @constants.on_off_calc_TP03= 1
    @constants.on_off_calc_TP04= 1
    @constants.on_off_calc_TP05= 1
    @constants.on_off_calc_TP06= 1
    @constants.on_off_calc_TP07= 1
    @constants.on_off_calc_KS01= 1
    @constants.on_off_calc_KS02= 1
    @constants.on_off_calc_KS03= 1
    @constants.on_off_calc_KS04= 1
    @constants.on_off_calc_PT01= 1
    @constants.on_off_calc_PT02= 1
    @constants.on_off_calc_PT03= 1
    @constants.on_off_calc_PT04= 1
    
    
    
    #@constant.mat_100x60x100x15 = 1.00
    #@constant.wei_100x60x100x15 = 1.00
    #@constants.mat_list_2_1_07 = 1.00
    #@constants.mat_list_25_125_07 = 1.00
    #@constants.mat_list_2_1_1 = 1.00
    #@constants.mat_list_2_1_2 = 1.00
    #@constants.mat_list_25_125_2 = 1.00
    #@constants.mat_list_2_1_25 = 1.00
    #@constants.mat_list_25_125_25 = 1.00
    #@constants.mat_stoyki_arx = 1.00
    #@constants.mat_pyatki_arx = 1.00
    #@constants.mat_stoyki_sklad = 1.00
    #@constants.mat_traversa_sklad = 1.00
    #@constants.mat_pyatki_sklad = 1.00
    #@constants.mat_metizi_sklad = 1.00
    #@constants.mat_ukosi_sklad = 1.00
    #@constants.mat_zatsep_sklad = 1.00
    #@constants.mat_truba_25_25_12 = 1.00
    #@constants.mat_truba_25_25_15 = 1.00
    #@constants.mat_truba_25_25_2 = 1.00
    #@constants.mat_shina_#0_4 = 1.00
    #@constants.mat_skoba_styagnogo = 1.00
    #@constants.mat_stoyki_pallet = 1.00
    #@constants.mat_pyatki_pallet = 1.00
    #@constants.mat_metizi_pallet_ram = 1.00
    #@constants.mat_metizi_pallet_travers = 1.00
    #@constants.mat_zatsep_pallet = 1.00
    #@constants.mat_ukosi_pallet = 1.00
    #@constants.mat_truba_du_20_25 = 1.00
    #@constants.mat_plastini_teleg = 1.00
    #@constants.mat_metizi_teleg = 1.00
    #@constants.mat_ugolok_20_20_# = 1.00
    #@constants.mat_dsp_laminat = 1.00
    #@constants.mat_dsp_shlif = 1.00
    #@constants.job_stoyki_arx = 1.00
    #@constants.job_polki_arx = 1.00
    #@constants.job_usil_arx = 1.00
    #@constants.job_upakovka_arx = 1.00
    #@constants.job_ogranich = 1.00
    #@constants.job_okr_stoyki_arx = 1.00
    #@constants.job_okr_polki_arx = 1.00
    #@constants.job_stoyki_sklad = 1.00
    #@constants.job_traversi_sklad = 1.00
    #@constants.job_polki_sklad = 1.00
    #@constants.job_ukosi_sklad = 1.00
    #@constants.job_usil_styagnoy = 1.00
    #@constants.job_usil_g = 1.00
    #@constants.job_okr_usil_sklad = 1.00
    #@constants.job_okr_stoyki_sklad = 1.00
    #@constants.job_ork_polki_sklad = 1.00
    #@constants.job_okr_traversi_sklad = 1.00
    #@constants.job_upakovka_sklad = 1.00
    #@constants.job_stoyki_pallet = 1.00
    #@constants.job_traversi_pallet = 1.00
    #@constants.job_okr_travers_pallet = 1.00
    #@constants.job_ukosi_pallet = 1.00
    #@constants.job_svarka_ks_01 = 1.00
    #@constants.job_svarka_ks_02 = 1.00
    #@constants.job_svarka_ks_0# = 1.00
    #@constants.job_svarka_ks_04 = 1.00
    #@constants.job_svarka_pt_01 = 1.00
    #@constants.job_svarka_pt_02 = 1.00
    #@constants.job_svarka_pt_0# = 1.00
    #@constants.job_svarka_pt_04 = 1.00
    #@constants.job_svarka_tp_01 = 1.00
    #@constants.job_svarka_tp_02 = 1.00
    #@constants.job_svarka_tp_0# = 1.00
    #@constants.job_svarka_tp_04 = 1.00
    #@constants.job_svarka_tp_05 = 1.00
    #@constants.job_svarka_tp_06 = 1.00
    #@constants.job_svarka_tp_07 = 1.00
    #@constants.job_rezka = 1.00
    #@constants.job_okr_telegek = 1.00
    #@constants.job_gibka_du_20_25 = 1.00
    #@constants.job_rixtovka_ugolka = 1.00
    #@constants.job_upakovka_teleg = 1.00
    #@constants.job_rez_dsp_1mp = 1.00
    #@constants.job_natsenka = 1.00
    #@constants.job_dostavka_1kg = 1.00
    #@constants.job_kostven_arx = 1.00
    #@constants.job_kostven_sklad = 1.00
    #@constants.job_kostven_pallet = 1.00
    #@constants.job_kostven_telegi = 1.00
    #@constants.wei_list_2_1_055 = 1.00
    #@constants.wei_list_2_1_07 = 1.00
    #@constants.wei_list_25_125_07 = 1.00
    #@constants.wei_list_2_1_1 = 1.00
    #@constants.wei_list_2_1_2 = 1.00
    #@constants.wei_list_25_125_2 = 1.00
    #@constants.wei_list_2_1_25 = 1.00
    #@constants.wei_list_25_125_25 = 1.00
    #@constants.wei_stoyki_arx = 1.00
    #@constants.wei_pyatki_arx = 1.00
    #@constants.wei_stoyki_sklad = 1.00
    #@constants.wei_traversa_sklad = 1.00
    #@constants.wei_pyatki_sklad = 1.00
    #@constants.wei_metizi_sklad = 1.00
    #@constants.wei_ukosi_sklad = 1.00
    #@constants.wei_zatsep_sklad = 1.00
    #@constants.wei_truba_25_25_12 = 1.00
    #@constants.wei_truba_25_25_15 = 1.00
    #@constants.wei_truba_25_25_2 = 1.00
    #@constants.wei_shina_#0_4 = 1.00
    #@constants.wei_skoba_styagnogo = 1.00
    #@constants.wei_stoyki_pallet = 1.00
    #@constants.wei_pyatki_pallet = 1.00
    #@constants.wei_metizi_pallet_ram = 1.00
    #@constants.wei_metizi_pallet_travers = 1.00
    #@constants.wei_zatsep_pallet = 1.00
    #@constants.wei_ukosi_pallet = 1.00
    #@constants.wei_truba_du_20_25 = 1.00
    #@constants.wei_plastini_teleg = 1.00
    #@constants.wei_metizi_teleg = 1.00
    #@constants.wei_ugolok_20_20_# = 1.00
    #@constants.wei_dsp_laminat = 1.00
    #@constants.wei_dsp_shlif = 1.00
    #@constant.save

  end


  def update

    @constant.update_attributes(params[:constant])
    if @constant.errors.empty?
      flash[:success]="Отредактировано"
      redirect_to constant_path(@constant)
    else
      flash.now[:error] = "Ошибка в заполнении формы"
      render "/constants/edit"
    end

  end

  def find_item
    @constants = Constant.all
    @constant = Constant.where("id = 1").first

  end

end
