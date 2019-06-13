class SiteArticleTag < ActiveRecord::Base
  validates :site_tag_id, :site_article_id, presence: true

  belongs_to :site_tag
  belongs_to :site_article
end
