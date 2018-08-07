class Province < ActiveRecord::Base
  has_many :cities
  has_many :ec_orders
  has_many :ec_shops
  has_many :ec_addresses
end
