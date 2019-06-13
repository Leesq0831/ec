class EcShopTag < ActiveRecord::Base
  validates :ec_tag_id, :ec_shop_id, presence: true

  belongs_to :ec_tag
  belongs_to :ec_shop
end