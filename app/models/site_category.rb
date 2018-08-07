class SiteCategory < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :site

  has_many :site_articles

  enum_attr :is_recommend, in: [
    ['recommend', true, '是'],
    ['not_recommend', false, '否']
  ]

  enum_attr :category_type, in: [
    ['news', 1, '资讯'],
    ['case', 2, '展示']
  ]

  enum_attr :status, in: [
    ['onshelf', 1, '上架'],
    ['offshelf', -1, '下架']
  ]

  # default_scope -> { order('site_categories.category_type,site_categories.position desc') }

  # before_create do
  #   set_position
  # end

  def set_position
    self.position = self.site.site_categories.news.count + 1 if self.news?
    self.position = self.site.site_categories.case.count + 1 if self.case?
  end

  def pic_url
    qiniu_image_url(pic_key)
  end

  def icon_url
    qiniu_image_url(icon_key)
  end

  def format_icon_url **options
    return '' unless icon_url
    options.merge!(height: 160) unless options[:height]
    options.merge!(width: 140) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{icon_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

  def format_pic_url **options
    return '' unless pic_url
    options.merge!(height: 264) unless options[:height]
    options.merge!(width: 264) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{pic_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

end
