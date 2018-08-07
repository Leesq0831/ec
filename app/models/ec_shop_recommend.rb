class EcShopRecommend < ActiveRecord::Base

  validates :title,:pic_key,:ec_shop_id, presence: true
  belongs_to :ec_shop
  has_many :ec_shop_recommend_details
  has_many :ec_items, through: :ec_shop_recommend_details

  enum_attr :recommend_type, in: [
    ['homepage', 1, '商城首页'],
    ['detail', 2, '餐厅详情']
  ]

  def  pic_url
    qiniu_image_url(pic_key)
  end

  def format_pic_url **options
    return '' unless pic_url
    options.merge!(height: 712) unless options[:height]
    options.merge!(width: 426) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{pic_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

end