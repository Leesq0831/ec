class EcShopProduct < ActiveRecord::Base
  validates :ec_shop_id, :ec_product_id, presence: true

  belongs_to :ec_shop
  belongs_to :ec_product
  default_scope -> { where("ec_shop_products.status != ?", EcShopProduct::DELETED ) }

  acts_as_enum :status, :in =>[
    ['offshelf', 0,'下架'],
    ['onshelf', 1,'在售'],
    ['deleted', -2, '删除']
  ]
end
