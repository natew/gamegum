Gamegum::Application.routes.draw do
  # Root
  root :to => 'main#index'

  # Categories
  match 'games/category/:category', :to => 'games#category', :as => 'category'

  # Tags
  match 'games/tag/:tag', :to => 'games#tag', :as => 'tag'

  # Feed
  match 'games/feed', :to => 'games#feed'

  # Games
  resources :games, :id => /[0-9]+\/.+/ do
    resources :comments
    collection do
      get :viewed
      get :rated
      get :discussed
      get :favorites
      get :rate
      get :featured
      get :pages
      get :live
      get :tags
      get :adult
      get :teen
      get :everyone
    end
  end

  # Users
  resources :users, :id => /[0-9]+\/.+/ do
    member do
      get :favorites
      get :submissions
      get :friends
    end

    resources :friends

    member do
      put    :suspend
      put    :unsuspend
      delete :purge
    end
  end

  # Messages
  resources :messages do
    collection do
      post :destroy_selected
      get  :inbox
      get  :outbox
      get  :trashbin
    end

    member do
      get :reply
    end
  end

  # Articles
  resources :articles do
    collection do
      get :archive
    end
  end

  # Forums
  match "/topics/:topic/discussions/:id/edit", :to => 'discussions#edit'
  match "/topics/:topic/discussions/:id/:slug", :to => 'discussions#show'
  resources :posts
  resources :topics do
    resources :discussions
  end

  # Sessions
  resource  :session

  # Three special routes to match old ones and prevent from thinking its a :slug
  match "/users/:id/favorites",   :to => 'users#favorites'
  match "/users/:id/submissions", :to => 'users#submissions'
  match "/users/:id/friends",     :to => 'users#friends'
  match "/profile/:id/:slug",     :to => redirect(:status => 302) {|p| "/users/#{p[:id]}/#{p[:slug]}" }
  match "/users/:id/:slug",       :to => 'users#show'
  match "/activate/:id/:key",     :to => 'users#activate'

  match 'logout',   :to => 'sessions#destroy', :as => 'logout'
  match 'login',    :to => 'sessions#create',  :as => 'login'
  match 'register', :to => 'users#new',        :as => 'register'
  match 'forgot',   :to => 'sessions#forgot',  :as => 'forgot'
  match 'submit',   :to => 'games#new',        :as => 'submit'
  match 'rules',    :to => 'main#rules'
  match 'pulse',	:to => 'main#pulse'
  match 'play/:slug',     :to => 'pages#show',       :as => 'play'

  # Not Found
  match '/not_found',     :to => 'application#not_found'

  # Default
  # match ':controller(/:action(/:id(.:format)))'

end
