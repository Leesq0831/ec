json.categories @categories do |c|
  next if c.site_articles.onshelf.recommend.count == 0
  json.id c.id
  json.name c.name
  json.summary c.summary
  json.icon c.icon_url
  json.pic c.pic_url
  json.articles c.site_articles.onshelf.recommend.order(:position).limit(4) do |article|
    json.id article.id
    json.name article.name
    json.summary article.summary
    json.created_at article.created_at.to_s
    json.pic article.try(:site_pictures).try(:first).try(:pic_url)
  end
end
