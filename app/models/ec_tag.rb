class EcTag < ActiveRecord::Base
  validates :name, :tag_type, presence: true

  belongs_to :account
  has_many :ec_shop_tags, dependent: :destroy
  has_many :ec_tags, through: :ec_shop_tags

  has_many :ec_product_tags, dependent: :destroy
  has_many :ec_products, through: :ec_product_tags

  enum_attr :tag_type, in: [
    ['shop_tag', 1, '餐厅标签'],
    ['product_tag', 2, '商品标签']
  ]

  default_scope -> { order(:id) }
end
