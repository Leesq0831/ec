class EcCategory < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :account
  belongs_to :parent, class_name: 'EcCategory', foreign_key: :parent_id
  has_many :children, class_name: 'EcCategory', foreign_key: :parent_id

  has_many :ec_products
  has_many :ec_prices
  has_many :ec_shops

  enum_attr :category_type, in: [
    ['shop_category', 1, '餐厅分类'],
    ['product_category', 2, '商品分类']
  ]

  enum_attr :status, in: [
    ['onshelf', 1, '上架'],
    ['offshelf', -1, '下架']
  ]

  enum_attr :is_recommend, in: [
    ['recommend', true, '是'],
    ['not_recommend', false, '否']
  ]

  default_scope order(:position)

  def has_children?
    children.count > 0
  end

  def pic_url
    qiniu_image_url(pic_key)
  end

  def icon_url
    qiniu_image_url(icon_key)
  end

  def format_icon_url **options
    return '' unless icon_url
    options.merge!(height: 160) unless options[:height]
    options.merge!(width: 140) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{icon_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

  def format_pic_url **options
    return '' unless pic_url
    options.merge!(height: 264) unless options[:height]
    options.merge!(width: 264) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{pic_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

end
