Onoff::Application.routes.draw do

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, :at => '/'
          # The priority is based upon order of creation:
  # first created -> highest priority.
  resource :tags, only: [] do
    get :search_product_tags
    get :filter
  end

  Spree::Core::Engine.routes.prepend do
    get '/admin/products/import_products', :to => 'admin/products#new_products', :as => :new_products
    post '/admin/products/import_products', :to => 'admin/products#import_products', :as => :import_products
    get '/admin/products/:product_id/edit_images', :to => 'admin/products#edit_images', :as => :edit_images_admin_product
    put '/admin/products/:product_id/update_images', :to => 'admin/products#update_images', :as => :update_images_admin_product
    post '/admin/products/:product_id/create_image', :to => 'admin/products#create_image', :as => :create_image_admin_product
    put '/admin/products/:product_id/add_color', :to => 'admin/products#add_color', :as => :add_color_admin_product
    get '/admin/general_settings/homepage', :to => 'admin/general_settings#homepage_slideshow', :as => :list_admin_homepage_slideshow
    get '/admin/general_settings/edit_homepage', :to => 'admin/general_settings#edit_homepage_slideshow', :as => :edit_admin_homepage_slideshow
    post '/admin/general_settings/create_slide', :to => 'admin/general_settings#create_slide', :as => :create_homepage_slides
    post '/admin/general_settings/update_homepage', :to => 'admin/general_settings#update_homepage_slideshow', :as => :update_admin_homepage_slideshow
  end

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
