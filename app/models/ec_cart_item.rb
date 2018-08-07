class EcCartItem < ActiveRecord::Base
  validates :user_id, :ec_item_id, :qty, :original_price, presence: true
  validates :qty, numericality: { only_integer: true, greater_than: 0 }
  validates :original_price, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user
  belongs_to :ec_item

  def increase!
    update_attributes(qty: self.qty + 1)
  end

  def decrease!
    return false if ec_item.qty < 1
    update_attributes(qty: self.qty - 1)
  end

  def self.move_to_fav
    where(true).each do |cart_item|
      transaction do
        cart_item.user.ec_favorites.where(ec_item_id: cart_item.ec_item_id).first_or_create
        # cart_item.destroy
      end
    end
  end

end