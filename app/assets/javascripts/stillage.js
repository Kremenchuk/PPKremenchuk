function validate_form_stilage ( )
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
    if ( Number(document.contact_form.hight.value) > 3500  )
    {
        alert ( "Значение поля 'Высота' не должно быть больше 3500 мм." );
        valid = false;
    }
    if ( Number(document.contact_form.hight.value) < 500  )
    {
        alert ( "Значение поля 'Высота' не должно быть меньше 500 мм." );
        valid = false;
    }
    //проверка поля ширина
    if ( Number(document.contact_form.widthS.value) > 1150 )
    {
        alert ( "Значение поля 'Ширина' не должно быть больше 1150 мм." );
        valid = false;
    }
    if ( Number(document.contact_form.widthS.value) < 400 )
    {
        alert ( "Значение поля 'Ширина' не должно быть меньше 400 мм." );
        valid = false;
    }
    //проверка поля глубина

        if ( Number(document.contact_form.depth.value) > 800 )
        {
            alert("Значение поля 'Глубина' не должно быть больше 800 мм.");
            valid = false;
        }
        if ( Number(document.contact_form.depth.value) < 250 )
        {
            alert("Значение поля 'Глубина' не должно быть меньше 250 мм.");
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
        if ( Number(document.contact_form.shelf_load.value) > 200 )
        {
            alert ( "Нагрузка на полку не должна превышать 200 кг." );
            valid = false;
        }
        if ( Number(document.contact_form.shelf_load.value) < 20 )
        {
            alert ( "Минимальная нагрузка на полку 20 кг." );
            valid = false;
        }

    return valid;
}

//Place all the behaviors and hooks related to the matching controller here.
//All this logic will automatically be available in application.js.
//You can use CoffeeScript in this file: http://coffeescript.org/

