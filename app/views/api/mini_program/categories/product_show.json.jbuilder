json.product do
  json.id @product.id
  json.name @product.name
  json.description @product.description
  json.pic @product.ec_picture.pic_url
end
