class BookingOrder < ActiveRecord::Base
  include WxTemplate
  # belongs_to :site
  belongs_to :booking
  belongs_to :booking_item
  belongs_to :user
  belongs_to :payment_type

  store :metadata, accessors: [:express]

  has_many   :payments, as: :paymentable

  acts_as_enum :status, :in => [
    ['expired',   -2, '已过期'],
    ['canceled',  -1, '已取消'],
    ['pending',   0, '待支付'],
    ['paid',      1, '已支付'],
    ['completed', 2, '已完成'],
  ]

  enum_attr :payment_type_id, in: PaymentType::ENUM_ID_OPTIONS

  scope :latest, -> { order('booking_orders.created_at DESC') }

  before_create :add_default_attrs, :generate_order_no
  after_create :update_user_address#, :send_message

  def site
    booking.site
  end

  def site_id
    booking.site_id
  end

  def complete!
    update_attributes(status: COMPLETED, completed_at: Time.now)
  end

  def cancele!
    update_attributes(status: CANCELED, canceled_at: Time.now)
  end

  def paid!
    return if paid?

    update_attributes(status: PAID)

    send_message
    send_wx_message_template
  end

  def payment_request_params(params = {})
    params = HashWithIndifferentAccess.new(params)

    _order_params = {
      payment_type_id: payment_type_id,
      account_id: booking.site.account_id,
      site_id: booking.site.id,
      customer_id: user_id,
      customer_type: 'User',
      paymentable_id: id,
      paymentable_type: 'BookingOrder',
      out_trade_no: order_no,
      amount: pay_amount,
      body: "订单 #{order_no}",
      subject: "订单 #{order_no}",
      source: 'booking_order'
    }

    params.reverse_merge(_order_params)
  end

  def send_message
    return if booking.notify_merchant_mobiles.blank?

    remark = "#{order_no}，#{pay_amount}元(#{payment_type_id_name},#{status_name})，#{booking_item.try(:name)}，#{username}(#{tel})，收货地址：#{address}，取货信息：#{description.gsub('dwz.cn', 'url')}"
    sms_options = { mobiles: booking.notify_merchant_mobiles, template_code: 'SMS_9060020', params: { notify_name: '快递通知', remark: remark } }
    options = { operation_id: 7, site_id: booking.site_id, userable_id: user_id, userable_type: 'User' }

    booking.site.send_message(sms_options, options)
  end

  # options = send_wx_message(active_order_temp(user.openid))
  def send_wx_message(options)
    send_wx_message_temp(options: options, access_token: booking.site.wx_mp_user.wx_access_token)
  end

  def send_wx_message_template
    # to user
    send_wx_message(new_order_temp(user.wx_user.openid))

    # to merchant
    if booking.need_wx_message == '1'
      booking.merchant_openid_list.each do |merchant_openid|
        next if merchant_openid == user.wx_user.openid
        send_wx_message(new_order_temp(merchant_openid))
      end
    end
  rescue => error
    # TODO ...
  end

  def user_info
    "#{username} #{tel}"
  end

  def order_detail
    express_str = "\n快递公司：#{express}" if express.present?
    "#{booking_item.try(:name)}x#{qty}份\n收货地址：#{address}\n取货信息：#{description}#{express_str}" 
  end

  private

  def add_default_attrs
    if booking_item
      self.booking_id = booking_item.booking_id
      self.price = booking_item.price
      # self.total_amount = self.price * self.qty


      self.items_amount = booking_item.price * self.qty
      self.deliver_amount = booking.deliver_amount_f
      self.total_amount = self.items_amount + self.deliver_amount



      if user.vip_user
        vip_user_amount = user.vip_user.get_pay_amount(self.items_amount)
        self.discount = self.items_amount - vip_user_amount

        self.pay_amount = vip_user_amount + self.deliver_amount
      else
        self.pay_amount = self.total_amount
      end
    else
      self.price = 0
      self.total_amount = 0
    end
  end

  def generate_order_no
    self.order_no = Concerns::OrderNoGenerator.generate
  end

  def update_user_address
    if self.user
      self.user.name = self.username unless self.user.name
      self.user.address = self.address# unless self.user.address
      self.user.mobile = self.tel unless self.user.mobile
      self.user.save
    end
  end

end
