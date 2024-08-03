Rails.application.routes.draw do
  
  resources :sessions,    :only => [:index, :create, :destroy]
  resources :users,       :only => [:index, :show, :create, :update, :destroy] do
    resources :followers, :only => [:index, :create, :destroy]
  end
  resources :posts,       :only => [:index, :show, :create, :destroy] do
    resources :likes,     :only => [:index, :create, :destroy]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
