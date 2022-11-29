// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function getfocus(element) {
  document.getElementById(element).focus();
}

function showhide(id)
{
  if (document.getElementById(id).style.display == 'none') {
    document.getElementById(id).style.display = '';
  }
  else {
    document.getElementById(id).style.display = 'none'; 
  }
}

function showhide2(id1, id2)
{
  if (document.getElementById(id1).style.display == 'none') {
    document.getElementById(id1).style.display = '';
  }
  else {
    document.getElementById(id1).style.display = 'none'; 
  }
  if (document.getElementById(id2).style.display == 'none') {
    document.getElementById(id2).style.display = '';
  }
  else {
    document.getElementById(id2).style.display = 'none'; 
  }
}
