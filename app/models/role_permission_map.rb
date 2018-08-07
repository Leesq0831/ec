class RolePermissionMap < ActiveRecord::Base
  belongs_to :employee_role
  belongs_to :permission
end
