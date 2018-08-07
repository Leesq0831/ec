class EcOrderItem < ActiveRecord::Base
  validates :ec_item_id, :product_name, :qty, :price, :total_price, :total_pay_price, presence: true
  validates :qty, numericality: { only_integer: true, greater_than: 0 }
  validates :price, :total_price, :total_pay_price, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :account
  belongs_to :ec_order
  belongs_to :ec_shop
  belongs_to :ec_item

  before_create :set_default_attrs

  def freight_calc(city_id = {})
    return ec_item.logistic_price.to_f if ec_item.unified?
    
    lt = ec_item.ec_logistic_template
    return 0 if lt.nil?

    if ec_order.present?
      lt_item = lt.ec_logistic_template_items.joins(:cities).where(cities: {name: ec_order.city.name.gsub("市", "")}).first || lt.ec_logistic_template_items.joins(:cities).where(cities: {name: "全国"}).first
    else
      city = City.where(id: city_id).first
      lt_item = lt.ec_logistic_template_items.joins(:cities).where(cities: {name: city.name.gsub("市", "")}).first || lt.ec_logistic_template_items.joins(:cities).where(cities: {name: "全国"}).first
    end

    return 0 if lt_item.nil?

    if lt.weight?
      return weight_freight(lt, lt_item)
    elsif lt.money?
      return money_freight(lt, lt_item)
    else
      return 0
    end
  end

  def weight_freight(lt, lt_item)
    add_weight = (ec_item.weight.to_f * qty - lt_item.first_unit.to_f)
    return lt_item.first_unit_freight.to_f if add_weight <= 0
    lt_item.first_unit_freight.to_f + (add_weight / lt_item.add_unit.to_f) * lt_item.add_unit_freight.to_f
  end

  def money_freight(lt, lt_item)
    return lt_item.single_order_amount_freight.to_f
  end

  def pic_url
    # ec_item.ec_product.ec_picture.try(:pic_url)
    qiniu_image_url(pic_key)
  end

  private

    def set_default_attrs
      self.ec_shop_id ||= 0
      self.item_name ||= "item"
    end
end
