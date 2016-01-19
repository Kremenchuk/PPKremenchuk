
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







