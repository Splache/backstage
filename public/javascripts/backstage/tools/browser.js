BACKSTAGE.Tools.Browser = function(){
  var pub = {};
  
  pub.fit_in_window = function(dimensions, scale){
    var ratio = {greater: 0, h: 0, w: 0},
        window_dimensions = {h: $j(window).height(), w: $j(window).width()};
    
    if(!scale){ scale = 1; }
      
    if(dimensions.h > (window_dimensions.h * scale) || dimensions.w > (window_dimensions.w * scale)){
      ratio.h = dimensions.h / window_dimensions.h;
      ratio.w = dimensions.w / window_dimensions.w;
        
      ratio.greater = (ratio.h > ratio.w) ? ratio.h : ratio.w;
        
      dimensions.h = Math.floor((dimensions.h / ratio.greater) * scale);
      dimensions.w = Math.floor((dimensions.w / ratio.greater) * scale);
    }
    
    return dimensions;
  };
  
  pub.pop_window = function(options){
    var win;
    
    options = BACKSTAGE.merge_hash(options, {height: 300, url: '#', width: 300});
    
    if(options.fullscreen){
      options.width = window.top.screen.width - 10;
      options.height = window.top.screen.height - 75;
    }
    
    win = window.open(options.url, '', 'width=' + options.width + ',height=' + options.height + ',menubar=no,scrollbars=yes,toolbar=no,location=no,directories=no,resizable=yes,status=no');
    
    if(win && win.focus){ win.focus(); }
  };
  
  return pub;
};
BACKSTAGE.Tools.Browser = BACKSTAGE.Tools.Browser();