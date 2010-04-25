class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_project, :current_user
  protect_from_forgery
  
  def current_project
    session[:current_project] = Project.first.id if not session[:current_project]
      
    return Project.first(:conditions => { :id => session[:current_project] })
  end
  
  def current_user
    if session[:current_user]
      return User.first(:conditions => { :id => session[:current_user] })
    else
      return nil
    end
  end
  
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
end
