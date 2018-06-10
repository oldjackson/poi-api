Rails.application.routes.draw do
  get 'pois/museums', to: 'api/v1/pois#museums' # for automatically generated Mitest classes
  namespace :api do
    namespace :v1 do
      get 'museums', to: 'pois#museums' # for the proper API use
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
