# frozen_string_literal: true

Rails.application.routes.draw do
  # ai/v1-redesign-plan.md's privacy-first-user-discovery workstream
  # (2026-11-23), Step 3 — GET /follows (index) and GET /follows/:id
  # (show) removed entirely, not gated: verified zero consumers in
  # either repo (frontend's followsSlice.js only ever defined
  # addNewFollow/deleteFollow; follows_spec.rb never tested a GET on
  # either route), so the unscoped social-graph read they exposed is
  # closed by removing the surface, not restricting it.
  resources :follows, only: %i[create destroy]
  resources :favorites
  resources :workplaces
  resources :likes
  resources :categories
  resources :bars

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
  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — the only two places published_at is ever written;
  # never accepted as an ordinary update param (see
  # CocktailsController#cocktail_params).
  post '/cocktails/:id/publish', to: 'cocktails#publish'
  post '/cocktails/:id/unpublish', to: 'cocktails#unpublish'

  # ai/v1-redesign-plan.md's publication-lifecycle workstream
  # (2026-11-18) — the only HTTP surfaces that can ever produce a link
  # to an attached image's actual bytes, now that
  # config.active_storage.draw_routes is false (config/application.rb).
  # Fixed, named routes only — never a client-controlled transformation
  # parameter.
  get '/cocktails/:id/image', to: 'cocktails/images#show', as: :cocktail_image
  get '/cocktails/:id/image/original', to: 'cocktails/images#original', as: :cocktail_image_original
  get '/users/:id/avatar', to: 'users/avatars#show', as: :user_avatar
  get '/users/:id/avatar/original', to: 'users/avatars#original', as: :user_avatar_original

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
