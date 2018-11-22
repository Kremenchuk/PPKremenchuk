Rails.application.routes.draw do
  # get '/:locale' => 'welcome#index'
  # get 'change_locale' => 'application#setup_locale'

  root 'welcome#index'

  match 'change_locale/:new_locale' => 'application#set_locale', :via => [:put, :patch], :as => :locale,  :constraints => { :new_locale => I18n.available_locales.join('|') }

  scope '(/:locale)', :constraints => { :locale => I18n.available_locales.join('|') } do
    get 'stillage_pallet' => 'stillage_pallet#index', as: 'stillage_pallet_index'
    get 'stillage_pallet/show'

    get 'stillage_warehouse' => 'stillage_warehouse#index', as: 'stillage_warehouse_index'
    get 'stillage_warehouse/show'

    get 'stillage' => 'stillage#index', as: 'stillage_index'
    get 'stillage/show'

    get 'welcome' => 'welcome#index', as: 'welcome_index'

    get 'trolley' => 'trolley#index', as: 'trolley_index'
    get 'trolley/show'

    get 'mezzanine' => 'mezzanine#index', as: 'mezzanine_index'

    get 'gallery' => 'gallery#index', as: 'gallery_index'

    get 'contact' => 'contact#index', as: 'contact_index'

    get 'admin_panel' => 'admin_panel#index', as: 'admin_panel_index'

    get 'contacts_index' => 'admin_panel#contacts_index', as: 'contacts_index'
    post 'contacts_new' => 'admin_panel#contacts_new', as: 'contacts_new'
    put 'contacts_update' => 'admin_panel#contacts_update', as: 'contacts_update'
    delete 'contact_destroy' => 'admin_panel#contact_destroy', as: 'contact_destroy'

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
