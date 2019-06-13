json.cart_items @cart_items do |cart_item|
  json.pro_id cart_item.try(:ec_item).try(:id)
  json.id cart_item.id
  json.name cart_item.try(:ec_item).try(:ec_product).try(:name)
  json.price cart_item.original_price
  json.item_name cart_item.try(:ec_item).try(:name)
  json.pic cart_item.try(:ec_item).try(:ec_product).try(:ec_picture).try(:pic_url)
  json.qty cart_item.qty
  json.select false
end
