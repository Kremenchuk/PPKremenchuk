//Place all the behaviors and hooks related to the matching controller here.
//All this logic will automatically be available in application.js.
//You can use CoffeeScript in this file: http://coffeescript.org/
function validate_form ( )
{
    valid = true;
    if ( document.contact_form.hight.value == "" )
    {
        alert ( "Пожалуйста заполните поле 'Высота'." );
        valid = false;
    }
    if ( document.contact_form.widthS.value == "" )
    {
        alert ( "Пожалуйста заполните поле 'Ширина'." );
        valid = false;
    }
    if ( document.contact_form.depth.value == "" )
    {
        alert ( "Пожалуйста заполните поле 'Глубина'." );
        valid = false;
    }
    if ( document.contact_form.num_of_shelves.value == "" )
    {
        alert ( "Пожалуйста заполните поле 'Количество полок'." );
        valid = false;
    }
    if ( document.contact_form.shelf_load.value == "" )
    {
        alert ( "Пожалуйста заполните поле 'Нагрузка на полку'." );
        valid = false;
    }



    //проверка полей на соответствие min max значениям


    //Проверка поля высота
        if ( Number(document.contact_form.hight.value) > 5200  )
        {
            alert ( "Значение поля 'Высота' не должно быть больше 5200 мм." );
            valid = false;
        }
        if ( Number(document.contact_form.hight.value) < 1500  )
        {
            alert ( "Значение поля 'Высота' не должно быть меньше 1500 мм." );
            valid = false;
        }
    //проверка поля ширина
        if ( Number(document.contact_form.widthS.value) > 2700 )
        {
            alert ( "Значение поля 'Ширина' не должно быть больше 2700 мм." );
            valid = false;
        }
        if ( Number(document.contact_form.widthS.value) < 800 )
        {
            alert ( "Значение поля 'Ширина' не должно быть меньше 800 мм." );
            valid = false;
        }
    //проверка поля глубина
          if ( document.contact_form.group3.value == "metall" )
          {
              if ( Number(document.contact_form.depth.value) > 1215 )
              {
                  alert("Значение поля 'Глубина', для металлической полки, не должно быть больше 1215 мм.");
                  valid = false;
              }
          }
          if ( document.contact_form.group3.value == "dsp" )
          {
              if ( Number(document.contact_form.depth.value) > 1500 )
              {
                  alert("Значение поля 'Глубина', для полки из ДСП, не должно быть больше 1500 мм.");
                  valid = false;
              }
          }

        if ( Number(document.contact_form.depth.value) < 300 )
        {
            alert ( "Значение поля 'Глубина' не должно быть меньше 300 мм." );
            valid = false;
        }

    //проверка для поля Количество полок
        if ( Number(document.contact_form.num_of_shelves.value) > 15 )
        {
            alert ( "Количество полок не более 15 шт." );
            valid = false;
        }
        if ( Number(document.contact_form.num_of_shelves.value) < 2 )
        {
            alert ( "Количество полок не менее 2 шт." );
            valid = false;
        }

    //проверка поля Нагрузка на полку
        if ( Number(document.contact_form.shelf_load.value) > 400 )
        {
            alert ( "Нагрузка на полку не должна превышать 400 кг." );
            valid = false;
        }
        if ( Number(document.contact_form.shelf_load.value) < 150 )
        {
            alert ( "Минимальная нагрузка на полку 150 кг." );
            valid = false;
        }

    return valid;
}

function hide_dsp(element1)
{
    if ( document.contact_form.group3.value == "dsp" )
    {
        document.getElementById("hiden_radio_1").disabled = true; // сделать неактивной
        document.getElementById("hiden_radio_2").disabled = true;
        document.getElementById("hiden_radio_3").style.color = "rgb(150,150,150)";
        document.getElementById("hiden_radio_1").checked = true;
        document.contact_form.group2.value = "osinkovaniy";
    }
    if ( document.contact_form.group3.value == "metall" )
    {
        document.getElementById("hiden_radio_1").disabled = false; // сделать неактивной
        document.getElementById("hiden_radio_2").disabled = false;
        document.getElementById("hiden_radio_3").style.color = "rgb(0,0,0)";

    }


}