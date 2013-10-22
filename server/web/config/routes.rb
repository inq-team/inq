Inquisitor::Application.routes.draw do
#  map.connect ':controller/service.wsdl', :action => 'wsdl'

  get 'computer/:action/:id/:testing', :to => 'computer'

#  resources :orders do
#    collection do
#      get :testings, :staging
#    end
#    singular 'order'
#  end

  resources :computers
end
