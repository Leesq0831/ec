class EcStockItem < ActiveRecord::Base
  validates :ec_item_id, :qty, presence: true
  validates :qty, numericality: { only_integer: true, greater_than: 0 }

  belongs_to :account
  belongs_to :ec_item

  enum_attr :status, in: [
    ['pending', 0, '未入库'],
    ['effected', 1, '已入库'],
    ['deleted', -1, '入库失败']
  ]

  def effected
    ec_item.update_attributes(qty: ec_item.qty + qty)
    effected!
  end

end
