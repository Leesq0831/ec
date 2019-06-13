class CreateSettings < ActiveRecord::Migration
  def change
  	create_table "payment_settings", :force => true do |t|
	    t.integer  "account_id"
	    t.string   "type"
	    t.integer  "payment_type_id"
	    t.string   "partner_id"
	    t.text     "partner_key"
	    t.string   "partner_account"
	    t.string   "app_id"
	    t.string   "app_secret"
	    t.text     "pay_sign_key"
	    t.text     "pay_private_key"
	    t.text     "pay_public_key"
	    t.text     "api_client_cert"
	    t.text     "api_client_key"
	    t.string   "product_catalog"
	    t.integer  "sort",            :default => 1
	    t.integer  "status",          :default => 1
	    t.text     "metadata"
	    t.datetime "created_at",                     :null => false
	    t.datetime "updated_at",                     :null => false
	  end
  end
end
