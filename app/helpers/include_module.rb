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

end
