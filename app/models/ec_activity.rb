class EcActivity < ActiveRecord::Base
  store :metadata, accessors: [:title, :summary, :pic_key, :ec_item_id, :expires_in, :notice, :is_now_order, :openids]
  # validates :title, :summary, :pic_key, :ec_product_id, :ec_item_id, presence: true

  validates :notice, presence: true
  validates :expires_in, numericality: { only_integer: true }

  belongs_to :ec_item

  enum_attr :activity_type, in: [
    ['subscribe',1,'关注活动'],
    ['other', 2, '其它活动']
  ]

  enum_attr :status, in: [
    ['start',1,'启用'],
    ['stopped', -1, '停用']
  ]

  def is_now_order?
    self.is_now_order.to_i == 1
  end

  def pic_url
    qiniu_image_url(pic_key)
  end

  def test_openids
    openids.split(/[\r\n]+/)
  end

end
