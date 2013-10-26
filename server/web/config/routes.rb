Inquisitor::Application.routes.draw do
#  map.connect ':controller/service.wsdl', :action => 'wsdl'

  resources :computers do
    member do
      post :update_profile
      get :sticker, :log, :mark, :graph, :ssh, :comment_history, :audit
      get :comment_history, :comment_edit
      post :comment_update
    end
  end
  get 'computers/hw/:id', :to => 'computers#hw'

  # External API used by client for reporting
  post 'computers/advance/:id', :to => 'computers#advance'
  post 'computers/submit_components/:id', :to => 'computers#submit_components'
  post 'computers/submit_additional_components/:id', :to => 'computers#submit_additional_components'
  post 'computers/boot_from_image/:id', :to => 'computers#boot_from_image'
  post 'computers/monitoring_submit/:id', :to => 'computers#monitoring_submit'
  get 'computers/get_needed_firmwares_list/:id', :to => 'computers#get_needed_firmwares_list'
  get 'computers/plan/:id', :to => 'computers#plan'
  post 'computers/set_checker/:id', :to => 'computers#set_checker'

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
      post :create_computers
    end
  end

  resources :models do
    collection do
      get :long_list, :list
    end
  end

  resources :component_models do
    member do
      get :short_name
      post :set_short_name
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
