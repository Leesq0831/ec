class Permission < ActiveRecord::Base

  has_many :role_permission_maps
end
