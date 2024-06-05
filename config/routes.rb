Rails.application.routes.draw do
  devise_for :users
  
  root to: 'homes#index'
  resources :users
  resources :shops do
    collection do
      get 'search'
    end
    resources :reviews do
      resource :nice, only: [:create, :destroy]
    end
    resource :like, only: [:create, :destroy]
  end
  resources :contacts, only: [:new, :create] do
    collection do
      post 'confirm'
      post 'back'
      get 'done'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
