module CodeMethodHelper
  def show_method_name(m)
    content = [m.name]

    if not m.parameters.to_s.empty?
      parameters = []
      YAML.load(m.parameters).each { |p| parameters << p['name'] }

      content << ' (<span class="parameters">'
      content << parameters.join(', ')
      content << '</span>)'
    end

    return content.join
  end

  def show_method_parameters(parameters)
    #YAML.load(parameters).each do |p|
      #raise p.inspect
    #end
  end
end
