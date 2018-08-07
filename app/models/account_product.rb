class AccountProduct < ActiveRecord::Base
  # attr_accessible :description, :name, :price

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  enum_attr :status, :in => [
    ['active',  1, '正常'],
    ['deleted',  -1, '已删除']
  ]

  ENUM_ID_OPTIONS = [
    ['product0', 10000, '展示版'],
    ['product1', 10001, '电商版'],
    ['product2', 10002, '房产版'],
    # ['product3', 10003, 'V-门户版'],
  ]

  enum_attr :id, in: ENUM_ID_OPTIONS

end
