BACKSTAGE.Expositor = function(){
  var align_vertical, attach_events, build, clicked, hide, set_size, show,
      close_callback = null,
      holders = {box: null, content: null, head: null, root: null};

  this.initialize = function(id, size, options){
    options = BACKSTAGE.merge_hash(options, {close_callback: null, fit_to_window: true, scale_ratio: 0.90});

    if(!id){ id = 'expositor'; }

    build(id);
    close_callback = options.close_callback;
    set_size(size, options.fit_to_window, options.scale_ratio);
    attach_events();
  };

  this.update = function(title, new_content){
    show();
    holders.head.find('h2').html(title);
    holders.content.html(new_content);
  };

  align_vertical = function(){
    var box_height = holders.box.css('height').replace('px', ''),
        margin_top = 60,
        scroll_position = $j(window).scrollTop(),
        window_height = $j(window).height();

    margin_top = Math.floor((window_height - box_height) / 2) + scroll_position;

    holders.box.css('margin-top', margin_top + 'px');
  };

  attach_events = function(){ holders.root.click(function(e){ clicked($j(e.target)); }); };

  build = function(id){
    var content = new BACKSTAGE.StringBuilder();

    content.add('<div class="expositor" id="' + id + '" style="height:' + $j(document).height() + 'px;width:' + $j(document).width() + 'px;">');
    content.add('<div class="expositor-box">');
    content.add('<div class="expositor-head"><div class="btn-close">Fermer</div><h2>&nbsp;</h2></div>');
    content.add('<div class="expositor-content"></div>');
    content.add('</div></div>');

    $j('body').append(content.get());

    holders.root = $j('#' + id);
    holders.box = holders.root.find('div.expositor-box:first');
    holders.head = holders.root.find('div.expositor-head:first');
    holders.content = holders.root.find('div.expositor-content:first');
  };

  clicked = function(obj){
    if(obj.closest('div.expositor-content').length === 0){ hide(); }
    if(close_callback) { close_callback(); }
  };

  hide = function(){
    holders.root.hide();
    holders.content.html('');
  };

  set_size = function(box_size, fit_to_window, scale_ratio){
    var window_size = {h: $j(window).height(), w: $j(window).width()};

    box_size = BACKSTAGE.merge_hash(box_size, {h: '60%', w: '60%'});

    jQuery.each(['h', 'w'], function(){
      box_size[this] = String(box_size[this]);
      if(box_size[this].indexOf('%') !== -1){
        box_size[this] = box_size[this].replace('%', '');
        box_size[this] = Math.floor(window_size[this] * (box_size[this]/100));
      }else{
        box_size[this] = box_size[this].replace('px', '');
      }
    });

    if(fit_to_window){
      box_size = BACKSTAGE.Tools.Browser.fit_in_window(box_size, scale_ratio);
    }

    holders.box.height(box_size.h + 'px').width(box_size.w + 'px');

    holders.content.height(box_size.h - holders.head.css('height').replace('px', '') - 10);
  };

  show = function(){
    align_vertical();
    holders.root.show();
  };
};
