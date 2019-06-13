class EcParameter < ActiveRecord::Base
  attr_accessible :key, :value

  belongs_to :ec_product
end
