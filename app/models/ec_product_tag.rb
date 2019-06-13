class EcProductTag < ActiveRecord::Base
  validates :ec_tag_id, :ec_product_id, presence: true

  belongs_to :ec_tag
  belongs_to :ec_product
end