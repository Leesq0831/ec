class EcProduct < ActiveRecord::Base
  validates :ec_category_id, :name, presence: true

  belongs_to :account
  belongs_to :ec_category
  belongs_to :province
  belongs_to :city
  # has_one :ec_item, -> { where(product_type: EcItem::PRODUCT) }
  has_one :ec_picture, as: :pictureable
  has_many :ec_items, dependent: :destroy
  has_many :ec_product_tags, dependent: :destroy
  has_many :ec_tags, through: :ec_product_tags
  has_many :ec_pictures, as: :pictureable
  has_many :ec_shop_products, dependent: :destroy
  has_many :ec_shops, :through => :ec_shop_products

  has_many :ec_parameters

  enum_attr :status, in: [
    ['draft', 0, '待上架'],
    ['onshelf', 1, '已上架'],
    ['offshelf', -1, '已下架'],
    ['deleted', -2, '已删除']
  ]

  enum_attr :is_recommend, in: [
    ['recommend', true, '是'],
    ['not_recommend', false, '否']
  ]

  # default_scope where(["ec_products.status > ?", -2 ])
  scope :show, -> {where(["ec_products.status > ?", -2 ])}

  accepts_nested_attributes_for :ec_items, allow_destroy: true
  validates_associated :ec_items

  accepts_nested_attributes_for :ec_pictures, allow_destroy: true
  validates_associated :ec_pictures

  accepts_nested_attributes_for :ec_parameters, allow_destroy: true
  validates_associated :ec_parameters

  def ec_item
    ec_items.show.where(product_type: EcItem::PRODUCT).first
  end

  def self.onshelf_all(ec_product_ids)
    return false if ec_product_ids.blank?

    where(id: ec_product_ids).update_all(status: ONSHELF)
    EcItem.where(ec_product_id: ec_product_ids).update_all(status: EcItem::ONSHELF)
  end

  def self.offshelf_all(ec_product_ids)
    return false if ec_product_ids.blank?

    where(id: ec_product_ids).update_all(status: OFFSHELF)
    EcItem.where(ec_product_id: ec_product_ids).update_all(status: EcItem::OFFSHELF)
  end

  def self.deleted_all(ec_product_ids)
    return false if ec_product_ids.blank?

    where(id: ec_product_ids).update_all(status: DELETED)
    EcItem.where(ec_product_id: ec_product_ids).update_all(status: EcItem::DELETED)
  end

  def onshelf!
    update_attributes(status: ONSHELF)
    ec_items.update_all(status: EcItem::ONSHELF)
  end

  def offshelf!
    update_attributes(status: OFFSHELF)
    ec_items.update_all(status: EcItem::OFFSHELF)
  end

  def deleted!
    update_attributes(status: EcProduct::DELETED)
    ec_items.update_all(status: EcItem::DELETED)
  end

end
