class EcShopRecommendDetail < ActiveRecord::Base
  belongs_to :ec_shop_recommend
  belongs_to :ec_item

end