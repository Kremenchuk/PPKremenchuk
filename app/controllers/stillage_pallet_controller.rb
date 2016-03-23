class StillagePalletController < ApplicationController
  before_filter :check_if_diller, only: [:index, :show]
  include Include_Module

  def index
  end

  def control_parameters
    if @hight_var>6000 or @hight_var<2000
      redirect_to "/stillage_pallet/index"
    end
    if @width_var>3500 or @width_var<1200
      redirect_to "/stillage_pallet/index"
    end
    if @num_of_shelves_var>10 or @num_of_shelves_var<2
      redirect_to "/stillage_pallet/index"
    end
    if @shelf_load_var>3000 or @shelf_load_var<500
      redirect_to "/stillage_pallet/index"
    end
  end


  def show
    @hight_var      = Integer(params[:hight])
    @width_var      = Integer(params[:widthS])
    @depth_var      = 1100
    @num_of_shelves_var = Integer(params[:num_of_shelves])
    @shelf_load_var     = Integer(params[:shelf_load])

    control_parameters

    @constant = Constant.where("id = 1").first

    #Определение длины и количества укосов
      shag   = 900
      ukos_g_kol = 0
      ukos_b_kol = 0
      if @hight_var >= 2000 and @hight_var < 2500
        ukos_g_kol = 3
        ukos_b_kol = 1

      elsif @hight_var >= 2500 and @hight_var < 3000
        ukos_g_kol = 3
        ukos_b_kol = 2

      elsif @hight_var >= 3000 and @hight_var < 3500
        ukos_g_kol = 4
        ukos_b_kol = 2

      elsif @hight_var >= 3500 and @hight_var < 4000
        ukos_g_kol = 2
        ukos_b_kol = 3
      elsif @hight_var >= 4000 and @hight_var < 4500
        ukos_g_kol = 4
        ukos_b_kol = 3
      elsif @hight_var >= 4500 and @hight_var < 5000
        ukos_g_kol = 2
        ukos_b_kol = 4
      elsif @hight_var >= 5000 and @hight_var < 6100
        ukos_g_kol = 4
        ukos_b_kol = 4
      end

    #Определение длины укосов
      dlin_ukos_g = Float(@depth_var-84)
      dlin_ukos_b = Math.sqrt(Float((@depth_var-102) * (@depth_var-102) + shag**2))+18

    #Определение стоимости и веса укосов
      @ukos_g = (dlin_ukos_g/1000.0) * @constant.mat_ukosi_pallet + @constant.job_ukosi_pallet
      @ukos_b = (dlin_ukos_b/1000.0) * @constant.mat_ukosi_pallet + @constant.job_ukosi_pallet

      wei_ukosi = @constant.wei_ukosi_pallet * (((dlin_ukos_g/1000.0) + (dlin_ukos_b/1000.0)) *
                (ukos_g_kol + ukos_b_kol)) + @constant.wei_metizi_pallet_ram * (ukos_g_kol + ukos_b_kol)*2

    @ukos_g = @ukos_g.to_s(:rounded, :precision => 2).to_f
    @ukos_b = @ukos_b.to_s(:rounded, :precision => 2).to_f


    #Стоимость и вес стойки
      @price_stoyka = (@hight_var/1000.0) * @constant.mat_stoyki_pallet + @constant.job_stoyki_pallet
      wei_stoyki = @constant.wei_stoyki_pallet * (@hight_var/1000.0)

    #стоимость траверсы
      #Выбор сечения траверсы
        if @shelf_load_var <=1000
          @depth_traversi = 40
          @hight_traversi = 2.5 * ((@shelf_load_var * 1.35)/@depth_traversi)
        elsif @shelf_load_var > 1000 and @shelf_load_var <= 1800
          @depth_traversi = 50
          @hight_traversi = 2.5 * ((@shelf_load_var * 1.35)/@depth_traversi)
        elsif @shelf_load_var > 1800 and @shelf_load_var <= 3000
          @depth_traversi = 60
          @hight_traversi = 2.25 * ((@shelf_load_var * 1.35)/@depth_traversi)
        end

        #Проверка верхнего и нижнего предела для нагрузки 1,3-1,4
          @hight_traversi_verx = (@hight_traversi/10).to_i
          ostatok = (@hight_traversi % 10).to_i
          if ostatok > 5
            @hight_traversi_verx = (@hight_traversi_verx * 10) + 10
            @hight_traversi_niz = @hight_traversi_verx - 5
          elsif ostatok < 5
            @hight_traversi_verx = (@hight_traversi_verx * 10) + 5
            @hight_traversi_niz = @hight_traversi_verx - 5
          end
            #Расчет нагрузки на верхни)й и нижний предел высоты траверсы
            @p_verx = (160000*(((@depth_traversi/10.0) * (@hight_traversi_verx/10.0)**3) -
                   (((@depth_traversi - 3)/10.0) * ((@hight_traversi_verx-6)/10.0)**3))/
                   (6 * (@hight_traversi_verx/10.0)))/@width_var

            @p_niz = (160000*(((@depth_traversi/10.0) * (@hight_traversi_niz/10.0)**3) -
                (((@depth_traversi - 3)/10.0) * ((@hight_traversi_niz-6)/10.0)**3))/
                (6 * (@hight_traversi_niz/10.0)))/@width_var

            @koef_verx = ((@p_verx*2)/@shelf_load_var)/1.35
            @koef_niz = ((@p_niz*2)/@shelf_load_var)/1.35

            if @koef_verx > 1 and @koef_niz > 1
              if @koef_verx > @koef_niz
                @hight_traversi = @hight_traversi_niz
              end
            elsif @koef_verx > 1 and @koef_niz < 1
              @hight_traversi = @hight_traversi_verx
            elsif @koef_verx < 1 and @koef_niz < 1
              @hight_traversi = @hight_traversi_verx
            end

    #Расчет стоимости траверсы
      scope_traversi = (((@hight_traversi*2) + (@depth_traversi*4))/1000.0)*0.0015
      plosh_traversi = (((@hight_traversi*2) + (@depth_traversi*2))/1000.0)*(@width_var/1000.0) + 0.065
      @price_traversa = ((scope_traversi / 0.00033) * @constant.mat_100x60x100x15)*(@width_var/1000.0) +
                      @constant.mat_zatsep_pallet * 2 + @constant.job_traversi_pallet +
                      @constant.mat_metizi_pallet_travers * 4 + plosh_traversi * @constant.job_okr_travers_pallet


    #стоимость рамы
      @price_ram = @price_stoyka * 2 + @ukos_g * ukos_g_kol + @ukos_b * ukos_b_kol  + @constant.mat_pyatki_pallet * 2 +
          (@constant.mat_metizi_pallet_ram * (ukos_g_kol + ukos_b_kol) * 2) + 0.0576 * @constant.job_okr_travers_pallet

    #Расчет веса рамы и траверсы
      @wei_ram = wei_stoyki * 2 + wei_ukosi + @constant.wei_pyatki_pallet * 2
      @wei_traversi = (scope_traversi / 0.00033) * @constant.wei_100x60x100x15 * (@width_var/1000.0) +
                       @constant.wei_zatsep_pallet * 2 + @constant.wei_metizi_pallet_travers * 4


      @wei_traversi = @wei_traversi.to_s(:rounded, :precision => 2)
      @wei_ram = @wei_ram.to_s(:rounded, :precision => 2)


    @price_ram += @price_ram * @constant.job_kostven_pallet
    @price_traversa += @price_traversa * @constant.job_kostven_pallet

    @price_traversa *=  (@natsenka/100 +1)
    @price_ram *=  (@natsenka/100 +1)

    @price_stillage_osn   = @price_ram * 2 + @price_traversa * @num_of_shelves_var
    @price_stillage_prist = @price_stillage_osn - @price_ram

    @price_traversa = @price_traversa.to_s(:rounded, :precision => 2)
    @price_ram = @price_ram.to_s(:rounded, :precision => 2)

    @price_stillage_osn = @price_stillage_osn.to_s(:rounded, :precision => 2)
    @price_stillage_prist = @price_stillage_prist.to_s(:rounded, :precision => 2)


    @text_var = "уровень"

    if @num_of_shelves_var>1
      @text_var = "уровня"
    end
    if @num_of_shelves_var>4
      @text_var = "уровней"
    end
    @name_stillage="#{@hight_var}x#{@width_var} траверса: #{@width_var}x#{@hight_traversi}x#{@depth_traversi}x1.5 уровней: #{@num_of_shelves_var} п. "
    enter_row_to_excel(@name_stillage, @price_stillage_osn) #внесение в ексель файл данных о расчете стеллажа.

  end


end
