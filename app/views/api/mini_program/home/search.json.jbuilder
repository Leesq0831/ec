json.products @products do |product|
  ec_items = product.ec_items.onshelf
  ec_item = product.ec_item
  next unless ec_item
  next if ec_items.count == 0
  json.id ec_item.id
  json.name product.name
  json.price ec_item.price
  json.pic product.ec_picture.try(:pic_url)
  json.ec_price [product.ec_items.onshelf.minimum(:price), product.ec_items.onshelf.maximum(:price)].uniq.join(' ~ ')
  json.product_id product.id
end