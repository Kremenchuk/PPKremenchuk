function validate_form_stilage_pallet ( )
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
    if ( Number(document.contact_form.hight.value) > 6000  )
    {
        alert ( "Значение поля 'Высота' не должно быть больше 6000 мм." );
        valid = false;
    }
    if ( Number(document.contact_form.hight.value) < 2000  )
    {
        alert ( "Значение поля 'Высота' не должно быть меньше 2000 мм." );
        valid = false;
    }
    //проверка поля ширина
    if ( Number(document.contact_form.widthS.value) > 3500 )
    {
        alert ( "Значение поля 'Ширина' не должно быть больше 3500 мм." );
        valid = false;
    }
    if ( Number(document.contact_form.widthS.value) < 1200 )
    {
        alert ( "Значение поля 'Ширина' не должно быть меньше 1200 мм." );
        valid = false;
    }

    //проверка для поля Количество полок
    if ( Number(document.contact_form.num_of_shelves.value) > 10 )
    {
        alert ( "Количество полок не более 8 шт." );
        valid = false;
    }
    if ( Number(document.contact_form.num_of_shelves.value) < 2 )
    {
        alert ( "Количество полок не менее 2 шт." );
        valid = false;
    }

    //проверка поля Нагрузка на полку
    if ( Number(document.contact_form.shelf_load.value) > 3000 )
    {
        alert ( "Нагрузка на полку не должна превышать 100 кг." );
        valid = false;
    }
    if ( Number(document.contact_form.shelf_load.value) < 500 )
    {
        alert ( "Минимальная нагрузка на полку 500 кг." );
        valid = false;
    }

    return valid;
}


