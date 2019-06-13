class EmployeeRoleMap < ActiveRecord::Base
  belongs_to :employee
  belongs_to :employee_role
end
