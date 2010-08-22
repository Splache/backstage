ActionController::Routing::Routes.draw do |map|
  map.root :controller => :sessions, :action => :new
  
  map.resources :code_files do |cf|
    cf.resources :code_methods, :collection => {:generate => :post}
  end
  map.resources :code_methods
  
  map.documents_folder 'documents/folder/:folder_name.:format', :controller => 'documents', :action => 'index'
  map.resources :documents
  
  map.resources :projects do |project|
    project.resources :tasks do |task|
      task.resources :comments
    end
  end
  map.resources :tasks
  map.resources :comments
  
  
  map.resources :sessions
  map.resources :users
end
