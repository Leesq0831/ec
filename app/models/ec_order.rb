class EcOrder < ActiveRecord::Base
  # include WxTemplate
  include MpTemplate
  validates :user_id, presence: true

  belongs_to :account
  belongs_to :user
  belongs_to :province
  belongs_to :city
  belongs_to :district
  belongs_to :ec_shop
  belongs_to :ec_logistic_company
  belongs_to :source_shop, class_name: 'EcShop', foreign_key: 'source_shop_id'
  belongs_to :ec_address

  has_many :ec_order_items, dependent: :destroy
  has_many :ec_items, through: :ec_order_items
  has_one :payment, as: :paymentable

  accepts_nested_attributes_for :ec_order_items, allow_destroy: true
  validates_associated :ec_order_items

  acts_as_enum :delivery_type, :in => [
    ['home', 1, '配送到家'],
    ['restaurant', 2, '餐厅酒柜']#,
    # ['online', 3, '线上酒柜']
  ]

  acts_as_enum :pay_type, :in => [
    ['wxpay', 10001, '微信支付'],
    ['alipay', 10003, '支付宝支付'],
    ['cashpay', 10000, '货到付款']
  ]

  acts_as_enum :pay_status, :in => [
    ['paying', 0, '待支付'],
    ['paid', 1, '已支付']
  ]

  acts_as_enum :invoice_type, :in => [
    ['personal', 1, '个人发票'],
    ['company', 2, '公司发票']
  ]

  acts_as_enum :status, :in => [
    ['pending', 0, '待付款'],
    ['waiting', 1, '待发货'],
    ['delivered', 2, '待收货'],
    ['arrived', 3, '已送达'],
    ['confirmed', 4, '已收货'],
    ['finished', 5, '已完成'],
    ['canceled', -1, '已取消'],
    # ['refunding', -2, '申请退款中'],
    # ['refunded', -3, '已退款'],
    # ['overdue', -4, '逾期未支付'],
    # ['noback', -5, '不可退款/退货'],
    ['deleted', -6, '已删除']
  ]

  acts_as_enum :logistic_status, :in => [
    ['unshiped', 0, '待发货'],
    ['shipped', 1, '已发货']
  ]

  enum_attr :source_type, in: [
    ['online', 0, '在线商城'],
    ['offline', 1, '线下餐厅']
  ]

  default_scope -> { where("ec_orders.status != ?", DELETED) }
  scope :shipping, -> { where(status: [WAITING, DELIVERED, ARRIVED, CONFIRMED]) }
  scope :orders_all, -> {where(status: [ PENDING, WAITING, DELIVERED, FINISHED, CANCELED])}

  before_create :generate_order_no
  before_create :generate_captcha
  before_create :generate_total_amount
  before_create :set_default_attrs

  after_create :update_freight_value #计算运费暂注
  after_create :update_item_qty
  #after_create :remove_cart_items
  after_create :create_payment_for_pay
  after_create :update_user_attrs
  after_create :send_success_message
  # after_create :send_new_order_wx_message

  before_save :update_payment_amount

  def send_success_message
    return true
    SmsAlidayu.new.send_new_order_message(site.try(:account).try(:mobile)) if site.try(:account).try(:mobile)
  end

  def set_default_attrs
    self.username ||= ec_address.try(:username)
    self.mobile  ||= ec_address.try(:mobile)
    self.province_id ||= ec_address.try(:province_id)
    self.city_id ||= ec_address.try(:city_id)
    self.district_id ||= ec_address.try(:district_id)
    self.address ||= ec_address.try(:address)
  end

  def address_display
    [province.try(:name), city.try(:name), district.try(:name), address].compact.uniq.join
  end

  def paid!(openid, form_id)
    update_attributes(status: WAITING, pay_status: PAID, paid_at: Time.now)

    send_wx_message(buy_temp(openid, form_id)) if site.wx_mp_user.order_paid_wx_message_template_id

    arrived! if self.self_pickup?
  end

  def packing!
    # update_attributes(pay_status: PACKING)
    send_wx_message(new_order_temp(user.wx_user.openid))
  end

  def shipped(logistic_company_id, logistic_number, form_id)
    return false if logistic_number.blank? || logistic_company_id.blank?
    update_attributes(logistic_status: SHIPPED, status:DELIVERED, ec_logistic_company_id: logistic_company_id, logistic_no: logistic_number)
    send_wx_message(delivery_temp(user.wx_user.openid, form_id)) if site.wx_mp_user.order_packing_wx_message_template_id
    return true
  end

  # def delivered!
  #   update_attributes(status: DELIVERED)
  #   send_wx_message(delivery_temp(user.wx_user.openid))
  # end

  def arrived!
    update_attributes(status: ARRIVED, arrived_at: Time.now)
    # send_wx_message(arrived_temp(user.wx_user.openid))
  end

  def confirmed!
    update_attributes(status: CONFIRMED, receipt_at: Time.now)
    # send_wx_message(order_delivery_temp(user.wx_user.openid))
  end

  def canceled!
    return false if delivered?

    update_attributes(status: CANCELED, canceled_at: Time.now)
    # send_wx_message(cancel_order_temp(user.wx_user.openid))

    ec_order_items.each do |item|
      item.ec_item.update_attributes!(qty: item.ec_item.qty + item.qty, sold_qty: item.ec_item.sold_qty - item.qty, display_sold_qty: item.ec_item.display_sold_qty - item.qty)
    end
  end

  def completed!
    transaction do
      update_attributes(status: FINISHED, completed_at: Time.now)
      point_rule = EcPointRule.first_or_create

      if user.vip_user && point_rule.enabled? && point_rule.order_amount.to_f > 0 && point_rule.order_points.to_i > 0 && total_amount.to_i > 0
        pending_points = (total_amount.to_f / point_rule.order_amount.to_f) * point_rule.order_points.to_i
        user.vip_user.update_attributes(
          total_points: user.vip_user.total_points + pending_points,
          usable_points: user.vip_user.usable_points + pending_points
        )
        user.vip_user.point_transactions.create(
          site_id: user.site_id,
          pointable_id: id,
          pointable_type: 'VipUser',
          direction_type: PointTransaction::IN,
          points: pending_points,
          description: '消费送积分'
        )
      end
    end
  end

  # options = send_wx_message(active_order_temp(user.openid))
  def send_wx_message(options)
    Rails.logger.info "send_wx_message result: #{options}"
    #access_token = user.try(:wx_user).try(:wx_mp_user).try(:wx_access_token)
    access_token = MpUserSetting.fetch_access_token(user.try(:wx_user).try(:wx_mp_user))
    return true unless access_token
    send_mp_message_temp(options: options, access_token: access_token)
  end

  def order_detail
    items_info = ec_order_items.collect{|item| "#{item.product_name}x#{item.qty}份" }.join(',')
    "订单明细：#{items_info}\n收货地址：#{address}\n订单备注：#{description}"
  end

  def deleted!
    update_attributes(status: EcOrder::DELETED)
  end

  def can_delete?(e)
    if e.pay_status == 1 && e.status == 3
      return true
    elsif e.pay_status == 0 && e.status == 0
      return true
    elsif e.status == -1 || e.status == -3
      return true
    else
      return false
    end
  end
  def send_message
    return if mobile.blank?
    notify_name = '您已成功下单'
    order_items = ec_order_items.collect{|item| "#{item.product_name}×#{item.qty} ￥#{item.total_price}" }.join('，')
    remark = "总价：#{total_amount}元。商品：#{order_items}，收货信息：#{username}（#{mobile}），#{address}, 订单备注：#{description}"
    sms_options = { mobiles: mobile, template_code: 'SMS_9060020', params: { notify_name: notify_name, remark: remark } }

    options = { operation_id: 3, site_id: site.id, userable_id: user_id, userable_type: 'User' }

    site.send_message(sms_options, options)
  end

  def order_rule
    site.ec_order_rules.first_or_create
  end

  def remaining_time
    return false unless order_rule.is_auto_expire
    (order_rule.expires_in.to_f * 3600).to_i - (Time.now - created_at)
  end

  def check_order_expire!
    return true unless remaining_time
    if pending? && remaining_time < 0
      canceled!
    end
  end

  private

    def generate_order_no
      self.order_no = Concerns::OrderNoGenerator.generate
    end

    def generate_captcha
      self.captcha = rand(1000..9999)
    end

    def generate_total_amount
      total_amount, pay_amount = 0, 0

      ec_order_items.each do |item|
        total_amount += item.ec_item.price * item.qty
        # pay_amount += item.ec_item.price * item.qty
      end

      self.total_amount = total_amount
      self.pay_amount = total_amount
    end

    def update_item_qty
      ec_order_items.each do |item|
        if(item.ec_item.qty >= item.qty)
          item.ec_item.update_attributes(qty: item.ec_item.qty - item.qty, sold_qty: item.ec_item.sold_qty + item.qty, display_sold_qty: item.ec_item.display_sold_qty + item.qty)
        else
          errors.add(:base, "#{item.ec_item.try(:ec_product).try(:name)}库存不足")
          item.ec_item.update_attributes!(qty: item.ec_item.qty - item.qty, sold_qty: item.ec_item.sold_qty + item.qty, display_sold_qty: item.ec_item.display_sold_qty + item.qty)
        end
        
      end
    end

    def remove_cart_items
      user.ec_cart_items.where(ec_item_id: ec_items.pluck(:id)).destroy_all
    end

    def create_payment_for_pay
      if self.cashpay?
        self.waiting!
      else
        self.update_attributes(pay_type: 10001, pay_status: 0)

        Payment.create!(
          account_id: site.try(:account_id),
          site_id: site.try(:id),
          paymentable: self,
          customer: user,
          subject: "订单 #{order_no}",
          payment_type_id: pay_type,
          out_trade_no: order_no,
          open_id: user.wx_user.try(:openid),
          status: 0,
          amount: pay_amount,
          total_fee: pay_amount
        )

        # self.payment.update_attributes(status: 1, trade_status: Payment::TRADE_SUCCESS)
        # send_wx_message(new_order_temp(user.wx_user.openid))
        # send_wx_message(buy_temp(user.wx_user.openid))
      end
    end

    def update_payment_amount
      return true if self.paid? || payment.blank?
      if !self.new_record? && pay_amount_changed?
        payment.update_attributes(amount: pay_amount, total_fee: pay_amount)
      end
    end

    def send_new_order_wx_message
      send_wx_message(order_temp(user.wx_user.openid))
    end

    def update_user_attrs
      user.update_attributes(name: self.username)# if user.name.blank?
      user.update_attributes(mobile: self.mobile)# if user.mobile.blank?
      #user.update_attributes(address: self.address_display)# if user.address.blank?
    end

    def update_freight_value
      return true if self.self_pickup?
      value = 0.0
      ec_order_items.each do |order_item|
        value += order_item.freight_calc.to_f
      end

      update_attributes(freight_value: value.to_f, pay_amount: pay_amount.to_f + value.to_f)
    end

end
