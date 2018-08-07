class ShopProductComment < ActiveRecord::Base
  belongs_to :shop_product
  belongs_to :user

  validates :content, presence: true

  def commenter_display
    phone = user.try(:mobile)
    return nil if phone.blank? || phone.length < 11

    phone[3..6] = '****'
    phone
  end
end
