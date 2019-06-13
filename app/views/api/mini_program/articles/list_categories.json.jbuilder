json.categories @categories do |c|
  json.id c.id
  json.name c.name
  json.summary c.summary
  json.icon c.icon_url
  json.pic c.pic_url
end
