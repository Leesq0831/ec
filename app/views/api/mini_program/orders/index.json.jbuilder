json.orders @orders do |order|
  order.check_order_expire! if order.pending?

  json.id order.id
  json.order_no order.order_no
  json.total_amount order.ec_order_items.sum(:qty)
  json.pay_price order.pay_amount
  json.pay_type_name order.pay_type_name
  json.pay_status_name order.pay_status_name
  json.status_name order.status_name
  json.description order.description
  json.logistic_no order.logistic_no

  json.order_items order.try(:ec_order_items) do |order_item|
    json.id order_item.id
    json.amount order_item.qty
    json.price order_item.try(:ec_item).try(:price)
    json.name order_item.try(:ec_item).try(:ec_product).try(:name)
    json.item_name order_item.try(:ec_item).try(:name)
    json.pic order_item.try(:ec_item).try(:ec_product).try(:ec_picture).try(:pic_url)
  end
end
