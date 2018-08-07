# == Schema Information
#
# Table name: point_transactions
#
#  id             :integer          not null, primary key
#  site_id    :integer          not null
#  vip_user_id    :integer          not null
#  point_type_id  :integer          not null
#  direction_type :integer          default(1), not null
#  points         :integer          not null
#  pointable_id   :integer
#  pointable_type :string(255)
#  status         :integer          default(1), not null
#  description    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PointTransaction < ActiveRecord::Base

  belongs_to :vip_user

  acts_as_enum :direction_type, :in =>[
    ['out',1,'消费'],
    ['in',2,'获取']
  ]

end
