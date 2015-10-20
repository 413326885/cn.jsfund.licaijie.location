var TXLocation = function() {

};

TXLocation.prototype.init = function(key, successFn, failFn) {
  cordova.exec(successFn, failFn, 'Location', 'init', [key]);
};

TXLocation.install = function() {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.location = new TXLocation();
  return window.plugins.location;
}

cordova.addConstructor(TXLocation.install);
