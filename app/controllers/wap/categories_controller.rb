class Wap::CategoriesController < Wap::BaseController

  def index
    @categories = EcCategory.product_category.order("ec_categories.position asc")
  end

end
