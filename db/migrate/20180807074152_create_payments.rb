class CreatePayments < ActiveRecord::Migration
  def change
  	create_table "payments", :force => true do |t|
	    t.integer  "account_id"
	    t.integer  "customer_id"
	    t.string   "customer_type"
	    t.integer  "paymentable_id"
	    t.string   "paymentable_type"
	    t.integer  "payment_type_id"
	    t.string   "out_trade_no",                                                                                     :null => false
	    t.string   "trade_no"
	    t.string   "prepay_id"
	    t.string   "trade_status",                                                    :default => "WAIT_BUYER_PAY",    :null => false
	    t.decimal  "amount",                           :precision => 12, :scale => 2, :default => 0.0,                 :null => false
	    t.decimal  "total_fee",                        :precision => 12, :scale => 2, :default => 0.0,                 :null => false
	    t.string   "payment_type",        :limit => 1,                                :default => "1",                 :null => false
	    t.string   "subject"
	    t.string   "body"
	    t.string   "quantity",                                                        :default => "1",                 :null => false
	    t.decimal  "price",                            :precision => 12, :scale => 2, :default => 0.0,                 :null => false
	    t.decimal  "discount",                         :precision => 12, :scale => 2, :default => 0.0,                 :null => false
	    t.string   "is_total_fee_adjust", :limit => 1,                                :default => "N",                 :null => false
	    t.string   "use_coupon",          :limit => 1,                                :default => "N",                 :null => false
	    t.datetime "gmt_create"
	    t.datetime "gmt_payment"
	    t.datetime "gmt_close"
	    t.string   "buyer_id"
	    t.string   "buyer_email"
	    t.string   "seller_id"
	    t.string   "seller_email"
	    t.string   "sign_type",                                                       :default => "MD5",               :null => false
	    t.string   "sign"
	    t.string   "notify_type",                                                     :default => "trade_status_sync", :null => false
	    t.string   "notify_id"
	    t.datetime "notify_time"
	    t.boolean  "is_delivery",                                                     :default => false,               :null => false
	    t.string   "callback_url"
	    t.string   "merchant_url"
	    t.string   "notify_url"
	    t.string   "account_url"
	    t.text     "order_msg"
	    t.text     "pay_params"
	    t.integer  "status",                                                          :default => 0,                   :null => false
	    t.integer  "settle_status",                                                   :default => 0,                   :null => false
	    t.decimal  "settle_fee_rate",                  :precision => 6,  :scale => 4, :default => 0.0,                 :null => false
	    t.datetime "settle_at"
	    t.string   "state"
	    t.string   "open_id"
	    t.string   "source"
	    t.boolean  "is_trade_synced"
	    t.datetime "created_at",                                                                                       :null => false
	    t.datetime "updated_at",                                                                                       :null => false
  	end

  end
end
