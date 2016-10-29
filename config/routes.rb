Rails.application.routes.draw do
  # get '/:locale' => 'welcome#index'
  # get 'change_locale' => 'application#setup_locale'

  root 'welcome#index'

  match 'change_locale/:new_locale' => 'welcome#set_locale', :via => [:put, :patch], :as => :locale,  :constraints => { :new_locale => I18n.available_locales.join('|') }

  scope '(/:locale)', :constraints => { :locale => I18n.available_locales.join('|') } do
    get 'stillage_pallet/index'
    get 'stillage_pallet/show'

    get 'stillage_warehouse/index'
    get 'stillage_warehouse/show'

    get 'stillage/index'
    get 'stillage/show'

    get 'welcome/index'

    get 'trolleys/index'
    get 'trolleys/show'

    get 'mezzanine/index'

    get 'gallery/index'

    get 'contact/index'

    get 'admin_panel/index'

    resources :admin_panel do
      get :change_diller, on: :member
      get :change_admin, on: :member
    end



    #get 'constants/:id/edit' => 'material_path'
    resources :constants
    devise_for :users, controllers: {registrations: 'registrations' }

  end
  post 'constants/load_constant' => 'constants#load_constant'

end
