Rails.application.routes.draw do
  get 'direct_uploads/create'
  resources :likes
  resources :follows
  resources :cocktails
  resources :categories

  get "users/:id", to: "users#show"
  get "/users", to: "users#index"
  post "/login", to: "users#login"
  post "/signup", to: "users#signup"
  get "/me", to: "users#me"
  patch "/me", to: "users#update"
  
  patch 'image/:id', to: 'images#update'
  post 'rails/active_storage/direct_uploads', to: 'direct_uploads#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
