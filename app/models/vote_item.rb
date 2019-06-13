class VoteItem < ActiveRecord::Base
  # establish_connection "shequ_#{Rails.env}"

  belongs_to :activity
  has_many :pictures, class_name: "VoteItemPicture"

  def default_pic_url
    qiniu_image_url(pictures.first.try(:pic_key))
  end
end