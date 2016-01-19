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
var num = [25];
for(i=0;i<25;i++){
    num[i]=false;
}


function showHide(element1, element2)
{
    $("div[class^=" + element1 + "]").toggle('normal');
    obj = document.getElementById(element2);
    var a;
    a = Number(String(obj.id).substr(-2));
    if (num[a] == true) {
        obj.src = '/assets/plus.png';
        num[a] = false;
    }
    else {
        obj.src = '/assets/minus.png';
        num[a] = true;
    }

}






