class StillageController < ApplicationController

  before_action :check_if_diller, only: [:index, :calculate_actual_price]
  include IncludeModule

  #before_action :authenticate_user!, only: [:index] #Рабочее ограничение на юзара
  def index
  end

  def control_parameters(params)
    if @hight_var>3500 or @hight_var<500
      return false
    end
    if @width_var>1150 or @width_var<400
      return false
    end
    if @depth_var>800 or @depth_var<250
      return false
    end
    if @num_of_shelves_var>15 or @num_of_shelves_var<2
      return false
    end
    if @shelf_load_var > 200 or @shelf_load_var<20
      return false
    end
    return true
  end

  def calculate_actual_price
    @hight_var      = params[:hight].present? ? params[:hight].to_i : 0
    @width_var      = params[:widthS].present? ? params[:widthS].to_i : 0
    @depth_var      = params[:depth].present? ? params[:depth].to_i : 0
    @num_of_shelves_var = params[:num_of_shelves].present? ? params[:num_of_shelves].to_i : 0
    @shelf_load_var     = params[:shelf_load].present? ? params[:shelf_load].to_i : 0
    @metall_or_dsp      = params[:group1]
    @okr_or_oc          = params[:group2]

    if control_parameters(params)
      @constant = Constant.where("id = 1").first

      if @metall_or_dsp == "metall"
        metall_shelf
      else
        dsp_shelf
      end

      enter_row_to_excel(@name_stilage, @price_stillage) #внесение в ексель файл данных о расчете стеллажа.
    end
    render 'index'
  end

  private


  def metall_shelf
    a_polki = @width_var + 90
    b_polki = @depth_var + 90

    @usil=0

    if @depth_var >= 600
      @usil = 1
    end
    if @shelf_load_var > 70
      if @depth_var >= 459
        @usil = 1
      end
    end
    if @shelf_load_var > 60
      if @depth_var >= 600
        @usil = 2
      end
    end

    if a_polki > 1000
      @price_polki_bolsh = price_shelf_layer(a_polki,  b_polki, 2500, 1250, @constant.mat_list_25_125_07)
      @price_polki_mal = @constant.mat_list_2_1_07
      kol_usil_virub_bol = $kol_usil_virub
    else
      @price_polki_mal = price_shelf_layer(a_polki,  b_polki, 2000, 1000, @constant.mat_list_2_1_07)
      kol_usil_virub_mal = $kol_usil_virub
      @price_polki_bolsh = price_shelf_layer(a_polki,  b_polki, 2500, 1250, @constant.mat_list_25_125_07)
      kol_usil_virub_bol = $kol_usil_virub
    end
    if @price_polki_mal < @price_polki_bolsh
      @price_polki = @price_polki_mal
      a_list = 2000
      b_list = 1000
      @kol_usil_virub = kol_usil_virub_mal
      @kol_polok_s_lista = @constant.mat_list_2_1_07 / @price_polki
      @price_list = @constant.mat_list_2_1_07
      @wei_polki = ((@constant.wei_list_2_1_07 * (a_polki/1000.0)*(b_polki/1000.0))/2) +
          ((@constant.wei_list_2_1_07 * (@usil * (@constant.area_usil_arx/2) * (@width_var/1000.0)))/2)
    else
      @price_polki = @price_polki_bolsh
      a_list = 2500
      b_list = 1250
      @kol_usil_virub = kol_usil_virub_bol
      @kol_polok_s_lista = @constant.mat_list_25_125_07 / @price_polki
      @price_list = @constant.mat_list_25_125_07
      @wei_polki = ((@constant.wei_list_25_125_07 * (a_polki/1000.0)*(b_polki/1000.0))/3.125) +
          ((@constant.wei_list_25_125_07 * (@usil * (@constant.area_usil_arx/2) * (@width_var/1000.0)))/3.125)
    end
    # Работа за полочку + 22%
    @price_polki += @constant.job_polki_arx * 1.22    #((H5*(F4*(J8/2)*(B3/1000)))/3.125)

    @kol_usil=0
    #Вычисляем количество усилителей на одну полку в зависимости от количества усилителей вырубаных с остатка от листа по длине
    @mini_var = Float(@usil * @kol_polok_s_lista)
    if @mini_var!=0
      @kol_usil = @usil * (1-(Float(@kol_usil_virub)/@mini_var))
    end
    if @kol_usil<0
      @kol_usil=0
    end


    #стоимость усилителей при заготовке 120 мм + 22%
    if @width_var > 1000
      @price_usil   = (@constant.mat_list_25_125_07/(Integer(2500/((@constant.area_usil_arx/2))/1000))) + @constant.job_usil_arx * 1.22
    else
      @price_usil   = (@constant.mat_list_2_1_07/(Integer(2000/((@constant.area_usil_arx/2))/1000))) + @constant.job_usil_arx * 1.22
    end


    #Вес стеллажа
    @wei_stilage = (@hight_var/1000.0) * 4 * @constant.wei_stoyki_arx + @wei_polki * @num_of_shelves_var +
        @constant.wei_pyatki_arx * 4
    @wei_stilage = @wei_stilage.round(2).to_s

    # cnjbvjcnm cnjqrb + 22%
    @price_stoyka = (leng_stoyki(@hight_var, @constant.rack_multiplicity)/1000.0) * @constant.mat_stoyki_arx + @constant.job_stoyki_arx * 1.22

    @sebest = @price_stoyka * 4 + @price_polki * @num_of_shelves_var +
        @price_usil * @num_of_shelves_var * @kol_usil + (@constant.mat_pyatki_arx * 4 * 1.22) +
        @constant.job_upakovka_arx * 1.22

    @sebest = @sebest * (@constant.otxod_pk/100 +1)
    @kostven = @sebest * @constant.job_kostven_arx
    @sebest = @sebest + @kostven


    @price_stillage = @sebest * (@natsenka/100 +1)

    @name_stilage = "#{@hight_var} x #{@width_var} x #{@depth_var} #{@num_of_shelves_var}п "

    if @usil == 1
      @name_stilage = @name_stilage + " #{@usil} усилитель"
    end

    if @usil == 2
      @name_stilage = @name_stilage + " #{@usil} усилителя"
    end

    #проверка выбора оцинкованный или окрашенный стеллаж
    if @okr_or_oc == "osinkovaniy"
      @name_stilage = @name_stilage + " " + t('page.all.osinkovaniy')
      @okraska=0
    else
      @name_stilage = @name_stilage + " " + t('page.all.okrash')

      #считаем площадь
      #площадь стоек + площадь полок + площадь усилителей
      @plosh_st = (@constant.area_stoyki_arx * (Float(@hight_var))/1000 * 4)
      @plosh_pol= Float(((((@width_var + 90) * (@depth_var + 90) * 2.0)/1000000.0) + ((@constant.area_usil_arx / 2.0) * @usil) * (@width_var/1000.0)) * @num_of_shelves_var)
      @okraska = @plosh_st * @constant.job_okr_stoyki_arx + @plosh_pol * @constant.job_okr_polki_arx * 1.22
    end
    @price_stillage = @price_stillage + @okraska

    @price_stillage = @price_stillage.round(2).to_s
  end

  def dsp_shelf()
    a_tf = @width_var
    a_tb = @depth_var
    b_tf_tb = Integer((@constant.area_tb_tf/2) * 1000)


    if @width_var > 1000
      price_polki_bolsh_tf = price_shelf_layer(a_tf,  b_tf_tb, 2500, 1250, @constant.mat_list_25_125_08)
      price_polki_bolsh_tb = price_shelf_layer(a_tb,  b_tf_tb, 2500, 1250, @constant.mat_list_25_125_08)
      price_polki_mal_tf = @constant.mat_list_2_1_08
      price_polki_mal_tb = @constant.mat_list_2_1_08
    else
      price_polki_bolsh_tf = price_shelf_layer(a_tf,  b_tf_tb, 2500, 1250, @constant.mat_list_25_125_08)
      price_polki_bolsh_tb = price_shelf_layer(a_tb,  b_tf_tb, 2500, 1250, @constant.mat_list_25_125_08)

      price_polki_mal_tf = price_shelf_layer(a_tf,  b_tf_tb, 2000, 1000, @constant.mat_list_2_1_08)
      price_polki_mal_tb = price_shelf_layer(a_tb,  b_tf_tb, 2000, 1000, @constant.mat_list_2_1_08)

    end

    if price_polki_mal_tf < price_polki_bolsh_tf
      price_tf = price_polki_mal_tf

      kol_polok_s_lista = @constant.mat_list_2_1_08 / price_tf
      price_list = @constant.mat_list_2_1_08
      wei_tf = ((@constant.wei_list_2_1_08 * (a_tf/1000.0)*(b_tf_tb/1000.0))/2)

    else
      price_tf = price_polki_bolsh_tf

      kol_polok_s_lista = @constant.mat_list_25_125_08 / price_tf
      price_list = @constant.mat_list_25_125_08
      wei_tf = ((@constant.wei_list_2_1_08 * (a_tf/1000.0)*(b_tf_tb/1000.0))/2)
    end


    if price_polki_mal_tb < price_polki_bolsh_tb
      price_tb = price_polki_mal_tb

      kol_polok_s_lista = @constant.mat_list_2_1_08 / price_tb
      price_list = @constant.mat_list_2_1_08
      wei_tb = ((@constant.wei_list_2_1_08 * (a_tb/1000.0)*(b_tf_tb/1000.0))/2)

    else
      price_tb = price_polki_bolsh_tb

      kol_polok_s_lista = @constant.mat_list_25_125_08 / price_tb
      price_list = @constant.mat_list_25_125_08
      wei_tb = ((@constant.wei_list_2_1_08 * (a_tb/1000.0)*(b_tf_tb/1000.0))/2)
    end
    price_tf += @constant.job_tb_tf_traversa * 1.22
    price_tb += @constant.job_tb_tf_traversa * 1.22

    #Вес стеллажа
    @wei_stilage = (@hight_var/1000.0) * 4 * @constant.wei_stoyki_arx + wei_tf * @num_of_shelves_var * 2 + wei_tb * @num_of_shelves_var * 2 + @constant.wei_pyatki_arx * 4
    @wei_stilage = @wei_stilage.round(2).to_s


    price_stoyka = (leng_stoyki(@hight_var, @constant.rack_multiplicity)/1000.0) * @constant.mat_stoyki_arx + @constant.job_stoyki_arx * 1.22

    sebest = price_stoyka * 4 + price_tf * @num_of_shelves_var * 2 + price_tb * @num_of_shelves_var * 2 + @constant.mat_pyatki_arx * 4 + @constant.job_upakovka_arx * 1.22

    sebest = sebest * (@constant.otxod_pk/100 +1)
    kostven = sebest * @constant.job_kostven_arx
    sebest = sebest + kostven


    @price_stillage = sebest * (@natsenka/100 +1)

    @name_stilage = "#{@hight_var} x #{@width_var} x #{@depth_var} #{@num_of_shelves_var}п "

    #проверка выбора оцинкованный или окрашенный стеллаж
    if @okr_or_oc == "osinkovaniy"
      @name_stilage = @name_stilage + " " + t('page.all.osinkovaniy')
      okraska = 0
    else
      @name_stilage = @name_stilage + " " + t('page.all.okrash')

      #считаем площадь
      #площадь стоек + площадь полок + площадь усилителей
      plosh_st = (@constant.area_stoyki_arx * (Float(@hight_var))/1000 * 4)

      plosh_pol= Float(((@constant.area_tb_tf * (a_tf / 1000)) + (@constant.area_tb_tf * (a_tb / 1000))) * @num_of_shelves_var * 2)

      okraska = plosh_st * @constant.job_okr_stoyki_arx + plosh_pol * @constant.job_okr_polki_arx
    end
    @price_stillage = @price_stillage + okraska

    @price_stillage = @price_stillage.round(2).to_s

  end

end