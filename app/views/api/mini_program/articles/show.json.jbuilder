json.article do
  json.id @article.id
  json.name @article.name
  json.summary @article.summary
  json.content @article.content
  json.created_at @article.created_at.to_s

  json.pictures @article.try(:site_pictures).each do |pic|
    json.pic pic.pic_url
  end
  json.tags @article.try(:site_tags).each do |tag|
    json.name tag.name
  end
end
