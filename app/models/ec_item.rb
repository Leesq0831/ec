class EcItem < ActiveRecord::Base

  validates :name, :sku, :price, :market_price, presence: true
  validates :sku, uniqueness: true
  validates :qty, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, on: :update
  belongs_to :account
  belongs_to :ec_product
  belongs_to :ec_shop_recommend
  belongs_to :ec_logistic_template
  has_many :ec_comments, dependent: :destroy
  has_many :ec_favorites, dependent: :destroy
  has_many :ec_car_items, dependent: :destroy

  enum_attr :status, in: [
    ['draft', 0, '待上架'],
    ['onshelf', 1, '已上架'],
    ['offshelf', -1, '已下架'],
    ['deleted', -2, '已删除']
  ]

  enum_attr :product_type, in: [
    ['product',1,'卖品'],
    ['gift', 2, '赠品']
  ]

  enum_attr :logistic_type, in: [
    ['unified',  1, '统一运费'],
    ['template', 2, '运费模板']
  ]

  # default_scope where(["ec_items.status > ?", -2 ])
  scope :show, -> {where(["ec_items.status > ?", -2 ])}

  before_validation do
    if self.unified? && self.logistic_price.to_f < 0.0
      return false
    end
  end

  before_save :set_ec_price

  def full_name
    "#{ec_product.name} #{name}"
  end

  def province_city
    "#{ec_product.city.try(:name)}"
  end

  def sold_qty_text
    display_sold_qty || sold_qty || 0
  end

  def pic_url
    ec_product.ec_picture.try(:pic_url)
  end

  def format_pic_url **options
    return '' unless pic_url
    options.merge!(height: 210) unless options[:height]
    options.merge!(width: 210) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{pic_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

  def logistic(city_id, num)
    return self.logistic_price.to_f if self.unified?
    lt = ec_logistic_template
    return 0 if lt.nil?
    city = City.where(id: city_id.to_i).first

    lt_item = lt.ec_logistic_template_items.joins(:cities).where(cities: {name: city.name.gsub("市", "")}).first || lt.ec_logistic_template_items.joins(:cities).where(cities: {name: "全国"}).first

  return 0 if lt_item.nil?

    if lt.weight?
      return weight_freight(lt_item, num)
    elsif lt.money?
      return money_freight(lt_item, num)
    else
      return 0
    end
  end

  def weight_freight(lt_item, num)
    add_weight = (self.weight.to_f * num - lt_item.first_unit.to_f)
    return lt_item.first_unit_freight.to_f if add_weight <= 0

    lt_item.first_unit_freight.to_f + (add_weight / lt_item.add_unit.to_f).round(2) * lt_item.add_unit_freight.to_f
  end

  def money_freight(lt_item, num)
    return lt_item.single_order_amount_freight.to_f
  end

  private

    def set_ec_price
      ec_product.ec_category.ec_prices.each do |ec_price|
        if self.price > ec_price.min_price.to_f && self.price < ec_price.max_price
          self.ec_price_id = ec_price.id
        end
      end
    end

end
