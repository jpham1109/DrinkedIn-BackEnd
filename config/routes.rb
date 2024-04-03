# frozen_string_literal: true

Rails.application.routes.draw do
  resources :follows
  resources :favorites
  resources :workplaces
  resources :likes
  resources :categories
  resources :bars

  get 'direct_uploads/create'

  get '/users/:id', to: 'users#show'
  get '/users', to: 'users#index'
  post '/login', to: 'sessions#create'
  post '/signup', to: 'users#signup'
  get '/me', to: 'sessions#show'
  patch '/me', to: 'users#update'
  delete '/me', to: 'users#destroy'

  get '/cocktails', to: 'cocktails#index'
  get '/cocktails/:id', to: 'cocktails#show'
  post '/cocktails', to: 'cocktails#create'
  patch '/cocktails/:id', to: 'cocktails#update'
  delete '/cocktails/:id', to: 'cocktails#destroy'

  patch 'image/:id', to: 'images#update'
  patch 'avatar/:id', to: 'images#user'
  # post 'rails/active_storage/direct_uploads', to: 'direct_uploads#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
