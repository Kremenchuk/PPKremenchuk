$ ->
  myNode = document.getElementById('actual_price')
  myNode.innerHTML = ''
  $('#actual_price').append('<%= j (raw render partial: 'show_actual_price') %>')
  $('html, body').animate { scrollTop: $('#contact_form').offset().top - 70 }, 300
