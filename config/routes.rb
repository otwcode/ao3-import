Ao3Import::Application.routes.draw do
  namespace :api do
    resources :imports, only: [ :create ]
  end
end
