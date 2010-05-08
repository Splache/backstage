module ApplicationHelper
  
  def htmlize(text)
    text = textilize(text)
    text = link_to_internal(text, 'code_file')
    text = link_to_internal(text, 'code_method')
    
    return text
  end
  
  def icon(name, options={})
    options.reverse_merge!(:id => nil)
    
    return content_tag(:span, '&nbsp;', :class => "ico ico-#{name}", :id => options[:id])
    #return '<span class="ico ico-' + name + '">&nbsp;</span>'
  end
  
  def in_section?(name)
    case name
      when 'code' then return (@code_files or @code_file) ? true : false
      when 'documents' then return (@documents or @document) ? true : false
      when 'tasks' then return (@tasks or @task) ? true : false
    end
  end
  
  def link_icon_to(name, path, options={}, html_options=nil)
    if options[:icon]
      name = icon(options[:icon]) + name
      options[:icon] = nil
    end
    
    return link_to(name, path, options, html_options)
  end
  
  def link_to_internal(text, model)
    ["link_#{model}_name_pl", "link_#{model}_name", "link_#{model}"].each do |nature_link|
      if text.include?("[#{nature_link}_")
        new_text = []
        parts = text.split("[#{nature_link}_")
        parts.each do |part|
          appended = false
          if part.include?(']') and part.index(']') < 6
            file_id, part_content = part.split(']',2)
          
            if file_id.to_i > 0
              record = model.camelize.constantize.first(:conditions => { :id => file_id.to_i })
            
              if record
                case nature_link
                  when 'link_code_file' then new_text << link_to(record.full_path, code_file_path(record))
                  when 'link_code_file_name' then new_text << link_to(record.name_without_extension, code_file_path(record))
                  when 'link_code_file_name_pl' then new_text << link_to(record.name_without_extension(true), code_file_path(record))
                  when 'link_code_method' then new_text << link_to(record.name_with_file(true), code_file_path(record.code_file, :anchor => "m#{record.id}"))
                  when 'link_code_method_name' then new_text << link_to(record.name_with_file(true), code_file_path(record.code_file, :anchor => "m#{record.id}"))
                end
                new_text << part_content
                appended = true
              end
            end
          end
        
          new_text << part if not appended
        end
      
        text = new_text.join
      end
    end
    
    return text
  end
  
  def menu_files_item_is_visible?(code_file, current_file)
    return false unless code_file
    
    if code_file.path.include?(current_file.path) or code_file.full_path == current_file.path
      return true
    end
    
    return false
  end
  
  def show_menu_code(code_file=nil)
    content = []
    
    files = current_project.code_files_tree
    
    if not files.empty?
      content << '<ul class="tree">'
      files.each do |f|
        css_class = []
        css_class << 'level' + f.full_path.split('/').length.to_s
        css_class << 'undefined' if f.description.empty? and not f.is_directory?
        css_class << 'show' if menu_files_item_is_visible?(code_file, f)
        
        content << '<li class="' + css_class.join(' ') + '">'
        content << link_icon_to(f.name, code_file_path(f), :icon => (f.is_directory? ? 'folder' : 'file'))
        content << '</li>'
      end
      content << '</ul>'
    end
    
    return content.join
  end
  
  def show_menu_documents(document_selected=nil)
    content = []
    
    documents = current_project.documents
    
    last_path = ''
    
    if not documents.empty?
      content << '<ul class="tree">'
      documents.each do |doc|
        if not doc.path.to_s.empty? and doc.path != last_path
          content << '<li class="level1">' + link_icon_to(doc.path, documents_folder_path(:folder_name => doc.path.parameterize), :icon => 'folder') + '</li>'
          last_path = doc.path
        end
        
        css_class = []
        css_class << 'level' + (doc.path.to_s.empty? ? '1' : '2')
        css_class << 'show' if params[:folder_name] == doc.path.parameterize or (document_selected and document_selected.path == doc.path)
        
        content << '<li class="' + css_class.join(' ') + '">' 
        if not doc.url.to_s.empty? and doc.description.empty?
          content << link_icon_to(doc.name, doc.url, :icon => 'file')
        else
          content << link_icon_to(doc.name, document_path(doc), :icon => 'file')
        end
        content << link_icon_to('Modifier', edit_document_path(doc), :icon => 'edit', :class => 'operation')
        content << link_icon_to('Supprimer', document_path(doc), :icon => 'delete', :class => 'operation', :method => :delete, :confirm => 'Êtes-vous sur de vouloir détruire ce document ?')
        content << '</li>'
      end
      content << '</ul>'
    end
    
    return content.join
  end
  
  def show_relationships(code_file)
    relations = code_file.relations
    content = []
    
    if relations.empty?
      content << '<p>Aucune relations</p>'
    else
      content << '<ul class="relationships">'
      relations.each do |relation|
        content << '<li>'
        content << '<span class="nature">' + relation[:nature] + '</span> '
        if relation[:code_file]
          content << link_to(relation[:model_name], code_file_path(relation[:code_file])) 
        else
          content << '<span class="model_name">' + relation[:model_name] + '</span> '
        end
        content << '</li>'
      end
      content << '</ul>'
    end
    
    return content.join
  end
end
