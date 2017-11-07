//= require vendor/modernizr-2.7.1.min
//= require _twitter

window.App = window.App || {};
window.App.init = function() {
  window.App.initializeTwitter();
};

document.addEventListener('DOMContentLoaded', window.App.init)
