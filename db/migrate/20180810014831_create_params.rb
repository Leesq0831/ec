class CreateParams < ActiveRecord::Migration
  def change
  	create_table "ec_parameters", :force => true do |t|
	    t.integer  "ec_product_id", :null => false
	    t.string   "key",           :null => false
	    t.string   "value"
	    t.datetime "created_at",    :null => false
	    t.datetime "updated_at",    :null => false
	  end

	  add_column :ec_items,   :ec_price_id,    :integer
	  add_column :ec_items,   :logistic_type,  :integer,   limit: 1
	  add_column :ec_items,   :logistic_price, :decimal,  :precision => 12, :scale => 2, :default => 0.0
	  add_column :ec_items,   :qty,            :integer,  default: 0
	  add_column :ec_items,   :volume,         :string,   limit: 100
	  add_column :ec_items,  	:ec_logistic_template_id,  :integer
  end
end
