class EcSlide < ActiveRecord::Base
  validates :pic_key, presence: true, unless: :bottom_menu?

  belongs_to :site
  has_many :ec_slide_users
  has_many :users, through: :ec_slide_users

  default_scope order(:position)

  def pic_url
    qiniu_image_url(pic_key)
  end

  acts_as_enum :slide_type, :in => [
    ['swipe',       1, '首页幻灯片'],
    ['home_menu',   2, '首页菜单'],
    ['banner',      3, '首页广告'],
    ['bottom_menu', 4, '底部菜单'],
    ['pop_banner',  5, '弹出广告']
  ]

  acts_as_enum :url, :in => [
    ['home_url',         'pages/index/index', '首页'],
    ['user_url',         'pages/user/my-center', '我的'],
    ['ec_car_url',       'pages/ec/shopping-cart/shopping-cart', '购物车'],
    ['ec_category_url',  'pages/ec/category/category', '商城分类'],
    ['site_category_url','pages/site/category', '资讯中心'],
    ['site_case_url',    'pages/site/case_list', '展示中心']
  ]

  BOTTOM = {"首页" => 'pages/index/index', "我的" => 'pages/user/my-center',  "购物车" => 'pages/ec/shopping-cart/shopping-cart', "商城分类" => 'pages/ec/category/category', "资讯中心" => 'pages/site/category', '展示中心' => 'pages/site/case_list'}
  
  def format_pic_url **options
    return '' unless pic_url
    options.merge!(height: 520) unless options[:height]
    options.merge!(width: 750) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{pic_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

end
