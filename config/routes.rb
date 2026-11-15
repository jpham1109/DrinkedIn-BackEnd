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
  delete '/logout', to: 'sessions#destroy'

  get '/csrf_token', to: 'csrf_tokens#show'

  # Render's healthCheckPath (render.yaml) — Rails 7.1+ ships a built-in
  # `get "up"` route for this; this app is pinned to '~> 7.0.0' (Gemfile),
  # so it doesn't exist yet. Minimal controller, see health_controller.rb.
  get '/up', to: 'health#show'

  # Test-only: establishes a real, correctly-signed session cookie via the
  # actual session middleware, for specs that need a session-authenticated
  # request before SessionsController#create itself establishes sessions
  # (see ai/auth-migration-plan.md PR 2). Not routed outside test env.
  post '/test_support/session', to: 'test_support/sessions#create' if Rails.env.test?

  get '/cocktails', to: 'cocktails#index'
  get '/cocktails/:id', to: 'cocktails#show'
  post '/cocktails', to: 'cocktails#create'
  patch '/cocktails/:id', to: 'cocktails#update'
  delete '/cocktails/:id', to: 'cocktails#destroy'

  # post 'rails/active_storage/direct_uploads', to: 'direct_uploads#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
