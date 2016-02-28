module Include_Module
  private
  def price_shelf_layer(a_pol, b_pol, a_list, b_list, price_list)
    #Вариант рубки №1

    result1 = a_list / b_pol
    result2 = b_list / a_pol
    #Вычисляем остатки и что с них можем еще получить
    ost = b_list - result2 * a_pol #какой кусок остался
    vozm = b_pol * (b_list / b_pol)  #возможность отрубить по ширине более одной заготовки
    if vozm ==0
      vozm =1
    end
    if vozm > a_pol
      koef = (b_list / vozm) * 2
    else
      koef = (b_list / vozm) * 1
    end
    r_ost = (ost / b_pol) * koef
    vsego1 = result1 * result2 + r_ost #Всего с листа при рубке по варианту №1

    #Вариант рубки №2

    result1 = a_list / a_pol
    result2 = b_list / b_pol
    #Вычисляем остатки и что с них можем еще получить
    ost = a_list - result1 * a_pol #какой кусок остался
    vozm = b_pol * ((b_list / 2) / b_pol)  #возможность отрубить по длине более одной заготовки
    if vozm ==0
      vozm =1
    end
    if vozm > a_pol
      koef = ((b_list / 2) / vozm) * 2
      if koef == 0
        koef = 1
      end
    else
      koef = 1
    end
    r_ost = (ost / b_pol) * koef

    vsego2 = result1 * result2 + r_ost #Всего с листа при рубке по варианту №2

    # Вычисляем и возвращаем наименьшую цену за полку
    if vsego1 >= vsego2
      return price_list/vsego1
    else
      return price_list/vsego2
    end
  end

  private
  def enter_row_to_excel(stillage,price)
    t=Time.now
    workbook = RubyXL::Parser.parse("1.xlsx")
    worksheet = workbook[1]
    @kol_row = worksheet[1][0].value

    if @kol_row==0
      write_row_to_excel(stillage,price)
    else

      worksheet = workbook[0]
      @last_date = worksheet[@kol_row][5].value
      @current_date = t.strftime("%Y%m%d")

      if Integer(@last_date)==Integer(@current_date)
        write_row_to_excel(stillage,price)
      else
        #отправка файла на е-маил и отчистка строк
        SendEmail.send_calculation_file.deliver_now

        worksheet = workbook[0]
        @kol_row.times do |a|
          worksheet.delete_cell(a+1, 0)
          worksheet.delete_cell(a+1, 1)
          worksheet.delete_cell(a+1, 2)
          worksheet.delete_cell(a+1, 3)
          worksheet.delete_cell(a+1, 4)
          worksheet.delete_cell(a+1, 5)
        end
        worksheet = workbook[1]
        worksheet.add_cell(1, 0, '0')
        workbook.write
      end
    end

  end

  def write_row_to_excel(stillage,price)
    t=Time.now

    workbook = RubyXL::Parser.parse("1.xlsx")
    worksheet = workbook[0]
    worksheet.insert_row(1)
    if current_user.login == nil
      loginvar = "Без логина"
    else
      loginvar = current_user.login
    end

    if current_user.email == nil
      emailvar = "Без логина"
    else
      emailvar = current_user.email
    end
    worksheet.add_cell(1, 0, "#{loginvar}")
    worksheet.add_cell(1, 1, "#{emailvar}")
    worksheet.add_cell(1, 2, "#{stillage}")
    worksheet.add_cell(1, 3, "#{price}")
    worksheet.add_cell(1, 4, "#{t.strftime("%H:%M")}")
    worksheet.add_cell(1, 5, "#{t.strftime("%Y%m%d")}")
    worksheet = workbook[1]
    kol_row = worksheet[1][0].value
    kol_row=kol_row+1
    worksheet.add_cell(1, 0, "#{kol_row}")
    workbook.write
  end
end
