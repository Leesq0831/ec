class EcDiningTime < ActiveRecord::Base
  # attr_accessible :ec_shop_id, :end_at, :start_at
  validates :end_at, :start_at, :position, presence: true

  def self.first_of_today
    where('start_at > ?', Time.now).order('start_at asc').first || order('start_at asc').first
  end

  def self.first_dining_date
    if where('start_at > ?', Time.now).order('start_at asc').first.present?
      Date.today
    else
      Date.today.tomorrow
    end
  end
end
