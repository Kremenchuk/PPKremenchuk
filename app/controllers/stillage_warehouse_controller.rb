class StillageWarehouseController < ApplicationController
  before_filter :check_if_diller, only: [:index, :calculate_actual_price]
  include Include_Module

  def index
  end

  def control_parameters
    if @hight_var>5200 or @hight_var<1500
      redirect_to "/stillage_warehouse/index"
    end
    if @width_var>2700 or @width_var<800
      redirect_to "/stillage_warehouse/index"
    end
    if @pol_met_or_dsp =="metall"
      if @depth_var>1215
        redirect_to "/stillage_warehouse/index"
      end
    end
    if @pol_met_or_dsp =="dsp"
      if @depth_var>1500
        redirect_to "/stillage_warehouse/index"
      end
    end
    if @depth_var<300
      redirect_to "/stillage_warehouse/index"
    end
    if @num_of_shelves_var>15 or @num_of_shelves_var<2
      redirect_to "/stillage_warehouse/index"
    end
    if @shelf_load_var>400 or @shelf_load_var<150
      redirect_to "/stillage_warehouse/index"
    end
  end

  def calculate_actual_price
    @hight_var      = Integer(params[:hight])
    @width_var      = Integer(params[:widthS])
    @depth_var      = Integer(params[:depth])
    @num_of_shelves_var = Integer(params[:num_of_shelves])
    @shelf_load_var     = Integer(params[:shelf_load])
    @okr_or_oc_ram          = params[:group1]
    @okr_or_oc_pol          = params[:group2]
    @pol_met_or_dsp         = params[:group3]

    control_parameters

    @constant = Constant.where("id = 1").first

    i = @shelf_load_var
    min_price = 1000000
    min_price_load = 0
    while i <= 400
      @shelf_load_var = i
      calculate_price_sk
      if min_price > Float(@price_stillage_osn).round(2)
        min_price = Float(@price_stillage_osn).round(2)
        min_price_load = i
      end
      i+=10
    end
    @shelf_load_var = min_price_load
    calculate_price_sk
  end

  def calculate_price_sk

    #Определение длины и количества укосов
    shag   = 600
    ukos_g_kol = 0
    ukos_b_kol = 0
    if @hight_var >= 1500 and @hight_var <= 1900
      ukos_g_kol = 2
      ukos_b_kol = 1
      if @hight_var <= 1650
        shag   = 300
      end

    elsif @hight_var > 1900 and @hight_var <= 2100
      ukos_g_kol = 2
      ukos_b_kol = 1
      shag   = 900
    elsif @hight_var > 2100 and @hight_var <= 2500
      ukos_g_kol = 3
      ukos_b_kol = 1
      shag   = 900
    elsif @hight_var > 2500 and @hight_var <= 2800
      ukos_g_kol = 2
      ukos_b_kol = 2
    elsif @hight_var > 2800 and @hight_var <= 3100
      ukos_g_kol = 3
      ukos_b_kol = 2
    elsif @hight_var > 3100 and @hight_var <= 3400
      ukos_g_kol = 4
      ukos_b_kol = 2
    elsif @hight_var > 3400 and @hight_var <= 3700
      ukos_g_kol = 4
      ukos_b_kol = 2
    elsif @hight_var > 3700 and @hight_var <= 4000
      ukos_g_kol = 3
      ukos_b_kol = 3
    elsif @hight_var > 4000 and @hight_var <= 4300
      ukos_g_kol = 4
      ukos_b_kol = 2
    elsif @hight_var > 4300 and @hight_var <= 4600
      ukos_g_kol = 2
      ukos_b_kol = 4
    elsif @hight_var > 4600 and @hight_var <= 4900
      ukos_g_kol = 3
      ukos_b_kol = 4
    elsif @hight_var > 4900 and @hight_var <= 5200
      ukos_g_kol = 4
      ukos_b_kol = 4
    end

    #Определение длины укосов
    @dlin_ukos_g = Float(@depth_var-48)
    @dlin_ukos_b = ((Math.sqrt(Float((@depth_var-64) * (@depth_var-64) + shag**2))+16).to_s(:rounded, :precision => 0)).to_f

    #Определение стоимости укосов
    @ukos_g = ((@dlin_ukos_g/1000.0) * @constant.mat_ukosi_sklad + @constant.job_ukosi_sklad).round(2) #металл+работа
    @ukos_b = ((@dlin_ukos_b/1000.0) * @constant.mat_ukosi_sklad + @constant.job_ukosi_sklad).round(2) #металл+работа

    #Площадь рам
      @plosh_ram = 0
      if @okr_or_oc_ram == "okrash"
       plosh_stoyki = (Float(@constant.area_stoyki_sklad * @hight_var)/1000.0 + @constant.area_pyatki_sklad)
       plosh_ukosi = (Float(@constant.area_ukosi_sklad * (@dlin_ukos_g * ukos_g_kol + @dlin_ukos_b * ukos_b_kol))/1000.0)
       @plosh_ram = (plosh_stoyki * 2 + plosh_ukosi).round(2)
      end

    #Стоимость стойки
    @price_stoyka = ((leng_stoyki(@hight_var, @constant.rack_multiplicity)/1000.0) * @constant.mat_stoyki_sklad + @constant.job_stoyki_sklad).round(2)

    #стоимость траверсы
    @plosh_travera = (@constant.area_traversa_sklad * (@width_var/1000.0) + @constant.area_zatsep_sklad * 2).round(2)

    @price_traversa = ((Float(@width_var)/1000.0) * @constant.mat_traversa_sklad + @constant.job_traversi_sklad +
        @constant.mat_zatsep_sklad * 2 + @plosh_travera * @constant.job_okr_traversi_sklad).round(2)

    #стоимость рамы
    @price_ram = (@price_stoyka * 2 + @ukos_g * ukos_g_kol + @ukos_b * ukos_b_kol + @plosh_ram *
                @constant.job_okr_stoyki_sklad + @constant.mat_pyatki_sklad * 2 + (@constant.mat_metizi_sklad *
                (ukos_g_kol + ukos_b_kol + 2) * 2)).round(2)

    #Вычисление с какого листа и какую по размеру полочку ПМ вырубивать в зависимости от веса на уровень


    #Вычисляем количество усилителей
    @kol_usil_styag = 0
    @kol_usil_g = 0
    @price_usil_styag = 0
    @price_usil_g     = 0
    type_stillage = t('page.stillage_warehouse.show.metall_pol')
    if @pol_met_or_dsp == "dsp"
      @kol_usil_styag = 1
      @kol_usil_g = 2
      if @width_var>=1900 #and @shelf_load_var>250
        @kol_usil_styag = 2
      end
      #if @width_var>1500 and @width_var<=2000 and @shelf_load_var>250
      #  @kol_usil_styag = 2
      #end
      if @depth_var>=900 and @width_var>1900
        @kol_usil_styag = 2
      end
      if @depth_var>=1200 and @width_var>=1500
        @kol_usil_styag = 2
      end
      if @depth_var>=1300
        @kol_usil_styag = 2
      end


      #Вычисляем длину и площадь усилителей
      @dlin_usil_styag = @depth_var - 45
      @dlin_usil_g = @depth_var - 38
      plosh_usil_styag = (@constant.area_profil_usil_warehouse * (@dlin_usil_styag/1000.0)).to_s(:rounded, :precision => 5).to_f
      plosh_usil_g = (@constant.area_profil_usil_warehouse * (@dlin_usil_g/1000.0)).to_s(:rounded, :precision => 5).to_f

      type_stillage = t('page.stillage_warehouse.show.metall_pol')
      #Вычисляем стоимость усилителей
      @price_usil_styag = 0
      @price_usil_g     = 0
      if @pol_met_or_dsp == "dsp"
        @price_usil_styag = ((@dlin_usil_styag/1000.0) * @constant.mat_profil_usil_warehouse) + @constant.job_usil_styagnoy +
            plosh_usil_styag * @constant.job_okr_usil_sklad
        @price_usil_g = ((@dlin_usil_g/1000.0) * @constant.mat_profil_usil_warehouse) + @constant.job_usil_g +
            plosh_usil_g * @constant.job_okr_usil_sklad
        type_stillage = t('page.stillage_warehouse.show.karkas_dsp')
      end
    end


    #Вычисляем размер полки
      if @depth_var > 1000
        @width_polki = (15/(Float(@shelf_load_var)/Float(@width_var-20))).to_i
      elsif @depth_var > 700 and @depth_var <= 1000
        @width_polki = (20/(Float(@shelf_load_var)/Float(@width_var-20))).to_i
      elsif @depth_var > 500 and @depth_var <= 700
        @width_polki = (25/(Float(@shelf_load_var)/Float(@width_var-20))).to_i
      elsif @depth_var >= 300 and @depth_var <= 500
        @width_polki = (35/(Float(@shelf_load_var)/Float(@width_var-20))).to_i
      end

    # количество полок если делать с 0,65 листа
    @kol_polok_065 = (@width_var-20)/@width_polki
    length = @width_polki * @kol_polok_065
    if (@width_var - 20 - length)>15
      @kol_polok_065 += 1
      @width_polki = (@width_var-20)/@kol_polok_065
    end

    # количество полок если делать с 0,45 листа при полке 97мм
    width_045_polki = 97
    plosh_polki_045 = 0
    plosh_polki_045_dodelki = 0
    kol_polok_045_dodelki = 0
    kol_polok_045 = (@width_var-20)/width_045_polki
    width_dodelki = (@width_var-20) - kol_polok_045 * width_045_polki
    if width_dodelki < 50
      kol_polok_045 -= 1
      kol_polok_045_dodelki = 2
      width_dodelki = (Float((@width_var-20) - kol_polok_045 * width_045_polki)/2).ceil
    end
    # Вычисление стоимости полки и уровня из металла 0,45мм

    if @pol_met_or_dsp == "metall"
      a_polki = @depth_var + 32
      b_polki = width_045_polki + 56

      @price_polki_045 = price_shelf_layer(a_polki,  b_polki, 2000, 1000, @constant.mat_list_2_1_045)
      @wei_polki_045 = (@constant.wei_list_2_1_045 * (a_polki/1000.0)*(b_polki/1000.0))/2
      plosh_polki_045 = ((a_polki * b_polki * 2)/1000000.0).round(2)

      b_polki = width_dodelki + 56
      @price_polki_045_dodelki = price_shelf_layer(a_polki,  b_polki, 2000, 1000, @constant.mat_list_2_1_045)
      @wei_polki_dodelki = (@constant.wei_list_2_1_045 * (a_polki/1000.0)*(b_polki/1000.0))/2
      plosh_polki_045_dodelki = ((a_polki * b_polki * 2)/1000000.0).round(2)
    end
    uroven_045 = (@price_polki_045 + @constant.job_polki_sklad) * kol_polok_045 + (@price_polki_045_dodelki + @constant.job_polki_sklad) * kol_polok_045_dodelki


    uroven_065 = 0
    plosh_polki_065 = 0
    #Вычис ление с какого листа делаем полку (критерий = минимальная стоимость материала) из листа 0,65
      if @pol_met_or_dsp == "metall"
        a_polki = @depth_var + 32
        b_polki = @width_polki + 56
        if a_polki > 1000
          @price_polki_bolsh = price_shelf_layer(a_polki,  b_polki, 2500, 1250, @constant.mat_list_25_125_07)
          @price_polki_mal = @constant.mat_list_2_1_07

        else
          @price_polki_mal = price_shelf_layer(a_polki,  b_polki, 2000, 1000, @constant.mat_list_2_1_07)
          @price_polki_bolsh = price_shelf_layer(a_polki,  b_polki, 2500, 1250, @constant.mat_list_25_125_07)
        end
        if @price_polki_mal < @price_polki_bolsh
          @price_polki = @price_polki_mal
          @wei_polki = (@constant.wei_list_2_1_07 / 2) * (a_polki/1000.0) * (b_polki/1000.0)
        else
          @price_polki = @price_polki_bolsh
          @wei_polki = (@constant.wei_list_25_125_07 / 3.125) * (a_polki/1000.0)*(b_polki/1000.0)
        end
        uroven_065 = (@price_polki + @constant.job_polki_sklad) * @kol_polok_065
        plosh_polki_065 = ((a_polki * b_polki * 2)/1000000.0).round(2)

      else
        #если полка ДСП
        a_polki = @depth_var
        b_polki = @width_var - 10
        @price_polki = price_shelf_layer(a_polki,  b_polki, 3500, 1750, @constant.mat_dsp_shlif)
        @price_polki = @price_polki + @constant.job_rez_dsp_1mp * ((a_polki + b_polki)/1000.0)
        @wei_polki = (@constant.wei_dsp_shlif * (a_polki/1000.0)*(b_polki/1000.0))/6.125
        @kol_polok = 1

        #Добавлено для исключения расчета полочки ДСП (только каркас)
        @price_polki = 0.0
        @wei_polki = @kol_usil_styag * (@dlin_usil_styag/1000.0) + @kol_usil_g * (@dlin_usil_g/1000.0)
      end

    if @pol_met_or_dsp == "metall"
      if uroven_045 >= uroven_065
        @price_shelves = uroven_065
        wei_urovnya = @wei_polki * @kol_polok_065
        if @okr_or_oc_pol == "okrash"
          type_stillage = t('page.stillage_warehouse.show.okrash_matall')
          plosh_polki = plosh_polki_065 * @kol_polok_065
          @price_shelves += plosh_polki * @constant.job_ork_polki_sklad
        end
      else
        @price_shelves = uroven_045
        wei_urovnya = @wei_polki_045 * kol_polok_045 +  @wei_polki_dodelki * kol_polok_045_dodelki
        if @okr_or_oc_pol == "okrash"
          type_stillage = t('page.stillage_warehouse.show.okrash_matall')
          plosh_polki = plosh_polki_045 * kol_polok_045 + plosh_polki_045_dodelki * kol_polok_045_dodelki
          @price_shelves += plosh_polki * @constant.job_ork_polki_sklad
        end
      end
    end


    #Вычисляем площадь полочки


    #Вес рамы и уровня
      wei_ram = (@hight_var/1000.0) * @constant.wei_stoyki_sklad * 2 +
                ((@dlin_ukos_g * ukos_g_kol + @dlin_ukos_b * ukos_b_kol)/1000.0) * @constant.wei_ukosi_sklad + @constant.wei_pyatki_sklad * 2
      wei_urovnya += (@width_var/1000.0) * @constant.wei_traversa_sklad * 2 + @constant.wei_zatsep_sklad * 4

      @wei_osn = wei_ram * 2 + wei_urovnya * @num_of_shelves_var
      @wei_pris = @wei_osn - wei_ram
      @wei_osn = @wei_osn.to_s(:rounded, :precision => 2)
      @wei_pris = @wei_pris.to_s(:rounded, :precision => 2)


    @price_usil_styag = @price_usil_styag * (@constant.otxod_sk/100 + 1)
    @price_usil_g     = @price_usil_g     * (@constant.otxod_sk/100 + 1)
    @price_shelves    = @price_shelves    * (@constant.otxod_sk/100 + 1)
    @price_ram        = @price_ram        * (@constant.otxod_sk/100 + 1)
    @price_traversa   = @price_traversa   * (@constant.otxod_sk/100 + 1)


    @price_usil_styag = @price_usil_styag + @price_usil_styag * @constant.job_kostven_sklad
    @price_usil_g     = @price_usil_g     + @price_usil_g     * @constant.job_kostven_sklad
    @price_shelves    = @price_shelves    + @price_shelves    * @constant.job_kostven_sklad
    @price_ram        = @price_ram        + @price_ram        * @constant.job_kostven_sklad
    @price_traversa   = @price_traversa   + @price_traversa   * @constant.job_kostven_sklad


    @price_usil_styag = (@price_usil_styag * (@natsenka/100 + 1)).round(2)
    @price_usil_g     = (@price_usil_g     * (@natsenka/100 + 1)).round(2)
    @price_shelves    = (@price_shelves    * (@natsenka/100 + 1)).round(2)
    @price_ram        = (@price_ram        * (@natsenka/100 + 1)).round(2)
    @price_traversa   = (@price_traversa   * (@natsenka/100 + 1)).round(2)
    @price_shelves += (@price_traversa * 2) + @price_usil_styag * @kol_usil_styag +
        @price_usil_g * @kol_usil_g

    @price_stillage_osn = @price_shelves * @num_of_shelves_var + @price_ram * 2 + @constant.job_upakovka_sklad
    @price_stillage_prist = @price_stillage_osn - @price_ram


    # подготовка к выводу инфы
    @price_stillage_osn = @price_stillage_osn.to_s(:rounded, :precision => 2)
    @price_stillage_prist = @price_stillage_prist.to_s(:rounded, :precision => 2)
    @price_ram = @price_ram.to_s(:rounded, :precision => 2)
    @price_shelves = @price_shelves.to_s(:rounded, :precision => 2)

    @text_var = t('page.all.uroven')

    if @num_of_shelves_var>1
      @text_var = t('page.all.urovnya')
    end
    if @num_of_shelves_var>4
      @text_var = t('page.all.urovney')
    end

    @name_stillage="#{@hight_var}x#{@width_var}x#{@depth_var} #{@num_of_shelves_var} п. " + type_stillage
    enter_row_to_excel(@name_stillage, @price_stillage_osn) #внесение в ексель файл данных о расчете стеллажа.
  end
end
