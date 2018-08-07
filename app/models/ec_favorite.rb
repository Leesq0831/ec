class EcFavorite < ActiveRecord::Base
  validates :user_id, :ec_item_id, presence: true

  belongs_to :user
  belongs_to :ec_item
end