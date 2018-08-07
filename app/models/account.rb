class Account < ActiveRecord::Base
  has_secure_password

  store :metadata, accessors: [:auth_mobile, :permission_list, :template, :mp_code, :lng, :lat, :cashpay]

  attr_accessor :current_password

  validates :nickname, presence: true, uniqueness: { case_sensitive: false }, length: { within: 2..20, too_short: '太短了，最少3位', too_long: "太长了，最多20位" }
  validates :email, email: true, presence: true#, uniqueness: { case_sensitive: false }
  validates :mobile, presence: true#, format: { with: /^\d{11}$/, message: '手机格式不正确' }
  validates :password, presence: { message: '不能为空', on: :create }, length: { within: 6..20, too_short: '太短了，最少6位', too_long: "太长了，最多20位" }, allow_blank: true
  # validates_confirmation_of :password, message: '确认不一致'

  enum_attr :account_type, :in => [
    ['normal_account', 1, '正式帐号'],
    ['trial_account',  2, '试用帐号'],
    ['free_account',  3, '免费帐号'],
  ]

  enum_attr :status, :in => [
    ['pending', 0, '待审核'],
    ['active',  1, '正常'],
    ['froze',  -1, '已冻结']
  ]

  enum_attr :ec_template_id, :in => [
    ['ec_template1', 1, '模板一'],
    ['ec_template2', 2, '模板二'],
  ]

  TEMPLATE = { "电商版本" => 1, "展示版本" => 2 }

  belongs_to :agent
  belongs_to :account_product
  belongs_to :account_category
  has_one :print
  has_one :pay_account
  has_many :payments

  has_many :employees
  has_many :employee_roles

  has_many :ec_categories
  has_many :ec_items
  has_many :ec_logistic_templates
  has_many :ec_orders
  has_many :ec_order_items
  has_many :ec_order_rules
  has_many :ec_products
  has_many :ec_slides
  has_many :ec_stocks
  has_many :ec_stock_items
  has_many :ec_tags

  #after_create :init_data

  before_save do
    if self.changed.include?("address")
      url = "http://api.map.baidu.com/geocoder/v2/?address=#{self.address}&output=json&ak=#{Settings.baidu_ak}"
      res = JSON(RestClient.get(URI.encode(url.strip)))
      if res["status"] == 0
        self.lng = res["result"]["location"]["lng"].to_s
        self.lat = res["result"]["location"]["lat"].to_s
      end
    end
  end

  def self.current
    Thread.current[:account]
  end

  def self.current=(account)
    Thread.current[:account] = account
  end

  def self.authenticated(nickname, password)
    where("lower(nickname) = ?", nickname.to_s.downcase).first.try(:authenticate, password)
  end

  def update_sign_in_attrs_with(sign_in_ip)
    update_attributes(
      sign_in_count: sign_in_count.next,
      last_sign_in_at: current_sign_in_at,
      last_sign_in_ip: current_sign_in_ip,
      current_sign_in_at: Time.now,
      current_sign_in_ip: sign_in_ip
    )
  end

  def expired?
    expired_at.nil? || expired_at < Time.now
  end

  def need_auth_mobile?
    auth_mobile.to_i != 1
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    AccountMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Account.exists?(column => self[column])
  end

  def permission_ids
    (self.permission_list || "").split(',')
  end

  def permissions
    Permission.where(id: permission_ids)
  end

  private

  def init_data

    role = EmployeeRole.where(account_id: id, name: "系统管理员").first_or_create

    employee = Employee.new(account_id: id, name: nickname, password_digest: password_digest, user_type: 1, login: "admin")
    employee.save(validate: false)

    EmployeeRoleMap.where(
      employee_id: employee.id,
      employee_role_id: role.id
    ).first_or_create

    Permission.find_each do |permission|
      RolePermissionMap.where(
        employee_role_id: role.id,
        permission_id: permission.id
      ).first_or_create
    end
  end

end
