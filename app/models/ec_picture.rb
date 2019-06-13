class EcPicture < ActiveRecord::Base
  # validates :pictureable_id, :pictureable_type, :pic_key, presence: true

  belongs_to :pictureable, polymorphic: true

  def pic_url
    qiniu_image_url(pic_key)
  end

  def format_pic_url **options
    return '' unless pic_url
    options.merge!(height: 210) unless options[:height]
    options.merge!(width: 210) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{pic_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end

  def format_shop_banner_pic_url **options
    return '' unless pic_url
    options.merge!(height: 335) unless options[:height]
    options.merge!(width: 216) unless options[:height]
    size = "#{options[:height]}x#{options[:width]}"
    "#{pic_url}?imageMogr2/auto-orient/thumbnail/!#{size}"
  end


end