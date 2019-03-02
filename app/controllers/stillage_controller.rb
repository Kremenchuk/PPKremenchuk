class StillageController < ApplicationController

  before_filter :check_if_diller, only: [:index, :calculate_actual_price]
  include Include_Module

  #before_filter :authenticate_user!, only: [:index] #Рабочее ограничение на юзара
  def index
  end

  def control_parameters
    if @hight_var>3500 or @hight_var<500
      redirect_to "/stillage/index"
    end
    if @width_var>1150 or @width_var<400
      redirect_to "/stillage/index"
    end
    if @depth_var>800 or @depth_var<250
      redirect_to "/stillage/index"
    end
    if @num_of_shelves_var>15 or @num_of_shelves_var<2
      redirect_to "/stillage/index"
    end
    if @shelf_load_var>100 or @shelf_load_var<20
      redirect_to "/stillage/index"
    end
  end

  def calculate_actual_price
    @hight_var      = Integer(params[:hight])
    @width_var      = Integer(params[:widthS])
    @depth_var      = Integer(params[:depth])
    @num_of_shelves_var = Integer(params[:num_of_shelves])
    @shelf_load_var     = Integer(params[:shelf_load])
    @okr_or_oc          = params[:group1]

    control_parameters

    @constant = Constant.where("id = 1").first

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
    @price_polki += @constant.job_polki_arx     #((H5*(F4*(J8/2)*(B3/1000)))/3.125)

    @kol_usil=0
    #Вычисляем количество усилителей на одну полку в зависимости от количества усилителей вырубаных с остатка от листа по длине
      @mini_var = Float(@usil * @kol_polok_s_lista)
      if @mini_var!=0
        @kol_usil = @usil * (1-(Float(@kol_usil_virub)/@mini_var))
      end
    if @kol_usil<0
      @kol_usil=0
    end


    #стоимость усилителей при заготовке 120 мм
      if @width_var > 1000
        @price_usil   = (@constant.mat_list_25_125_07/(Integer(2500/((@constant.area_usil_arx/2))/1000))) + @constant.job_usil_arx
      else
        @price_usil   = (@constant.mat_list_2_1_07/(Integer(2000/((@constant.area_usil_arx/2))/1000))) + @constant.job_usil_arx
      end


    #Вес стеллажа
      @wei_stilage = (@hight_var/1000.0) * 4 * @constant.wei_stoyki_arx + @wei_polki * @num_of_shelves_var +
                       @constant.wei_pyatki_arx * 4
      @wei_stilage = @wei_stilage.to_s(:rounded, :precision => 2)


    @price_stoyka = (leng_stoyki(@hight_var, @constant.rack_multiplicity)/1000.0) * @constant.mat_stoyki_arx + @constant.job_stoyki_arx

    @sebest = @price_stoyka * 4 + @price_polki * @num_of_shelves_var +
              @price_usil * @num_of_shelves_var * @kol_usil + @constant.mat_pyatki_arx * 4 +
              @constant.job_upakovka_arx

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
      @okraska = @plosh_st * @constant.job_okr_stoyki_arx + @plosh_pol * @constant.job_okr_polki_arx
    end
    @price_stillage = @price_stillage + @okraska

    @price_stillage = @price_stillage.to_s(:rounded, :precision => 2)



    enter_row_to_excel(@name_stilage, @price_stillage) #внесение в ексель файл данных о расчете стеллажа.
  end

end