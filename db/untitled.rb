 create_table "cities", :force => true do |t|
    t.string   "name",                       :null => false
    t.string   "pinyin"
    t.integer  "province_id", :default => 9, :null => false
    t.integer  "sort",        :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "cities", ["province_id"], :name => "index_cities_on_province_id"

  create_table "districts", :force => true do |t|
    t.string   "name",                       :null => false
    t.string   "pinyin"
    t.integer  "city_id",    :default => 73, :null => false
    t.integer  "sort",       :default => 0,  :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "districts", ["city_id"], :name => "index_districts_on_city_id"

  create_table "ec_activities", :force => true do |t|
    t.integer  "activity_type"
    t.text     "metadata"
    t.integer  "status",        :default => 1, :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "title"
    t.string   "summary"
    t.string   "pic_key"
    t.integer  "ec_product_id"
    t.integer  "ec_item_id"
    t.string   "name"
  end

  create_table "ec_addresses", :force => true do |t|
    t.integer  "user_id",                        :null => false
    t.integer  "province_id", :default => 9,     :null => false
    t.integer  "city_id",     :default => 73,    :null => false
    t.integer  "district_id", :default => 702,   :null => false
    t.string   "address",                        :null => false
    t.string   "username",                       :null => false
    t.string   "mobile",                         :null => false
    t.boolean  "is_default",  :default => false, :null => false
    t.integer  "status",      :default => 1,     :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "ec_addresses", ["city_id"], :name => "index_ec_addresses_on_city_id"
  add_index "ec_addresses", ["district_id"], :name => "index_ec_addresses_on_district_id"
  add_index "ec_addresses", ["province_id"], :name => "index_ec_addresses_on_province_id"
  add_index "ec_addresses", ["user_id"], :name => "index_ec_addresses_on_user_id"

  create_table "ec_cart_items", :force => true do |t|
    t.integer  "user_id",                                                         :null => false
    t.integer  "ec_shop_id",                                                      :null => false
    t.integer  "ec_item_id",                                                      :null => false
    t.integer  "qty",                                           :default => 0,    :null => false
    t.decimal  "original_price", :precision => 12, :scale => 2, :default => 0.0,  :null => false
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.boolean  "is_selected",                                   :default => true
  end

  add_index "ec_cart_items", ["ec_item_id"], :name => "index_ec_cart_items_on_ec_item_id"
  add_index "ec_cart_items", ["user_id"], :name => "index_ec_cart_items_on_user_id"

  create_table "ec_categories", :force => true do |t|
    t.integer  "site_id"
    t.integer  "parent_id",     :default => 0,     :null => false
    t.integer  "category_type", :default => 1,     :null => false
    t.string   "name",                             :null => false
    t.string   "summary"
    t.string   "pic_key"
    t.string   "icon_key"
    t.integer  "position",      :default => 1,     :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "is_recommend",  :default => false, :null => false
    t.integer  "status",        :default => 1
    t.boolean  "is_delete",     :default => false
    t.boolean  "is_default",    :default => false
  end

  add_index "ec_categories", ["name"], :name => "index_ec_categories_on_name"
  add_index "ec_categories", ["parent_id"], :name => "index_ec_categories_on_parent_id"


  create_table "ec_comments", :force => true do |t|
    t.integer  "ec_order_item_id",                :null => false
    t.integer  "user_id",                         :null => false
    t.integer  "ec_item_id",                      :null => false
    t.text     "comment_type",                    :null => false
    t.integer  "star",             :default => 5, :null => false
    t.text     "content",                         :null => false
    t.string   "nickname"
    t.text     "reply"
    t.datetime "replied_at"
    t.integer  "status",           :default => 1, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ec_comments", ["ec_item_id"], :name => "index_ec_comments_on_ec_item_id"
  add_index "ec_comments", ["ec_order_item_id"], :name => "index_ec_comments_on_ec_order_item_id"
  add_index "ec_comments", ["user_id"], :name => "index_ec_comments_on_user_id"

  create_table "ec_dining_times", :force => true do |t|
    t.time     "start_at",   :null => false
    t.time     "end_at",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "position"
  end

  create_table "ec_favorites", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "ec_item_id", :null => false
    t.datetime "created_at", :null => false
  end

  add_index "ec_favorites", ["ec_item_id"], :name => "index_ec_favorites_on_ec_item_id"
  add_index "ec_favorites", ["user_id"], :name => "index_ec_favorites_on_user_id"

  create_table "ec_item_logs", :force => true do |t|
    t.integer  "ec_item_id"
    t.integer  "user_id"
    t.integer  "log_type",                                 :default => 1
    t.datetime "created_at"
    t.decimal  "money",      :precision => 5, :scale => 2, :default => 0.0
  end

  create_table "ec_item_tags", :force => true do |t|
    t.integer  "ec_item_id"
    t.integer  "ec_tag_id"
    t.datetime "created_at"
  end

  create_table "ec_items", :force => true do |t|
    t.integer  "site_id"
    t.integer  "ec_product_id",                                                      :null => false
    t.integer  "product_type",                                    :default => 1,     :null => false
    t.string   "name",                                                               :null => false
    t.string   "sku",                                                                :null => false
    t.decimal  "market_price",     :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "price",            :precision => 8,  :scale => 2, :default => 0.0,   :null => false
    t.float    "weight",                                          :default => 0.0,   :null => false
    t.integer  "sold_qty",                                        :default => 0,     :null => false
    t.integer  "display_sold_qty",                                :default => 0,     :null => false
    t.text     "description"
    t.integer  "status",                                          :default => 0,     :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "play_times",                                      :default => 0
    t.boolean  "is_pay",                                          :default => false
    t.integer  "audit_status",                                    :default => 1
    t.boolean  "is_delete",                                       :default => false
    t.integer  "ec_category_id"
    t.string   "key"
    t.integer  "second"
    t.integer  "likes_count",                                     :default => 0
    t.integer  "collection_count",                                :default => 0
    t.integer  "comment_count",                                   :default => 0
    t.integer  "play_count",                                      :default => 0
    t.string   "pic_key"
    t.string   "summary"
    t.integer  "user_id"
    t.string   "audio_key"
  end

  add_index "ec_items", ["ec_product_id"], :name => "index_ec_items_on_ec_product_id"
  add_index "ec_items", ["name"], :name => "index_ec_items_on_name"

  create_table "ec_logistic_companies", :force => true do |t|
    t.string   "name",                      :null => false
    t.integer  "status",     :default => 1, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "ec_logistic_template_items", :force => true do |t|
    t.integer  "ec_logistic_template_id"
    t.string   "meta"
    t.boolean  "is_default",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ec_logistic_template_items", ["ec_logistic_template_id"], :name => "index_ec_logistic_template_items_on_ec_logistic_template_id"

  create_table "ec_logistic_templates", :force => true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.integer  "valuation_method"
    t.integer  "ship_method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ec_order_items", :force => true do |t|
    t.integer  "site_id"
    t.integer  "ec_order_id",                                                     :null => false
    t.integer  "ec_shop_id",                                                      :null => false
    t.integer  "ec_item_id",                                                      :null => false
    t.string   "product_name",                                                    :null => false
    t.integer  "qty",                                            :default => 0,   :null => false
    t.decimal  "price",           :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",        :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total_price",     :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total_pay_price", :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.integer  "status",                                         :default => 0,   :null => false
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.string   "pic_key"
    t.string   "item_name"
  end

  add_index "ec_order_items", ["ec_item_id"], :name => "index_ec_order_items_on_ec_item_id"
  add_index "ec_order_items", ["ec_order_id"], :name => "index_ec_order_items_on_ec_order_id"
  add_index "ec_order_items", ["ec_shop_id"], :name => "index_ec_order_items_on_ec_shop_id"

  create_table "ec_order_rules", :force => true do |t|
    t.integer  "site_id"
    t.boolean  "is_auto_expire"
    t.float    "expires_in",                :default => 0.0
    t.boolean  "is_auto_confirm"
    t.integer  "confirms_in"
    t.boolean  "is_auto_close_refund_func"
    t.integer  "close_refund_in"
    t.boolean  "is_auto_comment"
    t.integer  "comments_in"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "ec_orders", :force => true do |t|
    t.integer  "site_id"
    t.string   "order_no",                                                                 :null => false
    t.integer  "user_id",                                                                  :null => false
    t.decimal  "total_amount",           :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "discount",               :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "pay_amount",             :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.integer  "delivery_type",                                         :default => 0,     :null => false
    t.integer  "province_id",                                           :default => 9,     :null => false
    t.integer  "city_id",                                               :default => 73,    :null => false
    t.integer  "district_id",                                           :default => 702,   :null => false
    t.string   "address"
    t.datetime "delivery_time"
    t.integer  "ec_shop_id"
    t.integer  "ec_shop_cabinet_id"
    t.decimal  "freight_value",          :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.string   "username",                                                                 :null => false
    t.string   "mobile",                                                                   :null => false
    t.integer  "status",                                                :default => 0,     :null => false
    t.text     "description"
    t.datetime "paid_at"
    t.string   "captcha"
    t.integer  "source_type",                                           :default => 0,     :null => false
    t.integer  "source_shop_id"
    t.integer  "pay_type",                                              :default => 10001, :null => false
    t.integer  "pay_status",                                            :default => 0,     :null => false
    t.datetime "expired_at"
    t.datetime "canceled_at"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.datetime "receipt_at"
    t.datetime "completed_at"
    t.date     "dining_date"
    t.time     "start_dining_at"
    t.time     "end_dining_at"
    t.string   "logistic_no"
    t.integer  "logistic_status",                                       :default => 0
    t.boolean  "need_invoice",                                          :default => false
    t.integer  "invoice_type",                                          :default => 1
    t.string   "invoice_title"
    t.integer  "ec_logistic_company_id"
    t.datetime "arrived_at"
    t.boolean  "self_pickup",                                           :default => false
    t.integer  "ec_address_id"
  end

  add_index "ec_orders", ["order_no"], :name => "index_ec_orders_on_order_no"
  add_index "ec_orders", ["user_id"], :name => "index_ec_orders_on_user_id"

  create_table "ec_parameters", :force => true do |t|
    t.integer  "ec_product_id", :null => false
    t.string   "key",           :null => false
    t.string   "value"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "ec_pictures", :force => true do |t|
    t.integer  "pictureable_id",   :null => false
    t.string   "pictureable_type", :null => false
    t.string   "pic_key",          :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "ec_pictures", ["pictureable_id"], :name => "index_ec_pictures_on_pictureable_id"
  add_index "ec_pictures", ["pictureable_type"], :name => "index_ec_pictures_on_pictureable_type"

  create_table "ec_point_rules", :force => true do |t|
    t.integer  "register_points",                                :default => 0,   :null => false
    t.decimal  "order_amount",    :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.integer  "order_points",                                   :default => 0,   :null => false
    t.integer  "comment_points",                                 :default => 0,   :null => false
    t.integer  "status",                                         :default => 0,   :null => false
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  create_table "ec_prices", :force => true do |t|
    t.integer  "ec_category_id"
    t.decimal  "min_price",      :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "max_price",      :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  create_table "ec_product_tags", :force => true do |t|
    t.integer  "ec_tag_id",     :null => false
    t.integer  "ec_product_id", :null => false
    t.datetime "created_at",    :null => false
  end

  add_index "ec_product_tags", ["ec_product_id"], :name => "index_ec_product_tags_on_ec_product_id"
  add_index "ec_product_tags", ["ec_tag_id"], :name => "index_ec_product_tags_on_ec_tag_id"

  create_table "ec_products", :force => true do |t|
    t.integer  "site_id"
    t.integer  "ec_category_id",                    :null => false
    t.string   "name",                              :null => false
    t.integer  "province_id",    :default => 9,     :null => false
    t.integer  "city_id",        :default => 73,    :null => false
    t.string   "description"
    t.integer  "status",         :default => 0,     :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "position"
    t.boolean  "is_recommend",   :default => false, :null => false
    t.boolean  "is_delete",      :default => false
  end

  add_index "ec_products", ["ec_category_id"], :name => "index_ec_products_on_ec_category_id"
  add_index "ec_products", ["name"], :name => "index_ec_products_on_name"

  create_table "ec_search_histories", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "keyword",    :null => false
    t.datetime "created_at", :null => false
  end

  create_table "ec_shop_cabinets", :force => true do |t|
    t.string   "ec_shop_id",                :null => false
    t.string   "name",                      :null => false
    t.string   "no",                        :null => false
    t.integer  "status",     :default => 1, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "ec_shop_cabinets", ["ec_shop_id"], :name => "index_ec_shop_cabinets_on_ec_shop_id"
  add_index "ec_shop_cabinets", ["name"], :name => "index_ec_shop_cabinets_on_name"

  create_table "ec_shop_products", :force => true do |t|
    t.integer  "ec_shop_id",                   :null => false
    t.integer  "ec_product_id",                :null => false
    t.integer  "status",        :default => 1, :null => false
    t.datetime "created_at",                   :null => false
  end

  add_index "ec_shop_products", ["ec_product_id"], :name => "index_ec_shop_products_on_ec_product_id"
  add_index "ec_shop_products", ["ec_shop_id"], :name => "index_ec_shop_products_on_ec_shop_id"

  create_table "ec_shop_recommend_details", :force => true do |t|
    t.integer  "ec_shop_recommend_id",                :null => false
    t.integer  "ec_item_id",                          :null => false
    t.integer  "position",             :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ec_shop_recommends", :force => true do |t|
    t.integer  "ec_shop_id",                    :null => false
    t.string   "title"
    t.string   "pic_key"
    t.integer  "position",       :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recommend_type", :default => 1
  end

  create_table "ec_shop_tags", :force => true do |t|
    t.integer  "ec_tag_id",  :null => false
    t.integer  "ec_shop_id", :null => false
    t.datetime "created_at", :null => false
  end

  add_index "ec_shop_tags", ["ec_shop_id"], :name => "index_ec_shop_tags_on_ec_shop_id"
  add_index "ec_shop_tags", ["ec_tag_id"], :name => "index_ec_shop_tags_on_ec_tag_id"

  create_table "ec_shops", :force => true do |t|
    t.integer  "ec_category_id",                   :null => false
    t.string   "name",                             :null => false
    t.string   "tel"
    t.string   "logo_key"
    t.integer  "province_id",     :default => 9,   :null => false
    t.integer  "city_id",         :default => 73,  :null => false
    t.integer  "district_id",     :default => 702, :null => false
    t.string   "address",                          :null => false
    t.string   "location_x"
    t.string   "location_y"
    t.text     "description"
    t.integer  "status",          :default => 1,   :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "slide_pic_key"
    t.string   "real_location_x"
    t.string   "real_location_y"
    t.integer  "cabinets_count",  :default => 0,   :null => false
  end

  add_index "ec_shops", ["name"], :name => "index_ec_shops_on_name"

  create_table "ec_slide_users", :force => true do |t|
    t.integer  "ec_slide_id", :null => false
    t.integer  "user_id",     :null => false
    t.datetime "created_at",  :null => false
  end

  create_table "ec_slides", :force => true do |t|
    t.integer  "site_id"
    t.string   "title",                         :null => false
    t.string   "pic_key",                       :null => false
    t.string   "url",                           :null => false
    t.integer  "slide_type",     :default => 1, :null => false
    t.integer  "position",       :default => 1, :null => false
    t.integer  "status",         :default => 0, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "ec_category_id"
  end

  create_table "ec_stock_items", :force => true do |t|
    t.integer  "site_id"
    t.integer  "ec_stock_id", :default => 1
    t.integer  "ec_item_id",                 :null => false
    t.integer  "qty",                        :null => false
    t.integer  "status",      :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "ec_stock_items", ["ec_item_id"], :name => "index_ec_stock_items_on_ec_item_id"
  add_index "ec_stock_items", ["ec_stock_id"], :name => "index_ec_stock_items_on_ec_stock_id"

  create_table "ec_stocks", :force => true do |t|
    t.integer  "site_id"
    t.string   "no",                         :null => false
    t.text     "description"
    t.integer  "status",      :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "ec_tags", :force => true do |t|
    t.integer  "site_id"
    t.string   "name",                      :null => false
    t.integer  "tag_type",   :default => 1, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "user_id"
  end

  add_index "ec_tags", ["name"], :name => "index_ec_tags_on_name"
  add_index "ec_tags", ["tag_type"], :name => "index_ec_tags_on_tag_type"

  create_table "ec_user_activities", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.string   "ec_activity_id", :null => false
    t.datetime "created_at",     :null => false
  end

  create_table "employee_role_maps", :force => true do |t|
    t.integer  "employee_id",      :null => false
    t.integer  "employee_role_id", :null => false
    t.datetime "created_at",       :null => false
  end

  create_table "employee_roles", :force => true do |t|
    t.integer  "account_id",                :null => false
    t.string   "name",                      :null => false
    t.integer  "sort",       :default => 0, :null => false
    t.integer  "status",     :default => 1, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at"
  end

  create_table "employees", :force => true do |t|
    t.integer  "account_id",                     :null => false
    t.string   "name",                           :null => false
    t.string   "mobile"
    t.string   "email"
    t.integer  "gender",          :default => 1, :null => false
    t.string   "password_digest"
    t.integer  "status",          :default => 1, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at"
    t.integer  "user_type",       :default => 2
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "site_id"
    t.string   "user_id"
    t.string   "user_type"
    t.string   "source_type"
    t.string   "contact"
    t.string   "contact_info"
    t.integer  "feedback_type", :default => 1,     :null => false
    t.text     "content"
    t.integer  "admin_user_id"
    t.text     "reply"
    t.datetime "reply_at"
    t.boolean  "is_read",       :default => false
    t.integer  "status",        :default => 1,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

   create_table "provinces", :force => true do |t|
    t.string   "name",                      :null => false
    t.string   "pinyin"
    t.integer  "sort",       :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "wx_mp_users", :force => true do |t|
    t.integer  "account_id"
    t.integer  "site_id",                                                 :null => false
    t.integer  "status",                :limit => 1,   :default => 0,     :null => false
    t.string   "nickname",                                                :null => false
    t.string   "openid"
    t.string   "app_id"
    t.string   "app_secret"
    t.string   "token"
    t.string   "url"
    t.string   "code"
    t.string   "head_img"
    t.string   "alias"
    t.string   "qrcode_key"
    t.string   "qrcode_url"
    t.integer  "user_type",             :limit => 1,   :default => 1,     :null => false
    t.integer  "bind_type",                            :default => 1
    t.boolean  "is_sync",                              :default => false, :null => false
    t.boolean  "is_oauth",                             :default => false, :null => false
    t.datetime "expires_in"
    t.string   "access_token",          :limit => 512
    t.string   "wx_jsapi_ticket"
    t.datetime "wx_jsapi_expires_in"
    t.string   "auth_code"
    t.string   "refresh_token"
    t.integer  "encrypt_mode",          :limit => 1,   :default => 0
    t.string   "encoding_aes_key",                     :default => ""
    t.string   "last_encoding_aes_key",                :default => ""
    t.string   "username"
    t.string   "password"
    t.text     "func_info"
    t.text     "metatada"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "service_type_info"
    t.string   "verify_type_info"
    t.string   "principal_name"
    t.string   "signature"
    t.string   "business_info"
    t.string   "mini_program_info"
  end

  add_index "wx_mp_users", ["account_id"], :name => "index_wx_mp_users_on_account_id"
  add_index "wx_mp_users", ["code"], :name => "index_wx_mp_users_on_code"
  add_index "wx_mp_users", ["openid"], :name => "index_wx_mp_users_on_openid"
  add_index "wx_mp_users", ["site_id"], :name => "index_wx_mp_users_on_site_id"



  create_table "wx_users", :force => true do |t|
    t.integer  "wx_mp_user_id"
    t.integer  "user_id"
    t.integer  "status",                  :default => 1,     :null => false
    t.string   "openid",                                     :null => false
    t.string   "nickname"
    t.integer  "subscribe"
    t.integer  "sex",                     :default => 0
    t.string   "language"
    t.string   "city"
    t.string   "province"
    t.string   "country"
    t.string   "headimgurl"
    t.datetime "subscribe_time"
    t.string   "unionid"
    t.string   "remark"
    t.integer  "groupid",                 :default => 0,     :null => false
    t.string   "location_x"
    t.string   "location_y"
    t.string   "location_label"
    t.datetime "location_updated_at"
    t.boolean  "leave_message_forbidden", :default => false
    t.boolean  "is_show_product_pic",     :default => true
    t.integer  "match_type",              :default => 1,     :null => false
    t.datetime "match_at"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "wx_users", ["nickname"], :name => "index_wx_users_on_nickname"
  add_index "wx_users", ["openid"], :name => "index_wx_users_on_openid"
  add_index "wx_users", ["user_id"], :name => "index_wx_users_on_user_id"
  add_index "wx_users", ["wx_mp_user_id"], :name => "index_wx_users_on_wx_mp_user_id"


  create_table "users", :force => true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.string   "mobile"
    t.integer  "gender",                                       :default => 1,   :null => false
    t.string   "address"
    t.integer  "status",                                       :default => 0,   :null => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.integer  "user_grade_id",                                :default => 0
    t.integer  "total_coins",                                  :default => 0
    t.integer  "usable_coins",                                 :default => 0
    t.integer  "frozen_coins",                                 :default => 0
    t.decimal  "total_amounts",  :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "usable_amounts", :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "frozen_amounts", :precision => 8, :scale => 2, :default => 0.0
  end

  add_index "users", ["site_id"], :name => "index_users_on_site_id"