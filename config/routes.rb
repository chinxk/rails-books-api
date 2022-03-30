Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      resources :books do
        get :by_isbn, on: :collection
        get :init, on: :collection
      end

      resources :users do
        post :storage, on: :collection
      end
    end
  end

end
