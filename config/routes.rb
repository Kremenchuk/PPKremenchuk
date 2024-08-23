Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"



  # get '/:locale' => 'welcome#index'
  # get 'change_locale' => 'application#setup_locale'

  root 'welcome#index'

  get '/change_locale/:new_locale', to: 'application#set_locale', as: 'locale', constraints: lambda { |req| I18n.available_locales.include? req['locale'].to_sym }

  resources :users
  resources :admin_contacts
  resources :app_requests, only: [:index]

  post 'constants/load_constant' => 'constants#load_constant'
  get 'sitemap' => 'welcome#site_map'

  scope '/:locale', constraints: lambda { |req| I18n.available_locales.include? req['locale'].to_sym } do
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

    get 'platform' => 'platform#index', as: 'platform_index'

    get 'galleries' => 'galleries#index', as: 'gallery_index'
    get :galleries_view_photo, controller: :galleries, action: :galleries_view_photo
    get :galleries_previous_view_photo, controller: :galleries, action: :galleries_previous_view_photo
    get :galleries_next_view_photo, controller: :galleries, action: :galleries_next_view_photo
    get :gallery_view_photo_close, controller: :galleries, action: :gallery_view_photo_close

    get 'contact' => 'contact#index', as: 'contact_index'

    get 'admin_panel' => 'admin_panel#index', as: 'admin_panel_index'



    # contacts
    get 'contacts_index' => 'admin_panel#contacts_index', as: 'contacts_index'
    post 'contacts_new' => 'admin_panel#contacts_new', as: 'contacts_new'
    put 'contacts_update' => 'admin_panel#contacts_update', as: 'contacts_update'
    delete 'contact_destroy' => 'admin_panel#contact_destroy', as: 'contact_destroy'

    get 'photo_browser_index' => 'galleries#photo_browser_index', as: 'photo_browser_index'
    post 'photo_browser_new' => 'galleries#photo_browser_new', as: 'photo_browser_new'
    delete 'photo_browser_destroy' => 'galleries#photo_browser_destroy', as: 'photo_browser_destroy'

    get 'news_admin_index' => 'news#news_admin_index', as: 'news_admin_index'

    get 'about_us' => 'welcome#about_us', as: 'about_us'

    namespace :admin do
      resources :articles
      post :image_to_article, controller: :articles
      delete 'image_delete/:id'=> 'articles#image_delete', as: 'image_delete'
    end

    resources :news
    #get 'constants/:id/edit' => 'material_path'
    resources :constants
    devise_for :users, controllers: {registrations: 'registrations' }
    resources :galleries
    resources :articles
    resources :lofts
    get 'sitemap' => 'welcome#site_map'
  end

end
