class SiteTag < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :site
  belongs_to :site_article

  has_many :site_article_tags, dependent: :destroy
  has_many :site_articles, through: :site_article_tags

  # default_scope -> { order('site_tags.id desc') }
end
