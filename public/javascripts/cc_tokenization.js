// function for card connect tokenization message
window.addEventListener('message', function(event) {
  document.getElementById('mytoken').value = JSON.parse(event.data);
  var token = JSON.parse(event.data);      
  var mytoken = document.getElementById('mytoken');
  mytoken.value = token.message;
  document.getElementById('token_submit').disabled = false;
  }, false);
