class EcLogisticTemplate < ActiveRecord::Base
  acts_as_taggable_on :ship_methods

  belongs_to :account
  has_many :ec_logistic_template_items, dependent: :destroy
  has_many :ec_items, dependent: :nullify

  accepts_nested_attributes_for :ec_logistic_template_items, allow_destroy: true

  validates :name, presence: true

  enum_attr :valuation_method, in: [
    ['weight', 0, '按重量'],
    ['money', 1, '按商品总额']#,
    # ['volume', 2, '按体积']
  ]

  ValuationMethodHuman = {
      weight: '按重量',
      money: '按商品总额'
  }

  def self.valuation_methods
    [['weight', 0], ['money', 1]]
  end

  def self.valuation_method_display(valuation_method)
    case valuation_method
    when 0
      'weight'
    when 1
      'money'
    else
      nil
    end
  end

end
