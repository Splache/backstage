class CodeFile < ActiveRecord::Base
  belongs_to :project
	has_many :code_methods, :order => "nature ASC, name ASC", :dependent => :destroy
	
	def full_path
	  return [self.path, self.name].delete_if{|f| f.empty? }.join('/')
  end
  
  def full_path_with_root
    [self.project.root, self.full_path].join('/')
  end
  
  def is_directory?
    return (not File.file?(self.full_path_with_root))
  end
  
  def is_ruby_file?
    return (File.extname(self.name) == '.rb')
  end
  
  def name_without_extension(pluralize=false)
    name_formatted = name.include?('.') ? name[0,name.index('.')] : name
    
    name_formatted = name_formatted.pluralize if pluralize
    
    return name_formatted
  end
  
  def relations
    all_relations = []
    if File.file?(full_path_with_root)
      File.open(full_path_with_root, "r") do |f|
        while (line = f.gets)
          all_relations << parse_relation_from_line(line) if line_declare_relationship?(line)
        end
      end
    end
    
    return all_relations
  end
  
  def line_declare_relationship?(line)
    return (line.include?('belongs_to ') or line.include?('has_many '))
  end
  
  def parse_relation_from_line(line)
    relation = { :nature => 'belongs_to', :model_name => '', :code_file => nil }
    
    definition, params = line.split(',',2)
    
    if definition.include?('belongs_to')
      definition.gsub!('belongs_to', '')
    else
      definition.gsub!('has_many', '')
      relation[:nature] = 'has_many'
    end
    definition.gsub!(':', '')
    definition.strip!
    
    relation[:model_name] = definition
    
    file = CodeFile.first(:conditions => { :path => 'app/models', :name => definition.singularize + '.rb' })
    relation[:code_file] = file if file
    
    return relation
  end
  
end