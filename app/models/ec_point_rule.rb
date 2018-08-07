class EcPointRule < ActiveRecord::Base
  validates :register_points, :order_amount, :order_points, :comment_points, presence: true

  belongs_to :user
  belongs_to :ec_item

  acts_as_enum :status, :in =>[
    ['disabled',0,'禁用'],
    ['enabled',1,'启用']
  ]
end
