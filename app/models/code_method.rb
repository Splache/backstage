class CodeMethod < ActiveRecord::Base
  belongs_to :code_file
	
	def self.extract_from_file(code_file_id)
	  code_file = CodeFile.first(:conditions => { :id => code_file_id })
	  
	  is_private = false
	  
	  if code_file and File.file?(code_file.full_path_with_root)
	    File.open(code_file.full_path_with_root, "r") do |f|
        while (line = f.gets)
          if line_declare_new_method?(line)
            create_method_from_line(line, code_file_id, is_private)
          elsif line_start_private_block?(line)
            is_private = true
          end
        end
      end
    end
  end
  
  def self.create_method_from_line(line, code_file_id, is_private=false)
    line = line.strip.gsub('def ', '')
    
    cm = CodeMethod.new
    cm.code_file_id = code_file_id
    cm.nature = line.include?('self.') ? 'class' : 'instance'
    cm.is_private = is_private
    
    name, parameters = line.gsub('self.', '').split('(')
    
    cm.name = name
    cm.parameters = parse_raw_parameters(parameters.gsub(')', '')) if parameters
    
    return false if ['initialize', 'method_missing'].include?(name)
    
    cm.save
  end
  
  def self.get_natures
    natures = []
    natures << ['Classe', 'class']
    natures << ['Instance', 'instance']
    
    return natures
  end
  
  def self.parse_raw_parameters(raw)
    raw_parameters = raw.split(',')
    
    parameters = []
    
    raw_parameters.each do |raw_parameter|
      raw_parameter.strip!
      name, default = raw_parameter.split('=')
      
      parameter = {'name' => name, 'default' => default, 'description' => ''}
      
      parameters << parameter
    end
    
    return parameters.to_yaml
  end
  
  def self.line_declare_new_method?(line)
    return line.include?('def ')
  end
  
  def self.line_start_private_block?(line)
    return line.include?('private')
  end
  
  def name_with_file(full_path=false)
    return (full_path ? self.code_file.full_path : self.code_file.name) + '#' + self.name
  end
end