class EcLogisticCompany < ActiveRecord::Base
  validates :name, presence: true

  has_many :ec_orders

  enum_attr :status, in: [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  def destroy
    update_attributes(status: DELETED)
  end

end
