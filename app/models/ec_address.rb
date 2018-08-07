class EcAddress < ActiveRecord::Base
  validates :user_id, :province_id, :city_id, :district_id, :address, :username, :mobile, presence: true
  #before_save :fix_default
  belongs_to :user

  belongs_to :province
  belongs_to :city
  belongs_to :district

  has_many :ec_orders

  def fix_default
    EcAddress.update_all(is_default: false)
  end

  def address_display
    [province.try(:name), city.try(:name), district.try(:name), address].compact.uniq.join
  end
end
