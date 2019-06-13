class EcPrice < ActiveRecord::Base
  validates :ec_category_id,:min_price,:max_price, presence: true
  belongs_to :ec_category
end
