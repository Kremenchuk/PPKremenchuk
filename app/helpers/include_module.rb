module Include_Module
  private
  def leng_stoyki(true_leng, kratn)
    result = true_leng.to_f/kratn.to_f
    x = result.to_i
    if result > x
      y = (x + 1) * kratn
    else
      y = x * kratn
    end
    return y

  end




  private
  def price_shelf_layer(a_pol, b_pol, a_list, b_list, price_list)
    $kol_usil_virub = 0
    vsego1 = quantity_shelf_layer_v1(a_pol, b_pol, a_list, b_list)
    vsego2 = quantity_shelf_layer_v2(a_pol, b_pol, a_list, b_list)
    price_pol1 = price_list/vsego1
    price_pol2 = price_list/vsego2



    if price_pol1 >= price_pol2
      $kol_usil_virub = @kol_usil_v2
      x = price_pol2
    else
      $kol_usil_virub = @kol_usil_v1
      x = price_pol1
    end

    if vsego1 == vsego2
      if @kol_usil_v2>=@kol_usil_v1
        $kol_usil_virub = @kol_usil_v2
      else
        $kol_usil_virub = @kol_usil_v1
      end
    end

    return x
  end

  def quantity_shelf_layer_v1(a_pol, b_pol, a_list, b_list) #Вариант рубки №1
    result1 = a_list / b_pol
    result2 = b_list / a_pol
    ost_a = ((a_list/2)/b_pol) * b_pol #(половина листа по длине/Б полки...
    ost_b = b_list - a_pol * result2
    s_ost = 0
    if ost_a>=a_pol
      if ost_b>=b_pol
        begin
          x = @kol_usil_v2
        rescue
        end
        s_ost = quantity_shelf_layer_v2(a_pol, b_pol,ost_a,ost_b) * 2
        begin
          @kol_usil_v2 += x + @kol_usil_v2
        rescue
        end
      end
    end
    @kol_usil_v1 = (a_list - result1 * b_pol) / 120
    vsego1 = result1 * result2 + s_ost #Всего с листа при рубке по варианту №1
    return vsego1
  end

  def quantity_shelf_layer_v2(a_pol, b_pol, a_list, b_list) #Вариант рубки №2
    result1 = a_list / a_pol
    result2 = b_list / b_pol
    ost_a = a_list - result1 * a_pol
    ost_b = b_list
    s_ost = 0
    if ost_a>=b_pol
      if ost_b>=a_pol
        begin
          x = @kol_usil_v1
        rescue
        end
        s_ost = quantity_shelf_layer_v1(a_pol, b_pol,ost_a,ost_b)
        begin
          @kol_usil_v1 += x + @kol_usil_v1
        rescue
        end
      end
    end
    @kol_usil_v2 = (ost_a - s_ost * b_pol) / 120
    vsego2 = result1 * result2 + s_ost #Всего с листа при рубке по варианту №2
    return vsego2
  end



  private
  def enter_row_to_excel(stillage, price)  #Внесение данных в книгу расчета
    # t=Time.now
    # workbook = RubyXL::Parser.parse("1.xlsx")
    # worksheet = workbook[1]
    # @kol_row = worksheet[1][0].value.to_i
    #
    # if @kol_row == 0
    #   write_row_to_excel(stillage, price)
    # else
    #
    #   worksheet = workbook[0]
    #
    #   @last_date = String(worksheet[@kol_row][5].value.gsub('.', ''))
    #   @current_date = t.strftime("%d%m%Y")
    #
    #   if String(@last_date) == String(@current_date)
    #     write_row_to_excel(stillage, price)
    #   else
    #     #отправка файла на е-маил и отчистка строк
    #     SendEmail.send_calculation_file.deliver_now
    #     worksheet = workbook[0]
    #     @kol_row.times do |a|
    #       worksheet.delete_cell(a+1, 0)
    #       worksheet.delete_cell(a+1, 1)
    #       worksheet.delete_cell(a+1, 2)
    #       worksheet.delete_cell(a+1, 3)
    #       worksheet.delete_cell(a+1, 4)
    #       worksheet.delete_cell(a+1, 5)
    #     end
    #     worksheet = workbook[1]
    #     worksheet.add_cell(1, 0, '0')
    #     workbook.write
    #   end
    # end

  end

  def write_row_to_excel(stillage,price)
    t=Time.now

    workbook = RubyXL::Parser.parse("1.xlsx")
    worksheet = workbook[0]
    worksheet.insert_row(1)
    if current_user == nil
      loginvar = "Без логина"
      emailvar = "Без логина"
    else
      loginvar = current_user.login
      emailvar = current_user.email
    end

    worksheet.add_cell(1, 0, "#{loginvar}")
    worksheet.add_cell(1, 1, "#{emailvar}")
    worksheet.add_cell(1, 2, "#{stillage}")
    worksheet.add_cell(1, 3, "#{price}")
    worksheet.add_cell(1, 4, "#{t.strftime("%H:%M")}")
    worksheet.add_cell(1, 5, "#{t.strftime('%d.%m.%Y')}")
    worksheet = workbook[1]
    kol_row = worksheet[1][0].value.to_i
    kol_row = kol_row + 1
    worksheet.add_cell(1, 0, "#{kol_row}")
    workbook.write
  end
end
