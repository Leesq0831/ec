class ShopOrder < ActiveRecord::Base
  include WxTemplate
  include CalculateDistance
  include PrintCenter

  enum_attr :status, :in => [
    ['draft',0,'购物车'],
    ['pending',1,'待处理'],
    ['completed',2,'已完成'],
    ['canceled',-1,'已关闭'],
    ['expired',-2,'已过期'],
    ['confirm', 3, '已接单'],
    ['delivering', 4, '配送中']
  ]

  enum_attr :book_status, :in => [
    ['in_branch', 1, '我在店'],
    ['in_queue',  2, '我在排号'],
    ['in_normal', 3, '我要订餐订座']
  ]

  enum_attr :pay_status, :in => [
    ['unfinish', 0,   '未支付'],
    ['finish',   1,   '已支付']
  ]

  enum_attr :pay_type, in: PaymentType::ENUM_ID_OPTIONS

  enum_attr :order_type, :in => [
    ['book_dinner', 1, '订餐'],
    ['take_out', 2, '外卖']
  ]

  DAYTIME = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]

  belongs_to :site
  belongs_to :user
  belongs_to :shop
  belongs_to :shop_branch
  belongs_to :shop
  has_many :shop_order_items
  has_many :print_orders

  has_one  :payment, as: :paymentable

  scope :formal, -> { where('status != ?', DRAFT) }
  scope :print, -> { where('is_print = ?', true) }
  scope :print_finish, -> { where('print_finish = ?', true ) }
  scope :need_print, -> { where('is_print = ? and print_finish = ?', true, false) }
  scope :need_expires, -> { where("created_at < ? AND status = ?", Time.now - 3.days, PENDING) }

  accepts_nested_attributes_for :shop_order_items, allow_destroy: true, reject_if: proc { |attributes| attributes['qty'] == '0' }

  before_create :add_default_attrs
  before_save :update_user_address
  after_save :update_expired

  def book_rule
    book_dinner? ? shop_branch.book_dinner_rule : shop_branch.take_out_rule
  end

  def ref_order
    ShopTableOrder.where(ref_order_id: self.id).first || ShopTableOrder.where(id: self.ref_order_id).first
  end

  def has_shop_product? shop_product
    shop_order_items.pluck(:shop_product_id).include?(shop_product.id)
  end

  def find_item_qty_by_product shop_product
    shop_order_items.where(:shop_product_id => shop_product.id).sum(:qty)
  end

  def find_item_by_product shop_product
    shop_order_items.where(:shop_product_id => shop_product.id).first
  end

  def print_total_print
    ret = 0
    self.shop_order_items.each do |item|
      if item.try(:shop_product).try(:is_current_price)
      else
        ret += item.total_price
      end
    end
    ret
  end

  def current_price_item
    t = 0
    shop_order_items.each do |item|
      if item.shop_product
        if item.shop_product.is_current_price
          t = t + 1
        end
      end
    end
    t
  end

  def current_price_number
    t = 0
    shop_order_items.each do |item|
      if item.shop_product
        if item.shop_product.is_current_price
          t = t + item.qty
        end
      end
    end
    t
  end

  def add_item shop_product
    result = true
    if self.has_shop_product? shop_product
      item = self.shop_order_items.where(shop_product_id: shop_product.id).first
      if (shop_product.quantity.present? && item.qty + 1 <= shop_product.quantity) || shop_product.quantity.blank?
        item.update_column("qty", item.qty + 1)
        item.save!
      else
        result = false
      end
    else
      item = self.shop_order_items.new shop_product_id: shop_product.id
      if (shop_product.quantity.present? && item.qty + 1 <= shop_product.quantity) || shop_product.quantity.blank?
        item.save!
      else
        result = false
      end
    end
    [item, result]
  end

  def remove_item shop_product
    if self.has_shop_product? shop_product
      item = self.shop_order_items.where(shop_product_id: shop_product.id).first
      if item.qty == 1
        item.destroy
      else
        item.update_column("qty", item.qty - 1)
        item.save!
      end
      return item
    else
      return nil
    end
  end

  def validate_money
    arr = Array.new

    if self.book_dinner? && self.shop_branch.book_dinner_rule.is_limit_money
      arr <<  self.shop_branch.book_dinner_rule.min_money
    end

    if self.take_out? && self.shop_branch.take_out_rule.is_limit_money
      arr << self.shop_branch.take_out_rule.min_money
    end

    if self.ref_order_id #should validate shop table order money
      shop_table_order = ShopTableOrder.find(ref_order_id)
      if shop_table_order.loge_table? || shop_table_order.loge_table_first?
        arr << shop_table_order.shop_branch.book_table_rule.loge_limit_money
      end

      if shop_table_order.hall_table? || shop_table_order.hall_table_first?
        arr << shop_table_order.shop_branch.book_table_rule.hall_limit_money
      end
    end

    return 0 if arr.nil? || arr.length == 0

    begin
      biggest_money = arr.sort[-1].to_f
    rescue
      return 0
    end

    return 0 if self.total_amount.to_f >= biggest_money.to_f

    biggest_money
  end

  def can_cancel?
    if self.book_dinner?
      rule = self.shop_branch.book_dinner_rule

      if rule.cancel_rule == -1
        return true
      elsif rule.cancel_rule == -2
        return false
      elsif rule.cancel_rule == -3
        if Time.now.ago(rule.created_minute.minutes) > self.created_at
          return false
        end
      elsif rule.cancel_rule == -4
        if Time.now.ago(rule.booked_minute.minutes) < self.book_at
          return false
        end
      end
      return true
    end

    if self.take_out?
      rule = self.shop_branch.take_out_rule
      if rule.cancel_rule == -1
        return true
      elsif rule.cancel_rule == -2
        return false
      elsif rule.cancel_rule == -3
        if Time.now.ago(rule.created_minute.minutes) > self.created_at
          return false
        end
      elsif rule.cancel_rule == -4
        if Time.now.ago(rule.booked_minute.minutes) < self.book_at
          return false
        end
      end
      return true
    end
  end

  def right_now
    if shop_order.take_out?
      return true
    elsif shop_order.in_branch? || shop_order.in_queue?
      return true
    end
    return false
  end

  def deleteable?
    pending?
  end

  def complete!
    update_attributes(status: COMPLETED)
  end

  def pay!
    return if finish?

    update_attributes(pay_status: 1)

    send_message

    # to user
    send_wx_message(new_order_temp(user.wx_user.openid))

    # to merchant
    if book_rule.need_wx_message == '1'
      shop_branch.merchant_openid_list.uniq.each do |merchant_openid|
        next if merchant_openid == user.wx_user.openid
        send_wx_message(new_order_temp(merchant_openid))
      end
    end

    shop_qrcode_amount
    update_product_qty

    # #自动打印
    # template = self.shop_branch.get_templates self
    # if template.print_type == 1 && template.is_auto_print
    #   self.to_print
    # end

    if printer.is_open?
      template = self.shop_branch.get_templates self
      print_receipt if template && template.is_open? && template.is_auto_print?
    end
  end

  def unpay!
    update_attributes(pay_status: 0)
  end

  def cancel! from = :wx_user
    update_attributes(status: CANCELED)
    send_wx_cancel_message(from) if site.wx_mp_user.cancel_order_wx_message_template_id.present?
  end

  def send_wx_cancel_message(from)
    # to user
    send_wx_message(cancel_order_temp(user.wx_user.openid))

    # to merchant
    if from == :wx_user
      shop_branch.merchant_openid_list.uniq.each do |merchant_openid|
        next if merchant_openid == user.wx_user.openid
        send_wx_message(cancel_order_temp(merchant_openid))
      end
    end
  end

  def total_qty
    shop_order_items.sum(:qty)
  end

  def shop_branch_name
    shop_branch.name
  end

  def print_template
    if book_dinner?
      shop_branch.book_dinner_template
    elsif take_out?
      shop_branch.take_out_template
    end
  end

  def to_print(responsecode = nil, orderindex = nil)
    case responsecode.to_i
    when 0
      status_code = PrintOrder::SUCCESS
    when 1
      status_code = PrintOrder::TOUCHED
    else
      status_code = PrintOrder::UNPRINT
    end

    print_orders.create(
      printer_id: printer.printer_id,
      shop_order_id: self.id,
      site_id: self.site_id,
      shop_branch_id: self.shop_branch.id,
      shop_branch_print_template_id: printer.id,
      order_index: orderindex,
      status: status_code
    )
  end

  def payment_request_params(params = {})
    params = HashWithIndifferentAccess.new(params)
    _order_params = {
      payment_type_id: pay_type,
      account_id: site.account_id,
      site_id: site_id,
      customer_id: user_id,
      customer_type: 'User',
      paymentable_id: id,
      paymentable_type: 'ShopOrder',
      out_trade_no: order_no,
      amount: total_amount,
      body: "订单 #{order_no}",
      subject: "订单 #{order_no}",
      source: 'shop_order',
      open_id: user.wx_user.try(:openid)
    }
    params.reverse_merge(_order_params)
  end

  def self.test_line shop_orders
    @chart = LazyHighCharts::HighChart.new('basic_line') do |f|
      f.chart({ type: 'line',
                marginRight: 130,
                marginBottom: 25 })
      f.title({ text: "下单时间分析图"})
      f.xAxis({
                categories:DAYTIME#.map{|t| t.to_s + " : 00"}
              })
      f.yAxis({
                title:{text: "下单数量"},
                plotLines: [{
                                value: 0,
                                width: 1,
                                color: '#808080'
                            }]
              })
      f.tooltip({
                  # valueSuffix: "份"
                })
      f.legend({
                   layout: 'vertical',
                   align: 'right',
                   verticalAlign: 'top',
                   x: -5,
                   y: 100,
                   borderWidth: 0
               })
      f.series({
                  name: "下单数量",
                  data:  select_day_time(shop_orders) #shop_orders.collect{|s| s.total_count }.flatten
               })

    end
  end

  def self.select_day_time shop_orders
    time_counts = shop_orders.collect{|s| [s.hour, s.total_count]}
    datas = []
    DAYTIME.each do |t|
      flag = true
      time_counts.each do |tc|

         if tc[0].to_i == t
           flag = false
           datas << tc[1]
           break
         end

      end

      unless t == 24
        datas << 0 if flag
      end
    end
    return datas
  end

  def title
    if self.description.blank?
      ""
    else
      ar = self.description.scan(/.{1,10}/)
      ar.join("&#10;").html_safe
    end

  end

  def clone_order
    new_order = self.dup
    new_order.status = 0
    new_order.pay_status = 0
    new_order.save!

    self.shop_order_items.each do |item|
      next unless item.shop_product
      new_item = item.dup
      new_item.shop_order_id = new_order.id
      new_item.save!
    end

    new_order.total_amount = new_order.shop_order_items.sum(:total_price)
    new_order.pay_amount = new_order.shop_order_items.sum(:total_pay_price)
    new_order.save

    return new_order
  end

  def shop_qrcode_amount
    column_name = book_dinner? ? "restaurant_amount" : "take_out_amount"
    user.qrcode_user_amount(column_name,total_amount)
  end

  def update_product_qty
    shop_order_items.each do |item|
      product = item.shop_product
      next unless product
      product.update_column('quantity', product.quantity - item.qty) if product.quantity
    end
  end

  def send_message
    return if shop_branch.mobile.blank?

    notify_name = book_dinner? ? '订餐通知' : '订单通知'
    order_items = shop_order_items.collect{|item| "#{item.product_name}×#{item.qty} ￥#{item.total_price}" }.join('，')
    remark = "门店：#{shop_branch.name}，总价：#{total_amount}元。菜品：#{order_items}，收货信息：#{username}（#{mobile}），#{address}, 订单备注：#{description}"
    sms_options = { mobiles: shop_branch.mobile, template_code: 'SMS_9060020', params: { notify_name: notify_name, remark: remark } }

    options = { operation_id: 3, site_id: site.id, userable_id: user_id, userable_type: 'User' }

    site.send_message(sms_options, options)
  end

  # notify someone when order cancelled by anotherone.
  def send_cancel_message cancel_user
    if cancel_user.is_a?(User) || cancel_user.is_a?(WxUser)
      receiver_mobile = shop_branch.mobile
    elsif cancel_user.is_a?(ShopBranch)
      receiver_mobile = user.mobile
    else
      receiver_mobile = nil
    end

    return if receiver_mobile.blank?

    sms_params = {
      username: username,
      phone: mobile,
      time: Time.now.to_s,
      order_item: shop_order_items.collect{|item| "#{item.product_name}×#{item.qty} ￥#{item.total_price}" }.first.concat("等信息")
    }
    sms_options = { mobiles: receiver_mobile, template_code: 'SMS_8916404', params: sms_params }

    options = { operation_id: 3, site_id: site.id, userable_id: cancel_user.id, userable_type: cancel_user.class.to_s }

    site.send_message(sms_options, options)
  end

  # options = send_wx_message(active_order_temp(user.openid))
  def send_wx_message(options)
    send_wx_message_temp(options: options, access_token: site.wx_mp_user.wx_access_token)
  end

  def user_info
    "#{username} #{mobile}"
  end

  def order_detail
    items_info = shop_order_items.collect{|item| "#{item.product_name}x#{item.qty}份" }.join(',')
    "订单明细：#{items_info}\n收货地址：#{address}\n订单备注：#{description}"
  end

  def shop_branch_name
    shop_branch.try(:name)
  end

  private

  def add_default_attrs
    now = Time.now

    self.order_no = Concerns::OrderNoGenerator.generate
    self.expired_at = now + 2.days
    self.serial_no = ShopOrder.where(shop_branch_id: shop_branch_id).where('DATE(created_at) = ?', Date.today).count + 1

    return unless self.shop_branch

    self.site_id = self.shop_branch.site_id
    self.shop_id = self.shop_branch.shop_id

    self.deliver_amount = self.book_rule.deliver_amount_f if self.take_out?
  end

  def update_expired
    self.expired_at = self.book_at + 1.days if self.book_at

    self.update_column("pay_amount", self.total_amount) if self.status == 2
  end

  def update_user_address
    if self.user
      self.user.name = self.username unless self.user.name
      self.user.mobile = self.mobile unless self.user.mobile
      self.user.address = self.address if self.address
    # else
      # self.build_user(address: self.address, mobile: self.mobile, name: self.username)
    end
    self.user.save if self.user
  end

end
