class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_project, :current_user, :dpath
  protect_from_forgery
  
  def authenticated?
    authenticate!
    
    if current_user
      return true
    else
      redirect_to root_path
    end
  end
  
  def authenticate!
    if not current_user
      if params[:login] and params[:password]
        session[:current_user] = User.authenticate(params[:login], params[:password])
      elsif cookies[:remember_me]
        session[:current_user] = User.authenticate_with_remember_me_key(cookies[:remember_me])
      end
      
      if session[:current_user] and params[:remember_me] == '1'
        cookies[:remember_me] = {:value => User.generate_remember_me_key(session[:current_user]), :expires => 30.days.from_now} 
      end
    end
  end
  
  def current_project
    project ||= Project.first(:conditions => { :id => params[:project_id] })
    
    return project
  end
  
  def current_user
    if session[:current_user]
      return User.first(:conditions => { :id => session[:current_user] })
    else
      return nil
    end
  end
  
  def admin_path(path, options={})    
    path_parts = [:admin]
    
    if current.organisation and (current.organisation.id != current.user.organisation_id)
      if path != 'organisation'
        path_parts << :organisation      
        options[:organisation_id] = current.organisation.id_external
      elsif not options[:id]
        options[:id] = current.organisation.id_external
      else
        options[:id] = Organisation.find_by_id_external(options[:id]).id_external
      end
    elsif current.organisation and path == 'organisation'
      options[:id] = current.organisation.id_external if not options[:id]
    end

    path_parts += path.split('.')
    
    path_parts.each do |path_part|
      if path_part == 'publication' and options[:action].to_s != 'new' 
        if path_part == path_parts.last
          options[:id] = current.publication.id if not options[:id]
        else
          options[:publication_id] = current.publication.id if not options[:publication_id]
        end
      end
    end
    
    return polymorphic_path(path_parts, options)
  end
  
  def dpath(path, options={})
    path_parts = []
    
    path_parts += path.split('.')
    
    path_parts.each do |path_part|
      if path_part != path_parts.last
        if not options["#{path_part.singularize}_id"]
          options["#{path_part.singularize}_id"] = params["#{path_part.singularize}_id"] if params["#{path_part.singularize}_id"]
        end
      end
    end

    return polymorphic_path(path_parts, options)
  end
  
  def dredirect_to(path, options={})
    redirect_to dpath(path, options)
  end
end
