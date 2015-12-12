// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
var num=false;
function showHide(element1, element2)
{
    $("div[class^=" + element1 + "]").toggle('normal');
    obj = document.getElementById(element2)
    if (num == true) {
        obj.src = '/assets/plus.png';
        num = false;
    }
    else {
        obj.src = '/assets/minus.png';
        num = true;
    }

}