Rails.application.routes.draw do
  # for automatically generated Minitest classes
  get 'pois/museums', to: 'api/v1/pois#museums'

  namespace :api do
    namespace :v1 do
      get 'museums', to: 'pois#museums' # for the proper API use
      get 'restaurants', to: 'pois#restaurants' # for the proper API use
      get 'cinemas', to: 'pois#cinemas' # for the proper API use
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
