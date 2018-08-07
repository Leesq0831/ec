json.articles @articles do |article|
  json.id article.id
  json.name article.name
  json.summary article.summary
  json.created_at article.created_at.to_s
  json.pic article.try(:site_pictures).try(:first).try(:pic_url)
end
