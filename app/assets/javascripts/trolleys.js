//Place all the behaviors and hooks related to the matching controller here.
//All this logic will automatically be available in application.js.
//You can use CoffeeScript in this file: http://coffeescript.org/
function validate_form_trolleys (element1)
{

    valid = true;
    objt = document.getElementById(element1);
    if (objt.lengthT.value == "") {
        alert("Пожалуйста заполните поле 'Длина'.");
        valid = false;
    }
    if (objt.widthS.value == "") {
        alert("Пожалуйста заполните поле 'Ширина'.");
        valid = false;
    }
    if (objt.hight_ruch.value == "") {
        alert("Пожалуйста заполните поле 'Высота ручки'.");
        valid = false;
    }
    if (objt.shelf_load.value == "") {
        alert("Пожалуйста заполните поле 'Нагрузка на полку'.");
        valid = false;
    }


    //проверка полей на соответствие min max значениям


    //Проверка поля высота
    if (Number(objt.lengthT.value) > 1500) {
        alert ( "Значение поля 'Длина' не должно быть больше 1500 мм." );
        valid = false;
    }
    if (Number(objt.lengthT.value) < 600) {
        alert ( "Значение поля 'Длина' не должно быть меньше 600 мм." );
        valid = false;
    }

    //проверка поля ширина
    if (Number(objt.widthS.value) > 1200) {
        alert ( "Значение поля 'Ширина' не должно быть больше 1200 мм." );
        valid = false;
    }
    if (Number(objt.widthS.value) < 500) {
        alert ( "Значение поля 'Ширина' не должно быть меньше 500 мм." );
        valid = false;
    }

    //проверка поля глубина
    if (Number(objt.hight_ruch.value) > 1200) {
        alert("Значение поля 'Высота ручки' не должно быть больше 1200 мм.");
        valid = false;
    }

    if (Number(objt.hight_ruch.value) < 600) {
        alert ( "Значение поля 'Высота ручки' не должно быть меньше 600 мм." );
        valid = false;
    }

    //проверка поля Нагрузка на полку
    if (Number(objt.shelf_load.value) > 400) {
        alert ( "Нагрузка на полку не должна превышать 400 кг." );
        valid = false;
    }
    if (Number(objt.shelf_load.value) < 50) {
        alert ( "Минимальная нагрузка на полку 50 кг." );
        valid = false;
    }

    return valid;
}