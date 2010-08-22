class Elements::FormCandy
  #*************************************************************************************
  # CONSTRUCTOR
  #*************************************************************************************
  def initialize(core, form_id, record)
    @core = core
    @form_id = form_id
    @record = record
  end
    
  #*************************************************************************************
  # PUBLIC METHODS
  #*************************************************************************************   
  def checkbox(id, label)
    field = hidden(id, '1')
    return wrap_it(id, label, 'check', field)
  end
  
  def close_form
    return '</div>'
  end
  
  def combo_box(id, label, values)
    field = select_tag("#{@form_id}[#{id}]", options_for_select(values, :selected => @record[id]), :class => 'custom-combo', :id => "#{@form_id}-#{id}")
    
    return wrap_it(id, label, 'combo', field)
  end
  
  def label_iconified(id, text)
    return '<label><span class="ico ico-' + id + '">&nbsp;</span>' + text + '</label>'
  end
  
  def hidden(id, value)
    return hidden_field_tag("#{@form_id}[#{id}]", value)
  end
  
  def open_form(id)
    id = 'id="' + id + '"' if id
    return '<div class="form-candy" ' + id + '>'
  end
  
  def text_field(id, label)
    field = text_field_tag("#{@form_id}[#{id}]", @record[id], :id => "#{@form_id}-#{id}")
    
    return wrap_it(id, label, 'input', field)
  end
  
  def wrap_it(id, label, nature, field=nil)
    content = []

    content << '<div class="' + base_css_class(id, nature) + '">'
    content << label_iconified(id, label)
    content << field
    content << '</div>'
    
    return content.join
  end
  
  private
  
  #*************************************************************************************
  # PRIVATE METHODS
  #*************************************************************************************
  
  def base_css_class(id, nature)
    css_class = [@form_id, "#{@form_id}-#{nature}", id]
    css_class << 'active' if @record[id.to_sym]
    
    return css_class.join(' ')
  end
  
  def method_missing(*args, &block) return @core.send(*args, &block) end
end