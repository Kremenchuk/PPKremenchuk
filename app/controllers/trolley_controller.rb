class TrolleyController < ApplicationController
  before_action :check_if_diller, only: [:index, :show]

  include IncludeModule

  def index
  end

  def control_parameters
    if @lengthT_var>1500 or @lengthT_var<600
      redirect_to "/stillage/index"
    end
    if @width_var>1200 or @width_var<500
      redirect_to "/stillage/index"
    end
    if @hight_ruch>1200 or @hight_ruch<600
      redirect_to "/stillage/index"
    end
    if @shelf_load_var>400 or @shelf_load_var<50
      redirect_to "/stillage/index"
    end
  end


  def show
    @lengthT_var    = Integer(params[:lengthT])
    @width_var      = Integer(params[:widthS])
    @hight_ruch     = Integer(params[:hight_ruch])
    @shelf_load_var = Integer(params[:shelf_load])
    @vid = params[:vid]
    @type_shelf = params[:group1]
    @type_shelf = "metall"
    control_parameters

    @constant = Constant.where("id = 1").first

    proc_udorogania_svarki = (((@lengthT_var - 1000)/100.0 + (@width_var - 600)/100.0) * @constant.job_procent_udor_svarki_telegki)/100.0 + 1.0
    if proc_udorogania_svarki < 1.0
      proc_udorogania_svarki = 1.0
    end
    kol_square_plat
    case @vid
      when "TP-01"
        svarka =  @constant.job_svarka_tp_01 * proc_udorogania_svarki
        @price_trol = priceTP(2, "dsp", svarka, 1)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "TP-02"
        svarka =  @constant.job_svarka_tp_02 * proc_udorogania_svarki
        @price_trol = priceTP(3, "dsp", svarka, 1)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "TP-03"
        svarka =  @constant.job_svarka_tp_03 * proc_udorogania_svarki
        @price_trol = priceTP(4, "dsp", svarka, 1)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "TP-04"
        svarka =  @constant.job_svarka_tp_04 * proc_udorogania_svarki
        @price_trol = priceTP(2, "dsp", svarka, 2)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "TP-05"
        svarka =  @constant.job_svarka_tp_05 * proc_udorogania_svarki
        @price_trol = priceTP(3, "dsp", svarka, 2)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "TP-06"
        svarka =  @constant.job_svarka_tp_06 * proc_udorogania_svarki
        @price_trol = priceTP(3, "met", svarka, 1)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "TP-07"
        svarka =  @constant.job_svarka_tp_07 * proc_udorogania_svarki
        @price_trol = priceTP(2, "met", svarka, 1)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "KS-01"
        svarka =  @constant.job_svarka_ks_01 * proc_udorogania_svarki
        @price_trol = priceKS(2.0,2.0,4.0,4.0,@type_shelf, svarka)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "KS-02"
        svarka =  @constant.job_svarka_ks_02 * proc_udorogania_svarki
        @price_trol = priceKS(0.0,2.0,2.0,4.0,@type_shelf, svarka)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "KS-03"
        svarka =  @constant.job_svarka_ks_03 * proc_udorogania_svarki
        @price_trol = priceKS(1.0,2.0,2.0,4.0,@type_shelf, svarka)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "KS-04"
        svarka =  @constant.job_svarka_ks_04 * proc_udorogania_svarki
        @price_trol = priceKS(2.0,2.0,6.0,5.0,@type_shelf, svarka)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2 +
            ((@lengthT_var/1000.0) * (@hight_ruch/1000.0) * 2)
      when "PT-01"
        svarka =  @constant.job_svarka_pt_01 * proc_udorogania_svarki
        @price_trol = pricePT(2.0,"met", svarka, 1)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0) * 2
      when "PT-02"
        svarka =  @constant.job_svarka_pt_02 * proc_udorogania_svarki
        @price_trol = pricePT(0.0,"met", svarka, 0)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2
      when "PT-03"
        svarka =  @constant.job_svarka_pt_03 * proc_udorogania_svarki
        @price_trol = pricePT(0.0,"dsp", svarka, 0)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2
      when "PT-04"
        svarka =  @constant.job_svarka_pt_04 * proc_udorogania_svarki
        @price_trol = pricePT(2.0,"dsp", svarka, 1)
        @plosh_upakovki = (@lengthT_var/1000.0) * (@width_var/1000.0) * 2 + (@hight_ruch/1000.0) * (@width_var/1000.0)*2
    end
    prise_upakovki = @plosh_upakovki * @constant.job_upakovka_teleg
    prise_upakovki = prise_upakovki * (@constant.otxod_trol/100 +1)
    prise_upakovki = (prise_upakovki + prise_upakovki * @constant.job_kostven_telegi) * ((@natsenka/100)+1)
    @price_trol = @price_trol + prise_upakovki
    @price_trol = @price_trol.round(2).to_s

    @name_stillage="Тип: #{@vid} #{@lengthT_var}x#{@width_var} высота ручки: #{@hight_ruch}"
    enter_row_to_excel(@name_stillage, @price_trol) #внесение в ексель файл данных о расчете стеллажа.
  end



  def kol_square_plat #Длина квадратной трубы на платформу тележки
    @kvadrat_leng = 0.0
    if @lengthT_var <= 1100
      @kvadrat_leng = (@lengthT_var * 2 + @width_var * 4 + (@lengthT_var - 380.0))/1000.0
    end
    if @lengthT_var > 1100 and @lengthT_var <= 1350
      @kvadrat_leng = (@lengthT_var * 2 + @width_var * 4 + (@lengthT_var - 380.0)*2)/1000.0
    end
    if @lengthT_var > 1350
      @kvadrat_leng = (@lengthT_var * 2 + @width_var * 6 + (@lengthT_var - 380.0)*2)/1000.0
    end
  end




  #Расчет телег типа ТР
  def priceTP(kol_shelf, shelf_typ, price_svarka, kol_ruchek)
    #Расчет одной полочки тележки
    @wei_trol = 0.0
    if shelf_typ == "dsp"
      price_shelf_layer_var = price_shelf_layer(@lengthT_var,@width_var,2800,2070,@constant.mat_dsp_laminat) +
                              ((@lengthT_var/1000.0) * 2 + (@width_var/1000.0) * 2) * @constant.job_rez_dsp_1mp
      plosh_shelf = 0
      @wei_trol = (@constant.wei_dsp_shlif / 5.796) * ((@lengthT_var/1000.0) * (@width_var/1000.0))
    else
      var1 = price_shelf_layer(@lengthT_var,@width_var,2000,1000,@constant.mat_list_2_1_2)
      var2 = price_shelf_layer(@lengthT_var,@width_var,2500,1250,@constant.mat_list_25_125_2)
      plosh_shelf = (@lengthT_var/1000.0) * (@width_var/1000.0)
       if var1<=var2
         @price_shelf_layer_var = var1
         @wei_trol = (@constant.wei_list_2_1_2 / 2.0) * ((@lengthT_var/1000.0) * (@width_var/1000.0)) * kol_shelf
       else
         @price_shelf_layer_var = var2
         @wei_trol = (@constant.wei_list_25_125_2 / 3.125) * ((@lengthT_var/1000.0) * (@width_var/1000.0)) * kol_shelf
       end
     end

    #Расчет труб,уголка и ручки на тележку
    price_ugolok = ((@lengthT_var * kol_shelf * 2 + @width_var * kol_shelf * 2)/1000.0) * @constant.mat_ugolok_20_20_3 +
        @constant.job_rixtovka_ugolka * 8.0 + @constant.job_rezka * 8.0
    @wei_trol += ((@lengthT_var * kol_shelf * 2 + @width_var * kol_shelf * 2)/1000.0) * @constant.wei_ugolok_20_20_3

    price_kvadr = (@kvadrat_leng + (((@hight_ruch - 150) * 4)/1000.0)) * @constant.mat_truba_25_25_2 +
                  @constant.job_rezka * 12.0
    @wei_trol += (@kvadrat_leng + (((@hight_ruch - 150) * 4)/1000.0)) * @constant.wei_truba_25_25_2

    price_round = (((@width_var + 300)/1000.0) * kol_ruchek) * @constant.mat_truba_du_20_25 + @constant.job_rezka * 2.0 + @constant.job_gibka_du_20_25 * 2.0
    @wei_trol +=(((@width_var + 300)/1000.0) * kol_ruchek) * @constant.wei_truba_du_20_25

    plosh_trol = (@kvadrat_leng + ((@hight_ruch - 150) * 4)/1000.0) * @constant.area_truba_25_25_2+
                  (((@width_var + 300)/1000.0) * kol_ruchek) * @constant.area_truba_du_20_25 +
                  ((@lengthT_var * 2.0 + @width_var * 2.0)/1000.0) * kol_shelf * @constant.area_ugolok_20_20_3 + (plosh_shelf * 2) * kol_shelf +
                  @constant.area_plastini_teleg * 2
    @wei_trol = @wei_trol.round(2).to_s
    price_trol = price_ugolok + @price_shelf_layer_var * kol_shelf + price_kvadr + price_round + plosh_trol * @constant.job_okr_telegek +
                  price_svarka + @constant.mat_plastini_teleg * 4 + @constant.mat_metizi_teleg * 16

    price_trol = price_trol * (@constant.otxod_trol/100 +1)

    price_trol = (price_trol + price_trol * @constant.job_kostven_telegi) * ((@natsenka/100)+1)
    return price_trol
  end






  #Расчет телег типа KS
  def priceKS(set_long, set_shot, nl, nh, shelf_typ, price_svarka)
    #Расчет одной полочки тележки
    @wei_trol = 0.0
    if shelf_typ == "dsp"
      price_shelf_layer_var = price_shelf_layer(@lengthT_var,@width_var,2800,2070,@constant.mat_dsp_laminat) +
          ((@lengthT_var/1000.0) + (@width_var/1000.0)) * @constant.job_rez_dsp_1mp
      plosh_shelf = 0
      @wei_trol = (@constant.wei_dsp_shlif / 5.796) * ((@lengthT_var/1000.0) * (@width_var/1000.0))
    else
      if price_shelf_layer(@lengthT_var,@width_var,2500,1250,@constant.mat_list_25_125_2)>=price_shelf_layer(@lengthT_var,@width_var,2000,1000,@constant.mat_list_2_1_2)
        price_shelf_layer_var = price_shelf_layer(@lengthT_var,@width_var,2000,1000,@constant.mat_list_2_1_2)
        @wei_trol = (@constant.wei_list_2_1_2 / 2.0) * ((@lengthT_var/1000.0) * (@width_var/1000.0))
      else
        price_shelf_layer_var = price_shelf_layer(@lengthT_var,@width_var,2500,1250,@constant.mat_list_25_125_2)
        @wei_trol = (@constant.wei_list_25_125_2 / 3.125) * ((@lengthT_var/1000.0) * (@width_var/1000.0))
      end
      plosh_shelf = (@lengthT_var/1000.0) * (@width_var/1000.0)
    end
    price_shelf = ((@lengthT_var * nl + @width_var * 4.0 + (@hight_ruch - 150.0) * nh)/1000.0) * @constant.mat_ugolok_20_20_3 +
        price_shelf_layer_var + ((nl+nh) * @constant.job_rixtovka_ugolka) + ((nl+nh) * @constant.job_rezka)
    @wei_trol+=((@lengthT_var * nl + @width_var * 4.0 + (@hight_ruch - 150.0) * nh)/1000.0) * @constant.wei_ugolok_20_20_3

    #Расчет труб и ручки на тележку
    price_kvadr = @kvadrat_leng * @constant.mat_truba_25_25_2 +
        @constant.job_rezka * 8.0
    @wei_trol += @kvadrat_leng * @constant.wei_truba_25_25_2

    price_round = ((@hight_ruch * 4.0 + @width_var * 2.0)/1000.0) * @constant.mat_truba_du_20_25 +
        @constant.job_rezka * 2.0 + @constant.job_gibka_du_20_25 * 2.0
    @wei_trol +=((@hight_ruch * 4.0 + @width_var * 2)/1000.0) * @constant.wei_truba_du_20_25

    price_setki_long = price_shelf_layer(@lengthT_var,(@hight_ruch - 150),2000,1000,(@constant.mat_setka_50_50_3*2))
    price_setki_shot = price_shelf_layer(@width_var,(@hight_ruch - 150),2000,1000,(@constant.mat_setka_50_50_3*2))
    @wei_trol += (price_setki_long/@constant.mat_setka_50_50_3) * @constant.wei_setka_50_50_3 * set_long +
                 (price_setki_shot/@constant.mat_setka_50_50_3) * @constant.wei_setka_50_50_3 * set_shot

    plosh_trol = ((@lengthT_var * 3.0 + @width_var * 3.0)/1000.0) * @constant.area_truba_25_25_2 +
        ((@hight_ruch * 4.0 + @width_var * 2.0)/1000.0) * @constant.area_truba_du_20_25 +
        ((@lengthT_var * nl + @width_var * nh)/1000.0) * @constant.area_ugolok_20_20_3 + (plosh_shelf * 2) + @constant.area_plastini_teleg * 2 +
        ((@lengthT_var / 1000.0) * ((@hight_ruch - 150.0)/1000.0)) * set_long +
        ((@width_var / 1000.0) * ((@hight_ruch - 150.0)/1000.0)) * set_shot

    price_trol = price_shelf + price_kvadr + price_round + plosh_trol * @constant.job_okr_telegek +
        price_svarka + @constant.mat_plastini_teleg * 4 + @constant.mat_metizi_teleg * 16 + price_setki_long * set_long +
        price_setki_shot * set_shot


    case @vid
      when "KS-04"
        price_trol += @constant.mat_shpingalet_naves * 4
        @wei_trol += @constant.wei_shpingalet_naves * 4
      when "KS-02"
        plosh = ((@width_var - 52) / 1000.0) * @constant.area_truba_du_20_25
        price_trol += ((@width_var - 52) / 1000.0) * @constant.mat_truba_du_20_25 +  @constant.job_rezka + plosh * @constant.job_okr_telegek
        @wei_trol += ((@width_var - 52) / 1000.0) * @constant.wei_truba_du_20_25
    end


    @wei_trol = @wei_trol.round(2).to_s

    price_trol = price_trol * (@constant.otxod_trol/100 +1)

    price_trol = (price_trol + price_trol * @constant.job_kostven_telegi) * ((@natsenka/100)+1)
    return price_trol
  end




  #Расчет телег типа PT
  def pricePT(nw, shelf_typ, price_svarka, setka)
    @wei_trol = 0.0
    #Расчет одной полочки тележки
    if shelf_typ == "dsp"
      price_shelf_layer_var = price_shelf_layer(@lengthT_var,@width_var,2800,2070,@constant.mat_dsp_laminat) +
          ((@lengthT_var/1000.0) + (@width_var/1000.0)) * @constant.job_rez_dsp_1mp * 2
      plosh_shelf = 0
      @wei_trol = (@constant.wei_dsp_shlif / 5.796) * ((@lengthT_var/1000.0) * (@width_var/1000.0))
    else
      if price_shelf_layer(@lengthT_var,@width_var,2500,1250,@constant.mat_list_25_125_2)>=price_shelf_layer(@lengthT_var,@width_var,2000,1000,@constant.mat_list_2_1_2)
        price_shelf_layer_var = price_shelf_layer(@lengthT_var,@width_var,2000,1000,@constant.mat_list_2_1_2)
        plosh_shelf = (@lengthT_var/1000.0) * (@width_var/1000.0)
        @wei_trol = (@constant.wei_list_2_1_2 / 2.0) * ((@lengthT_var/1000.0) * (@width_var/1000.0))
      else
        price_shelf_layer_var = price_shelf_layer(@lengthT_var,@width_var,2500,1250,@constant.mat_list_25_125_2)
        plosh_shelf = (@lengthT_var/1000.0) * (@width_var/1000.0)
        @wei_trol = (@constant.wei_list_25_125_2 / 3.125) * ((@lengthT_var/1000.0) * (@width_var/1000.0))
      end
    end

    if shelf_typ == "dsp"
      price_shelf = ((@width_var * 2 + @lengthT_var * 2 + @width_var * nw + (@hight_ruch - 150.0) * nw)/1000.0) * @constant.mat_ugolok_20_20_3 +
          price_shelf_layer_var + (nw*2 + 4) * @constant.job_rixtovka_ugolka + (nw*2 + 4) * @constant.job_rezka
      @wei_trol += ((@width_var * 2 + @lengthT_var * 2)/1000.0) * @constant.wei_ugolok_20_20_3
    else
      price_shelf = ((@width_var * nw + (@hight_ruch - 150.0) * nw)/1000.0) * @constant.mat_ugolok_20_20_3 +
          price_shelf_layer_var + ((nw*2) * @constant.job_rixtovka_ugolka) + ((nw*2) * @constant.job_rezka)
      @wei_trol += ((@width_var * nw + (@hight_ruch - 150.0) * nw)/1000.0) * @constant.wei_ugolok_20_20_3
    end

    #Расчет труб и ручки на тележку
    price_kvadr = @kvadrat_leng * @constant.mat_truba_25_25_2 + @constant.job_rezka * 8.0
    @wei_trol += @kvadrat_leng * @constant.wei_truba_25_25_2

    price_round = ((@hight_ruch * 2.0 + @width_var)/1000.0) * @constant.mat_truba_du_20_25 +
        @constant.job_rezka * 2.0 + @constant.job_gibka_du_20_25 * 2.0
    @wei_trol +=((@hight_ruch * 2.0 + @width_var)/1000.0) * @constant.wei_truba_du_20_25

    price_setki = price_shelf_layer(@width_var,(@hight_ruch-150),2000,1000,(@constant.mat_setka_50_50_3*2)) * setka
    @wei_trol += (@constant.wei_setka_50_50_3 / 2.0) * (((@hight_ruch - 150)/1000.0) * (@width_var/1000.0))

    if shelf_typ == "dsp"
      plosh_trol = ((@lengthT_var * 3.0 + @width_var * 3.0)/1000.0) * @constant.area_truba_25_25_2 +
          ((@hight_ruch * 2.0 + @width_var * 2.0)/1000.0) * @constant.area_truba_du_20_25 +
          ((@width_var * 2.0 + @lengthT_var * 2.0 + @width_var * nw + (@hight_ruch - 150.0) * nw)/1000.0) * @constant.area_ugolok_20_20_3 +
          (plosh_shelf * 2.0)  + @constant.area_plastini_teleg * 2 +
          ((@width_var / 1000.0) * ((@hight_ruch - 150.0)/1000.0)) * setka
    else
      plosh_trol = ((@lengthT_var * 3.0 + @width_var * 3.0)/1000.0) * @constant.area_truba_25_25_2 +
          ((@hight_ruch * 2.0 + @width_var)/1000.0) * @constant.area_truba_du_20_25 +
          (((@width_var * nw) + ((@hight_ruch - 150.0) * nw))/1000.0) * @constant.area_ugolok_20_20_3 +
          (plosh_shelf * 2.0)  + @constant.area_plastini_teleg * 2 +
          ((@width_var / 1000.0) * ((@hight_ruch - 150.0)/1000.0)) * setka
    end
    price_trol = price_shelf + price_kvadr + price_round + plosh_trol * @constant.job_okr_telegek +
        price_svarka + @constant.mat_plastini_teleg * 4 + @constant.mat_metizi_teleg * 16 + price_setki

    case @vid
      when "PT-02"
        plosh = ((@width_var - 52) / 1000.0) * @constant.area_truba_du_20_25
        price_trol += ((@width_var - 52) / 1000.0) * @constant.mat_truba_du_20_25 +  @constant.job_rezka + plosh * @constant.job_okr_telegek
        @wei_trol += ((@width_var - 52 ) / 1000.0) * @constant.wei_truba_du_20_25
      when "PT-01"
        plosh = ((@width_var - 52) / 1000.0) * @constant.area_truba_du_20_25
        price_trol += ((@width_var - 52) / 1000.0) * @constant.mat_truba_du_20_25 +  @constant.job_rezka + plosh * @constant.job_okr_telegek
        @wei_trol += ((@width_var - 52 )/ 1000.0) * @constant.wei_truba_du_20_25
    end

    @wei_trol = @wei_trol.round(2).to_s

    price_trol = price_trol * (@constant.otxod_trol/100 +1)

    price_trol = (price_trol + price_trol * @constant.job_kostven_telegi) * ((@natsenka/100)+1)
    return price_trol
  end

end
