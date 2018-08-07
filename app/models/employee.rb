  class Employee < ActiveRecord::Base
  has_secure_password
  attr_accessor :current_password
  validates :name, :account_id, :presence => true
  # validates :mobile, uniqueness: true
  validates :name, uniqueness: { scope: [:account_id], case_sensitive: false }
  validates_length_of :password, :in => 6..20, :on => :create

  belongs_to :account
  has_many :employee_role_maps
  has_many :employee_roles, through: :employee_role_maps

  acts_as_enum :gender, :in => [
    ['secret', 0 , '未知'],
    ['male', 1 , '男'],
    ['female', 2 , '女']
  ]

  enum_attr :status, in: [
    ['normal', 1, '正常'],
    ['frost', -1, '冻结']
  ]

  acts_as_enum :user_type, :in => [
    ['manager', 1 , '管理员'],
    ['member', 2 , '职员']
  ]

  def self.authenticated(login, password)
    where("lower(login) = ?", login.to_s.downcase).first.try(:authenticate, password)
  end

  def has_privilege_for?(id_or_ids)
    # return true
    ids = []
    employee_roles.each{|role| ids << role.permission_ids }
    (ids.flatten.uniq & [id_or_ids].flatten.uniq).count > 0
  end

  def roles
    ids = []
    employee_roles.each{|role| ids << role.permissions.pluck(:key) }
    ids.flatten.uniq
  end

  def username
    manager? ? name : [name, account_id].join('@')
  end

  #
  # def find_or_generate_auth_token(encrypt = true)
  #   # update_attributes(token: SecureRandom.urlsafe_base64(60)) unless token.present?
  #   # encrypt ? Des.encrypt(self.token) : self.token
  #   return true
  # end
end
