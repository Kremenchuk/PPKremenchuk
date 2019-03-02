Rails.application.routes.draw do


  # get '/:locale' => 'welcome#index'
  # get 'change_locale' => 'application#setup_locale'

  root 'welcome#index'

  match 'change_locale/:new_locale' => 'application#set_locale', :via => [:put, :patch], :as => :locale,  :constraints => { :new_locale => I18n.available_locales.join('|') }

  scope '(/:locale)', :constraints => { :locale => I18n.available_locales.join('|') } do
    get 'stillage_pallet' => 'stillage_pallet#index', as: 'stillage_pallet_index'
    get 'calculate_actual_price_stillage_pallet' => 'stillage_pallet#calculate_actual_price', as: 'calculate_actual_price_stillage_pallet'

    get 'stillage_warehouse' => 'stillage_warehouse#index', as: 'stillage_warehouse_index'
    get 'calculate_actual_price_stillage_warehouse' => 'stillage_warehouse#calculate_actual_price', as: 'calculate_actual_price_stillage_warehouse'

    get 'stillage' => 'stillage#index', as: 'stillage_index'
    get 'calculate_actual_price_stillage' => 'stillage#calculate_actual_price', as: 'calculate_actual_price_stillage'

    get 'welcome' => 'welcome#index', as: 'welcome_index'

    get 'trolley' => 'trolley#index', as: 'trolley_index'
    get 'trolley/show'

    get 'mezzanine' => 'mezzanine#index', as: 'mezzanine_index'

    get 'galleries' => 'galleries#index', as: 'gallery_index'

    get 'contact' => 'contact#index', as: 'contact_index'

    get 'admin_panel' => 'admin_panel#index', as: 'admin_panel_index'

    get 'contacts_index' => 'admin_panel#contacts_index', as: 'contacts_index'
    post 'contacts_new' => 'admin_panel#contacts_new', as: 'contacts_new'
    put 'contacts_update' => 'admin_panel#contacts_update', as: 'contacts_update'
    delete 'contact_destroy' => 'admin_panel#contact_destroy', as: 'contact_destroy'

    get 'photo_browser_index' => 'galleries#photo_browser_index', as: 'photo_browser_index'
    post 'photo_browser_new' => 'galleries#photo_browser_new', as: 'photo_browser_new'
    delete 'photo_browser_destroy' => 'galleries#photo_browser_destroy', as: 'photo_browser_destroy'

    get 'news_admin_index' => 'news#news_admin_index', as: 'news_admin_index'

    get 'about_us' => 'welcome#about_us', as: 'about_us'


    get 'articles_admin_index' => 'article#articles_admin_index', as: 'articles_admin_index'
    post 'article_new' => 'article#article_new', as: 'article_new'
    delete 'article_delete' => 'article#article_delete', as: 'article_delete'
    post 'image_to_article' => 'article#image_to_article', as: 'image_to_article'


    resources :news

    resources :admin_panel do
      get :change_diller, on: :member
      get :change_admin, on: :member
    end



    #get 'constants/:id/edit' => 'material_path'
    resources :constants
    devise_for :users, controllers: {registrations: 'registrations' }
    resources :galleries
    resources :article
  end
  post 'constants/load_constant' => 'constants#load_constant'

end
