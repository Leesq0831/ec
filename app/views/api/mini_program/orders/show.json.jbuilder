json.order do
  json.id          @order.id
  json.order_no    @order.order_no
  json.name        @order.username
  json.mobile      @order.mobile
  json.detail_address  "#{@order.address_display}" + "#{@order.address}"
  json.freight     @order.freight_value
  json.pay_amount  @order.pay_amount
  json.total       @order.total_amount
  json.paid_at     @order.paid_at
  json.created_at  @order.created_at.to_s
  json.status_name      @order.status_name
  json.des @order.description
  json.logistic_no @order.logistic_no
  json.pay_type   @order.pay_type

  json.order_items @order.try(:ec_order_items) do |order_item|
    json.id order_item.id
    json.amount order_item.qty
    json.pro_id order_item.try(:ec_item).try(:id)
    json.price order_item.try(:ec_item).try(:price)
    json.name order_item.try(:ec_item).try(:ec_product).try(:name)
    json.item_name order_item.try(:ec_item).try(:name)
    json.pic order_item.try(:ec_item).try(:ec_product).try(:ec_picture).try(:pic_url)
  end

end

ec_order_rule = @order.order_rule
json.rule          ec_order_rule.is_auto_expire
json.expires_at    (ec_order_rule.expires_in.to_f * 3600).to_i - (Time.now.to_i - @order.created_at.to_i)
json.pending       @order.pending?
