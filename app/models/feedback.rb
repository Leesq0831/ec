class Feedback < ActiveRecord::Base
  validates :feedback_type, :content, presence: true

   belongs_to :user, polymorphic: true
   belongs_to :admin_user
  #belongs_to :user_type, polymorphic: true

  before_create do
    self.site_id = user.try(:site_id)
  end

  enum_attr :feedback_type, :in=> [
    ['product', 1, '产品建议'],
    ['error_feedback', 2, '错误反馈'],
    ['complain', 3, '投诉'],
  ]
  enum_attr :status, :in=> [
    ['unreply', 1, '未回复'],
    ['replied', 2, '已回复'],
  ]
end
