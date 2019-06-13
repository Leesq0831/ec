Wp::Application.routes.draw do

  namespace :ec do
    resources :prices, :categories, :tags, :dining_times

    resources :slides do
      post :cleanup, on: :collection
    end

    resources :shops do
      put :enabled,:disabled, on: :collection
      get :qrcode, on: :member
    end
    resources :shop_cabinets, :shop_tags, :shop_recommend_details
    resources :shop_recommends do
      post :change, :del, on: :member
      post :delete, on: :collection
    end
    resources :shop_categories do
      get :update_sorts, on: :member
    end
    resources :shop_products do
      post :delete, on: :collection
    end

    resources :products do
      member do
        get :items
        post :onshelf, :offshelf, :onshelf_all_item, :update_sort
      end

      collection do
        get :onshelf_all, :offshelf_all, :recommend_all, :not_recommend_all, :stock, :stock_in, :delete_all
      end
    end

    resources :items do
      member do
        get :off_shelf, :on_shelf
      end
    end

    resources :stocks do
      member do
        post :effect
      end
    end
    resources :stock_items

    resources :activities do
      post :start, :stop, on: :member
      get :subscribe, on: :collection
    end

    resources :logistic_templates, :logistic_template_items, :logistic_companies

    resources :product_categories do
      member do
        get :update_sorts
      end
    end
    resources :product_tags
    resources :comments
    resources :point_rules
    resources :comments,:comment_templates, :point_rules, :point_transactions, :shop_cabinets
    resources :orders do
      get :deliver, on: :member
      put :deliver_confirm, :receipt, :arrived, :completed, :cancel, :back, on: :member
    end
    resources :order_rules

    resources :vip_users, :users
  end

  namespace :wap do
    root to: 'home#index'
    get '/search', to: 'home#search'
    get '/recohis', to: 'home#recohis'
    get '/more', to: 'home#more'

    resources :cities, :districts, :prices, only: :index

    resources :activities, only: :show

    resources :shops, only: [:index, :show] do
      get :goto, :product_list, on: :member
    end
    resources :products, only: [:index, :show]
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
        get :pre_order, :histroy, :waiting, :comment, :calc_freight
      end

      member do
        get :pre_alipay
        post :cancel, :deliver, :complete, :refund, :confirm, :update_address
      end
    end

    resources :categories, only: [:index, :show]

    resources :comments, only: [:new, :create, :show]

    resources :favorites, only: [:index, :destroy]

    resources :users, only: [:index, :edit, :update] do
      collection do
        post :set_mobile, :report_location
      end
    end

    resources :addresses do
      member do
        post :set_default
      end
    end

  end

  namespace :pay do
    get 'alipay/pay', to: "alipay#pay"
    get 'alipay/callback', to: "alipay#callback"
    match 'alipay/notify', to: "alipay#notify", via: [:post, :put, :get]

    get 'wxpay/pay', to: "wxpay#pay"
    get 'wxpay/success', to: "wxpay#success"
    get 'wxpay/fail', to: "wxpay#fail"
    match 'wxpay/notify', to: "wxpay#notify", via: [:post, :put, :get]
  end

end
