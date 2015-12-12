class StillageController < ApplicationController

  #before_filter :check_if_admin, only: [:show]
  include Include_Module

  #before_filter :authenticate_user!, only: [:index] #Рабочее ограничение на юзара
  def index
    button_const
  end

  def show
    button_const
    @hight_var      = Integer(params[:hight])
    @width_var      = Integer(params[:widthS])
    @depth_var      = Integer(params[:depth])
    @num_of_shelves_var = Integer(params[:num_of_shelves])
    @shelf_load_var     = Integer(params[:shelf_load])
    @okr_or_oc          = params[:group1]
    @constant = Constant.where("id = 1").first

    a_polki = @width_var + 90
    b_polki = @depth_var + 90
    if a_polki > 1000
      @price_polki_bolsh = price_shelf_layer(a_polki,  b_polki, 2500, 1250, @constant.mat_list_25_125_07)
      @price_polki_mal = @constant.mat_list_2_1_07

    else
      @price_polki_mal = price_shelf_layer(a_polki,  b_polki, 2000, 1000, @constant.mat_list_2_1_07)
      @price_polki_bolsh = price_shelf_layer(a_polki,  b_polki, 2500, 1250, @constant.mat_list_25_125_07)
    end
    if @price_polki_mal < @price_polki_bolsh
      @price_polki = @price_polki_mal
      a_list = 2000
      b_list = 1000
      @kol_polok_s_lista = @constant.mat_list_2_1_07 / @price_polki
      @price_list = @constant.mat_list_2_1_07
      @wei_polki = (@constant.wei_list_2_1_07 * (a_polki/1000.0)*(b_polki/1000.0))/2
    else
      @price_polki = @price_polki_bolsh
      a_list = 2500
      b_list = 1250
      @kol_polok_s_lista = @constant.mat_list_25_125_07 / @price_polki
      @price_list = @constant.mat_list_25_125_07
      @wei_polki = (@constant.wei_list_25_125_07 * (a_polki/1000.0)*(b_polki/1000.0))/3.125
    end
    @price_polki += @constant.job_polki_arx

    #Вычисляем возможность отрубить с остатка усилитель
      #Проверка того, что полку для рубки расположили не как обычно
        if a_list == 2500 and a_polki < 1000
          #Проверка, что можно вырубить усилитель по длине листа
           #@kol_vozmogn_usil = ((b_list - b_polki * (1250/b_polki)) / 120) * (a_list/a_polki)
          #Проверка, что можно вырубить усилитель по ширине листа
           @kol_vozmogn_usil = ((a_list - (a_list / a_polki) * a_polki)) / 120
        else
          #Проверка, что можно вырубить усилитель по длине листа
            #@kol_vozmogn_usil = ((b_list - a_polki) / 120) * (a_list/(b_polki * 2))
          #Проверка, что можно вырубить усилитель по ширине листа
            @kol_vozmogn_usil = ((a_list - (Integer(@kol_polok_s_lista) * b_polki)) / 120)
        end
      #Количество ПОЛНЫХ листов необходимых для стеллажа

      #@kol_vozmogn_usil *= @num_of_shelves_var/Integer(@kol_polok_s_lista) unless (@num_of_shelves_var/Integer(@kol_polok_s_lista)) < 1


    @usil=0
    
    if @depth_var >= 500
      if @shelf_load_var <= 60
        @usil = 0
        if @depth_var >= 600
          @usil = 1
        end
      end

      if @shelf_load_var > 60
        @usil = 1
        if @depth_var >= 600
          @usil = 2
        end
      end
    end
    @usil = ((Float(@usil) * Float(@num_of_shelves_var)) - Float(@kol_vozmogn_usil)) /
            (Float(@usil) * Float(@num_of_shelves_var)) unless @usil == 0

    if @width_var > 1000
      @price_usil   = (@constant.mat_list_25_125_07/20) + @constant.job_usil_arx
    else
      @price_usil   = (@constant.mat_list_2_1_07/16) + @constant.job_usil_arx
    end


    #Вес стеллажа
      @wei_stilage = (@hight_var/1000.0) * 4 * @constant.wei_stoyki_arx + @wei_polki * @num_of_shelves_var +
                       @constant.wei_pyatki_arx * 4
      @wei_stilage = @wei_stilage.to_s(:rounded, :precision => 2)


    @price_stoyka = (Float(@hight_var)/1000) * @constant.mat_stoyki_arx + @constant.job_stoyki_arx

    @sebest = @price_stoyka * 4 + @price_polki * @num_of_shelves_var +
              @price_usil * @num_of_shelves_var * @usil + @constant.mat_pyatki_arx * 4 +
              @constant.job_upakovka_arx + @kol_vozmogn_usil * @constant.job_usil_arx

    @kostven = @sebest * @constant.job_kostven_arx
    @sebest = @sebest + @kostven
    @price_stillage = @sebest * (@constant.job_natsenka/100 +1)

    @name_stilage = "#{@hight_var} x #{@width_var} x #{@depth_var} #{@num_of_shelves_var}п "

    if @usil == 1
      @name_stilage = @name_stilage + " #{@usil} усилитель"
    end

    if @usil == 2
      @name_stilage = @name_stilage + " #{@usil} усилителя"
    end

    #проверка выбора оцинкованный или окрашенный стеллаж
    if @okr_or_oc == "osinkovaniy"
      @name_stilage = @name_stilage + " оцинкованный"
      @okraska=0
    else
      @name_stilage = @name_stilage + " окрашенный"

      #считаем площадь
                #площадь стоек + площадь полок + площадь усилителей
      @plosh_st = (0.136 * (Float(@hight_var))/1000 * 4)
      @plosh_pol= Float(((@width_var + 100) * (@depth_var + 100))* 2 * @num_of_shelves_var)/1000000
      @okraska = @plosh_st * @constant.job_okr_stoyki_arx + @plosh_pol * @constant.job_okr_polki_arx
    end
    @price_stillage = @price_stillage + @okraska

    @price_stillage = @price_stillage.to_s(:rounded, :precision => 2)
  end

end