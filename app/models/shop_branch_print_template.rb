class ShopBranchPrintTemplate < ActiveRecord::Base
  enum_attr :template_type, :in => [
    ['book_dinner',  1, '订餐小票'],
    ['take_out',     2, '外卖小票'],
    ['book_table',   3, '订座小票'],
    ['ec_order',     4, '电商小票']
  ]

  enum_attr :print_type, :in => [
    ['gprs', 1, 'gprs'],
    ['pc', 2, '直连']
  ]

  belongs_to :shop_branch
  has_many :thermal_printers

  accepts_nested_attributes_for :thermal_printers, reject_if: proc { |attributes| attributes['no'].blank? }, allow_destroy: true

  def name
    template_type_name
  end

  def set?
    printer_id.present? && printer_key.present? && print_times.present?
  end
end