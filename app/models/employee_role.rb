class EmployeeRole < ActiveRecord::Base
  validates :name, :presence => true

  belongs_to :account
  has_many :employee_role_maps
  has_many :role_permission_maps
  has_many :permissions, through: :role_permission_maps
end
