class EcShop < ActiveRecord::Base
  include CalculateDistance

  acts_as_enum :status, :in => [
    ['wait', 0, '停用'],
    ['pass', 1, '启用'],
    ['deleted', -1, '已删除']
  ]

  validates :name, :tel, :province_id, :city_id, :district_id, :address, presence: true

  belongs_to :province
  belongs_to :city
  belongs_to :district
  belongs_to :ec_category

  has_many :ec_shop_cabinets
  has_many :ec_shop_tags, dependent: :destroy
  has_many :ec_tags, through: :ec_shop_tags
  has_many :ec_shop_products
  has_many :ec_products, :through => :ec_shop_products
  has_many :ec_logistic_templates
  has_many :ec_dining_times
  has_many :ec_pictures, as: :pictureable
  has_many :ec_shop_recommends

  # default_scope -> { where("ec_shops.status != ?", DELETED) }

  # accepts_nested_attributes_for :ec_dining_times, allow_destroy: true
  # validates_associated :ec_dining_times

  accepts_nested_attributes_for :ec_pictures, allow_destroy: true
  validates_associated :ec_pictures

  before_save :update_real_location

  def self.sort_by_distance(user)
    lat1, lng1 = user.wx_user.location_x, user.wx_user.location_y
    arr = []
    EcShop.pass.each do |shop|
      next if shop.location_x.blank? || shop.location_y.blank?

      if user.wx_user.location_x.blank? || user.wx_user.location_y.blank?
        arr << [shop, nil]
        next
      end

      distance = shop.get_great_circle_distance(lat1, lng1, shop.real_location_x || shop.location_x, shop.real_location_y || shop.location_y)
      arr << [shop, distance]
    end
    return arr.sort_by {|a| a[1] }
  end

  def self.deleted_all!
    update_all(status: DELETED)
  end

  def address_display
    [province.try(:name), city.try(:name), district.try(:name), address].compact.uniq.join
  end

  def logo_url
    qiniu_image_url(logo_key)
  end

  def format_logo_url **options
    return '' unless logo_url
    options.merge!(height: 335) unless options[:height]
    options.merge!(width: 216) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{logo_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

  def slide_pic_url
    qiniu_image_url(slide_pic_key)
  end

  def format_slide_pic_url **options
    return '' unless slide_pic_url
    options.merge!(height: 335) unless options[:height]
    options.merge!(width: 216) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{slide_pic_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

  private

    def update_real_location
      if location_x_changed? || location_y_changed? || true
        url = "http://api.map.baidu.com/geoconv/v1/?coords=#{location_x},#{location_y}&from=1&to=5&ak=9c72e3ee80443243eb9d61bebeed1735"
        result = JSON(RestClient.get(url))['result'].try(:first) || {}

        if result['x'].present? && result['y'].present?
          x = location_x.to_f * 2 - result['x'].to_f
          y = location_y.to_f * 2 - result['y'].to_f
          self.real_location_x, self.real_location_y = x, y
        end
      end

    rescue => e
      Rails.logger.info "坐标转换失败: #{e}"
    end
end
