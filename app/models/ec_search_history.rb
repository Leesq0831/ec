class EcSearchHistory < ActiveRecord::Base
  validates :user_id, :keyword, presence: true
end
