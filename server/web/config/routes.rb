Inquisitor::Application.routes.draw do
#  map.connect ':controller/service.wsdl', :action => 'wsdl'

  resources :computers do
    member do
      post :update_profile
      get :sticker, :log, :mark, :graph, :ssh, :comment_history, :audit
    end
  end
  get 'computers/hw/:id', :to => 'computers#hw'

  resources :shelves do
    member do
      get :active_addresses
    end
  end

  resources :orders do
    collection do
      get :testings, :staging, :search
      get :auto_complete_for_order_customer
      get :auto_complete_for_order_manager
    end
    member do
      post :handle_computers
    end
  end

  resources :models do
    collection do
      get :long_list, :list
    end
  end

  resources :profiles
  resources :firmwares
  resources :people

  resources :account do
    collection do
      match :login, via: [:post, :get]
      get :logout
    end
  end

  resources :statistics do
    collection do
      get :rma, :assembly, :order_stages
    end
  end
end
