class EcShopCabinet < ActiveRecord::Base
  validates :ec_shop_id, :name, :no, presence: true

  belongs_to :ec_shop

  acts_as_enum :status, :in => [
  	['enabled', 1, '启用'],
  	['disabled', -1, '停用']
  ]
end
