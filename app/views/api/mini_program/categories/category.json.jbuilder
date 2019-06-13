json.categories @categories do |category|
  json.id category.id
  json.name category.name
  json.summary category.summary
  json.parent_id category.parent_id
  json.category_type category.category_type
  json.icon category.icon_url
  json.pic category.pic_url
end
