class SiteArticle < ActiveRecord::Base
  validates :site_category_id, :name, presence: true

  belongs_to :site
  belongs_to :site_category

  has_many :site_pictures

  has_many :site_article_tags, dependent: :destroy
  has_many :site_tags, through: :site_article_tags

  enum_attr :status, in: [
    ['draft', 0, '待发布'],
    ['onshelf', 1, '已发布'],
    ['offshelf', -1, '已下线'],
    ['deleted', -2, '已删除']
  ]

  enum_attr :article_type, in: [
    ['news', 1, '资讯'],
    ['case', 2, '展示']
  ]

  enum_attr :is_recommend, in: [
    ['recommend', true, '是'],
    ['not_recommend', false, '否']
  ]

  # default_scope -> { order('site_articles.article_type ,site_articles.position desc') }
  scope :show, -> {where(["site_articles.status > ?", -2 ])}

  accepts_nested_attributes_for :site_pictures, allow_destroy: true
  validates_associated :site_pictures

  before_create do
    self.article_type = site_category.category_type
    # set_position
  end

  def set_position
    self.position = self.site.site_articles.news.count + 1 if self.news?
    self.position = self.site.site_articles.case.count + 1 if self.case?
  end

  def self.onshelf_all(site_article_ids)
    return false if site_article_ids.blank?
    where(id: site_article_ids).update_all(status: ONSHELF)
  end

  def self.offshelf_all(site_article_ids)
    return false if site_article_ids.blank?
    where(id: site_article_ids).update_all(status: OFFSHELF)
  end

  def self.deleted_all(site_article_ids)
    return false if site_article_ids.blank?
    where(id: site_article_ids).update_all(status: DELETED)
  end

  def onshelf!
    update_attributes(status: ONSHELF)
  end

  def offshelf!
    update_attributes(status: OFFSHELF)
  end

  def deleted!
    update_attributes(status: SiteArticle::DELETED)
  end

end
