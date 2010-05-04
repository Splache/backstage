ActionController::Routing::Routes.draw do |map|
  map.root :controller => :sessions, :action => :new
  
  map.resources :code_files do |cf|
    cf.resources :code_methods, :collection => {:generate => :post}
  end
  map.resources :code_methods
  
  map.resources :comments
  
  map.documents_folder 'documents/folder/:folder_name.:format', :controller => 'documents', :action => 'index'
  map.resources :documents
  
  map.resources :projects
  map.resources :sessions
  map.resources :users
  
  map.resources :tasks
end
