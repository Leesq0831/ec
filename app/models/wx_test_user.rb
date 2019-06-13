class WxTestUser < ActiveRecord::Base
  validates :wx_id, presence: true

  belongs_to :site
end
