class EcStock < ActiveRecord::Base
  validates :status,:no, presence: true

  belongs_to :account
  has_many :ec_stock_items, dependent: :destroy

  accepts_nested_attributes_for :ec_stock_items, allow_destroy: true
  validates_associated :ec_stock_items

  enum_attr :status, in: [
    ['pending', 0, '待入库'],
    ['effected', 1, '已入库'],
    # ['deleted', -1, '已删除']
  ]

  before_validation :generate_no

  def effected!
    transaction do
      update_attributes(status: EcStock::EFFECTED)
      ec_stock_items.each do |i|
        i.ec_item.update_attributes(qty: i.ec_item.qty.to_i + i.qty.to_i)
        i.update_attributes(status: EcStockItem::EFFECTED)
      end
    end
  end

  private

    def generate_no
      self.no = Concerns::OrderNoGenerator.generate
    end

end
