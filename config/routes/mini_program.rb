Wp::Application.routes.draw do

  namespace :api do
    namespace :mini_program do
      resources :wx_users do
        get :wx_login, on: :collection
        get :user_info, on: :collection
      end

      resources :sessions

      resources :categories, only: [:index, :show] do
        get :category, :product, :index_products, :search, on: :collection
      end

      resources :articles, only: [:index, :show] do
        get :index_categories, :list_categories, on: :collection
      end

      resources :feedbacks, only: [:create]

      resources :home, only: [] do
        collection do
          get :swip_slides, :banner_slides, :search, :banner_products, :index_products, :cart_num, :get_areas, :logistics, :home_menu, :get_info
          post :add_cart
        end
      end

      resources :items, only: [:index, :show] do
        member do
          get :calc_freight
          post :add_cart, :add_fav, :del_fav, :check_qty
        end

        collection do
          get :check_qty_more
        end
      end

      resources :cart_items, only: [:index, :destroy] do
        member do
          post :increase, :decrease
        end

        collection do
          get :check_qty
          post :move_to_fav
          delete :remove_all
        end
      end

      resources :orders do
        collection do
          get :get_address
        end

        member do
          get :pre_alipay
          post :cancel, :confirm
        end
      end

      resources :order_items do
      end

      resources :addresses do
        member do
          post :set_default
        end
        collection do
          get :list
        end
      end

      #match '/messages/:app_id/receive', to: "messages#receive", via: [:post]

      resources :messages do
        collection do
          post :authorize_events
        end
      end

      resources :mp_users do
        get :bind_callback, :jssdk_config, :bind_callback, :set_mp_user, on: :collection
      end

      resources :order_data

      get 'commit/get_qrcode', to: "commit#get_qrcode"
      get 'commit/submit_audit', to: "commit#submit_audit"
      get 'commit/get_latest_auditstatus', to: "commit#get_latest_auditstatus"
      get 'commit/qrcode', to: "commit#qrcode"
      get 'commit/modify_domain', to: "commit#modify_domain"
      get 'commit/bind_tester', to: "commit#bind_tester"

      get 'wxpay/pay', to: "wxpay#pay"
      get 'wxpay/success', to: "wxpay#success"
      get 'wxpay/fail', to: "wxpay#fail"
      get 'wxpay/test', to: "wxpay#test"
      match 'wxpay/notify', to: "wxpay#notify", via: [:post, :put, :get]

    end
  end

  match '/api/mini_program/messages/service/:app_id', to: "api/mini_program/messages#service", via: [:post, :get]
  post "/api/mini_program/messages/receive/:app_id" => "api/mini_program/messages#receive"

end
