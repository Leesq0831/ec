class EcCommentTemplate < ActiveRecord::Base
  validates :content, presence: true
  default_scope -> { where("status != ?", EcCommentTemplate::DELETED) }

  enum_attr :status, :in =>[
    ['normal',1,'正常'],
    ['deleted',-2,'删除']
  ]

  def deleted!
    update_attributes(status: EcCommentTemplate::DELETED)
  end
end
