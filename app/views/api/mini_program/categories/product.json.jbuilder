json.product do
  json.name        @ec_product.name
  json.description @ec_product.description.html_safe
  json.pic 		   @ec_product.ec_picture.pic_url
  json.qty 		   @ec_product.ec_items.onshelf.sum(:qty)
  json.sold_qty    @ec_product.ec_items.onshelf.sum(:sold_qty)
  json.price       [@ec_product.ec_items.onshelf.minimum(:price), @ec_product.ec_items.onshelf.maximum(:price)].uniq.join(' ~ ')
end

json.ec_items @ec_product.ec_items.onshelf do |item|
  json.id       item.id
  json.name     item.name
  json.price    item.price
  json.selected false
end

json.pics @ec_product.ec_pictures do |pic|
  json.pic  pic.pic_url
end

json.tags @ec_product.ec_tags.product_tag.pluck(:name)

json.cartnum @cart_count
