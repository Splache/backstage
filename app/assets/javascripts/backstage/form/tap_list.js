BACKSTAGE.Form.TapList = function(){
  var attach_events, list_type;

  this.initialize = function(list){
    attach_events(list);
  };

  attach_events = function(list){
    list.find('li').click(function(){ click_item($j(this)) });
  };

  click_item = function(item){
    if(list_type(item) == 'radio'){
      click_item_radio(item);
    }else{
      click_item_check(item);
    }
  };

  click_item_check = function(item){
    var selected = item.hasClass('selected');

    if(selected){
      item.removeClass('selected');
      item.find('input.item-state').val('0');
    }else{
      item.addClass('selected');
      item.find('input.item-state').val('1');
    }
  };

  click_item_radio = function(item){
    var list = item.closest('ul.tap-list'),
        selected = item.hasClass('selected');

    if(!selected){
      list.find('li').removeClass('selected');
      list.find('input.list-value').val(item.find('input.item-state').val());
      item.addClass('selected');
    }
  };

  list_type = function(item){
    if(item.closest('ul.tap-list').hasClass('radio')){
      return 'radio';
    }else{
      return 'check';
    }
  };
};
