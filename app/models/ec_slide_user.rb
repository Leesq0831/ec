class EcSlideUser < ActiveRecord::Base
  belongs_to :ec_slide
  belongs_to :user

end
