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
    return '</div>'.html_safe
  end
  
  def combo_box(id, label, values, options={})
    options.reverse_merge!(:label_clickable => true)
    
    field = select_tag("#{@form_id}[#{id}]", options_for_select(values, :selected => @record[id.to_sym]), :class => 'custom-combo', :id => "#{@form_id}-#{id}")
    
    return wrap_it(id, label, 'combo', field, options)
  end
  
  def label_iconified(id, text, clickable=true)
    css_class = clickable ? 'clickable' : nil
    
    return content_tag(:label, "<span class=\"ico ico-#{id}\">&nbsp;</span>#{text}".html_safe, :class => css_class)
  end
  
  def hidden(id, value)
    return hidden_field_tag("#{@form_id}[#{id}]", value)
  end
  
  def open_form(id)
    id = 'id="' + id + '"' if id
    return ('<div class="form-candy" ' + id + '>').html_safe
  end
  
  def text_field(id, label)
    field = text_field_tag("#{@form_id}[#{id}]", @record[id], :id => "#{@form_id}-#{id}")
    
    return wrap_it(id, label, 'input', field)
  end
  
  def wrap_it(id, label, nature, field=nil, options={})
    options.reverse_merge!(:label_clickable => true)
    
    content = []

    content << '<div class="' + base_css_class(id, nature) + '">'
    content << label_iconified(id, label, options[:label_clickable])
    content << field
    content << '</div>'
    
    return content.join.html_safe
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