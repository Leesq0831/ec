json.categories @categories do |c|
  next if c.ec_products.onshelf.recommend.count == 0
  json.name      c.name
  json.pic       c.pic_url
  json.id        c.id
  json.summary   c.summary
  json.products c.ec_products.onshelf.recommend.order(:position).limit(4) do |product|
  	ec_items = product.ec_items.onshelf
  	next if ec_items.count == 0
	  ec_item = product.ec_item
	  next unless ec_item
	  json.id ec_item.id
	  json.name product.name
	  json.price ec_item.price
	  json.pic product.ec_picture.try(:pic_url)
	  json.ec_price [product.ec_items.onshelf.minimum(:price), product.ec_items.onshelf.maximum(:price)].uniq.join(' ~ ')
  end
end