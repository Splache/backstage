Backstage::Application.routes.draw do
  root :to => "sessions#new"

  resources :projects do
    resources :code_files do
      resources :code_methods do
        post :generate, :on => :collection
      end
    end
    resources :code_methods
    resources :documents
    resources :tasks do
      resources :comments
    end
  end

  resources :code_files
  resources :code_methods
  get 'projects/:project_id/documents/folder/:folder_name.:format' => "documents#index", :as => :documents_folder
  resources :documents

  resources :tasks
  resources :comments


  resources :sessions
  resources :users do
    resources :activity_reports
  end

  get 'logout', :to => 'sessions#destroy'
end
