class EcUserActivity < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :ec_activity

  after_create :set_gift_item

  private

    def set_gift_item
      user.ec_cart_items.create(ec_item_id: ec_activity.ec_item_id.to_i, qty: 1)# if ec_activity.ec_item.present?
    end

end
